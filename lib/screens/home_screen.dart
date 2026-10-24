import 'package:flutter/material.dart';

import '../utils/app_theme.dart';
import '../widgets/app_bar.dart';
import 'budget_screen.dart';
import 'dashboard_screen.dart';
import 'expense_form_screen.dart';
import 'expenses_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const List<String> _titles = [
    'Dashboard',
    'Expenses',
    'Budget',
    'Profile',
  ];

  int _index = 0;

  void _select(int index) => setState(() => _index = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context, _titles[_index]),
      body: IndexedStack(
        index: _index,
        children: [
          DashboardScreen(
            onOpenExpenses: () => _select(1),
            onOpenBudget: () => _select(2),
          ),
          const ExpensesScreen(),
          const BudgetScreen(),
          const ProfileScreen(),
        ],
      ),
      floatingActionButton: _index <= 1
          ? FloatingActionButton.extended(
              onPressed: () => ExpenseFormScreen.open(context),
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              elevation: 0,
              focusElevation: 0,
              hoverElevation: 0,
              highlightElevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add expense'),
            )
          : null,
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _select,
          backgroundColor: AppColors.surface,
          surfaceTintColor: Colors.transparent,
          indicatorColor: AppColors.accentSoft,
          elevation: 0,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: 'Expenses',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: Icon(Icons.account_balance_wallet),
              label: 'Budget',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
