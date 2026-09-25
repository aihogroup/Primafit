import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/error/result.dart';
import '../../../../core/widgets/state_views.dart';
import '../../data/verification_documents_store.dart';
import '../../domain/entities/verification_document.dart';
import '../providers/professional_providers.dart';
import 'verification_widgets.dart';

/// Upload / view / delete supporting documents for one registration.
class ApplicantDocumentsPanel extends ConsumerStatefulWidget {
  const ApplicantDocumentsPanel({
    super.key,
    required this.scope,
    required this.hint,
    this.canDelete = true,
  });

  final DocumentScope scope;

  /// Which documents the reviewer expects (e.g. "Scan STR dan SIP").
  final String hint;

  /// Approved registrations keep their evidence: deletion is disabled.
  final bool canDelete;

  @override
  ConsumerState<ApplicantDocumentsPanel> createState() => _ApplicantDocumentsPanelState();
}

class _ApplicantDocumentsPanelState extends ConsumerState<ApplicantDocumentsPanel> {
  bool _uploading = false;

  void _showMessage(String message) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  Future<void> _upload() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: VerificationDocumentsStore.allowedExtensions,
    );
    final path = picked?.files.single.path;
    if (path == null || !mounted) return;

    setState(() => _uploading = true);
    final result = await ref
        .read(professionalRepositoryProvider)
        .uploadDocument(widget.scope, File(path));
    if (!mounted) return;
    setState(() => _uploading = false);
    result.when(
      success: (_) {
        ref.invalidate(myDocumentsProvider(widget.scope));
        _showMessage('Dokumen berhasil diunggah.');
      },
      failure: (f) => _showMessage(f.message),
    );
  }

  Future<void> _open(VerificationDocument document) async {
    final result = await ref.read(professionalRepositoryProvider).documentUrl(document);
    if (!mounted) return;
    final uri = result.valueOrNull;
    if (uri == null) {
      result.when(success: (_) {}, failure: (f) => _showMessage(f.message));
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _delete(VerificationDocument document) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus dokumen?'),
        content: Text(document.displayName),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final Result<void> result = await ref
        .read(professionalRepositoryProvider)
        .deleteDocument(document);
    if (!mounted) return;
    result.when(
      success: (_) => ref.invalidate(myDocumentsProvider(widget.scope)),
      failure: (f) => _showMessage(f.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final documents = ref.watch(myDocumentsProvider(widget.scope));

    return SectionCard(
      title: 'Dokumen pendukung',
      trailing: _uploading
          ? const SizedBox.square(dimension: 24, child: CircularProgressIndicator(strokeWidth: 2))
          : TextButton.icon(
              onPressed: _upload,
              icon: const Icon(Icons.upload_file),
              label: const Text('Unggah'),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '${widget.hint} Format PDF/JPG/PNG, maksimal 5 MB per berkas.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          documents.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => AppErrorView.fromError(
              e,
              onRetry: () => ref.invalidate(myDocumentsProvider(widget.scope)),
            ),
            data: (docs) => DocumentList(
              documents: docs,
              onOpen: _open,
              onDelete: widget.canDelete ? _delete : null,
            ),
          ),
        ],
      ),
    );
  }
}
