import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/state_views.dart';
import '../../domain/entities/user_role.dart';
import '../providers/auth_providers.dart';

/// Renders [child] only when the current session holds one of [allowed].
///
/// Client-side guards are a UX layer only; the real enforcement is Supabase
/// RLS on every table, so a bypassed guard still cannot read foreign data.
class RoleGuard extends ConsumerWidget {
  const RoleGuard({super.key, required this.allowed, required this.child});

  final Set<UserRole> allowed;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    return session.when(
      loading: () => const Scaffold(body: AppLoadingView()),
      error: (error, _) => Scaffold(
        body: AppErrorView.fromError(error, onRetry: () => ref.invalidate(sessionProvider)),
      ),
      data: (session) {
        if (session != null && session.canAccess(allowed)) return child;
        return Scaffold(
          appBar: AppBar(),
          body: const AppEmptyView(
            icon: Icons.lock_outline,
            title: 'Akses dibatasi',
            message: 'Fitur ini hanya tersedia untuk peran tertentu.',
          ),
        );
      },
    );
  }
}
