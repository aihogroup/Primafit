import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:primafit/core/error/failure.dart';
import 'package:primafit/features/auth/presentation/pages/sign_in_page.dart';
import 'package:primafit/features/auth/presentation/providers/auth_providers.dart';

import 'fake_auth_repository.dart';

void main() {
  late FakeAuthRepository repository;

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: SignInPage()),
      ),
    );
  }

  setUp(() => repository = FakeAuthRepository());

  testWidgets('validates input before calling the backend', (tester) async {
    await pumpPage(tester);

    await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
    await tester.pump();

    expect(find.text('Email wajib diisi'), findsOneWidget);
    expect(find.text('Kata sandi wajib diisi'), findsOneWidget);
    expect(repository.calls, isEmpty);
  });

  testWidgets('submits the credentials to the auth repository', (tester) async {
    await pumpPage(tester);

    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), '  budi@mail.id ');
    await tester.enterText(find.widgetWithText(TextFormField, 'Kata sandi'), 'sehat2026');
    await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
    await tester.pumpAndSettle();

    expect(repository.calls, ['signIn:  budi@mail.id ']);
    expect(find.byType(SignInPage), findsOneWidget);
  });

  testWidgets('shows the backend error message inline', (tester) async {
    repository.failWith = const AuthFailure('Email atau kata sandi salah.');
    await pumpPage(tester);

    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'budi@mail.id');
    await tester.enterText(find.widgetWithText(TextFormField, 'Kata sandi'), 'salah123');
    await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
    await tester.pumpAndSettle();

    expect(find.text('Email atau kata sandi salah.'), findsOneWidget);
  });
}
