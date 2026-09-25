import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../auth/presentation/widgets/auth_form_widgets.dart';
import '../../../professional/domain/entities/verification_document.dart';
import '../../../professional/domain/entities/verification_status.dart';
import '../../../professional/presentation/widgets/verification_widgets.dart';
import '../../domain/entities/verification_request.dart';
import '../providers/verification_providers.dart';

/// Review one application: applicant data, documents, and the decision.
class VerificationDetailPage extends ConsumerStatefulWidget {
  const VerificationDetailPage({super.key, required this.request});

  final VerificationRequest request;

  /// Decisions available from each current status.
  static List<VerificationStatus> decisionsFor(VerificationStatus current) => switch (current) {
    VerificationStatus.pending => [VerificationStatus.approved, VerificationStatus.rejected],
    VerificationStatus.approved => [VerificationStatus.suspended],
    VerificationStatus.rejected => [VerificationStatus.approved],
    VerificationStatus.suspended => [VerificationStatus.approved],
  };

  static bool requiresNote(VerificationStatus decision) =>
      decision == VerificationStatus.rejected || decision == VerificationStatus.suspended;

  @override
  ConsumerState<VerificationDetailPage> createState() => _VerificationDetailPageState();
}

class _VerificationDetailPageState extends ConsumerState<VerificationDetailPage> {
  static final _date = DateFormat('d MMMM yyyy, HH:mm', 'id_ID');

  final _noteController = TextEditingController();
  String? _error;

  VerificationRequest get _request => widget.request;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  String _actionLabel(VerificationStatus decision) => switch (decision) {
    VerificationStatus.approved =>
      _request.status == VerificationStatus.pending ? 'Setujui' : 'Aktifkan kembali',
    VerificationStatus.rejected => 'Tolak',
    VerificationStatus.suspended => 'Tangguhkan',
    VerificationStatus.pending => 'Tandai menunggu',
  };

  Future<void> _decide(VerificationStatus decision) async {
    final note = _noteController.text.trim();
    if (VerificationDetailPage.requiresNote(decision) && note.isEmpty) {
      setState(() => _error = 'Tulis catatan alasan agar pemohon tahu apa yang harus diperbaiki.');
      return;
    }
    setState(() => _error = null);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${_actionLabel(decision)} pengajuan?'),
        content: Text(
          decision == VerificationStatus.approved
              ? '${_request.applicantName} akan mendapat akses sebagai '
                    '${_request.subject.label.toLowerCase()}.'
              : 'Akses ${_request.subject.label.toLowerCase()} untuk '
                    '${_request.applicantName} tidak akan aktif.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(_actionLabel(decision)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final result = await ref
        .read(reviewControllerProvider.notifier)
        .review(_request, decision: decision, note: note);
    if (!mounted) return;
    result.when(
      success: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pengajuan ${_request.title}: ${decision.label.toLowerCase()}.')),
        );
        Navigator.pop(context);
      },
      failure: (f) => setState(() => _error = f.message),
    );
  }

  Future<void> _openDocument(VerificationDocument document) async {
    final result = await ref.read(verificationAdminRepositoryProvider).documentUrl(document);
    if (!mounted) return;
    final uri = result.valueOrNull;
    if (uri == null) {
      result.when(
        success: (_) {},
        failure: (f) =>
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(f.message))),
      );
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final documents = ref.watch(requestDocumentsProvider(_request));
    final isSubmitting = ref.watch(reviewControllerProvider).isLoading;
    final decisions = VerificationDetailPage.decisionsFor(_request.status);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text('Pengajuan ${_request.subject.label}')),
      body: ListView(
        padding: AppSpacing.page,
        children: [
          SectionCard(
            title: _request.title,
            trailing: VerificationStatusBadge(status: _request.status),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _InfoRow(label: 'Pemohon', value: _request.applicantName),
                if (_request.applicantPhone != null)
                  _InfoRow(label: 'Telepon pemohon', value: _request.applicantPhone!),
                if (_request.submittedAt != null)
                  _InfoRow(label: 'Diajukan', value: _date.format(_request.submittedAt!.toLocal())),
                const Divider(height: AppSpacing.lg),
                for (final entry in _request.details.entries)
                  _InfoRow(label: entry.key, value: entry.value),
                if (_request.reviewNote != null) ...[
                  const Divider(height: AppSpacing.lg),
                  _InfoRow(label: 'Catatan terakhir', value: _request.reviewNote!),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SectionCard(
            title: 'Dokumen pendukung',
            child: documents.when(
              loading: () => const LinearProgressIndicator(),
              error: (e, _) => AppErrorView.fromError(
                e,
                onRetry: () => ref.invalidate(requestDocumentsProvider(_request)),
              ),
              data: (docs) => DocumentList(
                documents: docs,
                onOpen: _openDocument,
                emptyMessage:
                    'Pemohon belum mengunggah dokumen. Pertimbangkan untuk menolak dengan catatan.',
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SectionCard(
            title: 'Keputusan',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Periksa kecocokan ${_request.credential} dengan dokumen sebelum memutuskan. '
                  'Catatan wajib untuk penolakan atau penangguhan dan akan dilihat pemohon.',
                  style: textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: _noteController,
                  maxLines: 3,
                  maxLength: 500,
                  decoration: authInputDecoration(
                    label: 'Catatan untuk pemohon',
                    icon: Icons.edit_note,
                  ),
                ),
                if (_error != null) ...[
                  AuthErrorBanner(message: _error!),
                  const SizedBox(height: AppSpacing.md),
                ],
                for (final decision in decisions) ...[
                  _DecisionButton(
                    label: _actionLabel(decision),
                    destructive: decision != VerificationStatus.approved,
                    isLoading: isSubmitting,
                    onPressed: () => _decide(decision),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
          ),
          Expanded(child: SelectableText(value, style: textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _DecisionButton extends StatelessWidget {
  const _DecisionButton({
    required this.label,
    required this.destructive,
    required this.isLoading,
    required this.onPressed,
  });

  final String label;
  final bool destructive;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (!destructive) {
      return AuthSubmitButton(label: label, isLoading: isLoading, onPressed: onPressed);
    }
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.danger,
        side: const BorderSide(color: AppColors.danger),
      ),
      onPressed: isLoading ? null : onPressed,
      child: Text(label),
    );
  }
}
