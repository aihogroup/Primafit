import 'package:flutter/foundation.dart';

import 'verification_status.dart';

/// A doctor's application / verified practice profile (`public.doctor_profiles`).
@immutable
class DoctorRegistration {
  const DoctorRegistration({
    required this.strNumber,
    required this.specialization,
    this.sipNumber,
    this.consultationFee = 0,
    this.bio,
    this.status = VerificationStatus.pending,
    this.reviewNote,
    this.submittedAt,
  });

  final String strNumber;
  final String? sipNumber;
  final String specialization;
  final num consultationFee;
  final String? bio;
  final VerificationStatus status;
  final String? reviewNote;
  final DateTime? submittedAt;

  static const columns =
      'str_number, sip_number, specialization, consultation_fee, bio, '
      'verification_status, verification_note, created_at';

  factory DoctorRegistration.fromRow(Map<String, dynamic> row) => DoctorRegistration(
    strNumber: row['str_number'] as String,
    sipNumber: row['sip_number'] as String?,
    specialization: row['specialization'] as String,
    consultationFee: (row['consultation_fee'] as num?) ?? 0,
    bio: row['bio'] as String?,
    status: VerificationStatus.parse(row['verification_status'] as String?),
    reviewNote: row['verification_note'] as String?,
    submittedAt: DateTime.tryParse(row['created_at'] as String? ?? ''),
  );

  /// Writable columns only; verification fields are server-controlled.
  Map<String, Object?> toRow() => {
    'str_number': strNumber.trim(),
    'sip_number': _blankToNull(sipNumber),
    'specialization': specialization.trim(),
    'consultation_fee': consultationFee,
    'bio': _blankToNull(bio),
  };

  static String? _blankToNull(String? value) =>
      (value == null || value.trim().isEmpty) ? null : value.trim();
}
