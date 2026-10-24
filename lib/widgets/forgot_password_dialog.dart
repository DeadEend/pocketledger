import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../utils/app_exception.dart';
import '../utils/app_theme.dart';
import '../utils/validators.dart';
import 'inline_error.dart';

class ForgotPasswordDialog extends StatefulWidget {
  const ForgotPasswordDialog({super.key, this.initialEmail = ''});

  final String initialEmail;

  @override
  State<ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<ForgotPasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  bool _busy = false;
  String? _error;
  String? _sentTo;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail.trim());
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    final email = _emailController.text.trim();
    final auth = context.read<AuthProvider>();
    setState(() {
      _busy = true;
      _error = null;
    });

    String? error;
    try {
      await auth.sendPasswordReset(email);
    } on AppException catch (e) {
      error = e.message;
    } catch (_) {
      error = genericErrorMessage;
    }

    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = error;
      _sentTo = error == null ? email : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sentTo = _sentTo;

    return AlertDialog(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
        side: const BorderSide(color: AppColors.border),
      ),
      title: const Text('Reset password'),
      titleTextStyle: Theme.of(context).textTheme.titleLarge,
      content: SingleChildScrollView(
        child: sentTo != null
            ? Text(
                'If an account exists for $sentTo, a password reset link is on '
                'its way. Check your inbox and spam folder.',
              )
            : Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Enter your email and we will send you a link to choose a new password.',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _send(),
                      validator: validateEmail,
                      decoration: appInputDecoration(label: 'Email'),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      InlineError(message: _error!),
                    ],
                  ],
                ),
              ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(),
          child: Text(sentTo != null ? 'Close' : 'Cancel'),
        ),
        if (sentTo == null)
          TextButton(
            onPressed: _busy ? null : _send,
            child: _busy
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Send link'),
          ),
      ],
    );
  }
}
