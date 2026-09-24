import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_controller.dart';
import '../widgets/auth_form_widgets.dart';

/// Email + password sign-in. On success the app shell reacts to the new
/// session and routes to the start gate; this page does not navigate.
class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key});

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final result = await ref
        .read(authControllerProvider.notifier)
        .signIn(email: _emailController.text, password: _passwordController.text);
    if (!mounted) return;
    result.when(success: (_) {}, failure: (f) => setState(() => _error = f.message));
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return AuthScaffold(
      title: 'Masuk ke Primafit',
      subtitle: 'Kelola kesehatan Anda dan keluarga dalam satu aplikasi.',
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                autocorrect: false,
                textInputAction: TextInputAction.next,
                validator: Validators.email,
                decoration: authInputDecoration(label: 'Email', icon: Icons.mail_outline),
              ),
              const SizedBox(height: AppSpacing.md),
              PasswordField(
                controller: _passwordController,
                label: 'Kata sandi',
                validator: Validators.password,
                onSubmitted: (_) => _submit(),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: isLoading
                      ? null
                      : () => Navigator.pushNamed(context, AppRoutes.forgotPassword),
                  child: const Text('Lupa kata sandi?'),
                ),
              ),
              if (_error != null) ...[
                AuthErrorBanner(message: _error!),
                const SizedBox(height: AppSpacing.md),
              ],
              AuthSubmitButton(label: 'Masuk', isLoading: isLoading, onPressed: _submit),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Belum punya akun?'),
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () => Navigator.pushNamed(context, AppRoutes.signUp),
                    child: const Text('Daftar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
