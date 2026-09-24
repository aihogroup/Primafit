import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primafit/features/recommendation/presentation/pakaian/pertanyaan_pakaian.dart';

class FashionMenuPage extends StatelessWidget {
  const FashionMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF64D1DE), // Warna ungu lavender
        elevation: 0,
        title: Text(
          'Rekomendasi Fashion',
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
                      Color(0xFF64D1DE), // Warna ungu lavender
                      Color(0xCC64D1DE), // 80% opacity
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
                              CupertinoIcons.person_crop_circle_badge_checkmark,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Rekomendasi Fashion',
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
                              'Temukan gaya fashion yang sesuai untuk berbagai acara dan preferensi personal Anda',
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
                      'Mengapa Rekomendasi Fashion Penting?',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Feature/benefit items
                    _buildFeatureItem(
                      icon: CupertinoIcons.device_phone_portrait,
                      title: 'Personalisasi Gaya',
                      description: 'Rekomendasi fashion yang disesuaikan dengan preferensi, warna, dan jenis acara yang Anda hadiri.'
                    ),
                    _buildFeatureItem(
                      icon: CupertinoIcons.person_2_fill,
                      title: 'Kepercayaan Diri',
                      description: 'Tampil dengan pakaian yang cocok membuat Anda merasa lebih percaya diri dan nyaman.'
                    ),
                    _buildFeatureItem(
                      icon: CupertinoIcons.clock,
                      title: 'Hemat Waktu',
                      description: 'Tidak perlu bingung memilih pakaian, dapatkan inspirasi outfit lengkap dalam sekejap.'
                    ),
                    _buildFeatureItem(
                      icon: CupertinoIcons.money_dollar_circle_fill,
                      title: 'Smart Shopping',
                      description: 'Panduan untuk berbelanja item yang tepat dan membangun wardrobe yang versatile.'
                    ),
                    
                    const SizedBox(height: 30),
                    
                    Text(
                      'Fitur Rekomendasi Fashion',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 15),
                    
                    // Feature highlights
                    _buildFeatureItem(
                      icon: CupertinoIcons.suit_spade_fill,
                      title: 'Rekomendasi Berdasarkan Acara',
                      description: 'Dapatkan saran pakaian yang sesuai untuk acara formal, casual, atau semi-formal.'
                    ),
                    _buildFeatureItem(
                      icon: CupertinoIcons.color_filter_fill,
                      title: 'Analisis Palette Warna',
                      description: 'Temukan kombinasi warna yang cocok dengan preferensi dan tone kulit Anda.'
                    ),
                    _buildFeatureItem(
                      icon: CupertinoIcons.person_crop_rectangle_fill,
                      title: 'Tips Berdasarkan Bentuk Tubuh',
                      description: 'Pilihan potongan dan style yang paling flattering untuk tipe tubuh Anda.'
                    ),
                    _buildFeatureItem(
                      icon: CupertinoIcons.layers_alt_fill,
                      title: 'Outfit Lengkap',
                      description: 'Rekomendasi dari atas sampai bawah termasuk aksesoris dan sepatu.'
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
                      title: 'Jawab Pertanyaan Fashion',
                      description: 'Beri tahu kami tentang acara, preferensi warna, gaya, dan karakteristik personal Anda.'
                    ),
                    _buildStepItem(
                      number: '2',
                      title: 'Analisis Preferensi',
                      description: 'Sistem kami menganalisis jawaban untuk membuat rekomendasi yang dipersonalisasi.'
                    ),
                    _buildStepItem(
                      number: '3',
                      title: 'Terima Rekomendasi',
                      description: 'Dapatkan saran outfit lengkap dengan tips styling yang sesuai untuk Anda.'
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Start button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const FashionAnalysisPage()),
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
                            'Mulai Analisis Fashion',
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
                      'Catatan: Rekomendasi ini bersifat umum dan dapat disesuaikan dengan preferensi personal Anda. Tips fashion bertujuan untuk inspirasi dan bisa dimodifikasi sesuai kebutuhan.',
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