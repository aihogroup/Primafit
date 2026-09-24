import 'dart:async';

import 'package:primafit/core/error/failure.dart';
import 'package:primafit/core/error/result.dart';
import 'package:primafit/features/auth/domain/entities/app_session.dart';
import 'package:primafit/features/auth/domain/repositories/auth_repository.dart';

/// In-memory [AuthRepository] for controller and widget tests.
class FakeAuthRepository implements AuthRepository {
  final List<String> calls = [];
  Failure? failWith;
  SignUpStatus signUpStatus = SignUpStatus.awaitingEmailVerification;

  /// When set, calls wait for this completer (lets tests observe the loading state).
  Completer<void>? gate;

  Future<Result<T>> _answer<T>(String call, T value) async {
    calls.add(call);
    if (gate != null) await gate!.future;
    final failure = failWith;
    return failure == null ? Result.success(value) : Result.failure(failure);
  }

  @override
  Stream<AppSession?> watchSession() => const Stream.empty();

  @override
  Stream<void> watchPasswordRecovery() => const Stream.empty();

  @override
  Future<Result<void>> signInWithEmail({required String email, required String password}) =>
      _answer('signIn:$email', null);

  @override
  Future<Result<SignUpStatus>> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) => _answer('signUp:$email:$fullName', signUpStatus);

  @override
  Future<Result<void>> sendPasswordReset(String email) => _answer('reset:$email', null);

  @override
  Future<Result<void>> updatePassword(String newPassword) => _answer('updatePassword', null);

  @override
  Future<Result<void>> signOut() => _answer('signOut', null);
}
