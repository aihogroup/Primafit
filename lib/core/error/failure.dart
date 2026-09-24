/// Typed, user-presentable failure. Data layers translate raw exceptions
/// (SQLite, network, Supabase) into one of these so the UI never has to
/// inspect exception types or show stack traces to users.
sealed class Failure {
  const Failure(this.message, {this.cause});

  /// Message safe to show to end users (Bahasa Indonesia).
  final String message;
  final Object? cause;

  @override
  String toString() => '$runtimeType: $message';
}

final class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Tidak ada koneksi internet. Coba lagi.', Object? cause])
    : super(cause: cause);
}

final class StorageFailure extends Failure {
  const StorageFailure([super.message = 'Gagal mengakses data di perangkat.', Object? cause])
    : super(cause: cause);
}

final class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Sesi Anda berakhir. Silakan masuk kembali.', Object? cause])
    : super(cause: cause);
}

final class PermissionFailure extends Failure {
  const PermissionFailure([
    super.message = 'Anda tidak memiliki akses ke fitur ini.',
    Object? cause,
  ]) : super(cause: cause);
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Terjadi kesalahan. Silakan coba lagi.', Object? cause])
    : super(cause: cause);
}
