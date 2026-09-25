import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/supabase_professional_repository.dart';
import '../../domain/entities/doctor_registration.dart';
import '../../domain/entities/organization_registration.dart';
import '../../domain/entities/verification_document.dart';
import '../../domain/repositories/professional_repository.dart';

/// Only reachable when Supabase is configured (entry points are hidden in
/// offline mode), so the client is always initialised here.
final professionalRepositoryProvider = Provider<ProfessionalRepository>(
  (ref) => SupabaseProfessionalRepository(Supabase.instance.client),
);

final myDoctorRegistrationProvider = FutureProvider.autoDispose<DoctorRegistration?>(
  (ref) async =>
      (await ref.watch(professionalRepositoryProvider).myDoctorRegistration()).getOrThrow(),
);

final myOrganizationsProvider = FutureProvider.autoDispose
    .family<List<OrganizationRegistration>, OrganizationKind>(
      (ref, kind) async =>
          (await ref.watch(professionalRepositoryProvider).myOrganizations(kind)).getOrThrow(),
    );

final myDocumentsProvider = FutureProvider.autoDispose
    .family<List<VerificationDocument>, DocumentScope>(
      (ref, scope) async =>
          (await ref.watch(professionalRepositoryProvider).listDocuments(scope)).getOrThrow(),
    );
