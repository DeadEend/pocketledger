import '../models/expense.dart';
import '../models/expense_category.dart';

class MonthTotal {
  const MonthTotal(this.month, this.total);

  final DateTime month;
  final double total;
}

bool isSameMonth(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month;

/// 202610 for October 2026. Used to compare months cheaply.
int monthKey(DateTime date) => date.year * 100 + date.month;

double sumAmounts(Iterable<Expense> expenses) {
  var total = 0.0;
  for (final expense in expenses) {
    total += expense.amount;
  }
  return total;
}

List<Expense> expensesInMonth(Iterable<Expense> expenses, DateTime month) {
  return expenses.where((e) => isSameMonth(e.date, month)).toList();
}

Map<ExpenseCategory, double> totalsByCategory(Iterable<Expense> expenses) {
  final totals = <ExpenseCategory, double>{};
  for (final expense in expenses) {
    totals[expense.category] = (totals[expense.category] ?? 0) + expense.amount;
  }
  return totals;
}

/// Totals for the last [months] months, oldest first, ending with [now]'s month.
List<MonthTotal> monthlyTotals(
  Iterable<Expense> expenses,
  DateTime now, {
  int months = 6,
}) {
  final result = <MonthTotal>[];
  for (var i = months - 1; i >= 0; i--) {
    final month = DateTime(now.year, now.month - i);
    result.add(MonthTotal(month, sumAmounts(expensesInMonth(expenses, month))));
  }
  return result;
}
