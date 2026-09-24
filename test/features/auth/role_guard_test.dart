import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:primafit/features/auth/domain/entities/app_session.dart';
import 'package:primafit/features/auth/domain/entities/user_role.dart';
import 'package:primafit/features/auth/presentation/providers/auth_providers.dart';
import 'package:primafit/features/auth/presentation/widgets/role_guard.dart';

Widget _harness(AppSession? session, Set<UserRole> allowed) {
  return ProviderScope(
    overrides: [sessionProvider.overrideWith((ref) => Stream.value(session))],
    child: MaterialApp(
      home: RoleGuard(allowed: allowed, child: const Text('secret dashboard')),
    ),
  );
}

void main() {
  testWidgets('shows the page when the session holds an allowed role', (tester) async {
    await tester.pumpWidget(
      _harness(AppSession(userId: 'd', roles: const {UserRole.doctor}), {UserRole.doctor}),
    );
    await tester.pumpAndSettle();

    expect(find.text('secret dashboard'), findsOneWidget);
  });

  testWidgets('blocks the page for a role without access', (tester) async {
    await tester.pumpWidget(_harness(AppSession.local(), {UserRole.superadmin}));
    await tester.pumpAndSettle();

    expect(find.text('secret dashboard'), findsNothing);
    expect(find.text('Akses dibatasi'), findsOneWidget);
  });

  testWidgets('blocks the page when signed out', (tester) async {
    await tester.pumpWidget(_harness(null, {UserRole.user}));
    await tester.pumpAndSettle();

    expect(find.text('secret dashboard'), findsNothing);
  });
}
