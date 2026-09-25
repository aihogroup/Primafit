import 'package:flutter_test/flutter_test.dart';
import 'package:primafit/features/professional/domain/entities/doctor_registration.dart';
import 'package:primafit/features/professional/domain/entities/organization_registration.dart';
import 'package:primafit/features/professional/domain/entities/verification_document.dart';
import 'package:primafit/features/professional/domain/entities/verification_status.dart';

void main() {
  group('DoctorRegistration', () {
    test('fromRow reads verification fields', () {
      final doctor = DoctorRegistration.fromRow({
        'str_number': 'STR-1',
        'sip_number': null,
        'specialization': 'Anak',
        'consultation_fee': 75000,
        'bio': null,
        'verification_status': 'rejected',
        'verification_note': 'Scan buram',
        'created_at': '2026-09-24T10:00:00Z',
      });

      expect(doctor.status, VerificationStatus.rejected);
      expect(doctor.reviewNote, 'Scan buram');
      expect(doctor.consultationFee, 75000);
      expect(doctor.submittedAt, DateTime.utc(2026, 9, 24, 10));
    });

    test('toRow never sends verification fields and trims input', () {
      const doctor = DoctorRegistration(
        strNumber: ' STR-1 ',
        specialization: ' Anak ',
        sipNumber: '  ',
        status: VerificationStatus.approved,
        reviewNote: 'x',
      );

      expect(doctor.toRow(), {
        'str_number': 'STR-1',
        'sip_number': null,
        'specialization': 'Anak',
        'consultation_fee': 0,
        'bio': null,
      });
    });
  });

  group('OrganizationRegistration', () {
    test('maps partner columns (business_name, category, nib) and omits email', () {
      const partner = OrganizationRegistration(
        kind: OrganizationKind.partner,
        name: 'Apotek Sehat',
        type: 'pharmacy',
        licenseNumber: '1234567890123',
        email: 'ignored@mail.id',
      );

      expect(partner.toRow(), {
        'business_name': 'Apotek Sehat',
        'category': 'pharmacy',
        'nib': '1234567890123',
        'address': null,
        'phone': null,
      });
      expect(partner.typeLabel, 'Apotek');
      expect(OrganizationKind.partner.columns, isNot(contains('email')));
    });

    test('maps institution columns and reads them back', () {
      final institution = OrganizationRegistration.fromRow(OrganizationKind.institution, {
        'id': 'i1',
        'name': 'RS Sehat',
        'type': 'hospital',
        'license_number': 'LIC-9',
        'address': 'Jl. Sehat 1',
        'phone': null,
        'email': 'rs@mail.id',
        'verification_status': 'approved',
        'verification_note': null,
        'created_at': null,
      });

      expect(institution.typeLabel, 'Rumah sakit');
      expect(institution.status, VerificationStatus.approved);
      expect(institution.toRow()['email'], 'rs@mail.id');
      expect(OrganizationKind.institution.requiresAddress, isTrue);
    });
  });

  group('DocumentScope', () {
    test('owner id is always the first folder (required by storage RLS)', () {
      const doctor = DocumentScope(ownerId: 'u1', kind: 'doctor');
      const partner = DocumentScope(ownerId: 'u1', kind: 'partner', subjectId: 'p9');

      expect(doctor.folder, 'u1/doctor');
      expect(partner.folder, 'u1/partner/p9');
    });

    test('pathFor sanitises names and keeps the extension', () {
      const scope = DocumentScope(ownerId: 'u1', kind: 'doctor');
      final path = scope.pathFor('../Scan STR (2026).PDF', now: DateTime.utc(2026));

      expect(path, startsWith('u1/doctor/'));
      expect(path, endsWith('_scan-str-2026.pdf'));
      expect(path.split('/'), hasLength(3), reason: 'no path traversal');
    });

    test('scopes compare by value (used as provider keys)', () {
      expect(
        const DocumentScope(ownerId: 'u', kind: 'doctor'),
        const DocumentScope(ownerId: 'u', kind: 'doctor'),
      );
    });

    test('display name hides the timestamp prefix', () {
      const doc = VerificationDocument(path: 'u/doctor/1727_str.pdf', name: '1727_str.pdf');
      expect(doc.displayName, 'str.pdf');
    });
  });
}
