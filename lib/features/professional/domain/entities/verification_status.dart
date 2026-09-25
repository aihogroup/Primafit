/// Mirrors Postgres enum `public.verification_status`.
enum VerificationStatus {
  pending('pending', 'Menunggu verifikasi'),
  approved('approved', 'Terverifikasi'),
  rejected('rejected', 'Ditolak'),
  suspended('suspended', 'Ditangguhkan');

  const VerificationStatus(this.dbValue, this.label);

  final String dbValue;
  final String label;

  static VerificationStatus parse(String? value) =>
      values.firstWhere((s) => s.dbValue == value, orElse: () => pending);
}
