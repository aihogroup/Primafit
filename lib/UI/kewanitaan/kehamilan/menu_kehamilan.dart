import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primafit/UI/kewanitaan/kehamilan/beranda_kehamilan.dart';

class PregnancyMenuPage extends StatelessWidget {
  const PregnancyMenuPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE9458D), // Warna biru untuk kehamilan
        elevation: 0,
        title: Text(
          'Pemantauan Kehamilan',
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
                          color: Colors.white.withOpacity(0.1),
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
                          color: Colors.white.withOpacity(0.1),
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
                              color: Colors.white.withOpacity(0.2),
                            ),
                            child: const Icon(
                              CupertinoIcons.heart,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Pemantauan Kehamilan',
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
                              'Pantau perkembangan kehamilan, catat gejala, dan dapatkan informasi penting',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.9),
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
                      'Mengapa Memantau Kehamilan Penting?',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Feature/benefit items
                    _buildFeatureItem(
                      icon: CupertinoIcons.calendar_today,
                      title: 'Pemantauan Perkembangan',
                      description: 'Pantau pertumbuhan bayi dan perubahan tubuh ibu dari minggu ke minggu.'
                    ),
                    _buildFeatureItem(
                      icon: CupertinoIcons.doc_text,
                      title: 'Pencatatan Kesehatan',
                      description: 'Catat hasil pemeriksaan, gejala, dan informasi penting lainnya selama kehamilan.'
                    ),
                    _buildFeatureItem(
                      icon: CupertinoIcons.bell_fill,
                      title: 'Pengingat Pemeriksaan',
                      description: 'Dapatkan pengingat untuk jadwal pemeriksaan, tes penting, dan skrining kehamilan.'
                    ),
                    _buildFeatureItem(
                      icon: CupertinoIcons.chart_bar_alt_fill,
                      title: 'Statistik dan Tren',
                      description: 'Lihat tren berat badan, gejala, dan kesehatan selama kehamilan.'
                    ),
                    
                    const SizedBox(height: 30),
                    
                    Text(
                      'Fitur Pemantauan Kehamilan',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 15),
                    
                    // Feature highlights
                    _buildFeatureItem(
                      icon: CupertinoIcons.arrow_right_arrow_left_circle,
                      title: 'Kalender Kehamilan',
                      description: 'Lihat tanggal penting, jadwal pemeriksaan, dan kondisi kehamilan mingguan.'
                    ),
                    _buildFeatureItem(
                      icon: CupertinoIcons.photo,
                      title: 'Informasi Perkembangan Janin',
                      description: 'Dapatkan informasi tentang ukuran, berat, dan perkembangan organ janin setiap minggu.'
                    ),
                    _buildFeatureItem(
                      icon: CupertinoIcons.bandage,
                      title: 'Pencatatan Gejala',
                      description: 'Rekam gejala kehamilan untuk diskusi dengan dokter atau bidan Anda.'
                    ),
                    _buildFeatureItem(
                      icon: CupertinoIcons.heart_fill,
                      title: 'Penghitung Tendangan Bayi',
                      description: 'Pantau gerakan bayi untuk memastikan kesejahteraannya.'
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
                      title: 'Masukkan Tanggal HPHT',
                      description: 'Masukkan tanggal hari pertama haid terakhir untuk menghitung perkiraan tanggal kelahiran dan usia kehamilan.'
                    ),
                    _buildStepItem(
                      number: '2',
                      title: 'Catat Perkembangan',
                      description: 'Secara rutin catat berat badan, hasil pemeriksaan, dan gejala yang dialami.'
                    ),
                    _buildStepItem(
                      number: '3',
                      title: 'Dapatkan Informasi',
                      description: 'Dapatkan informasi perkembangan janin dan tips kehamilan berdasarkan usia kehamilan Anda.'
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Start button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const PregnancyTrackerHomePage()),
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
                            'Mulai Pantau Kehamilan',
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
                      'Catatan: Aplikasi ini untuk membantu pemantauan dan bukan pengganti konsultasi medis. Selalu konsultasikan dengan dokter atau bidan untuk keputusan medis terkait kehamilan Anda.',
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
              color: const Color(0xFFE9458D).withOpacity(0.1),
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