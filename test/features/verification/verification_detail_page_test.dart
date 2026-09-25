import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:primafit/core/error/result.dart';
import 'package:primafit/features/professional/domain/entities/verification_document.dart';
import 'package:primafit/features/professional/domain/entities/verification_status.dart';
import 'package:primafit/features/verification/domain/entities/verification_request.dart';
import 'package:primafit/features/verification/domain/repositories/verification_admin_repository.dart';
import 'package:primafit/features/verification/presentation/pages/verification_detail_page.dart';
import 'package:primafit/features/verification/presentation/providers/verification_providers.dart';

class _FakeAdminRepository implements VerificationAdminRepository {
  final reviews = <(VerificationStatus, String?)>[];

  @override
  Future<Result<List<VerificationDocument>>> documents(VerificationRequest request) async =>
      const Result.success([]);

  @override
  Future<Result<Uri>> documentUrl(VerificationDocument document) async =>
      Result.success(Uri.parse('https://example.test/doc'));

  @override
  Future<Result<Map<VerificationSubject, int>>> pendingCounts() async => const Result.success({});

  @override
  Future<Result<List<VerificationRequest>>> requests({
    required VerificationSubject subject,
    required VerificationStatus status,
  }) async => const Result.success([]);

  @override
  Future<Result<void>> review(
    VerificationRequest request, {
    required VerificationStatus decision,
    String? note,
  }) async {
    reviews.add((decision, note));
    return const Result.success(null);
  }
}

const _request = VerificationRequest(
  subject: VerificationSubject.doctor,
  subjectId: 'd1',
  applicantId: 'd1',
  applicantName: 'dr. Budi',
  title: 'Penyakit Dalam',
  credential: 'STR-001',
  status: VerificationStatus.pending,
  details: {'Nomor STR': 'STR-001'},
);

void main() {
  setUpAll(() => initializeDateFormatting('id_ID'));

  group('decision rules', () {
    test('available decisions follow the current status', () {
      expect(VerificationDetailPage.decisionsFor(VerificationStatus.pending), [
        VerificationStatus.approved,
        VerificationStatus.rejected,
      ]);
      expect(VerificationDetailPage.decisionsFor(VerificationStatus.approved), [
        VerificationStatus.suspended,
      ]);
    });

    test('reject and suspend require a note', () {
      expect(VerificationDetailPage.requiresNote(VerificationStatus.rejected), isTrue);
      expect(VerificationDetailPage.requiresNote(VerificationStatus.suspended), isTrue);
      expect(VerificationDetailPage.requiresNote(VerificationStatus.approved), isFalse);
    });
  });

  testWidgets('rejecting without a note is blocked before reaching the server', (tester) async {
    final repository = _FakeAdminRepository();
    tester.view.physicalSize = const Size(1080, 2400);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [verificationAdminRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: VerificationDetailPage(request: _request)),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.widgetWithText(OutlinedButton, 'Tolak'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Tolak'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Tulis catatan alasan'), findsOneWidget);
    expect(repository.reviews, isEmpty);
  });

  testWidgets('rejection with a note is sent after confirmation', (tester) async {
    final repository = _FakeAdminRepository();
    tester.view.physicalSize = const Size(1080, 2400);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [verificationAdminRepositoryProvider.overrideWithValue(repository)],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const VerificationDetailPage(request: _request),
                  ),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'Scan STR tidak terbaca');
    await tester.ensureVisible(find.widgetWithText(OutlinedButton, 'Tolak'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(OutlinedButton, 'Tolak'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Tolak'));
    await tester.pumpAndSettle();

    expect(repository.reviews, [(VerificationStatus.rejected, 'Scan STR tidak terbaca')]);
    expect(find.byType(VerificationDetailPage), findsNothing, reason: 'page closes on success');
  });
}
