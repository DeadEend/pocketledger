import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/expense.dart';
import '../models/expense_category.dart';
import '../providers/data_provider.dart';
import '../utils/app_theme.dart';
import '../utils/expense_filter.dart';
import '../utils/expense_stats.dart';
import '../utils/formatters.dart';
import '../widgets/empty_state.dart';
import '../widgets/expense_actions.dart';
import '../widgets/expense_tile.dart';
import '../widgets/sample_data_banner.dart';
import '../widgets/selectable_chip.dart';
import '../widgets/state_views.dart';
import 'expense_form_screen.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  ExpenseCategory? _category;
  int _month = 0; // a monthKey, or 0 for all months
  ExpenseSort _sort = ExpenseSort.newest;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _query = '';
      _category = null;
      _month = 0;
    });
  }

  /// Months that have expenses, newest first, always including this month.
  List<int> _availableMonths(List<Expense> expenses) {
    final keys = <int>{monthKey(DateTime.now())};
    for (final expense in expenses) {
      keys.add(monthKey(expense.date));
    }
    return keys.toList()..sort((a, b) => b.compareTo(a));
  }

  String _monthLabel(int key) => formatMonth(DateTime(key ~/ 100, key % 100));

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final error = data.error;
    if (error != null) return ErrorView(message: error, onRetry: data.reload);
    if (data.isLoading) return const LoadingView();

    final all = data.expenses;
    if (all.isEmpty) {
      return EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'No expenses yet',
        message: 'Add your first expense to start tracking where your money goes.',
        actionLabel: 'Add expense',
        onAction: () => ExpenseFormScreen.open(context),
      );
    }

    final textTheme = Theme.of(context).textTheme;
    final results = filterExpenses(
      all,
      query: _query,
      category: _category,
      month: _month,
      sort: _sort,
    );
    final total = sumAmounts(results);
    final filtersActive =
        _query.trim().isNotEmpty || _category != null || _month != 0;
    final months = _availableMonths(all);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onChanged: (value) => setState(() => _query = value),
            decoration: appInputDecoration(
              hint: 'Search by title',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Clear search',
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    ),
            ),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            children: [
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: SelectableChip(
                  label: 'All',
                  selected: _category == null,
                  onSelected: () => setState(() => _category = null),
                ),
              ),
              for (final category in ExpenseCategory.values)
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: SelectableChip(
                    label: category.label,
                    selected: _category == category,
                    color: category.color,
                    onSelected: () => setState(() => _category = category),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            0,
          ),
          child: Row(
            children: [
              Expanded(
                child: PopupMenuButton<int>(
                  tooltip: 'Filter by month',
                  color: AppColors.surface,
                  surfaceTintColor: Colors.transparent,
                  onSelected: (value) => setState(() => _month = value),
                  itemBuilder: (_) => [
                    const PopupMenuItem<int>(
                      value: 0,
                      child: Text('All months'),
                    ),
                    for (final key in months)
                      PopupMenuItem<int>(
                        value: key,
                        child: Text(_monthLabel(key)),
                      ),
                  ],
                  child: _MenuLabel(
                    icon: Icons.calendar_month_outlined,
                    text: _month == 0 ? 'All months' : _monthLabel(_month),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: PopupMenuButton<ExpenseSort>(
                  tooltip: 'Sort expenses',
                  color: AppColors.surface,
                  surfaceTintColor: Colors.transparent,
                  onSelected: (value) => setState(() => _sort = value),
                  itemBuilder: (_) => [
                    for (final option in ExpenseSort.values)
                      PopupMenuItem<ExpenseSort>(
                        value: option,
                        child: Text(option.label),
                      ),
                  ],
                  child: _MenuLabel(icon: Icons.sort, text: _sort.label),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.sm,
            0,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '${results.length} ${results.length == 1 ? 'expense' : 'expenses'}'
                  ' · ${formatCurrency(total)}',
                  style: textTheme.bodySmall,
                ),
              ),
              if (filtersActive)
                TextButton(
                  onPressed: _clearFilters,
                  child: const Text('Clear filters'),
                )
              else
                const SizedBox(height: 40),
            ],
          ),
        ),
        Expanded(
          child: results.isEmpty
              ? EmptyState(
                  icon: Icons.search_off,
                  title: 'No matching expenses',
                  message: 'Try a different search or clear the filters.',
                  actionLabel: 'Clear filters',
                  onAction: _clearFilters,
                )
              : ListView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.xs,
                    AppSpacing.md,
                    96,
                  ),
                  children: [
                    if (data.hasSampleData) ...[
                      const SampleDataBanner(),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    for (final expense in results)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: ExpenseTile(
                          expense: expense,
                          onTap: () =>
                              ExpenseFormScreen.open(context, expense: expense),
                          onDelete: () =>
                              confirmAndDeleteExpense(context, expense),
                        ),
                      ),
                    Center(
                      child: Text(
                        'Swipe an expense left to delete it',
                        style: textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _MenuLabel extends StatelessWidget {
  const _MenuLabel({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.field),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textMuted),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const Icon(Icons.arrow_drop_down, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
