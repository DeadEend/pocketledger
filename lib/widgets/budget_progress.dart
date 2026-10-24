import 'package:flutter/material.dart';

import '../utils/app_theme.dart';
import '../utils/budget_status.dart';
import '../utils/formatters.dart';

Color budgetColor(BudgetState state) {
  switch (state) {
    case BudgetState.over:
      return AppColors.danger;
    case BudgetState.warning:
      return AppColors.warning;
    case BudgetState.safe:
      return AppColors.success;
    case BudgetState.notSet:
      return AppColors.textMuted;
  }
}

/// Progress bar, remaining amount and a warning note when needed.
class BudgetProgress extends StatelessWidget {
  const BudgetProgress({super.key, required this.status});

  final BudgetStatus status;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final color = budgetColor(status.state);
    final isOver = status.state == BudgetState.over;

    final remainingText = isOver
        ? '${formatCurrency(-status.remaining)} over budget'
        : '${formatCurrency(status.remaining)} left';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: status.fraction,
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
          color: color,
          backgroundColor: AppColors.border,
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                remainingText,
                style: textTheme.titleSmall?.copyWith(color: color),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Text('of ${formatCurrency(status.budget)}', style: textTheme.bodySmall),
          ],
        ),
        if (status.state == BudgetState.warning) ...[
          const SizedBox(height: AppSpacing.sm),
          _Note(
            text: 'You have used ${status.percentUsed}% of this month\'s budget.',
            background: AppColors.warningSoft,
            color: AppColors.warning,
          ),
        ],
        if (isOver) ...[
          const SizedBox(height: AppSpacing.sm),
          const _Note(
            text: 'You are over this month\'s budget.',
            background: AppColors.dangerSoft,
            color: AppColors.danger,
          ),
        ],
      ],
    );
  }
}

class _Note extends StatelessWidget {
  const _Note({
    required this.text,
    required this.background,
    required this.color,
  });

  final String text;
  final Color background;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.field),
      ),
      child: Text(text, style: TextStyle(color: color, fontSize: 13)),
    );
  }
}
