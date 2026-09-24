import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_controller.dart';
import '../widgets/auth_form_widgets.dart';

/// Sends a password-reset link. Opening it on this phone launches the app
/// (deep link) straight into [UpdatePasswordPage].
class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  String? _error;
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    final result = await ref
        .read(authControllerProvider.notifier)
        .sendPasswordReset(_emailController.text);
    if (!mounted) return;
    result.when(
      success: (_) => setState(() => _sent = true),
      failure: (f) => setState(() => _error = f.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    if (_sent) {
      return AuthScaffold(
        title: 'Periksa email Anda',
        subtitle:
            'Jika ${_emailController.text.trim()} terdaftar, tautan untuk mengatur ulang '
            'kata sandi sudah dikirim. Buka tautan itu dari ponsel ini.',
        showBack: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.mark_email_read_outlined, size: 64, color: AppColors.primaryDark),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kembali ke halaman masuk'),
            ),
          ],
        ),
      );
    }

    return AuthScaffold(
      title: 'Lupa kata sandi',
      subtitle:
          'Masukkan email akun Anda. Kami akan mengirim tautan untuk membuat kata sandi baru.',
      showBack: true,
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
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _submit(),
              validator: Validators.email,
              decoration: authInputDecoration(label: 'Email', icon: Icons.mail_outline),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (_error != null) ...[
              AuthErrorBanner(message: _error!),
              const SizedBox(height: AppSpacing.md),
            ],
            AuthSubmitButton(label: 'Kirim tautan', isLoading: isLoading, onPressed: _submit),
          ],
        ),
      ),
    );
  }
}
