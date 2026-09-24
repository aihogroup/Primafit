import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/result.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_providers.dart';

/// Auth actions + their in-flight state. Screens watch `.isLoading` to disable
/// buttons and use the returned [Result] for feedback. Navigation after
/// sign-in/out is NOT done here: the app shell reacts to `sessionProvider`.
final authControllerProvider = NotifierProvider<AuthController, AsyncValue<void>>(
  AuthController.new,
);

class AuthController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  AuthRepository get _repository => ref.read(authRepositoryProvider);

  Future<Result<void>> signIn({required String email, required String password}) =>
      _perform(() => _repository.signInWithEmail(email: email, password: password));

  Future<Result<SignUpStatus>> signUp({
    required String fullName,
    required String email,
    required String password,
  }) => _perform(
    () => _repository.signUpWithEmail(email: email, password: password, fullName: fullName),
  );

  Future<Result<void>> sendPasswordReset(String email) =>
      _perform(() => _repository.sendPasswordReset(email));

  Future<Result<void>> updatePassword(String newPassword) =>
      _perform(() => _repository.updatePassword(newPassword));

  /// Signs out. Clearing on-device personal data is handled by the app shell
  /// when the session ends (see `PrimafitApp`), so it also runs on token expiry.
  Future<Result<void>> signOut() => _perform(_repository.signOut);

  Future<Result<T>> _perform<T>(Future<Result<T>> Function() action) async {
    state = const AsyncLoading();
    final result = await action();
    if (ref.mounted) {
      state = result.when(
        success: (_) => const AsyncData(null),
        failure: (failure) => AsyncError(failure, StackTrace.current),
      );
    }
    return result;
  }
}
