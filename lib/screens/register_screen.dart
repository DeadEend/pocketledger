import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../utils/app_exception.dart';
import '../utils/app_theme.dart';
import '../utils/validators.dart';
import '../widgets/app_bar.dart';
import '../widgets/inline_error.dart';
import '../widgets/primary_button.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    FocusScope.of(context).unfocus();
    final auth = context.read<AuthProvider>();
    setState(() {
      _busy = true;
      _error = null;
    });

    String? error;
    try {
      await auth.register(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
    } on AppException catch (e) {
      error = e.message;
    } catch (_) {
      error = genericErrorMessage;
    }

    if (!mounted) return;
    if (error == null) {
      // The root screen has switched to Home; drop this screen from the stack.
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }
    setState(() {
      _busy = false;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: buildAppBar(context, 'Create account'),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                      validator: validateName,
                      decoration: appInputDecoration(label: 'Full name'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      validator: validateEmail,
                      decoration: appInputDecoration(label: 'Email'),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      validator: validatePassword,
                      decoration: appInputDecoration(
                        label: 'Password',
                        helper: 'At least 6 characters',
                        suffixIcon: IconButton(
                          tooltip: _obscurePassword
                              ? 'Show password'
                              : 'Hide password',
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'A few sample expenses are added to new accounts so you '
                      'can explore the app. You can delete them at any time.',
                      style: textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    if (_error != null) ...[
                      InlineError(message: _error!),
                      const SizedBox(height: AppSpacing.md),
                    ],
                    PrimaryButton(
                      label: 'Create account',
                      isLoading: _busy,
                      onPressed: _submit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
