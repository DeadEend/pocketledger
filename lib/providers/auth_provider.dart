import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';
import '../services/expense_service.dart';
import '../utils/app_exception.dart';

/// Exposes the signed-in user and the auth actions to the UI.
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService, this._expenseService) {
    _subscription = _authService.authStateChanges().listen(
      (user) {
        _user = user;
        _ready = true;
        notifyListeners();
      },
      onError: (Object _) {
        _ready = true;
        notifyListeners();
      },
    );
  }

  final AuthService _authService;
  final ExpenseService _expenseService;
  late final StreamSubscription<User?> _subscription;

  User? _user;
  bool _ready = false;
  bool _registering = false;

  /// False until Firebase has reported the initial sign-in state.
  bool get isReady => _ready;

  /// Hidden while registering, so the app does not open the home screen
  /// before the profile and sample data have been written.
  User? get user => _registering ? null : _user;

  Future<void> signIn({required String email, required String password}) {
    return _authService.signIn(email: email, password: password);
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _registering = true;
    try {
      final created = await _authService.register(
        name: name,
        email: email,
        password: password,
      );
      try {
        await _expenseService.createProfile(
          uid: created.uid,
          name: name,
          email: created.email ?? email.trim(),
          withSampleData: false,
        );
      } on AppException {
        // The account exists. The profile is created on first load instead.
      }
    } finally {
      _registering = false;
      notifyListeners();
    }
  }

  Future<void> sendPasswordReset(String email) {
    return _authService.sendPasswordReset(email);
  }

  Future<void> signOut() => _authService.signOut();

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
