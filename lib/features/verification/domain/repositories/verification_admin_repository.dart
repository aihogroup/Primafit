import '../../../../core/error/result.dart';
import '../../../professional/domain/entities/verification_document.dart';
import '../../../professional/domain/entities/verification_status.dart';
import '../entities/verification_request.dart';

/// Superadmin review of doctor / institution / partner registrations.
/// Authorization is enforced by RLS + `private.guard_verification`; this
/// interface only shapes the data for the review screens.
abstract interface class VerificationAdminRepository {
  Future<Result<List<VerificationRequest>>> requests({
    required VerificationSubject subject,
    required VerificationStatus status,
  });

  Future<Result<Map<VerificationSubject, int>>> pendingCounts();

  Future<Result<List<VerificationDocument>>> documents(VerificationRequest request);

  Future<Result<Uri>> documentUrl(VerificationDocument document);

  /// Approve, reject or suspend. [note] is mandatory for reject/suspend
  /// (enforced by the database as well).
  Future<Result<void>> review(
    VerificationRequest request, {
    required VerificationStatus decision,
    String? note,
  });
}
