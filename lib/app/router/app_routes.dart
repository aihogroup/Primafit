import '../../features/auth/domain/entities/user_role.dart';

/// Every named route in the app.
///
/// Values are persisted in SQLite (home feature shortcuts store the route
/// string), so existing paths must never be renamed; add new ones instead.
abstract final class AppRoutes {
  // Public (no session required)
  static const splash = '/';
  static const intro = '/intro';

  // Account (Supabase Auth)
  static const signIn = '/masuk';
  static const signUp = '/daftar';
  static const forgotPassword = '/lupa-kata-sandi';
  static const updatePassword = '/ubah-kata-sandi';

  /// Profile completion form (name, birth date, gender, ...). Kept at the
  /// historical '/login' path for compatibility; it is not a sign-in screen.
  static const profileSetup = '/login';

  // Role dashboards (one per professional role)
  static const doctorDashboard = '/dasbor/dokter';
  static const institutionDashboard = '/dasbor/instansi';
  static const partnerDashboard = '/dasbor/mitra';
  static const adminDashboard = '/dasbor/admin';

  // Professional registration (user applies as doctor / institution / partner)
  static const professionalHub = '/profesional';
  static const doctorRegistration = '/profesional/dokter';
  static const organizationRegistration = '/profesional/organisasi';

  // Superadmin verification
  static const verificationQueue = '/admin/verifikasi';
  static const verificationDetail = '/admin/verifikasi/detail';

  // Shell / bottom navigation
  static const home = '/home';
  static const schedule = '/jadwal';
  static const analytics = '/analisis';
  static const articles = '/artikel';
  static const symptomHistory = '/riwayat';
  static const diagnosisHistory = '/histori';
  static const profile = '/profile';
  static const allFeatures = '/semua';

  // Health records
  static const cholesterol = '/kolesterol';
  static const bloodSugar = '/guladarah';
  static const uricAcid = '/asamurat';
  static const bloodPressure = '/tensi';
  static const bmi = '/bmi';
  static const bodyTemperature = '/suhu';

  // Reminders
  static const medicineInput = '/obat';
  static const agendaInput = '/agenda';

  // Health wallet
  static const bpjs = '/bpjs';
  static const vaccines = '/vaksin';
  static const documents = '/dokumen';

  // Nearby
  static const hospitals = '/hospital';
  static const pharmacies = '/apotek';
  static const ambulance = '/ambulan';

  // Diagnosis
  static const diagnosisLung = '/paru';
  static const diagnosisSkin = '/kulit';
  static const diagnosisDigestive = '/pencernaan';
  static const diagnosisMental = '/mental';
  static const diagnosisGeneral = '/umum';

  // Cancer screening
  static const cancerLung = '/kankerparu';
  static const cancerBreast = '/payudara';
  static const cancerColon = '/usus';
  static const cancerCervical = '/rahim';
  static const cancerLiver = '/hati';
  static const cancerProstate = '/prostat';

  // Skincare
  static const skinType = '/jeniskulit';
  static const facialWash = '/facial';
  static const sunscreen = '/sunscreen';
  static const serum = '/serum';
  static const toner = '/toner';
  static const moisturizer = '/moisturizer';
  static const exfoliator = '/exfoliator';

  // Recommendations
  static const nutrition = '/makanan';
  static const exercise = '/olahraga';
  static const fashion = '/pakaian';

  // Women & family health
  static const menstruation = '/menstruasi';
  static const pregnancy = '/kehamilan';
  static const testpack = '/testpack';
  static const parenting = '/parenting';
  static const parentingMilestone = '/milestone';
  static const parentingGrowth = '/growth';

  /// Landing screen of each role's shell.
  static String homeFor(UserRole role) => switch (role) {
    UserRole.user => home,
    UserRole.doctor => doctorDashboard,
    UserRole.institution => institutionDashboard,
    UserRole.partner => partnerDashboard,
    UserRole.superadmin => adminDashboard,
  };
}
