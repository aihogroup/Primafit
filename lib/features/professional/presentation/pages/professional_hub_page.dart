import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/state_views.dart';
import '../../domain/entities/organization_registration.dart';
import '../providers/professional_providers.dart';
import '../widgets/verification_widgets.dart';

/// "Join Primafit as a professional": doctor, institution, or partner.
/// Shows the status of every registration of the signed-in account.
class ProfessionalHubPage extends ConsumerWidget {
  const ProfessionalHubPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bergabung sebagai Profesional')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(myDoctorRegistrationProvider);
          ref.invalidate(myOrganizationsProvider);
        },
        child: ListView(
          padding: AppSpacing.page,
          children: [
            Text(
              'Layanan profesional Primafit hanya aktif setelah data Anda diverifikasi oleh tim kami.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            const _DoctorCard(),
            const SizedBox(height: AppSpacing.md),
            const _OrganizationsCard(kind: OrganizationKind.institution),
            const SizedBox(height: AppSpacing.md),
            const _OrganizationsCard(kind: OrganizationKind.partner),
          ],
        ),
      ),
    );
  }
}

class _DoctorCard extends ConsumerWidget {
  const _DoctorCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registration = ref.watch(myDoctorRegistrationProvider);
    return SectionCard(
      title: 'Dokter',
      child: registration.when(
        loading: () => const LinearProgressIndicator(),
        error: (e, _) =>
            AppErrorView.fromError(e, onRetry: () => ref.invalidate(myDoctorRegistrationProvider)),
        data: (doctor) => _HubTile(
          icon: Icons.medical_services_outlined,
          title: doctor?.specialization ?? 'Buka konsultasi online',
          subtitle: doctor == null ? 'Daftar dengan STR dan SIP Anda' : 'STR ${doctor.strNumber}',
          status: doctor == null ? null : VerificationStatusBadge(status: doctor.status),
          onTap: () => Navigator.pushNamed(context, AppRoutes.doctorRegistration),
        ),
      ),
    );
  }
}

class _OrganizationsCard extends ConsumerWidget {
  const _OrganizationsCard({required this.kind});

  final OrganizationKind kind;

  void _open(BuildContext context, OrganizationRegistration? existing) => Navigator.pushNamed(
    context,
    AppRoutes.organizationRegistration,
    arguments: (kind: kind, existing: existing),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final organizations = ref.watch(myOrganizationsProvider(kind));
    final isInstitution = kind == OrganizationKind.institution;
    return SectionCard(
      title: isInstitution ? 'Instansi kesehatan' : 'Mitra usaha',
      trailing: TextButton.icon(
        onPressed: () => _open(context, null),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
      child: organizations.when(
        loading: () => const LinearProgressIndicator(),
        error: (e, _) =>
            AppErrorView.fromError(e, onRetry: () => ref.invalidate(myOrganizationsProvider(kind))),
        data: (items) => items.isEmpty
            ? Text(
                isInstitution
                    ? 'Rumah sakit, klinik, puskesmas, PMR, atau organisasi kesehatan.'
                    : 'Apotek, toko skincare, fashion, gym, dan usaha sehat lainnya.',
                style: const TextStyle(color: AppColors.textSecondary),
              )
            : Column(
                children: [
                  for (final org in items)
                    _HubTile(
                      icon: isInstitution ? Icons.local_hospital_outlined : Icons.storefront,
                      title: org.name,
                      subtitle: org.typeLabel,
                      status: VerificationStatusBadge(status: org.status),
                      onTap: () => _open(context, org),
                    ),
                ],
              ),
      ),
    );
  }
}

class _HubTile extends StatelessWidget {
  const _HubTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.status,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: AppColors.primarySurface,
        child: Icon(icon, color: AppColors.primaryDark),
      ),
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
          if (status != null) ...[const SizedBox(height: AppSpacing.xs), status!],
        ],
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
