import 'package:firebase_core/firebase_core.dart';

/// An error whose message is safe to show to the user as it is.
class AppException implements Exception {
  const AppException(this.message);

  final String message;

  @override
  String toString() => message;
}

const String genericErrorMessage = 'Something went wrong. Please try again.';

String authErrorMessage(String code) {
  switch (code) {
    case 'invalid-email':
      return 'That email address does not look right.';
    case 'user-disabled':
      return 'This account has been disabled.';
    case 'user-not-found':
      return 'No account found with this email.';
    case 'wrong-password':
      return 'Incorrect password. Try again or reset it.';
    case 'invalid-credential':
    case 'invalid-login-credentials':
      return 'Incorrect email or password.';
    case 'email-already-in-use':
      return 'An account with this email already exists.';
    case 'weak-password':
      return 'Choose a stronger password with at least 6 characters.';
    case 'network-request-failed':
      return 'No internet connection. Check your network and try again.';
    case 'too-many-requests':
      return 'Too many attempts. Please wait a moment and try again.';
    case 'operation-not-allowed':
      return 'Email and password sign-in is not enabled in Firebase.';
    default:
      return genericErrorMessage;
  }
}

String firestoreErrorMessage(FirebaseException error) {
  switch (error.code) {
    case 'permission-denied':
      return 'Access denied. Make sure the Firestore rules are published and you are logged in.';
    case 'unavailable':
    case 'deadline-exceeded':
      return 'Cannot reach the server. Check your internet connection.';
    case 'not-found':
      return 'That item no longer exists.';
    default:
      return 'Could not complete the request. Please try again.';
  }
}
