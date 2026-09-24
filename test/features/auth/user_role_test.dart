import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:primafit/features/auth/domain/entities/user_role.dart';

void main() {
  test('dbValue set matches the Postgres app_role enum in the migration', () {
    final sql = Directory('supabase/migrations')
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.sql'))
        .map((f) => f.readAsStringSync())
        .join('\n');
    final match = RegExp(r'create type public\.app_role as enum \(([^)]*)\)').firstMatch(sql);
    expect(match, isNotNull, reason: 'app_role enum not found in migration');

    final dbValues = RegExp(
      r"'([^']+)'",
    ).allMatches(match!.group(1)!).map((m) => m.group(1)).toSet();
    expect(UserRole.values.map((r) => r.dbValue).toSet(), dbValues);
  });

  test('tryParse maps known values and rejects unknown ones', () {
    expect(UserRole.tryParse('doctor'), UserRole.doctor);
    expect(UserRole.tryParse('superadmin'), UserRole.superadmin);
    expect(UserRole.tryParse('hacker'), isNull);
    expect(UserRole.tryParse(null), isNull);
  });

  test('only professional roles require verification', () {
    expect(UserRole.values.where((r) => r.requiresVerification).toSet(), {
      UserRole.doctor,
      UserRole.institution,
      UserRole.partner,
    });
  });
}
