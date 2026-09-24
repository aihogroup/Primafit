import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:primafit/core/error/failure.dart';
import 'package:primafit/features/auth/data/supabase_auth_repository.dart';
import 'package:primafit/features/auth/domain/repositories/auth_repository.dart';
import 'package:primafit/features/auth/presentation/providers/auth_controller.dart';
import 'package:primafit/features/auth/presentation/providers/auth_providers.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeAuthRepository();
    container = ProviderContainer.test(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );
  });

  test('exposes loading while a request is in flight', () async {
    repository.gate = Completer<void>();
    final future = container
        .read(authControllerProvider.notifier)
        .signIn(email: 'a@b.co', password: 'x');

    expect(container.read(authControllerProvider).isLoading, isTrue);
    repository.gate!.complete();
    await future;
    expect(container.read(authControllerProvider).isLoading, isFalse);
  });

  test('success returns the sign-up status', () async {
    repository.signUpStatus = SignUpStatus.awaitingEmailVerification;

    final result = await container
        .read(authControllerProvider.notifier)
        .signUp(fullName: 'Budi', email: 'budi@mail.id', password: 'sehat2026');

    expect(result.valueOrNull, SignUpStatus.awaitingEmailVerification);
    expect(repository.calls, ['signUp:budi@mail.id:Budi']);
  });

  test('failure is returned and kept as error state', () async {
    repository.failWith = const AuthFailure('Email atau kata sandi salah.');

    final result = await container
        .read(authControllerProvider.notifier)
        .signIn(email: 'a@b.co', password: 'x');

    expect(result.isSuccess, isFalse);
    expect(container.read(authControllerProvider).hasError, isTrue);
  });

  test('Supabase error codes map to Indonesian user messages', () {
    String msg(String code) => SupabaseAuthRepository.messageFor(AuthException('raw', code: code));

    expect(msg('invalid_credentials'), 'Email atau kata sandi salah.');
    expect(msg('email_exists'), contains('sudah terdaftar'));
    expect(msg('weak_password'), contains('minimal 8'));
    expect(msg('over_email_send_rate_limit'), contains('Terlalu banyak'));
    expect(msg('email_address_not_authorized'), contains('Hubungi admin'));
    expect(msg('something_new'), 'Autentikasi gagal. Silakan coba lagi.');
    expect(msg('invalid_credentials'), isNot(contains('raw')), reason: 'no internals leak');
  });
}
