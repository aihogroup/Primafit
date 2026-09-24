import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:primafit/UI/catat/asamurat/input_asamurat.dart';
import 'package:primafit/UI/catat/bmi/input_bmi.dart';
import 'package:primafit/UI/catat/guladarah/input_guladarah.dart';
import 'package:primafit/UI/catat/kolesterol/input_kolesterol.dart';
import 'package:primafit/UI/catat/suhu/input_suhu.dart';
import 'package:primafit/UI/catat/tensi/input_tensi.dart';
import 'package:primafit/UI/diagnosa/kulit/pertanyaan_kulit.dart';
import 'package:primafit/UI/diagnosa/mental/pertanyaan_mental.dart';
import 'package:primafit/UI/diagnosa/paru/pertanyaan_paru.dart';
import 'package:primafit/UI/diagnosa/pencernaan/pertanyaan_pencernaan.dart';
import 'package:primafit/UI/diagnosa/umum/pertanyaan_umum.dart';
import 'package:primafit/UI/kewanitaan/kehamilan/menu_kehamilan.dart';
import 'package:primafit/UI/kewanitaan/menstruasi/menu_menstruasi.dart';
import 'package:primafit/UI/kewanitaan/parenting/growthchart_parenting.dart';
import 'package:primafit/UI/kewanitaan/parenting/menu_parenting.dart';
import 'package:primafit/UI/kewanitaan/parenting/milestone_parenting.dart';
import 'package:primafit/UI/kewanitaan/testpack/menu_testpack.dart';
import 'package:primafit/UI/login/login.dart';
import 'package:primafit/UI/navigasi/analisis/analisis_page.dart';
import 'package:primafit/UI/navigasi/artikel/artikel_page.dart';
import 'package:primafit/UI/navigasi/home/home_page.dart';
import 'package:primafit/UI/navigasi/home/semua_fitur.dart';
import 'package:primafit/UI/navigasi/intro/intro.dart';
import 'package:primafit/UI/navigasi/profile/profile_page.dart';
import 'package:primafit/UI/navigasi/riwayat/diagnosis_histori.dart';
import 'package:primafit/UI/navigasi/riwayat/gejala_page.dart';
import 'package:primafit/UI/navigasi/splash/splash_screen.dart';
import 'package:primafit/UI/pengingat/jadwal/input_agenda.dart';
import 'package:primafit/UI/pengingat/jadwal/jadwal_page.dart';
import 'package:primafit/UI/pengingat/obat/input_obat.dart';
import 'package:primafit/UI/simpan/bpjs/bpjs_page.dart';
import 'package:primafit/UI/simpan/dokumen/dokumen_page.dart';
import 'package:primafit/UI/kanker/hati/pertanyaan_hati.dart';
import 'package:primafit/UI/kanker/paru/pertanyaan_paru.dart';
import 'package:primafit/UI/kanker/payudara/pertanyaan_payudara.dart';
import 'package:primafit/UI/kanker/prostat/pertanyaan_prostat.dart';
import 'package:primafit/UI/kanker/rahim/pertanyaan_rahim.dart';
import 'package:primafit/UI/kanker/usus/pertanyaan_usus.dart';
import 'package:primafit/UI/rekomendasi/makanan/menu_makanan.dart';
import 'package:primafit/UI/rekomendasi/olahraga/menu_olahraga.dart';
import 'package:primafit/UI/rekomendasi/pakaian/menu_pakaian.dart';
import 'package:primafit/UI/skincare/exfoliator/pertanyaan_exfoliator.dart';
import 'package:primafit/UI/skincare/facial/pertanyaan_facialwash.dart';
import 'package:primafit/UI/skincare/jenis_kulit/menu_kulit.dart';
import 'package:primafit/UI/skincare/moisturizer/pertanyaan_moisturizer.dart';
import 'package:primafit/UI/skincare/serum/pertanyaan_serum.dart';
import 'package:primafit/UI/skincare/sunscreen/pertanyaan_sunscreen.dart';
import 'package:primafit/UI/skincare/toner/pertanyaan_toner.dart';
import 'package:primafit/UI/simpan/vaksin/vaksin_page.dart';
import 'package:primafit/UI/temukan/ambulan/ambulan_page.dart';
import 'package:primafit/UI/temukan/apotek/apotek_page.dart';
import 'package:primafit/UI/temukan/hospital/hospital_page.dart';

void main() {
  initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Primafit',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 52, 219, 235)),
      ),
      initialRoute: "/",
      routes: {
        '/milestone': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return MilestoneParentingPage(
            childId: args['childId'],
            childName: args['childName'],
          );
        },
        '/growth': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return GrowthChartPage(
            childId: args['childId'],
            childName: args['childName'],
          );
        },
        "/": (context) => SplashScreen(),
        "/home": (context) => const HomePage(),
        "/intro": (context) => const IntroScreen(),
        "/login": (context) => const LoginPage(),
        "/jadwal": (context) => const JadwalPage(),
        "/analisis": (context) => const AnalysisPage(),
        "/artikel": (context) => const ArticlePage(),
        "/riwayat": (context) => GejalaPage(),
        "/histori": (context) => DiagnosisHistoryPage(),
        "/profile": (context) => ProfilePage(),
        "/kolesterol": (context) => InputKolesterolScreen(),
        "/guladarah": (context) => InputGulaDarahScreen(),
        "/asamurat": (context) => InputAsamUratScreen(),
        "/tensi": (context) => InputTensiScreen(),
        "/bmi": (context) => InputBmiScreen(),
        "/obat": (context) => InputObatScreen(),
        "/agenda": (context) => InputAgendaScreen(),
        "/semua": (context) => SemuaFiturPage(),
        "/bpjs": (context) => BpjsListPage(),
        "/hospital": (context) => HospitalPage(),
        "/vaksin": (context) => VaksinListPage(),
        "/dokumen": (context) => DokumenListPage(),
        "/apotek": (context) => ApotekPage(),
        "/paru": (context) => ParuPage(),
        "/ambulan": (context) => AmbulanPage(),
        "/kulit": (context) => kulitPage(),
        "/pencernaan": (context) => PencernaanPage(),
        "/mental": (context) => MentalPage(),
        "/jeniskulit": (context) => SkinTypeMenuPage(),
        "/umum": (context) => UmumPage(),
        "/kankerparu": (context) => KankerParuPage(),
        "/payudara": (context) => KankerPayudaraPage(),
        "/usus": (context) => KankerUsusPage(),
        "/rahim": (context) => KankerRahimPage(),
        "/hati": (context) => KankerHatiPage(),
        "/prostat": (context) => KankerProstatPage(),
        "/facial": (context) => FacialWashRecommendationPage(),
        "/sunscreen": (context) => SunscreenRecommendationPage(),
        "/serum": (context) => SerumRecommendationPage(),
        "/toner": (context) => TonerRecommendationPage(),
        "/moisturizer": (context) => MoisturizerRecommendationPage(),
        "/exfoliator": (context) => ExfoliatorRecommendationPage(),
        "/makanan": (context) => NutritionMenuPage(),
        "/olahraga": (context) => ExerciseMenuPage(),
        "/pakaian": (context) => FashionMenuPage(),
        "/menstruasi": (context) => MenstrualMenuPage(),
        "/kehamilan": (context) => PregnancyMenuPage(),
        "/testpack": (context) => TestpackOnlinePage(),
        "/suhu": (context) => InputSuhuScreen(),
        "/parenting": (context) => ParentingMenuPage(),
      }
    );
  }
}