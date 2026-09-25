import 'package:flutter/foundation.dart';

/// Where an applicant's supporting documents live in the private
/// `verification-docs` bucket: `<ownerId>/<kind>[/<subjectId>]/<file>`.
/// The first folder must be the owner's id: storage RLS relies on it.
@immutable
class DocumentScope {
  const DocumentScope({required this.ownerId, required this.kind, this.subjectId});

  final String ownerId;

  /// `doctor`, `institution` or `partner`.
  final String kind;

  /// Institution/partner id; doctors have one registration per account.
  final String? subjectId;

  String get folder => [ownerId, kind, ?subjectId].join('/');

  @override
  bool operator ==(Object other) =>
      other is DocumentScope &&
      other.ownerId == ownerId &&
      other.kind == kind &&
      other.subjectId == subjectId;

  @override
  int get hashCode => Object.hash(ownerId, kind, subjectId);

  /// Storage object path for a new upload. The original name is reduced to a
  /// safe slug and prefixed with a timestamp to avoid collisions.
  String pathFor(String originalName, {DateTime? now}) {
    final dot = originalName.lastIndexOf('.');
    final base = dot > 0 ? originalName.substring(0, dot) : originalName;
    final ext = dot > 0 ? originalName.substring(dot + 1).toLowerCase() : '';
    final slug = base
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
    final safe = slug.isEmpty ? 'dokumen' : (slug.length > 60 ? slug.substring(0, 60) : slug);
    final stamp = (now ?? DateTime.now()).millisecondsSinceEpoch;
    return '$folder/${stamp}_$safe${ext.isEmpty ? '' : '.$ext'}';
  }
}

@immutable
class VerificationDocument {
  const VerificationDocument({
    required this.path,
    required this.name,
    this.sizeBytes,
    this.uploadedAt,
  });

  final String path;
  final String name;
  final int? sizeBytes;
  final DateTime? uploadedAt;

  /// Display name without the timestamp prefix added by [DocumentScope.pathFor].
  String get displayName => name.replaceFirst(RegExp(r'^\d+_'), '');
}
