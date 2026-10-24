import '../models/expense.dart';
import '../models/expense_category.dart';

/// Fifteen realistic expenses spread over the last six months.
/// Dates in the current month never fall after today.
List<Expense> buildSampleExpenses(DateTime now) {
  Expense make(
    String title,
    double amount,
    ExpenseCategory category,
    int monthsAgo,
    int day,
  ) {
    final monthStart = DateTime(now.year, now.month - monthsAgo);
    final lastDay = DateTime(monthStart.year, monthStart.month + 1, 0).day;
    var safeDay = day > lastDay ? lastDay : day;
    if (monthsAgo == 0 && safeDay > now.day) {
      safeDay = now.day;
    }
    return Expense(
      id: '',
      title: title,
      amount: amount,
      category: category,
      date: DateTime(monthStart.year, monthStart.month, safeDay),
      createdAt: now,
      isSample: true,
    );
  }

  return [
    make('Room rent', 4500, ExpenseCategory.rent, 0, 1),
    make('Canteen lunch', 120, ExpenseCategory.food, 0, 2),
    make('Metro card recharge', 500, ExpenseCategory.travel, 0, 4),
    make('Movie with friends', 350, ExpenseCategory.entertainment, 0, 8),
    make('Room rent', 4500, ExpenseCategory.rent, 1, 1),
    make('Mobile recharge', 299, ExpenseCategory.bills, 1, 7),
    make('Groceries', 780, ExpenseCategory.food, 1, 14),
    make('Data structures textbook', 650, ExpenseCategory.books, 2, 5),
    make('Birthday dinner', 1100, ExpenseCategory.food, 2, 16),
    make('Room rent', 4500, ExpenseCategory.rent, 3, 1),
    make('Stationery', 350, ExpenseCategory.books, 3, 12),
    make('OTT subscription', 199, ExpenseCategory.entertainment, 4, 10),
    make('Electricity share', 420, ExpenseCategory.bills, 4, 18),
    make('Lab fees', 800, ExpenseCategory.other, 5, 9),
    make('Train tickets home', 1250, ExpenseCategory.travel, 5, 15),
  ];
}
