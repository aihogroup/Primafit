import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../../../core/logging/app_logger.dart';
import '../domain/entities/app_session.dart';
import '../domain/entities/user_role.dart';
import '../domain/repositories/auth_repository.dart';

/// Supabase-backed authentication. Roles come from `public.user_roles`,
/// which is protected by RLS (a user can only read their own rows).
class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  /// Deep link that email verification and password-reset links open.
  /// Must be registered in AndroidManifest/Info.plist AND in Supabase
  /// Dashboard > Authentication > URL Configuration > Redirect URLs.
  static const authRedirectUrl = 'primafit://auth-callback';

  final SupabaseClient _client;

  GoTrueClient get _auth => _client.auth;

  @override
  Stream<AppSession?> watchSession() async* {
    yield await _toAppSession(_auth.currentUser);
    await for (final state in _auth.onAuthStateChange) {
      yield await _toAppSession(state.session?.user);
    }
  }

  @override
  Stream<void> watchPasswordRecovery() =>
      _auth.onAuthStateChange.where((state) => state.event == AuthChangeEvent.passwordRecovery);

  @override
  Future<Result<void>> signInWithEmail({required String email, required String password}) =>
      _run(() => _auth.signInWithPassword(email: email.trim(), password: password));

  @override
  Future<Result<SignUpStatus>> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) => _run(() async {
    // `full_name` is read by the `handle_new_user` trigger to seed the profile.
    final response = await _auth.signUp(
      email: email.trim(),
      password: password,
      data: {'full_name': fullName.trim()},
      emailRedirectTo: authRedirectUrl,
    );
    return response.session == null
        ? SignUpStatus.awaitingEmailVerification
        : SignUpStatus.signedIn;
  });

  @override
  Future<Result<void>> sendPasswordReset(String email) =>
      _run(() => _auth.resetPasswordForEmail(email.trim(), redirectTo: authRedirectUrl));

  @override
  Future<Result<void>> updatePassword(String newPassword) =>
      _run(() => _auth.updateUser(UserAttributes(password: newPassword)));

  @override
  Future<Result<void>> signOut() => _run(_auth.signOut);

  Future<AppSession?> _toAppSession(User? user) async {
    if (user == null) return null;
    try {
      final rows = await _client.from('user_roles').select('role').eq('user_id', user.id);
      final roles = {for (final row in rows) ?UserRole.tryParse(row['role'] as String?)};
      return AppSession(userId: user.id, email: user.email, roles: roles);
    } catch (e) {
      // Offline or transient error: keep the user signed in with the base
      // role only (least privilege) instead of failing the whole session.
      AppLogger.warning('Could not load roles; falling back to user role', tag: 'auth', error: e);
      return AppSession(userId: user.id, email: user.email, roles: const {UserRole.user});
    }
  }

  Future<Result<T>> _run<T>(Future<T> Function() action) async {
    try {
      return Result.success(await action());
    } on AuthException catch (e) {
      AppLogger.warning('Auth error: ${e.code}', tag: 'auth', error: e);
      return Result.failure(AuthFailure(messageFor(e), e));
    } catch (e, st) {
      AppLogger.error('Unexpected auth error', tag: 'auth', error: e, stackTrace: st);
      return Result.failure(const NetworkFailure());
    }
  }

  /// Maps Supabase error codes to user-facing copy without leaking internals.
  static String messageFor(AuthException e) => switch (e.code) {
    'invalid_credentials' => 'Email atau kata sandi salah.',
    'email_not_confirmed' => 'Email belum diverifikasi. Buka tautan verifikasi di email Anda.',
    'user_already_exists' || 'email_exists' => 'Email sudah terdaftar. Silakan masuk.',
    'email_address_invalid' || 'validation_failed' => 'Format email tidak valid.',
    'weak_password' =>
      'Kata sandi terlalu lemah. Gunakan minimal 8 karakter berisi huruf dan angka.',
    'same_password' => 'Kata sandi baru harus berbeda dari kata sandi lama.',
    'signup_disabled' => 'Pendaftaran akun sedang ditutup.',
    // Supabase's built-in SMTP only mails the project team until custom SMTP is set up.
    'email_address_not_authorized' =>
      'Email verifikasi belum dapat dikirim ke alamat ini. Hubungi admin Primafit.',
    'over_request_rate_limit' ||
    'over_email_send_rate_limit' => 'Terlalu banyak percobaan. Tunggu sebentar lalu coba lagi.',
    _ => 'Autentikasi gagal. Silakan coba lagi.',
  };
}
