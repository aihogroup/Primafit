import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../domain/entities/app_session.dart';
import '../domain/repositories/auth_repository.dart';

/// Offline MVP mode (no Supabase keys configured): a single on-device `user`
/// session, matching how the app behaved before the super-app migration.
class LocalAuthRepository implements AuthRepository {
  static const _unavailable = AuthFailure('Masuk akun belum tersedia pada mode offline.');

  @override
  Stream<AppSession?> watchSession() => Stream.value(AppSession.local());

  @override
  Stream<void> watchPasswordRecovery() => const Stream.empty();

  @override
  Future<Result<void>> signInWithEmail({required String email, required String password}) async =>
      const Result.failure(_unavailable);

  @override
  Future<Result<SignUpStatus>> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async => const Result.failure(_unavailable);

  @override
  Future<Result<void>> sendPasswordReset(String email) async => const Result.failure(_unavailable);

  @override
  Future<Result<void>> updatePassword(String newPassword) async =>
      const Result.failure(_unavailable);

  @override
  Future<Result<void>> signOut() async => const Result.success(null);
}
