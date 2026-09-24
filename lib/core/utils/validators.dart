/// Form validators shared by every screen. Each returns an error message
/// (Bahasa Indonesia) or `null` when the value is valid, so they plug
/// straight into `TextFormField.validator`.
abstract final class Validators {
  static final _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');
  static final _letter = RegExp(r'[A-Za-z]');
  static final _digit = RegExp(r'[0-9]');

  static const minPasswordLength = 8;

  static String? requiredText(String? value, {String field = 'Kolom ini'}) =>
      (value == null || value.trim().isEmpty) ? '$field wajib diisi' : null;

  static String? fullName(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Nama lengkap wajib diisi';
    if (v.length < 3) return 'Nama minimal 3 karakter';
    if (v.length > 120) return 'Nama maksimal 120 karakter';
    return null;
  }

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email wajib diisi';
    if (!_email.hasMatch(v)) return 'Format email tidak valid';
    return null;
  }

  /// Minimum policy for new passwords. Mirror it in Supabase Dashboard >
  /// Authentication > Policies (min length 8, letters + digits).
  static String? newPassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Kata sandi wajib diisi';
    if (v.length < minPasswordLength) return 'Minimal $minPasswordLength karakter';
    if (!_letter.hasMatch(v) || !_digit.hasMatch(v)) return 'Gunakan kombinasi huruf dan angka';
    return null;
  }

  /// Sign-in only checks presence: existing accounts may predate the policy.
  static String? password(String? value) =>
      (value == null || value.isEmpty) ? 'Kata sandi wajib diisi' : null;

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) return 'Ulangi kata sandi';
    if (value != original) return 'Kata sandi tidak sama';
    return null;
  }
}
