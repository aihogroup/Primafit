import 'dart:io';

import '../../../../core/error/result.dart';
import '../entities/doctor_registration.dart';
import '../entities/organization_registration.dart';
import '../entities/verification_document.dart';

/// Registrations of the signed-in account as doctor / institution / partner.
/// Verification status is server-controlled (see `private.guard_verification`):
/// new submissions are always pending, and editing a rejected one resubmits it.
abstract interface class ProfessionalRepository {
  /// The account's doctor registration, or `null` if never submitted.
  Future<Result<DoctorRegistration?>> myDoctorRegistration();

  /// Creates or updates (resubmits) the doctor registration.
  Future<Result<DoctorRegistration>> submitDoctor(DoctorRegistration registration);

  Future<Result<List<OrganizationRegistration>>> myOrganizations(OrganizationKind kind);

  /// Creates (when `id` is null) or updates an institution/partner registration.
  Future<Result<OrganizationRegistration>> submitOrganization(
    OrganizationRegistration registration,
  );

  /// Scope of the current account's documents for a registration.
  DocumentScope documentScope({required String kind, String? subjectId});

  Future<Result<List<VerificationDocument>>> listDocuments(DocumentScope scope);

  Future<Result<VerificationDocument>> uploadDocument(DocumentScope scope, File file);

  Future<Result<void>> deleteDocument(VerificationDocument document);

  /// Short-lived link to view a private document.
  Future<Result<Uri>> documentUrl(VerificationDocument document);
}
