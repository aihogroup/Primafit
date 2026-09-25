import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/entities/user_role.dart';
import '../providers/active_role_provider.dart';
import '../providers/auth_providers.dart';

/// Lets accounts with several roles (e.g. user + doctor) switch the active
/// shell. Hidden for single-role accounts.
class RoleSwitcher extends ConsumerWidget {
  const RoleSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider).value;
    if (session == null || session.roles.length < 2) return const SizedBox.shrink();
    final active = ref.watch(activeRoleProvider).value ?? session.activeRole;
    final roles = UserRole.values.where(session.hasRole);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Masuk sebagai',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final role in roles)
              ChoiceChip(
                label: Text(role.label),
                selected: role == active,
                onSelected: role == active
                    ? null
                    : (_) async {
                        final switched = await ref.read(activeRoleProvider.notifier).select(role);
                        if (!switched || !context.mounted) return;
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.homeFor(role),
                          (_) => false,
                        );
                      },
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );
  }
}
