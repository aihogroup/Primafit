import 'package:flutter_test/flutter_test.dart';
import 'package:primafit/core/utils/validators.dart';

void main() {
  test('email', () {
    expect(Validators.email(''), isNotNull);
    expect(Validators.email('budi@'), isNotNull);
    expect(Validators.email('budi@mail'), isNotNull);
    expect(Validators.email(' budi@mail.co.id '), isNull);
  });

  test('new password requires 8+ chars with letters and digits', () {
    expect(Validators.newPassword(''), isNotNull);
    expect(Validators.newPassword('abc123'), 'Minimal 8 karakter');
    expect(Validators.newPassword('abcdefgh'), 'Gunakan kombinasi huruf dan angka');
    expect(Validators.newPassword('12345678'), 'Gunakan kombinasi huruf dan angka');
    expect(Validators.newPassword('sehat2026'), isNull);
  });

  test('sign-in password only checks presence (legacy accounts)', () {
    expect(Validators.password(''), isNotNull);
    expect(Validators.password('123'), isNull);
  });

  test('confirm password must match', () {
    expect(Validators.confirmPassword('', 'sehat2026'), isNotNull);
    expect(Validators.confirmPassword('sehat2025', 'sehat2026'), 'Kata sandi tidak sama');
    expect(Validators.confirmPassword('sehat2026', 'sehat2026'), isNull);
  });

  test('full name length', () {
    expect(Validators.fullName('  '), isNotNull);
    expect(Validators.fullName('Al'), isNotNull);
    expect(Validators.fullName('a' * 121), isNotNull);
    expect(Validators.fullName('Budi Santoso'), isNull);
  });
}
