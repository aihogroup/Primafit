import 'package:flutter/material.dart';

import '../../features/analytics/presentation/analisis_page.dart';
import '../../features/article/presentation/artikel_page.dart';
import '../../features/cancer_screening/presentation/hati/pertanyaan_hati.dart';
import '../../features/cancer_screening/presentation/paru/pertanyaan_paru.dart';
import '../../features/cancer_screening/presentation/payudara/pertanyaan_payudara.dart';
import '../../features/cancer_screening/presentation/prostat/pertanyaan_prostat.dart';
import '../../features/cancer_screening/presentation/rahim/pertanyaan_rahim.dart';
import '../../features/cancer_screening/presentation/usus/pertanyaan_usus.dart';
import '../../features/diagnosis/presentation/kulit/pertanyaan_kulit.dart';
import '../../features/diagnosis/presentation/mental/pertanyaan_mental.dart';
import '../../features/diagnosis/presentation/paru/pertanyaan_paru.dart';
import '../../features/diagnosis/presentation/pencernaan/pertanyaan_pencernaan.dart';
import '../../features/diagnosis/presentation/umum/pertanyaan_umum.dart';
import '../../features/health_record/presentation/asamurat/input_asamurat.dart';
import '../../features/health_record/presentation/bmi/input_bmi.dart';
import '../../features/health_record/presentation/guladarah/input_guladarah.dart';
import '../../features/health_record/presentation/kolesterol/input_kolesterol.dart';
import '../../features/health_record/presentation/suhu/input_suhu.dart';
import '../../features/health_record/presentation/tensi/input_tensi.dart';
import '../../features/health_wallet/presentation/bpjs/bpjs_page.dart';
import '../../features/health_wallet/presentation/dokumen/dokumen_page.dart';
import '../../features/health_wallet/presentation/vaksin/vaksin_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/home/presentation/semua_fitur.dart';
import '../../features/nearby/presentation/ambulan/ambulan_page.dart';
import '../../features/nearby/presentation/apotek/apotek_page.dart';
import '../../features/nearby/presentation/hospital/hospital_page.dart';
import '../../features/onboarding/presentation/intro.dart';
import '../../features/onboarding/presentation/login.dart';
import '../../features/onboarding/presentation/splash_screen.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/recommendation/presentation/makanan/menu_makanan.dart';
import '../../features/recommendation/presentation/olahraga/menu_olahraga.dart';
import '../../features/recommendation/presentation/pakaian/menu_pakaian.dart';
import '../../features/reminder/presentation/jadwal/input_agenda.dart';
import '../../features/reminder/presentation/jadwal/jadwal_page.dart';
import '../../features/reminder/presentation/obat/input_obat.dart';
import '../../features/skincare/presentation/exfoliator/pertanyaan_exfoliator.dart';
import '../../features/skincare/presentation/facial/pertanyaan_facialwash.dart';
import '../../features/skincare/presentation/jenis_kulit/menu_kulit.dart';
import '../../features/skincare/presentation/moisturizer/pertanyaan_moisturizer.dart';
import '../../features/skincare/presentation/serum/pertanyaan_serum.dart';
import '../../features/skincare/presentation/sunscreen/pertanyaan_sunscreen.dart';
import '../../features/skincare/presentation/toner/pertanyaan_toner.dart';
import '../../features/symptom_history/presentation/diagnosis_histori.dart';
import '../../features/symptom_history/presentation/gejala_page.dart';
import '../../features/women_health/presentation/kehamilan/menu_kehamilan.dart';
import '../../features/women_health/presentation/menstruasi/menu_menstruasi.dart';
import '../../features/women_health/presentation/parenting/growthchart_parenting.dart';
import '../../features/women_health/presentation/parenting/menu_parenting.dart';
import '../../features/women_health/presentation/parenting/milestone_parenting.dart';
import '../../features/women_health/presentation/testpack/menu_testpack.dart';

import '../../core/widgets/state_views.dart';
import '../../features/auth/domain/entities/user_role.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/sign_in_page.dart';
import '../../features/auth/presentation/pages/sign_up_page.dart';
import '../../features/auth/presentation/pages/update_password_page.dart';
import '../../features/auth/presentation/widgets/role_guard.dart';
import 'app_routes.dart';

/// Route table + access control.
///
/// Each entry declares which roles may open it; `null` means public (no
/// session needed). Role-specific shells (doctor, institution, partner,
/// superadmin) register here with their own role sets as they are built.
abstract final class AppRouter {
  static const Set<UserRole> _anyUser = {UserRole.user};

  static final Map<String, ({WidgetBuilder builder, Set<UserRole>? roles})> _routes = {
    // Public
    AppRoutes.splash: (builder: (_) => const SplashScreen(), roles: null),
    AppRoutes.intro: (builder: (_) => const IntroScreen(), roles: null),
    AppRoutes.profileSetup: (builder: (_) => const LoginPage(), roles: null),

    // Account (Supabase Auth)
    AppRoutes.signIn: (builder: (_) => const SignInPage(), roles: null),
    AppRoutes.signUp: (builder: (_) => const SignUpPage(), roles: null),
    AppRoutes.forgotPassword: (builder: (_) => const ForgotPasswordPage(), roles: null),
    AppRoutes.updatePassword: (builder: (_) => const UpdatePasswordPage(), roles: _anyUser),

    // Shell
    AppRoutes.home: (builder: (_) => const HomePage(), roles: _anyUser),
    AppRoutes.schedule: (builder: (_) => const JadwalPage(), roles: _anyUser),
    AppRoutes.analytics: (builder: (_) => const AnalysisPage(), roles: _anyUser),
    AppRoutes.articles: (builder: (_) => const ArticlePage(), roles: _anyUser),
    AppRoutes.symptomHistory: (builder: (_) => const GejalaPage(), roles: _anyUser),
    AppRoutes.diagnosisHistory: (builder: (_) => const DiagnosisHistoryPage(), roles: _anyUser),
    AppRoutes.profile: (builder: (_) => const ProfilePage(), roles: _anyUser),
    AppRoutes.allFeatures: (builder: (_) => const SemuaFiturPage(), roles: _anyUser),

    // Health records
    AppRoutes.cholesterol: (builder: (_) => const InputKolesterolScreen(), roles: _anyUser),
    AppRoutes.bloodSugar: (builder: (_) => const InputGulaDarahScreen(), roles: _anyUser),
    AppRoutes.uricAcid: (builder: (_) => const InputAsamUratScreen(), roles: _anyUser),
    AppRoutes.bloodPressure: (builder: (_) => const InputTensiScreen(), roles: _anyUser),
    AppRoutes.bmi: (builder: (_) => const InputBmiScreen(), roles: _anyUser),
    AppRoutes.bodyTemperature: (builder: (_) => const InputSuhuScreen(), roles: _anyUser),

    // Reminders
    AppRoutes.medicineInput: (builder: (_) => const InputObatScreen(), roles: _anyUser),
    AppRoutes.agendaInput: (builder: (_) => const InputAgendaScreen(), roles: _anyUser),

    // Health wallet
    AppRoutes.bpjs: (builder: (_) => const BpjsListPage(), roles: _anyUser),
    AppRoutes.vaccines: (builder: (_) => const VaksinListPage(), roles: _anyUser),
    AppRoutes.documents: (builder: (_) => const DokumenListPage(), roles: _anyUser),

    // Nearby
    AppRoutes.hospitals: (builder: (_) => const HospitalPage(), roles: _anyUser),
    AppRoutes.pharmacies: (builder: (_) => const ApotekPage(), roles: _anyUser),
    AppRoutes.ambulance: (builder: (_) => const AmbulanPage(), roles: _anyUser),

    // Diagnosis
    AppRoutes.diagnosisLung: (builder: (_) => const ParuPage(), roles: _anyUser),
    AppRoutes.diagnosisSkin: (builder: (_) => const kulitPage(), roles: _anyUser),
    AppRoutes.diagnosisDigestive: (builder: (_) => const PencernaanPage(), roles: _anyUser),
    AppRoutes.diagnosisMental: (builder: (_) => const MentalPage(), roles: _anyUser),
    AppRoutes.diagnosisGeneral: (builder: (_) => const UmumPage(), roles: _anyUser),

    // Cancer screening
    AppRoutes.cancerLung: (builder: (_) => const KankerParuPage(), roles: _anyUser),
    AppRoutes.cancerBreast: (builder: (_) => const KankerPayudaraPage(), roles: _anyUser),
    AppRoutes.cancerColon: (builder: (_) => const KankerUsusPage(), roles: _anyUser),
    AppRoutes.cancerCervical: (builder: (_) => const KankerRahimPage(), roles: _anyUser),
    AppRoutes.cancerLiver: (builder: (_) => const KankerHatiPage(), roles: _anyUser),
    AppRoutes.cancerProstate: (builder: (_) => const KankerProstatPage(), roles: _anyUser),

    // Skincare
    AppRoutes.skinType: (builder: (_) => const SkinTypeMenuPage(), roles: _anyUser),
    AppRoutes.facialWash: (builder: (_) => const FacialWashRecommendationPage(), roles: _anyUser),
    AppRoutes.sunscreen: (builder: (_) => const SunscreenRecommendationPage(), roles: _anyUser),
    AppRoutes.serum: (builder: (_) => const SerumRecommendationPage(), roles: _anyUser),
    AppRoutes.toner: (builder: (_) => const TonerRecommendationPage(), roles: _anyUser),
    AppRoutes.moisturizer: (builder: (_) => const MoisturizerRecommendationPage(), roles: _anyUser),
    AppRoutes.exfoliator: (builder: (_) => const ExfoliatorRecommendationPage(), roles: _anyUser),

    // Recommendations
    AppRoutes.nutrition: (builder: (_) => const NutritionMenuPage(), roles: _anyUser),
    AppRoutes.exercise: (builder: (_) => const ExerciseMenuPage(), roles: _anyUser),
    AppRoutes.fashion: (builder: (_) => const FashionMenuPage(), roles: _anyUser),

    // Women & family health
    AppRoutes.menstruation: (builder: (_) => const MenstrualMenuPage(), roles: _anyUser),
    AppRoutes.pregnancy: (builder: (_) => const PregnancyMenuPage(), roles: _anyUser),
    AppRoutes.testpack: (builder: (_) => const TestpackOnlinePage(), roles: _anyUser),
    AppRoutes.parenting: (builder: (_) => const ParentingMenuPage(), roles: _anyUser),
    AppRoutes.parentingMilestone: (
      builder: (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map;
        return MilestoneParentingPage(childId: args['childId'], childName: args['childName']);
      },
      roles: _anyUser,
    ),
    AppRoutes.parentingGrowth: (
      builder: (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map;
        return GrowthChartPage(childId: args['childId'], childName: args['childName']);
      },
      roles: _anyUser,
    ),
  };

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final spec = _routes[settings.name];
    if (spec == null) return onUnknownRoute(settings);

    return MaterialPageRoute<dynamic>(
      settings: settings,
      builder: (context) {
        final page = spec.builder(context);
        final roles = spec.roles;
        return roles == null ? page : RoleGuard(allowed: roles, child: page);
      },
    );
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute<dynamic>(
      settings: settings,
      builder: (_) => Scaffold(
        appBar: AppBar(),
        body: const AppEmptyView(
          icon: Icons.explore_off_outlined,
          title: 'Halaman tidak ditemukan',
          message: 'Halaman yang Anda tuju tidak tersedia.',
        ),
      ),
    );
  }
}
