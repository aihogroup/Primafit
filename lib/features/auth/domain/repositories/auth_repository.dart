import '../../../../core/error/result.dart';
import '../entities/app_session.dart';

/// Authentication boundary. The presentation layer depends only on this
/// interface, so the backend (Supabase today) can be swapped or mocked in
/// tests without touching UI code.
abstract interface class AuthRepository {
  /// Emits the current session and every change (sign-in, sign-out, token
  /// refresh, role change). `null` means signed out.
  Stream<AppSession?> watchSession();

  Future<Result<void>> signInWithEmail({required String email, required String password});

  Future<Result<void>> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  });

  Future<Result<void>> sendPasswordReset(String email);

  Future<Result<void>> signOut();
}
