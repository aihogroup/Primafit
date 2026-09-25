import 'package:flutter/foundation.dart';

import '../../../professional/domain/entities/organization_registration.dart';
import '../../../professional/domain/entities/verification_document.dart';
import '../../../professional/domain/entities/verification_status.dart';

/// What is being verified.
enum VerificationSubject {
  doctor('Dokter', 'doctor_profiles'),
  institution('Instansi', 'institutions'),
  partner('Mitra', 'partners');

  const VerificationSubject(this.label, this.table);

  final String label;
  final String table;

  /// Folder segment used for the applicant's documents.
  String get documentKind => name;

  /// Primary key column of the subject table.
  String get keyColumn => this == doctor ? 'user_id' : 'id';

  static VerificationSubject fromKind(OrganizationKind kind) =>
      kind == OrganizationKind.institution ? institution : partner;
}

/// One application in the superadmin review queue.
@immutable
class VerificationRequest {
  const VerificationRequest({
    required this.subject,
    required this.subjectId,
    required this.applicantId,
    required this.applicantName,
    required this.title,
    required this.credential,
    required this.status,
    this.applicantPhone,
    this.reviewNote,
    this.submittedAt,
    this.details = const {},
  });

  final VerificationSubject subject;

  /// Row key: doctor user id, or institution/partner id.
  final String subjectId;
  final String applicantId;
  final String applicantName;
  final String? applicantPhone;

  /// Specialization or organization name.
  final String title;

  /// STR, license number or NIB, the thing the reviewer must check.
  final String credential;
  final VerificationStatus status;
  final String? reviewNote;
  final DateTime? submittedAt;

  /// Extra label -> value pairs shown on the detail screen.
  final Map<String, String> details;

  DocumentScope get documentScope => DocumentScope(
    ownerId: applicantId,
    kind: subject.documentKind,
    subjectId: subject == VerificationSubject.doctor ? null : subjectId,
  );
}
