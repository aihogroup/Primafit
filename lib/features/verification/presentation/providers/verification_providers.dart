import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/result.dart';
import '../../../professional/domain/entities/verification_document.dart';
import '../../../professional/domain/entities/verification_status.dart';
import '../../data/supabase_verification_admin_repository.dart';
import '../../domain/entities/verification_request.dart';
import '../../domain/repositories/verification_admin_repository.dart';

final verificationAdminRepositoryProvider = Provider<VerificationAdminRepository>(
  (ref) => SupabaseVerificationAdminRepository(Supabase.instance.client),
);

final pendingCountsProvider = FutureProvider.autoDispose<Map<VerificationSubject, int>>(
  (ref) async =>
      (await ref.watch(verificationAdminRepositoryProvider).pendingCounts()).getOrThrow(),
);

typedef RequestFilter = ({VerificationSubject subject, VerificationStatus status});

final verificationRequestsProvider = FutureProvider.autoDispose
    .family<List<VerificationRequest>, RequestFilter>(
      (ref, filter) async =>
          (await ref
                  .watch(verificationAdminRepositoryProvider)
                  .requests(subject: filter.subject, status: filter.status))
              .getOrThrow(),
    );

final requestDocumentsProvider = FutureProvider.autoDispose
    .family<List<VerificationDocument>, VerificationRequest>(
      (ref, request) async =>
          (await ref.watch(verificationAdminRepositoryProvider).documents(request)).getOrThrow(),
    );

/// Review decisions + in-flight state. Refreshes queue and counters after a
/// decision so every open screen reflects it.
final reviewControllerProvider = NotifierProvider<ReviewController, AsyncValue<void>>(
  ReviewController.new,
);

class ReviewController extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<Result<void>> review(
    VerificationRequest request, {
    required VerificationStatus decision,
    String? note,
  }) async {
    state = const AsyncLoading();
    final result = await ref
        .read(verificationAdminRepositoryProvider)
        .review(request, decision: decision, note: note);
    if (!ref.mounted) return result;
    state = result.when(
      success: (_) => const AsyncData(null),
      failure: (f) => AsyncError(f, StackTrace.current),
    );
    if (result.isSuccess) {
      ref.invalidate(verificationRequestsProvider);
      ref.invalidate(pendingCountsProvider);
    }
    return result;
  }
}
