import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/expense.dart';
import '../models/expense_category.dart';
import '../providers/data_provider.dart';
import '../utils/app_theme.dart';
import '../utils/budget_status.dart';
import '../utils/expense_filter.dart';
import '../utils/expense_stats.dart';
import '../utils/formatters.dart';
import '../widgets/app_card.dart';
import '../widgets/budget_progress.dart';
import '../widgets/category_pie_chart.dart';
import '../widgets/expense_tile.dart';
import '../widgets/monthly_bar_chart.dart';
import '../widgets/sample_data_banner.dart';
import '../widgets/state_views.dart';
import 'expense_form_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.onOpenExpenses,
    required this.onOpenBudget,
  });

  final VoidCallback onOpenExpenses;
  final VoidCallback onOpenBudget;

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final error = data.error;
    if (error != null) return ErrorView(message: error, onRetry: data.reload);
    if (data.isLoading) return const LoadingView();

    final textTheme = Theme.of(context).textTheme;
    final now = DateTime.now();
    final monthExpenses = expensesInMonth(data.expenses, now);
    final status = BudgetStatus.from(
      spent: sumAmounts(monthExpenses),
      budget: data.monthlyBudget,
    );
    final categoryEntries = totalsByCategory(monthExpenses).entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final monthly = monthlyTotals(data.expenses, now);
    final hasHistory = monthly.any((item) => item.total > 0);
    final recent = filterExpenses(data.expenses).take(5).toList();

    final name = data.displayName;
    final firstName = name.isEmpty ? '' : name.split(RegExp(r'\s+')).first;
    final greeting = greetingFor(now);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Text(
          firstName.isEmpty ? greeting : '$greeting, $firstName',
          style: textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text("Here is how ${formatMonth(now)} is going.",
            style: textTheme.bodySmall),
        const SizedBox(height: AppSpacing.md),
        if (data.hasSampleData) ...[
          const SampleDataBanner(),
          const SizedBox(height: AppSpacing.md),
        ],
        _BudgetCard(status: status, month: now, onSetBudget: onOpenBudget),
        const SizedBox(height: AppSpacing.md),
        _CategoryCard(entries: categoryEntries),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Last 6 months', style: textTheme.titleMedium),
              const SizedBox(height: AppSpacing.md),
              if (hasHistory)
                MonthlyBarChart(totals: monthly)
              else
                Text(
                  'No spending recorded in the last 6 months.',
                  style: textTheme.bodyMedium
                      ?.copyWith(color: AppColors.textMuted),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _RecentCard(expenses: recent, onSeeAll: onOpenExpenses),
        // Space so the add button never covers the last card.
        const SizedBox(height: 72),
      ],
    );
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({
    required this.status,
    required this.month,
    required this.onSetBudget,
  });

  final BudgetStatus status;
  final DateTime month;
  final VoidCallback onSetBudget;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Spent in ${formatMonth(month)}', style: textTheme.bodySmall),
          const SizedBox(height: AppSpacing.xs),
          Text(formatCurrency(status.spent), style: textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.md),
          if (status.state == BudgetState.notSet) ...[
            Text(
              'Set a monthly budget to see how much you have left.',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton(
              onPressed: onSetBudget,
              style: outlinedButtonStyle(),
              child: const Text('Set budget'),
            ),
          ] else
            BudgetProgress(status: status),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.entries});

  final List<MapEntry<ExpenseCategory, double>> entries;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Spending by category', style: textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          if (entries.isEmpty)
            Text(
              'Nothing spent this month yet.',
              style: textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
            )
          else
            Row(
              children: [
                SizedBox(
                  width: 128,
                  height: 128,
                  child: CategoryPieChart(entries: entries),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    children: [
                      for (final entry in entries)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: entry.key.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  entry.key.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: textTheme.bodyMedium,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                formatCurrency(entry.value),
                                style: textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _RecentCard extends StatelessWidget {
  const _RecentCard({required this.expenses, required this.onSeeAll});

  final List<Expense> expenses;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Recent expenses', style: textTheme.titleMedium),
              TextButton(onPressed: onSeeAll, child: const Text('See all')),
            ],
          ),
          if (expenses.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                'No expenses yet. Tap Add expense to log your first one.',
                style:
                    textTheme.bodyMedium?.copyWith(color: AppColors.textMuted),
              ),
            )
          else
            for (var i = 0; i < expenses.length; i++) ...[
              if (i > 0)
                const Divider(height: 1, thickness: 1, color: AppColors.border),
              ExpenseTile(
                expense: expenses[i],
                bordered: false,
                onTap: () =>
                    ExpenseFormScreen.open(context, expense: expenses[i]),
              ),
            ],
        ],
      ),
    );
  }
}
