import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/state_views.dart';
import '../../../professional/domain/entities/verification_status.dart';
import '../../../professional/presentation/widgets/verification_widgets.dart';
import '../../domain/entities/verification_request.dart';
import '../providers/verification_providers.dart';

/// Superadmin review queue: one tab per subject, filtered by status
/// (pending by default; approved to suspend, rejected/suspended to follow up).
class VerificationQueuePage extends StatefulWidget {
  const VerificationQueuePage({super.key, this.initialSubject = VerificationSubject.doctor});

  final VerificationSubject initialSubject;

  @override
  State<VerificationQueuePage> createState() => _VerificationQueuePageState();
}

class _VerificationQueuePageState extends State<VerificationQueuePage> {
  VerificationStatus _status = VerificationStatus.pending;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: VerificationSubject.values.length,
      initialIndex: widget.initialSubject.index,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Verifikasi Pengajuan'),
          bottom: TabBar(tabs: [for (final s in VerificationSubject.values) Tab(text: s.label)]),
        ),
        body: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
              child: Row(
                children: [
                  for (final status in VerificationStatus.values)
                    Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: ChoiceChip(
                        label: Text(status.label),
                        selected: _status == status,
                        onSelected: (_) => setState(() => _status = status),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  for (final subject in VerificationSubject.values)
                    _RequestList(filter: (subject: subject, status: _status)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestList extends ConsumerWidget {
  const _RequestList({required this.filter});

  final RequestFilter filter;

  static final _date = DateFormat('d MMM yyyy', 'id_ID');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(verificationRequestsProvider(filter));
    return RefreshIndicator(
      onRefresh: () => ref.refresh(verificationRequestsProvider(filter).future),
      child: requests.when(
        loading: () => const AppLoadingView(),
        error: (e, _) => ListView(
          children: [
            AppErrorView.fromError(
              e,
              onRetry: () => ref.invalidate(verificationRequestsProvider(filter)),
            ),
          ],
        ),
        data: (items) => items.isEmpty
            ? ListView(
                children: [
                  AppEmptyView(
                    icon: Icons.task_alt,
                    title: 'Tidak ada pengajuan',
                    message:
                        '${filter.subject.label}: tidak ada pengajuan berstatus '
                        '"${filter.status.label.toLowerCase()}".',
                  ),
                ],
              )
            : ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                itemCount: items.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final r = items[i];
                  return ListTile(
                    title: Text(r.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(
                      [
                        r.applicantName,
                        r.credential,
                        if (r.submittedAt != null) _date.format(r.submittedAt!.toLocal()),
                      ].join(' · '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: r.status.color.withValues(alpha: 0.12),
                      child: Icon(r.status.icon, color: r.status.color),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.verificationDetail, arguments: r),
                  );
                },
              ),
      ),
    );
  }
}
