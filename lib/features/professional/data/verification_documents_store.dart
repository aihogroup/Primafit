import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/entities/verification_document.dart';

/// Thin wrapper over the private `verification-docs` bucket, shared by the
/// applicant repository and the superadmin review repository.
class VerificationDocumentsStore {
  VerificationDocumentsStore(this._client);

  static const bucket = 'verification-docs';
  static const maxBytes = 5 * 1024 * 1024;
  static const allowedExtensions = ['pdf', 'jpg', 'jpeg', 'png'];

  static const _contentTypes = {
    'pdf': 'application/pdf',
    'jpg': 'image/jpeg',
    'jpeg': 'image/jpeg',
    'png': 'image/png',
  };

  final SupabaseClient _client;

  StorageFileApi get _files => _client.storage.from(bucket);

  Future<List<VerificationDocument>> list(DocumentScope scope) async {
    final objects = await _files.list(
      path: scope.folder,
      searchOptions: const SearchOptions(
        sortBy: SortBy(column: 'created_at', order: 'desc'),
      ),
    );
    return [
      for (final o in objects)
        // Sub-folders come back as entries without an id.
        if (o.id != null)
          VerificationDocument(
            path: '${scope.folder}/${o.name}',
            name: o.name,
            sizeBytes: (o.metadata?['size'] as num?)?.toInt(),
            uploadedAt: DateTime.tryParse(o.createdAt ?? ''),
          ),
    ];
  }

  /// Throws [ArgumentError] for unsupported or oversized files (the bucket
  /// enforces the same limits server-side).
  Future<VerificationDocument> upload(DocumentScope scope, File file) async {
    final name = p.basename(file.path);
    final ext = p.extension(name).replaceFirst('.', '').toLowerCase();
    if (!_contentTypes.containsKey(ext)) {
      throw ArgumentError('Format berkas harus PDF, JPG, atau PNG.');
    }
    final size = await file.length();
    if (size > maxBytes) throw ArgumentError('Ukuran berkas maksimal 5 MB.');

    final path = scope.pathFor(name);
    await _files.upload(
      path,
      file,
      fileOptions: FileOptions(contentType: _contentTypes[ext], upsert: false),
    );
    return VerificationDocument(
      path: path,
      name: p.basename(path),
      sizeBytes: size,
      uploadedAt: DateTime.now(),
    );
  }

  Future<void> delete(VerificationDocument document) => _files.remove([document.path]);

  Future<Uri> signedUrl(VerificationDocument document, {int expiresInSeconds = 600}) async =>
      Uri.parse(await _files.createSignedUrl(document.path, expiresInSeconds));
}
