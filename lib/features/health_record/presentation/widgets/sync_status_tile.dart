import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/health_sync_providers.dart';

/// Cloud backup status of the health records + manual sync.
class SyncStatusTile extends ConsumerWidget {
  const SyncStatusTile({super.key});

  static String describe(DateTime? lastSyncedAt, {DateTime? now}) {
    if (lastSyncedAt == null) return 'Belum pernah disinkronkan';
    final diff = (now ?? DateTime.now()).difference(lastSyncedAt);
    if (diff.inMinutes < 1) return 'Tersinkron baru saja';
    if (diff.inHours < 1) return 'Tersinkron ${diff.inMinutes} menit lalu';
    if (diff.inDays < 1) return 'Tersinkron ${diff.inHours} jam lalu';
    return 'Tersinkron ${DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(lastSyncedAt.toLocal())}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(healthSyncControllerProvider.notifier);
    if (!controller.isAvailable) return const SizedBox.shrink();
    final status = ref.watch(healthSyncControllerProvider);
    final hasError = status.error != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.card,
          side: BorderSide(color: hasError ? AppColors.warning : AppColors.border),
        ),
        child: ListTile(
          leading: Icon(
            hasError ? Icons.cloud_off_outlined : Icons.cloud_done_outlined,
            color: hasError ? AppColors.warning : AppColors.primaryDark,
          ),
          title: const Text('Cadangan catatan kesehatan'),
          subtitle: Text(
            status.running ? 'Menyinkronkan…' : (status.error ?? describe(status.lastSyncedAt)),
          ),
          trailing: status.running
              ? const SizedBox.square(
                  dimension: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : IconButton(
                  tooltip: 'Sinkronkan sekarang',
                  icon: const Icon(Icons.sync),
                  onPressed: controller.sync,
                ),
        ),
      ),
    );
  }
}
