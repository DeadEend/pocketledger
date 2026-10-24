import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/expense.dart';
import '../models/expense_category.dart';
import '../providers/data_provider.dart';
import '../utils/app_exception.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/validators.dart';
import '../widgets/app_bar.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/expense_actions.dart';
import '../widgets/inline_error.dart';
import '../widgets/primary_button.dart';
import '../widgets/selectable_chip.dart';

/// Add a new expense, or edit [expense] when one is given.
class ExpenseFormScreen extends StatefulWidget {
  const ExpenseFormScreen({super.key, this.expense});

  final Expense? expense;

  static Future<void> open(BuildContext context, {Expense? expense}) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ExpenseFormScreen(expense: expense),
      ),
    );
  }

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late ExpenseCategory _category;
  late DateTime _date;
  bool _busy = false;
  String? _error;

  bool get _isEditing => widget.expense != null;

  @override
  void initState() {
    super.initState();
    final expense = widget.expense;
    final today = DateTime.now();
    _titleController = TextEditingController(text: expense?.title ?? '');
    _amountController = TextEditingController(
      text: expense == null ? '' : formatAmountInput(expense.amount),
    );
    _noteController = TextEditingController(text: expense?.note ?? '');
    _category = expense?.category ?? ExpenseCategory.food;
    _date = expense?.date ?? DateTime(today.year, today.month, today.day);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final lastDate = DateTime(now.year, now.month, now.day);
    final initialDate = _date.isAfter(lastDate) ? lastDate : _date;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: lastDate,
    );
    if (picked != null && mounted) {
      setState(() => _date = picked);
    }
  }

  Future<void> _save() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    final parsedAmount = parseAmount(_amountController.text);
    if (parsedAmount == null) return;

    FocusScope.of(context).unfocus();
    final data = context.read<DataProvider>();
    final existing = widget.expense;
    setState(() {
      _busy = true;
      _error = null;
    });

    String? error;
    bool synced = true;
    try {
      if (existing == null) {
        synced = await data.addExpense(
          Expense(
            id: '',
            title: _titleController.text.trim(),
            amount: roundMoney(parsedAmount),
            category: _category,
            date: _date,
            note: _noteController.text.trim(),
            createdAt: DateTime.now(),
          ),
        );
      } else {
        synced = await data.updateExpense(
          existing.copyWith(
            title: _titleController.text.trim(),
            amount: roundMoney(parsedAmount),
            category: _category,
            date: _date,
            note: _noteController.text.trim(),
          ),
        );
      }
    } on AppException catch (e) {
      error = e.message;
    } catch (_) {
      error = genericErrorMessage;
    }

    if (!mounted) return;
    if (error != null) {
      setState(() {
        _busy = false;
        _error = error;
      });
      return;
    }

    showAppSnackBar(
      context,
      synced
          ? (existing == null ? 'Expense added' : 'Expense updated')
          : queuedMessage,
    );
    Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    final expense = widget.expense;
    if (expense == null) return;
    final deleted = await confirmAndDeleteExpense(context, expense);
    if (!mounted) return;
    if (deleted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: buildAppBar(
        context,
        _isEditing ? 'Edit expense' : 'Add expense',
        actions: [
          if (_isEditing)
            IconButton(
              tooltip: 'Delete expense',
              icon: const Icon(Icons.delete_outline),
              onPressed: _busy ? null : _delete,
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [LengthLimitingTextInputFormatter(60)],
                  validator: validateTitle,
                  decoration: appInputDecoration(label: 'Title'),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                  ],
                  validator: validateAmount,
                  decoration: appInputDecoration(
                    label: 'Amount',
                    prefixText: '₹ ',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Category', style: textTheme.titleSmall),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    for (final category in ExpenseCategory.values)
                      SelectableChip(
                        label: category.label,
                        selected: _category == category,
                        color: category.color,
                        onSelected: () => setState(() => _category = category),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                InkWell(
                  borderRadius: BorderRadius.circular(AppRadius.field),
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: appInputDecoration(
                      label: 'Date',
                      suffixIcon: const Icon(Icons.calendar_today_outlined, size: 20),
                    ),
                    child: Text(formatDate(_date)),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _noteController,
                  minLines: 2,
                  maxLines: 4,
                  textCapitalization: TextCapitalization.sentences,
                  inputFormatters: [LengthLimitingTextInputFormatter(200)],
                  validator: validateNote,
                  decoration: appInputDecoration(label: 'Note (optional)'),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (_error != null) ...[
                  InlineError(message: _error!),
                  const SizedBox(height: AppSpacing.md),
                ],
                PrimaryButton(
                  label: _isEditing ? 'Save changes' : 'Save expense',
                  isLoading: _busy,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
