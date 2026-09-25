import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/state_views.dart';
import '../../auth/domain/entities/user_role.dart';
import '../../auth/presentation/widgets/account_section.dart';
import '../../professional/domain/entities/organization_registration.dart';
import '../../professional/domain/entities/verification_status.dart';
import '../../professional/presentation/providers/professional_providers.dart';
import '../../professional/presentation/widgets/verification_widgets.dart';
import '../../profile/presentation/providers/profile_providers.dart';
import '../../verification/domain/entities/verification_request.dart';
import '../../verification/presentation/providers/verification_providers.dart';

/// Landing screen for professional roles. Operational modules arrive in later
/// sprints (see docs/ROADMAP.md); until then each dashboard shows the verified
/// data behind the role plus what is coming next.
class RoleDashboardPage extends ConsumerWidget {
  const RoleDashboardPage({super.key, required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(profileControllerProvider).value?.name;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text('Dasbor ${role.label}'), automaticallyImplyLeading: false),
      body: ListView(
        padding: const EdgeInsets.only(top: AppSpacing.md),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              name == null ? 'Selamat datang' : 'Halo, $name',
              style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: switch (role) {
              UserRole.superadmin => const _AdminOverview(),
              UserRole.doctor => const _DoctorOverview(),
              UserRole.institution => const _OrganizationOverview(OrganizationKind.institution),
              UserRole.partner => const _OrganizationOverview(OrganizationKind.partner),
              UserRole.user => const SizedBox.shrink(),
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          const AccountSection(),
        ],
      ),
    );
  }
}

class _AdminOverview extends ConsumerWidget {
  const _AdminOverview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counts = ref.watch(pendingCountsProvider);
    return SectionCard(
      title: 'Menunggu verifikasi',
      trailing: IconButton(
        tooltip: 'Muat ulang',
        icon: const Icon(Icons.refresh),
        onPressed: () => ref.invalidate(pendingCountsProvider),
      ),
      child: counts.when(
        loading: () => const LinearProgressIndicator(),
        error: (e, _) =>
            AppErrorView.fromError(e, onRetry: () => ref.invalidate(pendingCountsProvider)),
        data: (map) => Column(
          children: [
            for (final subject in VerificationSubject.values)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: AppColors.primarySurface,
                  child: Text(
                    '${map[subject] ?? 0}',
                    style: const TextStyle(
                      color: AppColors.primaryDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                title: Text(subject.label),
                subtitle: Text((map[subject] ?? 0) == 0 ? 'Tidak ada antrean' : 'Perlu ditinjau'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.verificationQueue, arguments: subject),
              ),
          ],
        ),
      ),
    );
  }
}

class _DoctorOverview extends ConsumerWidget {
  const _DoctorOverview();

  static final _currency = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registration = ref.watch(myDoctorRegistrationProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionCard(
          title: 'Profil praktik',
          trailing: TextButton(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.doctorRegistration),
            child: const Text('Ubah'),
          ),
          child: registration.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => AppErrorView.fromError(
              e,
              onRetry: () => ref.invalidate(myDoctorRegistrationProvider),
            ),
            data: (doctor) => doctor == null
                ? const Text('Data praktik tidak ditemukan.')
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      VerificationStatusBadge(status: doctor.status),
                      const SizedBox(height: AppSpacing.sm),
                      Text(doctor.specialization, style: Theme.of(context).textTheme.titleMedium),
                      Text('STR ${doctor.strNumber}'),
                      Text('Tarif konsultasi ${_currency.format(doctor.consultationFee)}'),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const _ComingSoon(
          icon: Icons.video_chat_outlined,
          title: 'Konsultasi online',
          message: 'Jadwal praktik, booking pasien, dan chat konsultasi hadir di Sprint 4.',
        ),
      ],
    );
  }
}

class _OrganizationOverview extends ConsumerWidget {
  const _OrganizationOverview(this.kind);

  final OrganizationKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final organizations = ref.watch(myOrganizationsProvider(kind));
    final isInstitution = kind == OrganizationKind.institution;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionCard(
          title: isInstitution ? 'Instansi terverifikasi' : 'Usaha terverifikasi',
          child: organizations.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => AppErrorView.fromError(
              e,
              onRetry: () => ref.invalidate(myOrganizationsProvider(kind)),
            ),
            data: (items) {
              final approved = items.where((o) => o.status == VerificationStatus.approved);
              if (approved.isEmpty) return const Text('Belum ada yang terverifikasi.');
              return Column(
                children: [
                  for (final org in approved)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        isInstitution ? Icons.local_hospital_outlined : Icons.storefront,
                        color: AppColors.primaryDark,
                      ),
                      title: Text(org.name),
                      subtitle: Text(org.typeLabel),
                    ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _ComingSoon(
          icon: isInstitution ? Icons.event_available_outlined : Icons.inventory_2_outlined,
          title: isInstitution ? 'Layanan & antrean' : 'Katalog & promosi',
          message: isInstitution
              ? 'Katalog layanan (MCU, vaksinasi, donor darah) dan antrean hadir di Sprint 5.'
              : 'Katalog produk, promosi, dan pesanan hadir di Sprint 6.',
        ),
      ],
    );
  }
}

class _ComingSoon extends StatelessWidget {
  const _ComingSoon({required this.icon, required this.title, required this.message});

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: title,
      child: Row(
        children: [
          Icon(icon, size: 40, color: AppColors.primaryDark),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(message, style: const TextStyle(color: AppColors.textSecondary)),
          ),
        ],
      ),
    );
  }
}
