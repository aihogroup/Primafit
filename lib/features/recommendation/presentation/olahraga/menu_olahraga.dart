import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primafit/features/recommendation/presentation/olahraga/pertanyaan_olahraga.dart';

class ExerciseMenuPage extends StatelessWidget {
  const ExerciseMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF64D1DE),
        elevation: 0,
        title: Text(
          'Rekomendasi Program Olahraga',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Banner image or illustration
              Container(
                height: 220,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF64D1DE),
                      Color(0xCC64D1DE), // ini 80% opacity
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Semi-transparent patterns
                    Positioned(
                      top: -20,
                      right: -20,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -40,
                      left: -10,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    
                    // Content
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                            child: const Icon(
                              CupertinoIcons.flame,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Program Olahraga Personal',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              'Dapatkan rekomendasi olahraga yang disesuaikan dengan kebutuhan dan kondisi Anda',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white.withValues(alpha: 0.9),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mengapa Rekomendasi Olahraga Penting?',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Feature/benefit items
                    _buildFeatureItem(
                      icon: CupertinoIcons.person_crop_circle_badge_checkmark,
                      title: 'Program yang Dipersonalisasi',
                      description: 'Program olahraga yang dirancang khusus sesuai usia, kondisi kesehatan, dan tingkat kebugaran Anda.'
                    ),
                    _buildFeatureItem(
                      icon: CupertinoIcons.shield_lefthalf_fill,
                      title: 'Aman dan Efektif',
                      description: 'Rekomendasi yang mempertimbangkan riwayat cedera dan kondisi kesehatan untuk meminimalkan risiko.'
                    ),
                    _buildFeatureItem(
                      icon: CupertinoIcons.graph_circle,
                      title: 'Hasil Optimal',
                      description: 'Program dengan intensitas dan frekuensi yang tepat untuk mencapai tujuan kebugaran Anda.'
                    ),
                    _buildFeatureItem(
                      icon: CupertinoIcons.arrow_2_circlepath,
                      title: 'Variasi Latihan',
                      description: 'Kombinasi latihan yang bervariasi untuk menghindari kebosanan dan meningkatkan motivasi.'
                    ),
                    
                    const SizedBox(height: 30),
                    
                    Text(
                      'Fitur Rekomendasi Program Olahraga',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 15),
                    
                    // Feature highlights
                    _buildFeatureItem(
                      icon: CupertinoIcons.calendar_badge_plus,
                      title: 'Jadwal Latihan Lengkap',
                      description: 'Rekomendasi jadwal olahraga mingguan dengan rincian jenis dan durasi aktivitas.'
                    ),
                    _buildFeatureItem(
                      icon: CupertinoIcons.heart_circle,
                      title: 'Analisis Kebutuhan Kardio',
                      description: 'Perhitungan target zona detak jantung dan intensitas ideal sesuai tujuan Anda.'
                    ),
                    _buildFeatureItem(
                      icon: CupertinoIcons.gauge_badge_plus,
                      title: 'Penyesuaian untuk Kondisi Khusus',
                      description: 'Program khusus untuk kondisi seperti masalah jantung, sendi, atau masa kehamilan.'
                    ),
                    _buildFeatureItem(
                      icon: CupertinoIcons.timer,
                      title: 'Waktu Pemulihan Optimal',
                      description: 'Rekomendasi waktu istirahat antar sesi latihan untuk hasil terbaik.'
                    ),
                    
                    const SizedBox(height: 30),
                    
                    Text(
                      'Bagaimana Cara Kerjanya?',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 15),
                    
                    // How it works steps
                    _buildStepItem(
                      number: '1',
                      title: 'Isi Data Diri',
                      description: 'Jawab pertanyaan tentang usia, jenis kelamin, berat badan, dan tingkat aktivitas Anda.'
                    ),
                    _buildStepItem(
                      number: '2',
                      title: 'Tentukan Kebutuhan',
                      description: 'Beritahu kami tujuan olahraga, preferensi aktivitas, dan kondisi kesehatan Anda.'
                    ),
                    _buildStepItem(
                      number: '3',
                      title: 'Dapatkan Rekomendasi',
                      description: 'Terima program olahraga personal dan panduan latihan yang sesuai dengan kebutuhan Anda.'
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Start button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const ExerciseAnalysisPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF64D1DE),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(CupertinoIcons.arrow_right_circle_fill),
                          const SizedBox(width: 10),
                          Text(
                            'Mulai Analisis Kebutuhan',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Disclaimer text
                    Text(
                      'Catatan: Rekomendasi ini bersifat umum dan tidak menggantikan konsultasi dengan ahli olahraga atau dokter. Untuk kondisi kesehatan serius, konsultasi dengan profesional kesehatan dianjurkan sebelum memulai program olahraga baru.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF64D1DE).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF64D1DE),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStepItem({
    required String number,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: Color(0xFF64D1DE),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}