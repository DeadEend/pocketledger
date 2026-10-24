import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'home_screen.dart';
import 'login_screen.dart';
import 'splash_screen.dart';

/// Chooses the first screen from the auth state: Splash while Firebase
/// restores the session, then Login or Home.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (!auth.isReady) return const SplashScreen();

    final user = auth.user;
    if (user == null) return const LoginScreen();
    return HomeScreen(key: ValueKey(user.uid));
  }
}
