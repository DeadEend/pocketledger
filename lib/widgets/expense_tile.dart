import 'package:flutter/material.dart';

import '../models/expense.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import 'app_card.dart';
import 'category_avatar.dart';

/// One expense row. Tap to edit; if [onDelete] is given, swipe left to delete
/// (the callback is expected to ask for confirmation first).
class ExpenseTile extends StatelessWidget {
  const ExpenseTile({
    super.key,
    required this.expense,
    required this.onTap,
    this.onDelete,
    this.bordered = true,
  });

  final Expense expense;
  final VoidCallback onTap;
  final Future<void> Function()? onDelete;

  /// True: a card of its own. False: a plain row for use inside a card.
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final row = Row(
      children: [
        CategoryAvatar(category: expense.category),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                expense.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleSmall,
              ),
              const SizedBox(height: 2),
              Text(
                '${expense.category.label} · ${formatDate(expense.date)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(formatCurrency(expense.amount), style: textTheme.titleSmall),
      ],
    );

    final Widget tile;
    if (bordered) {
      tile = AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        onTap: onTap,
        child: row,
      );
    } else {
      tile = InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: row,
        ),
      );
    }

    final delete = onDelete;
    if (delete == null) return tile;

    return Dismissible(
      key: ValueKey(expense.id),
      direction: DismissDirection.endToStart,
      // The row stays in place; the live Firestore stream removes it once the
      // delete has gone through.
      confirmDismiss: (_) async {
        await delete();
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.dangerSoft,
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.danger),
      ),
      child: tile,
    );
  }
}
