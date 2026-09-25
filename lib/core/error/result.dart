import 'failure.dart';

/// Explicit success/failure return type for repositories, so callers must
/// handle the error path instead of relying on uncaught exceptions.
sealed class Result<T> {
  const Result();

  const factory Result.success(T value) = Success<T>;
  const factory Result.failure(Failure failure) = Err<T>;

  bool get isSuccess => this is Success<T>;

  T? get valueOrNull => switch (this) {
    Success<T>(:final value) => value,
    Err<T>() => null,
  };

  /// Value on success; throws the [Failure] otherwise. Meant for
  /// FutureProviders, where the thrown failure becomes `AsyncValue.error` and
  /// is rendered by the standard error views.
  T getOrThrow() => switch (this) {
    Success<T>(:final value) => value,
    Err<T>(failure: final f) => throw f,
  };

  R when<R>({required R Function(T value) success, required R Function(Failure failure) failure}) =>
      switch (this) {
        Success<T>(:final value) => success(value),
        Err<T>(failure: final f) => failure(f),
      };
}

final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

final class Err<T> extends Result<T> {
  const Err(this.failure);
  final Failure failure;
}

/// Runs [action] and maps any thrown exception with [onError] (defaults to
/// [UnexpectedFailure]). Keeps try/catch boilerplate out of repositories.
Future<Result<T>> guard<T>(
  Future<T> Function() action, {
  Failure Function(Object error)? onError,
}) async {
  try {
    return Result.success(await action());
  } catch (e) {
    return Result.failure(
      onError?.call(e) ?? UnexpectedFailure('Terjadi kesalahan. Silakan coba lagi.', e),
    );
  }
}
