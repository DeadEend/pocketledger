
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';
import '../utils/app_exception.dart';

/// Holds the signed-in user's profile and expenses, kept live by Firestore
/// streams. Streams are cancelled as soon as the user logs out.
class DataProvider extends ChangeNotifier {
  DataProvider(this._service);

  final ExpenseService _service;

  User? _user;
  StreamSubscription<AppUser?>? _profileSub;
  StreamSubscription<List<Expense>>? _expensesSub;
  Timer? _slowTimer;

  AppUser? _profile;
  List<Expense> _expenses = const [];
  bool _profileLoaded = false;
  bool _expensesLoaded = false;
  bool _timedOut = false;
  bool _creatingProfile = false;
  bool _suppressMissingProfileCreation = false;
  bool _disposed = false;

  Future<void>? _profileCreation;

  String? _error;

  List<Expense> get expenses => _expenses;

  bool get hasSampleData => _expenses.any((expense) => expense.isSample);

  double get monthlyBudget => _profile?.monthlyBudget ?? 0;

  String get displayName {
    final name = _profile?.name.trim() ?? '';
    if (name.isNotEmpty) return name;
    return _user?.displayName?.trim() ?? '';
  }

  AppUser? get profile => _profile;

  String? get error {
    if (_error != null) return _error;
    if (_timedOut && !(_profileLoaded && _expensesLoaded)) {
      return 'Cannot reach the server. Check your internet connection and try again.';
    }
    return null;
  }

  bool get isLoading =>
      error == null && !(_profileLoaded && _expensesLoaded);

  /// Called by the provider tree whenever the auth state changes.
  /// It must not notify listeners, because it runs while widgets are building.
  void bindUser(User? user) {
    if (user?.uid == _user?.uid) return;
    _start(user);
  }

  /// Prevents automatic profile recreation during account deletion.
  ///
  /// If profile creation has already started, wait for it to finish before
  /// the deletion process removes the Firestore documents.
  Future<void> prepareForAccountDeletion() async {
    _suppressMissingProfileCreation = true;
    await _profileCreation;
  }

  void reload() {
    _start(_user);
    _notify();
  }

  void _start(User? user) {
    final previousUid = _user?.uid;

    _stop();
    _user = user;

    // Reset the protection only when the signed-in user changes.
    if (previousUid != user?.uid) {
      _suppressMissingProfileCreation = false;
    }

    _profile = null;
    _expenses = const [];
    _profileLoaded = false;
    _expensesLoaded = false;
    _timedOut = false;
    _error = null;

    if (user == null) return;

    _profileSub = _service.profileStream(user.uid).listen(
          (profile) {
        _profile = profile;
        _profileLoaded = profile != null;

        if (profile == null && !_suppressMissingProfileCreation) {
          _createMissingProfile(user);
        }

        _notify();
      },
      onError: (Object error) {
        _error = _describe(error);
        _notify();
      },
    );

    _expensesSub = _service.expensesStream(user.uid).listen(
          (expenses) {
        _expenses = expenses;
        _expensesLoaded = true;
        _notify();
      },
      onError: (Object error) {
        _error = _describe(error);
        _notify();
      },
    );

    _slowTimer = Timer(const Duration(seconds: 12), () {
      if (!_profileLoaded || !_expensesLoaded) {
        _timedOut = true;
        _notify();
      }
    });
  }

  void _stop() {
    _profileSub?.cancel();
    _expensesSub?.cancel();
    _slowTimer?.cancel();

    _profileSub = null;
    _expensesSub = null;
    _slowTimer = null;
  }

  String _describe(Object error) {
    if (error is FirebaseException) {
      return firestoreErrorMessage(error);
    }
    return 'Could not load your data. Please try again.';
  }

  void _createMissingProfile(User user) {
    if (_creatingProfile || _suppressMissingProfileCreation) return;

    _creatingProfile = true;
    _profileCreation = _performMissingProfileCreation(user);
  }

  Future<void> _performMissingProfileCreation(User user) async {
    try {
      await _service.ensureProfile(user);
    } on AppException catch (error) {
      _error = error.message;
      _notify();
    } finally {
      _creatingProfile = false;
      _profileCreation = null;
    }
  }

  String get _uid {
    final user = _user;
    if (user == null) {
      throw const AppException('Please log in again.');
    }
    return user.uid;
  }

  Future<bool> addExpense(Expense expense) =>
      _service.addExpense(_uid, expense);

  Future<bool> updateExpense(Expense expense) =>
      _service.updateExpense(_uid, expense);

  Future<bool> deleteExpense(String expenseId) =>
      _service.deleteExpense(_uid, expenseId);

  Future<bool> deleteSampleExpenses() {
    final ids = _expenses
        .where((expense) => expense.isSample)
        .map((expense) => expense.id)
        .toList();

    return _service.deleteExpenses(_uid, ids);
  }

  Future<bool> updateProfile({
    String? name,
    double? monthlyBudget,
  }) {
    final fields = <String, Object>{};

    if (name != null) fields['name'] = name;
    if (monthlyBudget != null) {
      fields['monthlyBudget'] = monthlyBudget;
    }

    return _service.updateProfile(_uid, fields);
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _stop();
    super.dispose();
  }
}
