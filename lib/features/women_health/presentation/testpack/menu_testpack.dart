import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primafit/features/women_health/presentation/testpack/pertanyaan_testpack.dart'; // Sesuaikan dengan path file pertanyaan kehamilan Anda

class TestpackOnlinePage extends StatelessWidget {
  const TestpackOnlinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE9458D), // Warna biru muda untuk testpack kehamilan
        elevation: 0,
        title: Text(
          'Testpack Kehamilan Online',
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
                      Color(0xFFE9458D),
                      Color(0xCCE9458D), // ini 80% opacity
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
                              CupertinoIcons.checkmark_shield,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Testpack Online',
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
                              'Cek kemungkinan kehamilan berdasarkan gejala yang dialami',
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
                      'Mengapa Menggunakan Testpack Online?',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Feature/benefit items
                    _buildFeatureItem(
                      icon: CupertinoIcons.lock_shield,
                      title: 'Privasi Terjaga',
                      description: 'Lakukan pengecekan awal kehamilan dengan nyaman dari rumah tanpa perlu pergi ke apotek.'
                    ),
                    _buildFeatureItem(
                      icon: CupertinoIcons.time,
                      title: 'Hasil Cepat',
                      description: 'Dapatkan hasil analisis kemungkinan kehamilan dalam hitungan menit.'
                    ),
                    _buildFeatureItem(
                      icon: CupertinoIcons.doc_text_search,
                      title: 'Analisis Menyeluruh',
                      description: 'Analisis berdasarkan 11 gejala umum kehamilan dengan bobot yang berbeda.'
                    ),
                    _buildFeatureItem(
                      icon: CupertinoIcons.info_circle_fill,
                      title: 'Informasi Akurat',
                      description: 'Dapatkan rekomendasi langkah selanjutnya berdasarkan hasil analisis.'
                    ),
                    
                    const SizedBox(height: 30),
                    
                    Text(
                      'Keunggulan Testpack Online',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 15),
                    
                    // Feature highlights
                    _buildFeatureItem(
                      icon: CupertinoIcons.checkmark_circle,
                      title: 'Tingkat Akurasi Tinggi',
                      description: 'Analisis komprehensif berdasarkan kombinasi berbagai gejala kehamilan.'
                    ),
                    _buildFeatureItem(
                      icon: CupertinoIcons.doc_person,
                      title: 'Personalisasi',
                      description: 'Hasil analisis disesuaikan dengan jawaban Anda terhadap setiap pertanyaan.'
                    ),
                    _buildFeatureItem(
                      icon: CupertinoIcons.share,
                      title: 'Berbagi Hasil',
                      description: 'Mudah berbagi hasil dengan pasangan atau dokter dalam format PDF.'
                    ),
                    _buildFeatureItem(
                      icon: CupertinoIcons.device_phone_portrait,
                      title: 'Kapan Saja, Dimana Saja',
                      description: 'Akses kapan saja dan dimana saja melalui smartphone Anda.'
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
                      title: 'Jawab Pertanyaan',
                      description: 'Jawab 11 pertanyaan singkat tentang gejala yang Anda alami dengan pilihan Ya, Tidak, atau Mungkin.'
                    ),
                    _buildStepItem(
                      number: '2',
                      title: 'Proses Analisis',
                      description: 'Sistem akan menganalisis jawaban Anda berdasarkan bobot dan keterkaitan gejala.'
                    ),
                    _buildStepItem(
                      number: '3',
                      title: 'Dapatkan Hasil',
                      description: 'Lihat persentase kemungkinan kehamilan beserta rekomendasi tindakan selanjutnya.'
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Start button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const KehamilanPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE9458D),
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
                            'Mulai Testpack Online',
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
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            CupertinoIcons.exclamationmark_triangle,
                            color: Colors.blue.shade800,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'CATATAN PENTING: Testpack online ini hanya untuk perkiraan awal dan tidak menggantikan tes kehamilan resmi atau konsultasi medis. Hasil positif harus dikonfirmasi dengan tes kehamilan konvensional dan pemeriksaan oleh dokter atau bidan.',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.blue.shade900,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
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
              color: const Color(0xFFE9458D).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFE9458D),
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
              color: Color(0xFFE9458D),
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