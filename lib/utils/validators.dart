import 'app_constants.dart';

final RegExp _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

/// Parses text typed by the user. Returns null if it is not a number.
double? parseAmount(String? input) {
  if (input == null) return null;
  final cleaned = input.replaceAll(',', '').trim();
  if (cleaned.isEmpty) return null;
  final value = double.tryParse(cleaned);
  if (value == null || value.isNaN || value.isInfinite) return null;
  return value;
}

/// Rounds to two decimal places (paise).
double roundMoney(double value) => double.parse(value.toStringAsFixed(2));

String? validateEmail(String? value) {
  final email = value?.trim() ?? '';
  if (email.isEmpty) return 'Enter your email';
  if (!_emailPattern.hasMatch(email)) return 'Enter a valid email address';
  return null;
}

String? validatePassword(String? value) {
  final password = value ?? '';
  if (password.isEmpty) return 'Enter a password';
  if (password.length < 6) return 'Use at least 6 characters';
  return null;
}

String? validateName(String? value) {
  final name = value?.trim() ?? '';
  if (name.isEmpty) return 'Enter your name';
  if (name.length < 2) return 'Name is too short';
  if (name.length > 50) return 'Name must be 50 characters or fewer';
  return null;
}

String? validateTitle(String? value) {
  final title = value?.trim() ?? '';
  if (title.isEmpty) return 'Enter a title';
  if (title.length > 60) return 'Title must be 60 characters or fewer';
  return null;
}

String? validateNote(String? value) {
  if ((value?.trim().length ?? 0) > 200) {
    return 'Note must be 200 characters or fewer';
  }
  return null;
}

String? validateAmount(String? value) {
  if (value == null || value.trim().isEmpty) return 'Enter an amount';
  final amount = parseAmount(value);
  if (amount == null) return 'Enter a valid amount';
  if (amount <= 0) return 'Amount must be greater than zero';
  if (amount > maxAmount) return 'Amount is too large';
  return null;
}

String? validateBudget(String? value) {
  if (value == null || value.trim().isEmpty) return 'Enter a monthly budget';
  final budget = parseAmount(value);
  if (budget == null) return 'Enter a valid amount';
  if (budget <= 0) return 'Budget must be greater than zero';
  if (budget > maxAmount) return 'Budget is too large';
  return null;
}
