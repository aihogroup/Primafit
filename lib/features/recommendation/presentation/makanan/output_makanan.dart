import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:primafit/features/recommendation/data/database_makanan.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class NutritionCategories {
  // Map untuk informasi tambahan setiap kategori nutrisi
  static final Map<String, Map<String, dynamic>> categoryInfo = {
    'dewasa_aktif': {
      'title': 'Dewasa Aktif',
      'description': 'Rekomendasi nutrisi dan menu untuk dewasa usia 19-50 tahun dengan aktivitas fisik sedang hingga tinggi.',
      'icon': 'flame',
      'color': Colors.orange,
      'karakteristik': [
        'Kebutuhan kalori relatif tinggi untuk mendukung aktivitas',
        'Fokus pada protein untuk pemulihan otot',
        'Karbohidrat kompleks untuk energi berkelanjutan',
        'Distribusi nutrisi yang seimbang',
        'Waktu makan disesuaikan dengan jadwal aktivitas'
      ],
      'fokus_nutrisi': [
        'Protein 1.2-2.0g per kg berat badan',
        'Karbohidrat 3-7g per kg berat badan',
        'Lemak sehat 20-35% dari total kalori',
        'Antioksidan untuk pemulihan',
        'Elektrolit untuk hidrasi optimal'
      ],
    },
    'dewasa_senior': {
      'title': 'Dewasa Senior',
      'description': 'Rekomendasi nutrisi dan menu untuk dewasa usia 65+ tahun dengan fokus pada kebutuhan nutrisi lansia.',
      'icon': 'person_crop_circle',
      'color': Colors.blue,
      'karakteristik': [
        'Kebutuhan kalori lebih rendah namun nutrisi lebih padat',
        'Fokus pada protein untuk mencegah kehilangan massa otot',
        'Kalsium dan vitamin D untuk kesehatan tulang',
        'Serat tinggi untuk kesehatan pencernaan',
        'Tekstur makanan yang mudah dikunyah dan dicerna'
      ],
      'fokus_nutrisi': [
        'Protein 1.0-1.5g per kg berat badan',
        'Kalsium 1200mg per hari',
        'Vitamin D 800-1000 IU per hari',
        'Vitamin B12 dari sumber fortifikasi',
        'Serat 21-30g per hari'
      ],
    },
    'anak_sekolah': {
      'title': 'Anak Usia Sekolah',
      'description': 'Rekomendasi nutrisi dan menu untuk anak usia 6-12 tahun dengan fokus pada pertumbuhan dan perkembangan optimal.',
      'icon': 'person_crop_circle_badge_plus',
      'color': Colors.green,
      'karakteristik': [
        'Kebutuhan nutrisi untuk mendukung pertumbuhan',
        'Makanan bernutrisi padat untuk energi aktivitas',
        'Pilihan makanan yang menarik dan bervariasi',
        'Jadwal makan teratur untuk kebiasaan sehat',
        'Membatasi makanan olahan dan tinggi gula'
      ],
      'fokus_nutrisi': [
        'Kalsium untuk pertumbuhan tulang',
        'Zat besi untuk perkembangan kognitif',
        'Protein untuk pertumbuhan',
        'Omega-3 untuk perkembangan otak',
        'Serat untuk kesehatan pencernaan'
      ],
    },
    'remaja': {
      'title': 'Remaja',
      'description': 'Rekomendasi nutrisi dan menu untuk remaja usia 13-18 tahun dengan fokus pada kebutuhan masa pubertas dan pertumbuhan cepat.',
      'icon': 'person_2',
      'color': Colors.purple,
      'karakteristik': [
        'Kebutuhan kalori tinggi untuk pertumbuhan cepat',
        'Protein untuk perkembangan massa otot',
        'Kalsium dan vitamin D untuk pembentukan tulang',
        'Zat besi (terutama untuk remaja putri)',
        'Makanan yang praktis dan sesuai gaya hidup aktif'
      ],
      'fokus_nutrisi': [
        'Kalsium 1300mg per hari',
        'Zat besi 15mg untuk putri, 11mg untuk putra',
        'Protein 0.85g per kg berat badan',
        'Zinc untuk perkembangan hormonal',
        'Vitamin D untuk kesehatan tulang'
      ],
    },
    'hamil_trimester1': {
      'title': 'Ibu Hamil (Trimester 1)',
      'description': 'Rekomendasi nutrisi dan menu untuk ibu hamil trimester pertama dengan fokus pada nutrisi penting untuk perkembangan janin awal.',
      'icon': 'heart_circle',
      'color': Colors.pink,
      'karakteristik': [
        'Fokus pada kualitas makanan, bukan kuantitas',
        'Makanan pencegah mual dan morning sickness',
        'Sumber asam folat dan vitamin penting',
        'Porsi kecil tapi sering',
        'Hindari makanan mentah atau tidak aman'
      ],
      'fokus_nutrisi': [
        'Folat/asam folat 600-800mcg per hari',
        'Zat besi untuk mencegah anemia',
        'B6 untuk mengurangi mual',
        'Kalsium untuk perkembangan tulang janin',
        'Protein tambahan 10g per hari'
      ],
    },
    'diabetes': {
      'title': 'Diabetes',
      'description': 'Rekomendasi nutrisi dan menu untuk penderita diabetes tipe 2 dengan fokus pada stabilitas gula darah.',
      'icon': 'gauge',
      'color': Colors.teal,
      'karakteristik': [
        'Karbohidrat kompleks berserat tinggi',
        'Distribusi karbohidrat merata sepanjang hari',
        'Protein tanpa lemak jenuh',
        'Lemak sehat untuk kesehatan kardiovaskular',
        'Porsi terkontrol dan terukur'
      ],
      'fokus_nutrisi': [
        'Serat larut untuk memperlambat penyerapan gula',
        'Protein tanpa lemak jenuh',
        'Lemak sehat dari ikan, kacang, dan minyak zaitun',
        'Magnesium untuk sensitivitas insulin',
        'Chromium untuk metabolisme glukosa'
      ],
    },
  };
}

class OutputPageNutrition extends StatefulWidget {
  const OutputPageNutrition({super.key});

  @override
  _OutputPageNutritionState createState() => _OutputPageNutritionState();
}

class _OutputPageNutritionState extends State<OutputPageNutrition> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  late Animation<double> _fadeAnimation;
  
  Map<String, dynamic>? _analysisResult;
  Map<String, dynamic>? _recommendationData;
  bool _isLoading = true;
  bool _noResults = false;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );
    
    _loadAnalysisResults();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Fungsi untuk membuat PDF hasil analisis
  Future<File> _generatePDF() async {
    final pdf = pw.Document();
    
    // Tambahkan halaman ke PDF
    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'REKOMENDASI MENU MAKAN SEHAT',
                  style: pw.TextStyle(
                    fontSize: 18, 
                    fontWeight: pw.FontWeight.bold
                  ),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Tanggal: ${DateFormat('dd MMMM yyyy, HH:mm').format(DateTime.now())}'),
              pw.SizedBox(height: 20),
              pw.Text(
                'Hasil Analisis Kebutuhan:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 5),
              if (_analysisResult != null)
                pw.Text(
                  'Kategori: ${_getCategoryTitle(_analysisResult!['analysis']['main_category'])}',
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
              pw.SizedBox(height: 5),
              if (_analysisResult != null)
                pw.Text(
                  'Kebutuhan Kalori: ${_analysisResult!['analysis']['recommended_calories'].toStringAsFixed(0)} kkal/hari',
                ),
              pw.SizedBox(height: 5),
              if (_analysisResult != null)
                pw.Text(
                  'Protein: ${_analysisResult!['analysis']['recommended_protein'].toStringAsFixed(0)}g | Karbohidrat: ${_analysisResult!['analysis']['recommended_carbs'].toStringAsFixed(0)}g | Lemak: ${_analysisResult!['analysis']['recommended_fat'].toStringAsFixed(0)}g',
                ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Rekomendasi Menu:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              
              // Rekomendasi menu
              if (_recommendationData != null)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Sarapan:'),
                    pw.Text(_recommendationData!['breakfast_options'] ?? ''),
                    pw.SizedBox(height: 5),
                    pw.Text('Makan Siang:'),
                    pw.Text(_recommendationData!['lunch_options'] ?? ''),
                    pw.SizedBox(height: 5),
                    pw.Text('Makan Malam:'),
                    pw.Text(_recommendationData!['dinner_options'] ?? ''),
                    pw.SizedBox(height: 5),
                    pw.Text('Makanan Ringan:'),
                    pw.Text(_recommendationData!['snack_options'] ?? ''),
                    pw.SizedBox(height: 5),
                    pw.Text('Tips Nutrisi:'),
                    pw.Text(_recommendationData!['nutritional_focus'] ?? ''),
                  ],
                ),
              
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Text(
                'Catatan Penting:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'Rekomendasi menu ini berdasarkan informasi yang Anda berikan. Konsistensi dalam pola makan sehat dan gaya hidup aktif adalah kunci untuk kesehatan optimal. Jika memiliki kondisi kesehatan khusus, konsultasikan dengan dokter atau ahli gizi.',
                style: pw.TextStyle(
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ],
          );
        },
      ),
    );
    
    // Simpan PDF
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/rekomendasi_menu_sehat.pdf');
    await file.writeAsBytes(await pdf.save());
    
    return file;
  }

  // Bagikan hasil rekomendasi
  Future<void> _shareResults() async {
    try {
      final pdfFile = await _generatePDF();
      
      await Share.shareXFiles(
        [XFile(pdfFile.path)],
        text: 'Rekomendasi Menu Makan Sehat Untukmu',
        subject: 'Rekomendasi Menu - ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal membagikan hasil rekomendasi: $e',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadAnalysisResults() async {
    try {
      final result = await DatabaseHelperNutrition.instance.getLatestAnalysisResult();
      
      if (!mounted) return;
      
      setState(() {
        _analysisResult = result;
        if (result != null) {
          _recommendationData = result['recommendation'];
        }
        _isLoading = false;
        _noResults = result == null;
      });
      
      if (result != null) {
        _animationController.forward();
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
        _noResults = true;
      });
      debugPrint('Error loading analysis results: $e');
    }
  }

  String _getCategoryTitle(String category) {
    return NutritionCategories.categoryInfo[category]?['title'] ?? 'Dewasa Aktif';
  }

  Color _getCategoryColor(String category) {
    return NutritionCategories.categoryInfo[category]?['color'] ?? const Color(0xFF64D1DE);
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'flame':
        return CupertinoIcons.flame_fill;
      case 'person_crop_circle':
        return CupertinoIcons.person_crop_circle_fill;
      case 'person_crop_circle_badge_plus':
        return CupertinoIcons.person;
      case 'person_2':
        return CupertinoIcons.person_2_fill;
      case 'heart_circle':
        return CupertinoIcons.heart_circle_fill;
      case 'gauge':
        return CupertinoIcons.gauge_badge_plus;
      default:
        return CupertinoIcons.circle_grid_3x3_fill;
    }
  }
  
  Widget _buildCalorieProgressCircle(double calories, String category) {
    final Color progressColor = _getCategoryColor(category);
    // Assuming max calories around 3000 for visualization purposes
    final double percentage = math.min(calories / 3000, 1.0);
    
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(220, 220),
          painter: CircleProgressPainter(
            percentage: _progressAnimation.value * percentage,
            strokeWidth: 25,
            backgroundColor: Colors.grey.shade200,
            progressColor: progressColor,
          ),
          child: SizedBox(
            width: 220,
            height: 220,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(_progressAnimation.value * calories).toInt()}',
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: progressColor,
                    ),
                  ),
                  Text(
                    'kkal/hari',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultCard() {
    if (_analysisResult == null) return const SizedBox();
    
    final analysis = _analysisResult!['analysis'];
    final String category = analysis['main_category'];
    final double calories = analysis['recommended_calories'];
    final double protein = analysis['recommended_protein'];
    final double carbs = analysis['recommended_carbs'];
    final double fat = analysis['recommended_fat'];
    
    final Map<String, dynamic>? info = NutritionCategories.categoryInfo[category];
    final Color categoryColor = _getCategoryColor(category);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: categoryColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    info != null ? _getIconData(info['icon']) : CupertinoIcons.circle_grid_3x3_fill,
                    size: 30,
                    color: categoryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getCategoryTitle(category),
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: categoryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.bolt_fill,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Kebutuhan: ${calories.toStringAsFixed(0)} kkal/hari',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.chart_bar_alt_fill,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Makronutrien: P ${protein.toStringAsFixed(0)}g | K ${carbs.toStringAsFixed(0)}g | L ${fat.toStringAsFixed(0)}g',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (info != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Deskripsi:',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                info['description'] ?? '',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Karakteristik:',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              ...List.generate(
                (info['karakteristik'] as List<String>).length,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        CupertinoIcons.circle_fill,
                        size: 8,
                        color: categoryColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          info['karakteristik'][index],
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Fokus Nutrisi:',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              ...List.generate(
                (info['fokus_nutrisi'] as List<String>).length,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        CupertinoIcons.checkmark_circle_fill,
                        size: 16,
                        color: categoryColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          info['fokus_nutrisi'][index],
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard() {
    if (_recommendationData == null) return const SizedBox();
    
    final String category = _analysisResult!['analysis']['main_category'];
    final Color categoryColor = _getCategoryColor(category);
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rekomendasi Menu Makan',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: categoryColor,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            
            // Breakfast
            _buildMealItem(
              icon: CupertinoIcons.sunrise_fill,
              title: 'Sarapan',
              description: _recommendationData!['breakfast_options'] ?? '',
              color: categoryColor,
            ),
            
            // Lunch
            _buildMealItem(
              icon: CupertinoIcons.sun_max_fill,
              title: 'Makan Siang',
              description: _recommendationData!['lunch_options'] ?? '',
              color: categoryColor,
            ),
            
            // Dinner
            _buildMealItem(
              icon: CupertinoIcons.sunset_fill,
              title: 'Makan Malam',
              description: _recommendationData!['dinner_options'] ?? '',
              color: categoryColor,
            ),
            
            // Snacks
            _buildMealItem(
              icon: CupertinoIcons.clock_fill,
              title: 'Makanan Ringan',
              description: _recommendationData!['snack_options'] ?? '',
              color: categoryColor,
            ),
            
            const Divider(),
            const SizedBox(height: 16),
            
            // Planning Tips
            Text(
              'Tips Perencanaan Makan',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _recommendationData!['meal_planning_tips'] ?? '',
              style: GoogleFonts.poppins(
                fontSize: 14,
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Portion Guidance
            Text(
              'Panduan Porsi',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _recommendationData!['portion_guidance'] ?? '',
              style: GoogleFonts.poppins(
                fontSize: 14,
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            
            // Hydration Tips
            Text(
              'Tips Hidrasi',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _recommendationData!['hydration_tips'] ?? '',
              style: GoogleFonts.poppins(
                fontSize: 14,
                height: 1.5,
                color: Colors.blue.shade700,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Timing Tips
            Text(
              'Tips Waktu Makan',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _recommendationData!['timing_tips'] ?? '',
              style: GoogleFonts.poppins(
                fontSize: 14,
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Special Considerations
            Text(
              'Pertimbangan Khusus',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _recommendationData!['special_considerations'] ?? '',
              style: GoogleFonts.poppins(
                fontSize: 14,
                height: 1.5,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: color,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimerCard() {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
    elevation: 2,
    color: Colors.blue.shade50,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
      side: BorderSide(color: Colors.blue.shade200),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(CupertinoIcons.exclamationmark_triangle_fill, 
               color: Colors.blue.shade800),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Catatan Penting',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rekomendasi menu ini berdasarkan informasi yang Anda berikan dan dapat berubah seiring waktu. Jika memiliki kondisi kesehatan khusus, konsultasikan dengan dokter atau ahli gizi profesional.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.blue.shade900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
Widget _buildNoResultWidget() {
  return Center(
    child: FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.doc_text_search,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          Text(
            'Tidak ditemukan hasil analisis',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Terjadi kesalahan saat memproses jawaban Anda. Silakan coba lagi dengan melakukan analisis ulang.',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(CupertinoIcons.arrow_left),
            label: const Text('Kembali ke Analisis'),
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF64D1DE),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

@override
Widget build(BuildContext context) {
  final now = DateTime.now();
  final dateFormat = DateFormat('dd MMMM yyyy, HH:mm');
  final formattedDate = dateFormat.format(now);
  
  return Scaffold(
    backgroundColor: Colors.grey.shade50,
    appBar: AppBar(
      backgroundColor: const Color(0xFF64D1DE),
      elevation: 0,
      title: Text(
        'Rekomendasi Menu Sehat',
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
      actions: [
        IconButton(
          icon: const Icon(CupertinoIcons.share, color: Colors.white),
          onPressed: _analysisResult == null ? null : _shareResults,
        ),
      ],
    ),
    body: _isLoading
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CupertinoActivityIndicator(radius: 20),
                SizedBox(height: 20),
                Text(
                  'Menganalisis hasil...',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          )
        : _noResults
            ? _buildNoResultWidget()
            : SafeArea(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Tanggal analisis
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.calendar,
                          size: 16,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tanggal: $formattedDate',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Visual circle progress
                    if (_analysisResult != null)
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Center(
                          child: _buildCalorieProgressCircle(
                            _analysisResult!['analysis']['recommended_calories'], 
                            _analysisResult!['analysis']['main_category'],
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 16),
                    
                    // Hasil analisis
                    if (_analysisResult != null)
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Center(
                          child: Text(
                            'Hasil analisis kebutuhan nutrisi:',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 8),
                    
                    // Kategori
                    if (_analysisResult != null)
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Center(
                          child: Text(
                            _getCategoryTitle(_analysisResult!['analysis']['main_category']),
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: _getCategoryColor(_analysisResult!['analysis']['main_category']),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 24),
                    
                    // Disclaimer
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildDisclaimerCard(),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Detail analisis
                    if (_analysisResult != null)
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          'Detail Kebutuhan Nutrisi',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 8),
                    
                    // Card detail analisis
                    if (_analysisResult != null)
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildResultCard(),
                      ),
                    
                    const SizedBox(height: 16),
                    
                    // Rekomendasi menu
                    if (_recommendationData != null)
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          'Rekomendasi Menu Makan',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 8),
                    
                    // Card rekomendasi
                    if (_recommendationData != null)
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildRecommendationCard(),
                      ),
                    
                    const SizedBox(height: 16),
                    
                    // Tombol tindakan
                    if (_analysisResult != null)
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            ElevatedButton.icon(
                              onPressed: _shareResults,
                              icon: const Icon(CupertinoIcons.share),
                              label: Text(
                                'Bagikan Hasil Analisis',
                                style: GoogleFonts.poppins(),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF64D1DE),
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(CupertinoIcons.refresh),
                              label: Text(
                                'Analisis Ulang',
                                style: GoogleFonts.poppins(),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF64D1DE),
                                side: const BorderSide(color: Color(0xFF64D1DE)),
                                minimumSize: const Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    const SizedBox(height: 70), // Spacing for FAB
                  ],
                ),
              ),
  );
}}

// Custom painter untuk progress circle
class CircleProgressPainter extends CustomPainter {
  final double percentage;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;

  CircleProgressPainter({
    required this.percentage,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - strokeWidth / 2;
    
    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    
    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius), 
      -math.pi / 2,  // Start from top
      2 * math.pi * percentage,  // Draw arc based on percentage
      false, 
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CircleProgressPainter oldDelegate) => 
      oldDelegate.percentage != percentage ||
      oldDelegate.strokeWidth != strokeWidth ||
      oldDelegate.backgroundColor != backgroundColor ||
      oldDelegate.progressColor != progressColor;
}