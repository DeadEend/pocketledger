import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/data_provider.dart';
import '../utils/app_exception.dart';
import '../utils/app_theme.dart';
import '../utils/budget_status.dart';
import '../utils/expense_stats.dart';
import '../utils/formatters.dart';
import '../utils/validators.dart';
import '../widgets/app_card.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/budget_progress.dart';
import '../widgets/expense_actions.dart';
import '../widgets/inline_error.dart';
import '../widgets/primary_button.dart';
import '../widgets/state_views.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final error = data.error;
    if (error != null) return ErrorView(message: error, onRetry: data.reload);
    if (data.isLoading) return const LoadingView();

    final textTheme = Theme.of(context).textTheme;
    final now = DateTime.now();
    final spent = sumAmounts(expensesInMonth(data.expenses, now));
    final status = BudgetStatus.from(spent: spent, budget: data.monthlyBudget);
    final isSet = status.state != BudgetState.notSet;

    final daysLeft = DateTime(now.year, now.month + 1, 0).day - now.day + 1;
    final perDay = isSet && status.remaining > 0
        ? (status.remaining / daysLeft).floorToDouble()
        : 0.0;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(formatMonth(now), style: textTheme.titleMedium),
              const SizedBox(height: AppSpacing.md),
              _StatRow(label: 'Spent so far', value: formatCurrency(spent)),
              const SizedBox(height: AppSpacing.sm),
              _StatRow(
                label: 'Monthly budget',
                value: isSet ? formatCurrency(status.budget) : 'Not set',
              ),
              if (isSet) ...[
                const SizedBox(height: AppSpacing.md),
                BudgetProgress(status: status),
                if (perDay >= 1) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'About ${formatCurrency(perDay)} a day for the remaining '
                    '$daysLeft ${daysLeft == 1 ? 'day' : 'days'} of the month.',
                    style: textTheme.bodySmall,
                  ),
                ],
              ],
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _BudgetForm(initialBudget: data.monthlyBudget),
        const SizedBox(height: 72),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: textTheme.bodyMedium),
        Text(value, style: textTheme.titleSmall),
      ],
    );
  }
}

class _BudgetForm extends StatefulWidget {
  const _BudgetForm({required this.initialBudget});

  final double initialBudget;

  @override
  State<_BudgetForm> createState() => _BudgetFormState();
}

class _BudgetFormState extends State<_BudgetForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialBudget > 0
          ? formatAmountInput(widget.initialBudget)
          : '',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    final parsed = parseAmount(_controller.text);
    if (parsed == null) return;

    FocusScope.of(context).unfocus();
    final data = context.read<DataProvider>();
    setState(() {
      _busy = true;
      _error = null;
    });

    String? error;
    bool synced = true;
    try {
      synced = await data.updateProfile(monthlyBudget: roundMoney(parsed));
    } on AppException catch (e) {
      error = e.message;
    } catch (_) {
      error = genericErrorMessage;
    }

    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = error;
    });
    if (error == null) {
      showAppSnackBar(context, synced ? 'Budget updated' : queuedMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Set monthly budget', style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _save(),
              validator: validateBudget,
              decoration: appInputDecoration(
                label: 'Monthly budget',
                prefixText: '₹ ',
                helper: 'You get a warning when you reach 80% of it.',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (_error != null) ...[
              InlineError(message: _error!),
              const SizedBox(height: AppSpacing.md),
            ],
            PrimaryButton(
              label: 'Save budget',
              isLoading: _busy,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
