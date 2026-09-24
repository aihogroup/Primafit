import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../providers/auth_controller.dart';
import '../widgets/auth_form_widgets.dart';

/// Opened by the app shell after a password-reset deep link (Supabase
/// `passwordRecovery` event); the user is in a temporary recovery session.
class UpdatePasswordPage extends ConsumerStatefulWidget {
  const UpdatePasswordPage({super.key});

  @override
  ConsumerState<UpdatePasswordPage> createState() => _UpdatePasswordPageState();
}

class _UpdatePasswordPageState extends ConsumerState<UpdatePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  String? _error;

  @override
  void dispose() {
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
        .updatePassword(_passwordController.text);
    if (!mounted) return;
    result.when(
      success: (_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Kata sandi berhasil diperbarui.')));
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.splash, (_) => false);
      },
      failure: (f) => setState(() => _error = f.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return AuthScaffold(
      title: 'Buat kata sandi baru',
      subtitle: 'Gunakan kata sandi yang belum pernah Anda pakai sebelumnya.',
      child: AutofillGroup(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PasswordField(
                controller: _passwordController,
                label: 'Kata sandi baru',
                autofillHints: const [AutofillHints.newPassword],
                textInputAction: TextInputAction.next,
                validator: Validators.newPassword,
              ),
              const SizedBox(height: AppSpacing.md),
              PasswordField(
                controller: _confirmController,
                label: 'Ulangi kata sandi baru',
                autofillHints: const [AutofillHints.newPassword],
                validator: (v) => Validators.confirmPassword(v, _passwordController.text),
                onSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: AppSpacing.lg),
              if (_error != null) ...[
                AuthErrorBanner(message: _error!),
                const SizedBox(height: AppSpacing.md),
              ],
              AuthSubmitButton(label: 'Simpan', isLoading: isLoading, onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
