import '../models/expense.dart';
import '../models/expense_category.dart';
import 'expense_stats.dart';

enum ExpenseSort {
  newest('Newest first'),
  oldest('Oldest first'),
  highest('Amount: high to low'),
  lowest('Amount: low to high');

  const ExpenseSort(this.label);

  final String label;
}

/// Filters and sorts in memory, so Firestore never needs a composite index.
/// [month] is a [monthKey] value, or 0 for all months.
List<Expense> filterExpenses(
  List<Expense> expenses, {
  String query = '',
  ExpenseCategory? category,
  int month = 0,
  ExpenseSort sort = ExpenseSort.newest,
}) {
  final needle = query.trim().toLowerCase();

  final result = expenses.where((expense) {
    if (category != null && expense.category != category) return false;
    if (month != 0 && monthKey(expense.date) != month) return false;
    if (needle.isNotEmpty && !expense.title.toLowerCase().contains(needle)) {
      return false;
    }
    return true;
  }).toList();

  result.sort((a, b) {
    final int primary = switch (sort) {
      ExpenseSort.newest => b.date.compareTo(a.date),
      ExpenseSort.oldest => a.date.compareTo(b.date),
      ExpenseSort.highest => b.amount.compareTo(a.amount),
      ExpenseSort.lowest => a.amount.compareTo(b.amount),
    };
    if (primary != 0) return primary;
    return b.createdAt.compareTo(a.createdAt);
  });

  return result;
}
