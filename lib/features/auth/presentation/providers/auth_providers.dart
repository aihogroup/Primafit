import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/env.dart';
import '../../data/local_auth_repository.dart';
import '../../data/supabase_auth_repository.dart';
import '../../domain/entities/app_session.dart';
import '../../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  if (Env.isSupabaseConfigured) {
    return SupabaseAuthRepository(Supabase.instance.client);
  }
  return LocalAuthRepository();
});

/// Current session; `null` when signed out. Drives role-based routing.
final sessionProvider = StreamProvider<AppSession?>(
  (ref) => ref.watch(authRepositoryProvider).watchSession(),
);
