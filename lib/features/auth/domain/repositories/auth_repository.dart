import '../../../../core/error/result.dart';
import '../entities/app_session.dart';

/// Result of a registration attempt.
enum SignUpStatus {
  /// Account is active and the user is already signed in.
  signedIn,

  /// Account created; the user must open the verification link in their email.
  awaitingEmailVerification,
}

/// Authentication boundary. The presentation layer depends only on this
/// interface, so the backend (Supabase today) can be swapped or mocked in
/// tests without touching UI code.
abstract interface class AuthRepository {
  /// Emits the current session and every change (sign-in, sign-out, token
  /// refresh, role change). `null` means signed out.
  Stream<AppSession?> watchSession();

  /// Emits when the user opened a password-reset link and must now choose a
  /// new password.
  Stream<void> watchPasswordRecovery();

  Future<Result<void>> signInWithEmail({required String email, required String password});

  Future<Result<SignUpStatus>> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  });

  Future<Result<void>> sendPasswordReset(String email);

  /// Sets a new password for the signed-in (or recovering) user.
  Future<Result<void>> updatePassword(String newPassword);

  Future<Result<void>> signOut();
}
