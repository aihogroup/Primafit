import 'package:flutter/material.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// Profile-page entry to apply as doctor / institution / partner.
class ProfessionalEntryTile extends StatelessWidget {
  const ProfessionalEntryTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Card(
        elevation: 0,
        color: AppColors.primarySurface,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.card),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          leading: const Icon(Icons.workspace_premium_outlined, color: AppColors.primaryDark),
          title: const Text('Bergabung sebagai profesional'),
          subtitle: const Text('Dokter, instansi kesehatan, atau mitra usaha'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.pushNamed(context, AppRoutes.professionalHub),
        ),
      ),
    );
  }
}
