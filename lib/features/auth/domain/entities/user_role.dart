/// Roles of the Primafit super-app. Mirrors the Postgres enum
/// `public.app_role` (see `supabase/migrations`), so [dbValue] must stay in
/// sync with the database.
enum UserRole {
  /// Patients and the general "generasi sehat" audience. Every account has it.
  user('user', 'Pengguna'),

  /// Verified doctors offering online consultation.
  doctor('doctor', 'Dokter'),

  /// Hospitals, clinics, PMR and health organisations providing services.
  institution('institution', 'Instansi'),

  /// Business partners (pharmacy, skincare, fashion, gym, ...) that promote
  /// and sell through Primafit.
  partner('partner', 'Mitra'),

  /// Verifies doctors/institutions/partners and curates the knowledge base
  /// used by the recommendation & diagnosis engine.
  superadmin('superadmin', 'Superadmin');

  const UserRole(this.dbValue, this.label);

  final String dbValue;
  final String label;

  /// Roles that require superadmin verification before they are granted.
  bool get requiresVerification => this == doctor || this == institution || this == partner;

  static UserRole? tryParse(String? value) {
    for (final role in values) {
      if (role.dbValue == value) return role;
    }
    return null;
  }
}
