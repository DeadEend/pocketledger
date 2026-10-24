import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/expense.dart';
import '../providers/data_provider.dart';
import '../utils/app_exception.dart';
import 'app_snackbar.dart';
import 'confirm_dialog.dart';

const String queuedMessage =
    'Saved on this device. It will sync when you are back online.';

/// Asks for confirmation, then deletes. Returns true if the expense was deleted.
Future<bool> confirmAndDeleteExpense(
  BuildContext context,
  Expense expense,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final data = context.read<DataProvider>();

  final confirmed = await showConfirmDialog(
    context,
    title: 'Delete expense?',
    message: '"${expense.title}" will be removed. This cannot be undone.',
    confirmLabel: 'Delete',
    destructive: true,
  );
  if (!confirmed) return false;

  try {
    final synced = await data.deleteExpense(expense.id);
    showMessengerSnackBar(
      messenger,
      synced ? 'Expense deleted' : queuedMessage,
    );
    return true;
  } on AppException catch (error) {
    showMessengerSnackBar(messenger, error.message, isError: true);
    return false;
  } catch (_) {
    showMessengerSnackBar(messenger, genericErrorMessage, isError: true);
    return false;
  }
}
