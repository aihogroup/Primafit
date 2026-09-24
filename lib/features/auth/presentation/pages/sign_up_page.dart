import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../domain/repositories/auth_repository.dart';
import '../providers/auth_controller.dart';
import '../widgets/auth_form_widgets.dart';

/// Registration. Every new account starts with the `user` role; professional
/// roles are requested later and verified by a superadmin.
class SignUpPage extends ConsumerStatefulWidget {
  const SignUpPage({super.key});

  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final result = await ref
        .read(authControllerProvider.notifier)
        .signUp(
          fullName: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );
    if (!mounted) return;
    result.when(
      // signedIn: the app shell routes to profile setup automatically.
      success: (status) {
        if (status == SignUpStatus.awaitingEmailVerification) _showVerifyEmailDialog();
      },
      failure: (f) => setState(() => _error = f.message),
    );
  }

  Future<void> _showVerifyEmailDialog() async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.mark_email_read_outlined, size: 40),
        title: const Text('Verifikasi email Anda'),
        content: Text(
          'Kami mengirim tautan verifikasi ke ${_emailController.text.trim()}. '
          'Buka tautan itu dari ponsel ini untuk mengaktifkan akun, lalu masuk.',
        ),
        actions: [
          FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Mengerti')),
        ],
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return AuthScaffold(
      title: 'Buat akun',
      subtitle: 'Satu akun untuk catatan kesehatan, konsultasi, dan layanan Primafit.',
      showBack: true,
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                autofillHints: const [AutofillHints.name],
                textInputAction: TextInputAction.next,
                validator: Validators.fullName,
                decoration: authInputDecoration(label: 'Nama lengkap', icon: Icons.person_outline),
              ),
              const SizedBox(height: AppSpacing.md),
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
                autofillHints: const [AutofillHints.newPassword],
                textInputAction: TextInputAction.next,
                validator: Validators.newPassword,
              ),
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs, left: AppSpacing.sm),
                child: Text(
                  'Minimal ${Validators.minPasswordLength} karakter, kombinasi huruf dan angka.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              PasswordField(
                controller: _confirmController,
                label: 'Ulangi kata sandi',
                autofillHints: const [AutofillHints.newPassword],
                validator: (v) => Validators.confirmPassword(v, _passwordController.text),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (_error != null) ...[
                AuthErrorBanner(message: _error!),
                const SizedBox(height: AppSpacing.md),
              ],
              AuthSubmitButton(label: 'Daftar', isLoading: isLoading, onPressed: _submit),
              const SizedBox(height: AppSpacing.md),
              TextButton(
                onPressed: isLoading ? null : () => Navigator.pop(context),
                child: const Text('Sudah punya akun? Masuk'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
