import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

void showAppSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  showMessengerSnackBar(ScaffoldMessenger.of(context), message,
      isError: isError);
}

/// Use this variant when the widget that triggered the message may be gone
/// by the time the message is shown.
void showMessengerSnackBar(
  ScaffoldMessengerState messenger,
  String message, {
  bool isError = false,
}) {
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: isError ? AppColors.danger : AppColors.text,
      margin: const EdgeInsets.all(AppSpacing.md),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.field),
      ),
      content: Text(message, style: const TextStyle(color: Colors.white)),
    ),
  );
}
