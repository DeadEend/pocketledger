import 'package:firebase_auth/firebase_auth.dart';

import '../utils/app_exception.dart';

/// Thin wrapper around Firebase Authentication that turns Firebase errors
/// into friendly [AppException]s.
class AuthService {
  AuthService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<void> signIn({required String email, required String password}) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (error) {
      throw AppException(authErrorMessage(error.code));
    } catch (_) {
      throw const AppException(genericErrorMessage);
    }
  }

  /// Creates the account and returns the new user.
  Future<User> register({
    required String name,
    required String email,
    required String password,
  }) async {
    User? user;
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      user = credential.user;
    } on FirebaseAuthException catch (error) {
      throw AppException(authErrorMessage(error.code));
    } catch (_) {
      throw const AppException(genericErrorMessage);
    }

    if (user == null) {
      throw const AppException(genericErrorMessage);
    }

    try {
      await user.updateDisplayName(name.trim());
    } catch (_) {
      // Not critical: the name is also stored in the Firestore profile.
    }
    return user;
  }

  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (error) {
      throw AppException(authErrorMessage(error.code));
    } catch (_) {
      throw const AppException(genericErrorMessage);
    }
  }

  Future<void> signOut() => _auth.signOut();
}
