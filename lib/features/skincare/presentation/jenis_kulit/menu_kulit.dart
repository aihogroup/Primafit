import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primafit/features/skincare/presentation/jenis_kulit/pertanyaan_kulit.dart';

class SkinTypeMenuPage extends StatelessWidget {
  const SkinTypeMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF64D1DE),
        elevation: 0,
        title: Text(
          'Analisis Jenis Kulit',
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
                              CupertinoIcons.person_crop_circle,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Analisis Jenis Kulit Wajah',
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
                              'Jawab beberapa pertanyaan untuk mengetahui jenis kulit Anda',
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
                      'Mengapa Analisis Jenis Kulit Penting?',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Feature/benefit items
                    _buildFeatureItem(
                      icon: CupertinoIcons.checkmark_seal,
                      title: 'Skincare yang Tepat',
                      description: 'Mengetahui jenis kulit membantu Anda memilih produk perawatan yang sesuai dengan kebutuhan kulit.'
                    ),
                    _buildFeatureItem(
                      icon: CupertinoIcons.lightbulb,
                      title: 'Menghindari Masalah Kulit',
                      description: 'Produk yang tidak sesuai dengan jenis kulit dapat memicu masalah seperti jerawat, iritasi, atau kekeringan.'
                    ),
                    _buildFeatureItem(
                      icon: CupertinoIcons.graph_circle,
                      title: 'Hasil Optimal',
                      description: 'Dengan mengetahui jenis kulit, rutinitas perawatan menjadi lebih efektif dan memberikan hasil yang lebih baik.'
                    ),
                    _buildFeatureItem(
                      icon: CupertinoIcons.money_dollar_circle,
                      title: 'Hemat Biaya',
                      description: 'Tidak perlu mencoba banyak produk yang mungkin tidak cocok, sehingga lebih hemat waktu dan biaya.'
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
                      description: 'Jawab serangkaian pertanyaan tentang kondisi kulit wajah Anda.'
                    ),
                    _buildStepItem(
                      number: '2',
                      title: 'Analisis Otomatis',
                      description: 'Sistem menganalisis jawaban Anda menggunakan algoritma dermatologis.'
                    ),
                    _buildStepItem(
                      number: '3',
                      title: 'Dapatkan Hasil',
                      description: 'Terima hasil analisis jenis kulit dan rekomendasi perawatan yang sesuai.'
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Start button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const SkinTypeAnalysisPage()),
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
                            'Mulai Analisis Jenis Kulit',
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
                      'Catatan: Analisis ini memberikan perkiraan jenis kulit berdasarkan informasi yang Anda berikan. Untuk masalah kulit yang serius, konsultasi dengan dokter kulit direkomendasikan.',
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
            decoration: BoxDecoration(
              color: const Color(0xFF64D1DE),
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