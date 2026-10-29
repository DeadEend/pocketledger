
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';
import '../models/expense.dart';
import '../utils/app_constants.dart';
import '../utils/app_exception.dart';
import '../utils/sample_data.dart';

/// All Firestore access for the signed-in user's profile and expenses.
///
/// Write methods return true once the server confirms the change, and false
/// if the device looks offline: Firestore keeps the change locally and syncs
/// it when the connection returns.
class ExpenseService {
  ExpenseService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  static const Duration _writeTimeout = Duration(seconds: 8);

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _userDoc(String uid) =>
      _db.collection('users').doc(uid);

  CollectionReference<Map<String, dynamic>> _expenses(String uid) =>
      _userDoc(uid).collection('expenses');

  /// Checks that the signed-in user's profile can be read from the server.
  ///
  /// This is a preflight check only; the connection can still fail later.
  Future<void> verifyServerConnection(String uid) async {
    try {
      await _userDoc(uid)
          .get(const GetOptions(source: Source.server))
          .timeout(_writeTimeout);
    } on FirebaseException catch (error) {
      throw AppException(firestoreErrorMessage(error));
    } on TimeoutException {
      throw const AppException(
        'The server is taking too long to respond. '
            'Check your connection and try again.',
      );
    } catch (_) {
      throw const AppException(genericErrorMessage);
    }
  }

  /// Emits null only when the server confirms the profile does not exist.
  Stream<AppUser?> profileStream(String uid) {
    return _userDoc(uid)
        .snapshots(includeMetadataChanges: true)
        .where((snapshot) => snapshot.exists || !snapshot.metadata.isFromCache)
        .map((snapshot) {
      final data = snapshot.data();
      if (!snapshot.exists || data == null) return null;
      return AppUser.fromMap(snapshot.id, data);
    });
  }

  /// No orderBy here on purpose; sorting happens in memory.
  Stream<List<Expense>> expensesStream(String uid) {
    return _expenses(uid).snapshots().map(
          (snapshot) => snapshot.docs
          .map((doc) => Expense.fromMap(doc.id, doc.data()))
          .toList(),
    );
  }

  /// Creates the profile and, optionally, sample expenses in one batch.
  Future<void> createProfile({
    required String uid,
    required String name,
    required String email,
    bool withSampleData = false,
  }) async {
    final batch = _db.batch();
    final profile = AppUser(
      uid: uid,
      name: name.trim(),
      email: email,
      monthlyBudget: defaultMonthlyBudget,
      createdAt: DateTime.now(),
    );
    batch.set(_userDoc(uid), profile.toMap());

    if (withSampleData) {
      for (final expense in buildSampleExpenses(DateTime.now())) {
        batch.set(_expenses(uid).doc(), expense.toMap());
      }
    }

    try {
      await batch.commit();
    } on FirebaseException catch (error) {
      throw AppException(firestoreErrorMessage(error));
    }
  }

  /// Recreates a missing profile, for example if the account was created but
  /// the first write failed. No sample data is added in that case.
  Future<void> ensureProfile(User user) {
    final displayName = user.displayName?.trim() ?? '';
    final email = user.email ?? '';
    final fallbackName =
    email.contains('@') ? email.split('@').first : 'Student';

    return createProfile(
      uid: user.uid,
      name: displayName.isEmpty ? fallbackName : displayName,
      email: email,
      withSampleData: false,
    );
  }

  Future<bool> addExpense(String uid, Expense expense) {
    final doc = _expenses(uid).doc();
    return _commit(doc.set(expense.toMap()));
  }

  Future<bool> updateExpense(String uid, Expense expense) {
    return _commit(_expenses(uid).doc(expense.id).update(expense.toMap()));
  }

  Future<bool> deleteExpense(String uid, String expenseId) {
    return _commit(_expenses(uid).doc(expenseId).delete());
  }

  Future<bool> deleteExpenses(String uid, List<String> expenseIds) {
    final batch = _db.batch();

    for (final id in expenseIds) {
      batch.delete(_expenses(uid).doc(id));
    }

    return _commit(batch.commit());
  }

  /// Deletes all expense documents and then the user's profile.
  ///
  /// Authentication account deletion is handled separately.
  /// Call only after explicit confirmation.
  Future<void> deleteAccountData(String uid) async {
    try {
      final expensesRef = _expenses(uid);

      while (true) {
        // Use server data rather than relying only on the local cache.
        final snapshot = await expensesRef.limit(450).get(
          const GetOptions(source: Source.server),
        );

        if (snapshot.docs.isEmpty) break;

        final batch = _db.batch();

        for (final document in snapshot.docs) {
          batch.delete(document.reference);
        }

        await batch.commit();
      }

      await _userDoc(uid).delete();
    } on FirebaseException catch (error) {
      throw AppException(firestoreErrorMessage(error));
    } catch (_) {
      throw const AppException(genericErrorMessage);
    }
  }

  Future<bool> updateProfile(String uid, Map<String, Object> fields) {
    return _commit(_userDoc(uid).set(fields, SetOptions(merge: true)));
  }

  Future<bool> _commit(Future<void> operation) async {
    try {
      await operation.timeout(_writeTimeout);
      return true;
    } on TimeoutException {
      return false;
    } on FirebaseException catch (error) {
      throw AppException(firestoreErrorMessage(error));
    }
  }
}
