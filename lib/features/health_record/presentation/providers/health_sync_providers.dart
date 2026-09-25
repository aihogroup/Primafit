import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/env.dart';
import '../../../../core/logging/app_logger.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/sync/health_sync_remote.dart';
import '../../data/sync/health_sync_service.dart';
import '../../data/sync/sync_state_store.dart';

/// Sync engine for the signed-in account; `null` in offline mode or when
/// signed out (nothing to sync with).
final healthSyncServiceProvider = Provider<HealthSyncService?>((ref) {
  if (!Env.isSupabaseConfigured) return null;
  final session = ref.watch(sessionProvider).value;
  if (session == null || session.isLocalOnly) return null;
  return HealthSyncService(
    remote: SupabaseHealthSyncRemote(Supabase.instance.client),
    state: SyncStateStore(session.userId),
  );
});

@immutable
class SyncStatus {
  const SyncStatus({this.running = false, this.lastSyncedAt, this.error, this.lastReport});

  final bool running;
  final DateTime? lastSyncedAt;

  /// User-facing message of the last failed run.
  final String? error;
  final SyncReport? lastReport;

  SyncStatus copyWith({
    bool? running,
    DateTime? lastSyncedAt,
    String? error,
    bool clearError = false,
    SyncReport? lastReport,
  }) => SyncStatus(
    running: running ?? this.running,
    lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    error: clearError ? null : (error ?? this.error),
    lastReport: lastReport ?? this.lastReport,
  );
}

/// Runs sync on demand (app shell triggers: sign-in, resume, pause, every
/// few minutes; plus the manual button). Concurrent requests are coalesced.
final healthSyncControllerProvider = NotifierProvider<HealthSyncController, SyncStatus>(
  HealthSyncController.new,
);

class HealthSyncController extends Notifier<SyncStatus> {
  Future<void>? _inFlight;

  @override
  SyncStatus build() {
    final service = ref.watch(healthSyncServiceProvider);
    if (service != null) {
      unawaited(
        service.state.readLastSync().then((at) {
          if (ref.mounted && at != null) state = state.copyWith(lastSyncedAt: at);
        }),
      );
    }
    return const SyncStatus();
  }

  bool get isAvailable => ref.read(healthSyncServiceProvider) != null;

  Future<void> sync() => _inFlight ??= _run().whenComplete(() => _inFlight = null);

  Future<void> _run() async {
    final service = ref.read(healthSyncServiceProvider);
    if (service == null) return;
    state = state.copyWith(running: true, clearError: true);
    try {
      final report = await service.sync();
      AppLogger.info(
        'Health sync: pushed ${report.pushed}, pulled ${report.pulled}, '
        'skipped ${report.skipped}, quarantined ${report.quarantined}',
        tag: 'sync',
      );
      if (ref.mounted) {
        state = state.copyWith(running: false, lastSyncedAt: DateTime.now(), lastReport: report);
      }
    } catch (e, st) {
      AppLogger.warning('Health sync failed', tag: 'sync', error: e);
      AppLogger.debug(st.toString(), tag: 'sync');
      if (ref.mounted) {
        state = state.copyWith(
          running: false,
          error: 'Sinkronisasi belum berhasil. Data tetap aman di perangkat dan akan dicoba lagi.',
        );
      }
    }
  }
}
