import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/app_user.dart';
import '../providers/auth_provider.dart';
import '../providers/data_provider.dart';
import '../utils/app_exception.dart';
import '../utils/app_theme.dart';
import '../utils/formatters.dart';
import '../utils/validators.dart';
import '../widgets/app_card.dart';
import '../widgets/app_snackbar.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/expense_actions.dart';
import '../widgets/inline_error.dart';
import '../widgets/primary_button.dart';
import '../widgets/state_views.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logOut(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final confirmed = await showConfirmDialog(
      context,
      title: 'Log out?',
      message: 'You will need to log in again to see your expenses.',
      confirmLabel: 'Log out',
    );
    if (!confirmed) return;
    await auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<DataProvider>();
    final error = data.error;
    if (error != null) return ErrorView(message: error, onRetry: data.reload);
    final profile = data.profile;
    if (data.isLoading || profile == null) return const LoadingView();

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _ProfileHeader(profile: profile),
        const SizedBox(height: AppSpacing.md),
        _ProfileForm(key: ValueKey(profile.uid), profile: profile),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton.icon(
          onPressed: () => _logOut(context),
          style: outlinedButtonStyle(color: AppColors.danger).copyWith(
            minimumSize: const WidgetStatePropertyAll(Size.fromHeight(52)),
          ),
          icon: const Icon(Icons.logout),
          label: const Text('Log out'),
        ),
        const SizedBox(height: 72),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});

  final AppUser profile;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final name = profile.name;
    final initial = name.isEmpty ? '?' : name.substring(0, 1).toUpperCase();

    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.accentSoft,
            shape: BoxShape.circle,
          ),
          child: Text(
            initial,
            style: textTheme.titleLarge?.copyWith(color: AppColors.accent),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name.isEmpty ? 'Your profile' : name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleMedium,
              ),
              const SizedBox(height: 2),
              Text(
                profile.email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileForm extends StatefulWidget {
  const _ProfileForm({super.key, required this.profile});

  final AppUser profile;

  @override
  State<_ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<_ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _budgetController;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final profile = widget.profile;
    _nameController = TextEditingController(text: profile.name);
    _budgetController = TextEditingController(
      text: profile.monthlyBudget > 0
          ? formatAmountInput(profile.monthlyBudget)
          : '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;
    final budget = parseAmount(_budgetController.text);
    if (budget == null) return;

    FocusScope.of(context).unfocus();
    final data = context.read<DataProvider>();
    setState(() {
      _busy = true;
      _error = null;
    });

    String? error;
    bool synced = true;
    try {
      synced = await data.updateProfile(
        name: _nameController.text.trim(),
        monthlyBudget: roundMoney(budget),
      );
    } on AppException catch (e) {
      error = e.message;
    } catch (_) {
      error = genericErrorMessage;
    }

    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = error;
    });
    if (error == null) {
      showAppSnackBar(context, synced ? 'Profile updated' : queuedMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AppCard(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Your details', style: textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              validator: validateName,
              decoration: appInputDecoration(label: 'Name'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              initialValue: widget.profile.email,
              enabled: false,
              decoration: appInputDecoration(label: 'Email'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _budgetController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _save(),
              validator: validateBudget,
              decoration: appInputDecoration(
                label: 'Monthly budget',
                prefixText: '₹ ',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (_error != null) ...[
              InlineError(message: _error!),
              const SizedBox(height: AppSpacing.md),
            ],
            PrimaryButton(
              label: 'Save changes',
              isLoading: _busy,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }
}
