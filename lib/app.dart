import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/data_provider.dart';
import 'screens/auth_gate.dart';
import 'services/auth_service.dart';
import 'services/expense_service.dart';
import 'utils/app_theme.dart';

class PocketLedgerApp extends StatelessWidget {
  const PocketLedgerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => AuthService()),
        Provider<ExpenseService>(create: (_) => ExpenseService()),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            context.read<AuthService>(),
            context.read<ExpenseService>(),
          ),
        ),
        ChangeNotifierProxyProvider<AuthProvider, DataProvider>(
          create: (context) => DataProvider(context.read<ExpenseService>()),
          update: (context, auth, previous) {
            final data = previous ?? DataProvider(context.read<ExpenseService>());
            data.bindUser(auth.user);
            return data;
          },
        ),
      ],
      child: MaterialApp(
        title: 'PocketLedger',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const AuthGate(),
      ),
    );
  }
}

/// Shown instead of the app if Firebase cannot be initialised, so the cause
/// is visible on screen rather than a blank page.
class StartupErrorApp extends StatelessWidget {
  const StartupErrorApp({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Builder(
                  builder: (context) => Text(
                    'PocketLedger could not start',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                const Text(
                  'Firebase failed to initialise. Run "flutterfire configure" '
                  'inside the project folder and start the app again.',
                ),
                const SizedBox(height: AppSpacing.md),
                Text(message, style: const TextStyle(color: AppColors.danger)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
