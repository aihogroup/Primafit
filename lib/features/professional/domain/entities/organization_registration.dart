import 'package:flutter/foundation.dart';

import '../../../auth/domain/entities/user_role.dart';
import 'verification_status.dart';

/// Institutions (hospital, PMR, ...) and partners (pharmacy, gym, ...) share
/// the same registration flow; [OrganizationKind] maps each to its table.
enum OrganizationKind {
  institution(
    label: 'Instansi',
    table: 'institutions',
    nameColumn: 'name',
    typeColumn: 'type',
    licenseColumn: 'license_number',
    licenseLabel: 'Nomor izin operasional',
    role: UserRole.institution,
    types: {
      'hospital': 'Rumah sakit',
      'clinic': 'Klinik',
      'puskesmas': 'Puskesmas',
      'pmr': 'PMR / PMI',
      'health_organization': 'Organisasi kesehatan',
      'laboratory': 'Laboratorium',
    },
  ),
  partner(
    label: 'Mitra',
    table: 'partners',
    nameColumn: 'business_name',
    typeColumn: 'category',
    licenseColumn: 'nib',
    licenseLabel: 'NIB (Nomor Induk Berusaha)',
    role: UserRole.partner,
    types: {
      'pharmacy': 'Apotek',
      'skincare': 'Toko skincare',
      'fashion': 'Toko fashion',
      'fitness': 'Gym / fitness',
      'nutrition': 'Nutrisi & makanan sehat',
      'other': 'Lainnya',
    },
  );

  const OrganizationKind({
    required this.label,
    required this.table,
    required this.nameColumn,
    required this.typeColumn,
    required this.licenseColumn,
    required this.licenseLabel,
    required this.role,
    required this.types,
  });

  final String label;
  final String table;
  final String nameColumn;
  final String typeColumn;
  final String licenseColumn;
  final String licenseLabel;
  final UserRole role;

  /// Database enum value -> display label.
  final Map<String, String> types;

  String get columns =>
      'id, $nameColumn, $typeColumn, $licenseColumn, address, phone, '
      '${this == institution ? 'email, ' : ''}'
      'verification_status, verification_note, created_at';

  /// Institutions must give an address (used by "Temukan" / nearby search).
  bool get requiresAddress => this == institution;
}

@immutable
class OrganizationRegistration {
  const OrganizationRegistration({
    required this.kind,
    required this.name,
    required this.type,
    required this.licenseNumber,
    this.id,
    this.address,
    this.phone,
    this.email,
    this.status = VerificationStatus.pending,
    this.reviewNote,
    this.submittedAt,
  });

  final String? id;
  final OrganizationKind kind;
  final String name;

  /// Database enum value (see [OrganizationKind.types]).
  final String type;
  final String licenseNumber;
  final String? address;
  final String? phone;
  final String? email;
  final VerificationStatus status;
  final String? reviewNote;
  final DateTime? submittedAt;

  String get typeLabel => kind.types[type] ?? type;

  factory OrganizationRegistration.fromRow(OrganizationKind kind, Map<String, dynamic> row) =>
      OrganizationRegistration(
        kind: kind,
        id: row['id'] as String?,
        name: row[kind.nameColumn] as String,
        type: row[kind.typeColumn] as String,
        licenseNumber: row[kind.licenseColumn] as String,
        address: row['address'] as String?,
        phone: row['phone'] as String?,
        email: row['email'] as String?,
        status: VerificationStatus.parse(row['verification_status'] as String?),
        reviewNote: row['verification_note'] as String?,
        submittedAt: DateTime.tryParse(row['created_at'] as String? ?? ''),
      );

  /// Writable columns only; owner and verification fields are set elsewhere.
  Map<String, Object?> toRow() => {
    kind.nameColumn: name.trim(),
    kind.typeColumn: type,
    kind.licenseColumn: licenseNumber.trim(),
    'address': _blankToNull(address),
    'phone': _blankToNull(phone),
    if (kind == OrganizationKind.institution) 'email': _blankToNull(email),
  };

  static String? _blankToNull(String? value) =>
      (value == null || value.trim().isEmpty) ? null : value.trim();
}
