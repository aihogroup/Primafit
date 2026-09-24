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
  Future<Result<void>> signInWithEmail({required String email, required String password}) =>
      _run(() => _auth.signInWithPassword(email: email.trim(), password: password));

  @override
  Future<Result<void>> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) =>
      // `full_name` is read by the `handle_new_user` trigger to seed the profile.
      _run(
        () => _auth.signUp(
          email: email.trim(),
          password: password,
          data: {'full_name': fullName.trim()},
        ),
      );

  @override
  Future<Result<void>> sendPasswordReset(String email) =>
      _run(() => _auth.resetPasswordForEmail(email.trim()));

  @override
  Future<Result<void>> signOut() => _run(_auth.signOut);

  Future<AppSession?> _toAppSession(User? user) async {
    if (user == null) return null;
    final rows = await _client.from('user_roles').select('role').eq('user_id', user.id);
    final roles = {for (final row in rows) ?UserRole.tryParse(row['role'] as String?)};
    return AppSession(userId: user.id, email: user.email, roles: roles);
  }

  Future<Result<void>> _run(Future<Object?> Function() action) async {
    try {
      await action();
      return const Result.success(null);
    } on AuthException catch (e) {
      AppLogger.warning('Auth error: ${e.code}', tag: 'auth', error: e);
      return Result.failure(AuthFailure(_messageFor(e), e));
    } catch (e, st) {
      AppLogger.error('Unexpected auth error', tag: 'auth', error: e, stackTrace: st);
      return Result.failure(UnexpectedFailure('Terjadi kesalahan. Silakan coba lagi.', e));
    }
  }

  /// Maps Supabase error codes to user-facing copy without leaking internals.
  String _messageFor(AuthException e) => switch (e.code) {
    'invalid_credentials' => 'Email atau kata sandi salah.',
    'email_not_confirmed' => 'Email belum diverifikasi. Periksa kotak masuk Anda.',
    'user_already_exists' || 'email_exists' => 'Email sudah terdaftar.',
    'weak_password' => 'Kata sandi terlalu lemah.',
    'over_request_rate_limit' ||
    'over_email_send_rate_limit' => 'Terlalu banyak percobaan. Tunggu sebentar lalu coba lagi.',
    _ => 'Autentikasi gagal. Silakan coba lagi.',
  };
}
