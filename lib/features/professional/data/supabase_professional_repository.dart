import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../../../core/logging/app_logger.dart';
import '../domain/entities/doctor_registration.dart';
import '../domain/entities/organization_registration.dart';
import '../domain/entities/verification_document.dart';
import '../domain/repositories/professional_repository.dart';
import 'verification_documents_store.dart';

class SupabaseProfessionalRepository implements ProfessionalRepository {
  SupabaseProfessionalRepository(this._client) : _documents = VerificationDocumentsStore(_client);

  final SupabaseClient _client;
  final VerificationDocumentsStore _documents;

  String get _uid {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw const AuthFailure();
    return id;
  }

  @override
  Future<Result<DoctorRegistration?>> myDoctorRegistration() => _run(() async {
    final row = await _client
        .from('doctor_profiles')
        .select(DoctorRegistration.columns)
        .eq('user_id', _uid)
        .maybeSingle();
    return row == null ? null : DoctorRegistration.fromRow(row);
  }, 'Gagal memuat data pendaftaran dokter.');

  @override
  Future<Result<DoctorRegistration>> submitDoctor(DoctorRegistration registration) =>
      _run(() async {
        final row = await _client
            .from('doctor_profiles')
            .upsert({'user_id': _uid, ...registration.toRow()}, onConflict: 'user_id')
            .select(DoctorRegistration.columns)
            .single();
        return DoctorRegistration.fromRow(row);
      }, 'Gagal mengirim pendaftaran dokter.');

  @override
  Future<Result<List<OrganizationRegistration>>> myOrganizations(OrganizationKind kind) =>
      _run(() async {
        final rows = await _client
            .from(kind.table)
            .select(kind.columns)
            .eq('owner_id', _uid)
            .order('created_at', ascending: false);
        return [for (final row in rows) OrganizationRegistration.fromRow(kind, row)];
      }, 'Gagal memuat data ${kind.label.toLowerCase()}.');

  @override
  Future<Result<OrganizationRegistration>> submitOrganization(
    OrganizationRegistration registration,
  ) => _run(() async {
    final kind = registration.kind;
    final id = registration.id;
    final query = id == null
        ? _client.from(kind.table).insert({'owner_id': _uid, ...registration.toRow()})
        : _client.from(kind.table).update(registration.toRow()).eq('id', id);
    final row = await query.select(kind.columns).single();
    return OrganizationRegistration.fromRow(kind, row);
  }, 'Gagal mengirim pendaftaran ${registration.kind.label.toLowerCase()}.');

  @override
  DocumentScope documentScope({required String kind, String? subjectId}) =>
      DocumentScope(ownerId: _uid, kind: kind, subjectId: subjectId);

  @override
  Future<Result<List<VerificationDocument>>> listDocuments(DocumentScope scope) =>
      _run(() => _documents.list(scope), 'Gagal memuat dokumen.');

  @override
  Future<Result<VerificationDocument>> uploadDocument(DocumentScope scope, File file) =>
      _run(() => _documents.upload(scope, file), 'Gagal mengunggah dokumen.');

  @override
  Future<Result<void>> deleteDocument(VerificationDocument document) =>
      _run(() => _documents.delete(document), 'Gagal menghapus dokumen.');

  @override
  Future<Result<Uri>> documentUrl(VerificationDocument document) =>
      _run(() => _documents.signedUrl(document), 'Gagal membuka dokumen.');

  Future<Result<T>> _run<T>(Future<T> Function() action, String fallback) async {
    try {
      return Result.success(await action());
    } on Failure catch (f) {
      return Result.failure(f);
    } on ArgumentError catch (e) {
      return Result.failure(ValidationFailure(e.message as String));
    } on PostgrestException catch (e) {
      AppLogger.warning('Professional request failed: ${e.code}', tag: 'professional', error: e);
      return Result.failure(StorageFailure(_messageFor(e) ?? fallback, e));
    } on StorageException catch (e) {
      AppLogger.warning('Document storage failed', tag: 'professional', error: e);
      return Result.failure(StorageFailure(fallback, e));
    } catch (e, st) {
      AppLogger.error(fallback, tag: 'professional', error: e, stackTrace: st);
      return Result.failure(NetworkFailure('$fallback Periksa koneksi internet Anda.', e));
    }
  }

  /// Database constraint codes -> actionable Indonesian messages.
  static String? _messageFor(PostgrestException e) => switch (e.code) {
    '23505' => 'Nomor STR/izin/NIB ini sudah terdaftar. Periksa kembali nomor Anda.',
    '23514' => 'Data tidak valid. Periksa kembali isian Anda.',
    '42501' => 'Anda tidak memiliki izin untuk mengubah data ini.',
    _ => null,
  };
}
