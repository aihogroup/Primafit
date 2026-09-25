import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/verification_document.dart';
import '../../domain/entities/verification_status.dart';

extension VerificationStatusStyle on VerificationStatus {
  Color get color => switch (this) {
    VerificationStatus.pending => AppColors.warning,
    VerificationStatus.approved => AppColors.success,
    VerificationStatus.rejected => AppColors.danger,
    VerificationStatus.suspended => AppColors.textSecondary,
  };

  IconData get icon => switch (this) {
    VerificationStatus.pending => Icons.hourglass_top_rounded,
    VerificationStatus.approved => Icons.verified_rounded,
    VerificationStatus.rejected => Icons.cancel_rounded,
    VerificationStatus.suspended => Icons.pause_circle_filled_rounded,
  };

  /// What the applicant should know / do next.
  String get applicantHint => switch (this) {
    VerificationStatus.pending =>
      'Tim Primafit sedang memeriksa data dan dokumen Anda. Pastikan dokumen pendukung sudah diunggah.',
    VerificationStatus.approved =>
      'Akun Anda aktif. Mengubah data kredensial akan memicu verifikasi ulang.',
    VerificationStatus.rejected =>
      'Perbaiki data sesuai catatan di bawah, lalu kirim ulang. Pengajuan akan diperiksa kembali.',
    VerificationStatus.suspended =>
      'Akses sedang ditangguhkan. Hubungi admin Primafit untuk informasi lebih lanjut.',
  };
}

class VerificationStatusBadge extends StatelessWidget {
  const VerificationStatusBadge({super.key, required this.status});

  final VerificationStatus status;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Status: ${status.label}',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        decoration: BoxDecoration(
          color: status.color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(status.icon, size: 16, color: status.color),
            const SizedBox(width: AppSpacing.xs),
            Text(
              status.label,
              style: TextStyle(color: status.color, fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

/// Status + reviewer note + next step, shown at the top of registration pages.
class VerificationStatusCard extends StatelessWidget {
  const VerificationStatusCard({super.key, required this.status, this.note});

  final VerificationStatus status;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.08),
        borderRadius: AppRadius.card,
        border: Border.all(color: status.color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VerificationStatusBadge(status: status),
          const SizedBox(height: AppSpacing.sm),
          Text(status.applicantHint, style: textTheme.bodyMedium),
          if (note != null && note!.trim().isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Text('Catatan peninjau', style: textTheme.labelLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(note!, style: textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic)),
          ],
        ],
      ),
    );
  }
}

/// Titled white card used to group form sections.
class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.card,
        side: BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                ?trailing,
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            child,
          ],
        ),
      ),
    );
  }
}

/// Supporting documents list. Actions are optional so the same widget serves
/// the applicant (upload/delete) and the reviewer (view only).
class DocumentList extends StatelessWidget {
  const DocumentList({
    super.key,
    required this.documents,
    required this.onOpen,
    this.onDelete,
    this.emptyMessage = 'Belum ada dokumen yang diunggah.',
  });

  final List<VerificationDocument> documents;
  final ValueChanged<VerificationDocument> onOpen;
  final ValueChanged<VerificationDocument>? onDelete;
  final String emptyMessage;

  static final _date = DateFormat('d MMM yyyy, HH:mm', 'id_ID');

  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Text(emptyMessage, style: const TextStyle(color: AppColors.textSecondary)),
      );
    }
    return Column(
      children: [
        for (final doc in documents)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(
              doc.name.toLowerCase().endsWith('.pdf')
                  ? Icons.picture_as_pdf_outlined
                  : Icons.image_outlined,
              color: AppColors.primaryDark,
            ),
            title: Text(doc.displayName, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(
              [
                if (doc.sizeBytes != null) _size(doc.sizeBytes!),
                if (doc.uploadedAt != null) _date.format(doc.uploadedAt!.toLocal()),
              ].join(' · '),
            ),
            onTap: () => onOpen(doc),
            trailing: onDelete == null
                ? const Icon(Icons.open_in_new, size: 20)
                : IconButton(
                    tooltip: 'Hapus dokumen',
                    icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                    onPressed: () => onDelete!(doc),
                  ),
          ),
      ],
    );
  }

  static String _size(int bytes) => bytes >= 1024 * 1024
      ? '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB'
      : '${(bytes / 1024).ceil()} KB';
}
