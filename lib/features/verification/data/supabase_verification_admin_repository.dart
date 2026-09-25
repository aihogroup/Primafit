import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../../../core/logging/app_logger.dart';
import '../../professional/data/verification_documents_store.dart';
import '../../professional/domain/entities/organization_registration.dart';
import '../../professional/domain/entities/verification_document.dart';
import '../../professional/domain/entities/verification_status.dart';
import '../domain/entities/verification_request.dart';
import '../domain/repositories/verification_admin_repository.dart';

class SupabaseVerificationAdminRepository implements VerificationAdminRepository {
  SupabaseVerificationAdminRepository(this._client)
    : _documents = VerificationDocumentsStore(_client);

  static const _pageSize = 100;
  static final _currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

  final SupabaseClient _client;
  final VerificationDocumentsStore _documents;

  @override
  Future<Result<List<VerificationRequest>>> requests({
    required VerificationSubject subject,
    required VerificationStatus status,
  }) => _run(() async {
    // `applicant:` embeds the owner's profile through the named FK (the
    // tables also reference profiles via verified_by, so the hint is needed).
    final applicantFk = subject == VerificationSubject.doctor
        ? 'doctor_profiles_user_id_fkey'
        : '${subject.table}_owner_id_fkey';
    final rows = await _client
        .from(subject.table)
        .select('*, applicant:profiles!$applicantFk(full_name, phone)')
        .eq('verification_status', status.dbValue)
        .order('created_at')
        .limit(_pageSize);
    return [for (final row in rows) _toRequest(subject, row)];
  }, 'Gagal memuat antrean verifikasi.');

  @override
  Future<Result<Map<VerificationSubject, int>>> pendingCounts() => _run(() async {
    final counts = await Future.wait([
      for (final subject in VerificationSubject.values)
        _client
            .from(subject.table)
            .count()
            .eq('verification_status', VerificationStatus.pending.dbValue),
    ]);
    return {for (final (i, subject) in VerificationSubject.values.indexed) subject: counts[i]};
  }, 'Gagal memuat ringkasan verifikasi.');

  @override
  Future<Result<List<VerificationDocument>>> documents(VerificationRequest request) =>
      _run(() => _documents.list(request.documentScope), 'Gagal memuat dokumen pendukung.');

  @override
  Future<Result<Uri>> documentUrl(VerificationDocument document) =>
      _run(() => _documents.signedUrl(document), 'Gagal membuka dokumen.');

  @override
  Future<Result<void>> review(
    VerificationRequest request, {
    required VerificationStatus decision,
    String? note,
  }) => _run(() async {
    final trimmed = note?.trim();
    final updated = await _client
        .from(request.subject.table)
        .update({
          'verification_status': decision.dbValue,
          'verification_note': (trimmed == null || trimmed.isEmpty) ? null : trimmed,
        })
        .eq(request.subject.keyColumn, request.subjectId)
        .select(request.subject.keyColumn);
    if (updated.isEmpty) throw const PermissionFailure();
  }, 'Gagal menyimpan keputusan verifikasi.');

  VerificationRequest _toRequest(VerificationSubject subject, Map<String, dynamic> row) {
    final applicant = row['applicant'] as Map<String, dynamic>?;
    final common = (
      status: VerificationStatus.parse(row['verification_status'] as String?),
      note: row['verification_note'] as String?,
      submittedAt: DateTime.tryParse(row['created_at'] as String? ?? ''),
      name: (applicant?['full_name'] as String?) ?? '(tanpa nama)',
      phone: applicant?['phone'] as String?,
    );

    if (subject == VerificationSubject.doctor) {
      return VerificationRequest(
        subject: subject,
        subjectId: row['user_id'] as String,
        applicantId: row['user_id'] as String,
        applicantName: common.name,
        applicantPhone: common.phone,
        title: row['specialization'] as String,
        credential: row['str_number'] as String,
        status: common.status,
        reviewNote: common.note,
        submittedAt: common.submittedAt,
        details: {
          'Nomor STR': row['str_number'] as String,
          if (row['sip_number'] != null) 'Nomor SIP': row['sip_number'] as String,
          'Spesialisasi': row['specialization'] as String,
          'Tarif konsultasi': _currency.format(row['consultation_fee'] ?? 0),
          if (row['bio'] != null) 'Profil singkat': row['bio'] as String,
        },
      );
    }

    final kind = subject == VerificationSubject.institution
        ? OrganizationKind.institution
        : OrganizationKind.partner;
    final org = OrganizationRegistration.fromRow(kind, row);
    return VerificationRequest(
      subject: subject,
      subjectId: org.id!,
      applicantId: row['owner_id'] as String,
      applicantName: common.name,
      applicantPhone: common.phone,
      title: org.name,
      credential: org.licenseNumber,
      status: common.status,
      reviewNote: common.note,
      submittedAt: common.submittedAt,
      details: {
        'Nama': org.name,
        'Jenis': org.typeLabel,
        kind.licenseLabel: org.licenseNumber,
        if (org.address != null) 'Alamat': org.address!,
        if (org.phone != null) 'Telepon': org.phone!,
        if (org.email != null) 'Email': org.email!,
      },
    );
  }

  Future<Result<T>> _run<T>(Future<T> Function() action, String fallback) async {
    try {
      return Result.success(await action());
    } on Failure catch (f) {
      return Result.failure(f);
    } on PostgrestException catch (e) {
      AppLogger.warning(
        'Verification admin request failed: ${e.code}',
        tag: 'verification',
        error: e,
      );
      final message = switch (e.code) {
        '23514' => 'Catatan wajib diisi (dan harus baru) untuk menolak atau menangguhkan.',
        '42501' => 'Anda tidak dapat me-review pengajuan ini.',
        _ => fallback,
      };
      return Result.failure(StorageFailure(message, e));
    } catch (e, st) {
      AppLogger.error(fallback, tag: 'verification', error: e, stackTrace: st);
      return Result.failure(NetworkFailure('$fallback Periksa koneksi internet Anda.', e));
    }
  }
}
