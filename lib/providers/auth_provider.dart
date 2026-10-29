
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';
import '../services/expense_service.dart';
import '../utils/app_exception.dart';

/// Exposes the signed-in user and authentication actions to the UI.
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
  bool _deletingAccount = false;

  bool get isReady => _ready;
  User? get user => _registering ? null : _user;
  bool get isDeletingAccount => _deletingAccount;

  Future<void> signIn({
    required String email,
    required String password,
  }) {
    return _authService.signIn(
      email: email,
      password: password,
    );
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
        // The account exists. The profile can be created on first load.
      }
    } finally {
      _registering = false;
      notifyListeners();
    }
  }

  Future<void> sendPasswordReset(String email) {
    return _authService.sendPasswordReset(email);
  }

  /// Verifies the current user's identity before account deletion.
  Future<void> reauthenticate({
    required String password,
  }) {
    return _authService.reauthenticate(password: password);
  }

  /// Deletes the user's Firestore data and Authentication account.
  ///
  /// Reauthentication must happen before calling this method.
  ///
  /// Firestore and Authentication deletion are separate operations.
  /// If Authentication deletion fails after Firestore cleanup, the account
  /// may remain without its original profile and expenses.
  Future<void> deleteAccount() async {
    if (_deletingAccount) {
      throw const AppException(
        'Account deletion is already in progress.',
      );
    }

    final currentUser = _user;

    if (currentUser == null) {
      throw const AppException('Please log in again.');
    }

    _deletingAccount = true;
    notifyListeners();

    try {
      // Check connectivity before making any irreversible changes.
      await _expenseService.verifyServerConnection(currentUser.uid);

      // Delete Firestore data while the user is still authenticated.
      await _expenseService.deleteAccountData(currentUser.uid);

      // Delete the Firebase Authentication account.
      try {
        await _authService.deleteAccount();
      } on AppException {
        throw const AppException(
          accountDeletionPartialFailureMessage,
        );
      }
    } finally {
      _deletingAccount = false;
      notifyListeners();
    }
  }

  Future<void> signOut() => _authService.signOut();

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
