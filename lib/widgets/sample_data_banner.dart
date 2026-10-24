import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/data_provider.dart';
import '../utils/app_exception.dart';
import '../utils/app_theme.dart';
import 'app_card.dart';
import 'app_snackbar.dart';
import 'confirm_dialog.dart';
import 'expense_actions.dart';

/// Tells the user that some expenses are demo data and how to remove them.
class SampleDataBanner extends StatelessWidget {
  const SampleDataBanner({super.key});

  Future<void> _removeSamples(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final data = context.read<DataProvider>();

    final confirmed = await showConfirmDialog(
      context,
      title: 'Remove sample expenses?',
      message: 'Only the sample expenses are deleted. Expenses you added stay.',
      confirmLabel: 'Remove',
      destructive: true,
    );
    if (!confirmed) return;

    try {
      final synced = await data.deleteSampleExpenses();
      showMessengerSnackBar(
        messenger,
        synced ? 'Sample expenses removed' : queuedMessage,
      );
    } on AppException catch (error) {
      showMessengerSnackBar(messenger, error.message, isError: true);
    } catch (_) {
      showMessengerSnackBar(messenger, genericErrorMessage, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      color: AppColors.accentSoft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sample data', style: textTheme.titleSmall),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Some expenses here were added so you can explore the app. '
            'You can delete them one by one, or all at once.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          TextButton(
            onPressed: () => _removeSamples(context),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 36),
              alignment: Alignment.centerLeft,
            ),
            child: const Text('Remove sample expenses'),
          ),
        ],
      ),
    );
  }
}
