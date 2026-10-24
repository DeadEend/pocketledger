import 'dart:math' as math;

import 'app_constants.dart';

enum BudgetState { notSet, safe, warning, over }

/// How this month's spending compares with the monthly budget.
class BudgetStatus {
  const BudgetStatus({
    required this.spent,
    required this.budget,
    required this.state,
  });

  factory BudgetStatus.from({required double spent, required double budget}) {
    final BudgetState state;
    if (budget <= 0) {
      state = BudgetState.notSet;
    } else if (spent > budget) {
      state = BudgetState.over;
    } else if (spent >= budget * budgetWarningThreshold) {
      state = BudgetState.warning;
    } else {
      state = BudgetState.safe;
    }
    return BudgetStatus(spent: spent, budget: budget, state: state);
  }

  final double spent;
  final double budget;
  final BudgetState state;

  double get remaining => budget - spent;

  /// Progress bar value between 0 and 1.
  double get fraction {
    if (budget <= 0) return 0;
    return math.min(1.0, math.max(0.0, spent / budget));
  }

  int get percentUsed => budget <= 0 ? 0 : (spent / budget * 100).round();
}
