import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:primafit/features/skincare/data/database_skintype.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class SkinTypeCategories {
  // Map untuk informasi tambahan setiap jenis kulit
  static final Map<String, Map<String, dynamic>> skinTypeInfo = {
    'berminyak': {
      'title': 'Kulit Berminyak',
      'description': 'Kulit berminyak ditandai dengan produksi sebum berlebih yang membuat wajah terlihat mengkilap, terutama di area T-zone. Pori-pori biasanya lebih terlihat dan cenderung berjerawat.',
      'icon': 'drop_fill',
      'color': Colors.green,
      'karakteristik': [
        'Wajah cepat terlihat mengkilap',
        'Pori-pori tampak lebih besar',
        'Cenderung berjerawat',
        'Makeup tidak tahan lama',
        'T-zone (dahi, hidung, dagu) sangat berminyak'
      ],
      'penyebab': [
        'Faktor genetik',
        'Perubahan hormonal',
        'Kelembapan tinggi',
        'Gaya hidup dan pola makan',
        'Produk skincare yang terlalu harsh'
      ],
    },
    'kering': {
      'title': 'Kulit Kering',
      'description': 'Kulit kering menghasilkan sebum lebih sedikit dari yang dibutuhkan untuk mempertahankan kelembapan alami kulit. Akibatnya, kulit terasa kaku, kasar, dan sering terkelupas.',
      'icon': 'waveform_path',
      'color': Colors.orange,
      'karakteristik': [
        'Terasa kencang/tertarik setelah mencuci wajah',
        'Tekstur kulit kasar atau bersisik',
        'Cenderung kemerahan',
        'Pori-pori kecil dan hampir tidak terlihat',
        'Garis-garis halus lebih terlihat'
      ],
      'penyebab': [
        'Faktor genetik',
        'Cuaca dingin atau kering',
        'Penggunaan produk yang mengandung alkohol',
        'Usia lanjut',
        'Air panas saat memcuci wajah'
      ],
    },
    'normal': {
      'title': 'Kulit Normal',
      'description': 'Kulit normal memiliki keseimbangan yang baik antara kadar minyak dan kelembapan. Teksturnya halus dengan sedikit ketidaksempurnaan, dan tidak terlalu berminyak atau kering.',
      'icon': 'smiley',
      'color': Colors.blue,
      'karakteristik': [
        'Jarang bermasalah dengan jerawat',
        'Tidak terlalu berminyak atau kering',
        'Pori-pori kecil',
        'Tekstur halus dan merata',
        'Kilau sehat tanpa terlihat berminyak'
      ],
      'penyebab': [
        'Faktor genetik',
        'Keseimbangan hormon yang baik',
        'Gaya hidup seimbang',
        'Rutinitas skincare yang tepat',
        'Hidrasi yang cukup'
      ],
    },
    'kombinasi': {
      'title': 'Kulit Kombinasi',
      'description': 'Kulit kombinasi memiliki karakteristik berbeda di area wajah yang berbeda. Umumnya berminyak di T-zone (dahi, hidung, dagu) dan normal atau kering di area pipi dan sekitar mata.',
      'icon': 'arrow_2_circlepath',
      'color': Colors.purple,
      'karakteristik': [
        'T-zone berminyak, pipi normal/kering',
        'Pori-pori lebih besar di area hidung dan dahi',
        'Jerawat biasanya muncul di area T-zone',
        'Pipi bisa terasa kering',
        'Kebutuhan produk skincare berbeda di area berbeda'
      ],
      'penyebab': [
        'Faktor genetik',
        'Perubahan hormon',
        'Perubahan cuaca',
        'Penggunaan produk skincare yang tidak tepat',
        'Gaya hidup tidak teratur'
      ],
    },
    'sensitif': {
      'title': 'Kulit Sensitif',
      'description': 'Kulit sensitif mudah bereaksi terhadap produk skincare, perubahan lingkungan, atau faktor eksternal lainnya. Reaksi dapat berupa kemerahan, gatal, terbakar, atau iritasi.',
      'icon': 'exclamationmark_shield',
      'color': Colors.red,
      'karakteristik': [
        'Mudah kemerahan dan iritasi',
        'Sering terasa terbakar setelah penggunaan produk',
        'Reaksi negatif terhadap produk beraroma',
        'Mudah teriritasi saat terpapar matahari',
        'Pembuluh darah tampak lebih terlihat'
      ],
      'penyebab': [
        'Barrier kulit yang lemah',
        'Kondisi kulit seperti eczema, rosacea, atau dermatitis',
        'Alergi dan intoleransi terhadap bahan tertentu',
        'Perubahan ekstrem suhu atau lingkungan',
        'Penggunaan produk dengan bahan terlalu keras'
      ],
    },
  };
}

class OutputPageSkinType extends StatefulWidget {
  const OutputPageSkinType({super.key});

  @override
  _OutputPageSkinTypeState createState() => _OutputPageSkinTypeState();
}

class _OutputPageSkinTypeState extends State<OutputPageSkinType> with SingleTickerProviderStateMixin {
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
                  'HASIL ANALISIS JENIS KULIT',
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
                'Hasil Analisis:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 5),
              if (_analysisResult != null)
                pw.Text(
                  _analysisResult!['analysis']['primary_skin_type'].toString(),
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
              pw.SizedBox(height: 5),
              if (_analysisResult != null)
                pw.Text(
                  'Kesesuaian: ${_analysisResult!['analysis']['match_percentage'].toStringAsFixed(1)}%',
                ),
              pw.SizedBox(height: 5),
              if (_analysisResult != null)
                pw.Text(
                  'Kecenderungan sekunder: ${_analysisResult!['analysis']['secondary_skin_type']}',
                ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Karakteristik Jenis Kulit:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              
              // Karakteristik jenis kulit
              if (_analysisResult != null && _analysisResult!['analysis']['top_skin_type'] != null)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: SkinTypeCategories.skinTypeInfo[_analysisResult!['analysis']['top_skin_type']]?['karakteristik'].take(5).map<pw.Widget>((feature) {
                    return pw.Container(
                      margin: const pw.EdgeInsets.only(bottom: 5),
                      child: pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('• '),
                          pw.Expanded(child: pw.Text(feature)),
                        ],
                      ),
                    );
                  }).toList() ?? [],
                ),
                
              pw.SizedBox(height: 20),
              pw.Text(
                'Rekomendasi Perawatan:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              
              // Rekomendasi perawatan
              if (_recommendationData != null)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Pembersih:'),
                    pw.Text(_recommendationData!['cleanser_tip'] ?? ''),
                    pw.SizedBox(height: 5),
                    pw.Text('Pelembab:'),
                    pw.Text(_recommendationData!['moisturizer_tip'] ?? ''),
                    pw.SizedBox(height: 5),
                    pw.Text('Sunscreen:'),
                    pw.Text(_recommendationData!['sunscreen_tip'] ?? ''),
                    pw.SizedBox(height: 5),
                    pw.Text('Bahan yang Baik:'),
                    pw.Text(_recommendationData!['ingredients_to_look'] ?? ''),
                    pw.SizedBox(height: 5),
                    pw.Text('Bahan yang Sebaiknya Dihindari:'),
                    pw.Text(_recommendationData!['ingredients_to_avoid'] ?? ''),
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
                'Analisis ini berdasarkan informasi yang Anda berikan dan dapat berubah seiring waktu. Konsistensi dalam perawatan kulit dan pemilihan produk yang tepat adalah kunci untuk kulit sehat. Jika memiliki masalah kulit serius, konsultasikan dengan dokter kulit.',
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
    final file = File('${output.path}/analisis_jenis_kulit.pdf');
    await file.writeAsBytes(await pdf.save());
    
    return file;
  }

  // Bagikan hasil rekomendasi
  Future<void> _shareResults() async {
    try {
      final pdfFile = await _generatePDF();
      
      await Share.shareXFiles(
        [XFile(pdfFile.path)],
        text: 'Rekomendasi Sunscreen Untukmu',
        subject: 'Rekomendasi Sunscreen - ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
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
    final result = await DatabaseHelperSkinType.instance.getLatestAnalysisResult();
    
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

  Color _getSkinTypeColor(String skinType) {
  switch (skinType) {
    case 'berminyak':
      return Colors.green;
    case 'kering':
      return Colors.orange;
    case 'normal':
      return Colors.blue;
    case 'kombinasi':
      return Colors.purple;
    case 'sensitif':
      return Colors.red;
    default:
      return const Color(0xFF64D1DE); // Warna default tema aplikasi
  }
}



  IconData _getIconData(String iconName) {
  switch (iconName) {
    case 'waveform_path':
      return CupertinoIcons.waveform_path;
    case 'drop_fill':
      return CupertinoIcons.drop_fill;
    case 'exclamationmark_shield':
      return CupertinoIcons.exclamationmark_shield;
    case 'arrow_2_circlepath':
      return CupertinoIcons.arrow_2_circlepath;
    case 'smiley':
      return CupertinoIcons.smiley;
    case 'bandage':
      return CupertinoIcons.bandage;
    case 'sparkles':
      return CupertinoIcons.sparkles;
    case 'sun_max':
      return CupertinoIcons.sun_max;
    case 'face_smiling':
      return CupertinoIcons.person;
    case 'moon_zzz':
      return CupertinoIcons.moon_zzz;
    case 'hand_raised':
      return CupertinoIcons.hand_raised;
    case 'wand_stars':
      return CupertinoIcons.wand_stars;
    case 'flame':
      return CupertinoIcons.flame;
    case 'cloud_sun':
      return CupertinoIcons.cloud_sun;
    default:
      return CupertinoIcons.question_circle;
  }
}
  
Widget _buildProgressCircle(double percentage, String skinType) {
    final Color progressColor = _getSkinTypeColor(skinType);
    
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(220, 220),
          painter: CircleProgressPainter(
            percentage: _progressAnimation.value * percentage / 100,
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
                    '${(_progressAnimation.value * percentage).toInt()}%',
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: progressColor,
                    ),
                  ),
                  Text(
                    'Kesesuaian',
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
    final String skinType = analysis['top_skin_type'];
    final double percentage = analysis['match_percentage'];
    final String primarySkinType = analysis['primary_skin_type'];
    final String secondarySkinType = analysis['secondary_skin_type'];
    final String tendencyLevel = analysis['tendency_level'];
    
    final Map<String, dynamic>? info = SkinTypeCategories.skinTypeInfo[skinType];
    final Color skinTypeColor = _getSkinTypeColor(skinType);
    
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
                    color: skinTypeColor.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    info != null ? _getIconData(info['icon']) : CupertinoIcons.question_circle,
                    size: 30,
                    color: skinTypeColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        primarySkinType,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: skinTypeColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.percent,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Kesesuaian: ${percentage.toStringAsFixed(1)}%',
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
                            CupertinoIcons.arrow_branch,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Kecenderungan $tendencyLevel ke $secondarySkinType',
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
                        color: skinTypeColor,
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
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard() {
    if (_recommendationData == null) return const SizedBox();
    
    final String skinType = _analysisResult!['analysis']['top_skin_type'];
    final Color skinTypeColor = _getSkinTypeColor(skinType);
    
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
              'Rekomendasi Perawatan',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: skinTypeColor,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            
            // Cleanser
            _buildRecommendationItem(
              icon: CupertinoIcons.drop,
              title: 'Pembersih (Cleanser)',
              description: _recommendationData!['cleanser_tip'] ?? '',
              color: skinTypeColor,
            ),
            
            // Toner
            _buildRecommendationItem(
              icon: CupertinoIcons.sparkles,
              title: 'Toner',
              description: _recommendationData!['toner_tip'] ?? '',
              color: skinTypeColor,
            ),
            
            // Moisturizer
            _buildRecommendationItem(
              icon: CupertinoIcons.snow,
              title: 'Pelembab (Moisturizer)',
              description: _recommendationData!['moisturizer_tip'] ?? '',
              color: skinTypeColor,
            ),
            
            // Sunscreen
            _buildRecommendationItem(
              icon: CupertinoIcons.sun_max,
              title: 'Tabir Surya (Sunscreen)',
              description: _recommendationData!['sunscreen_tip'] ?? '',
              color: skinTypeColor,
            ),
            
            // Exfoliation
            _buildRecommendationItem(
              icon: CupertinoIcons.wand_stars,
              title: 'Eksfoliasi',
              description: _recommendationData!['exfoliation_tip'] ?? '',
              color: skinTypeColor,
            ),
            
            const Divider(),
            const SizedBox(height: 16),
            
            // AM Routine
            Text(
              'Rutinitas Pagi',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _recommendationData!['routine_am'] ?? '',
              style: GoogleFonts.poppins(
                fontSize: 14,
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // PM Routine
            Text(
              'Rutinitas Malam',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _recommendationData!['routine_pm'] ?? '',
              style: GoogleFonts.poppins(
                fontSize: 14,
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            
            // Ingredients to look for
            Text(
              'Bahan yang Baik untuk Kulit Anda',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _recommendationData!['ingredients_to_look'] ?? '',
              style: GoogleFonts.poppins(
                fontSize: 14,
                height: 1.5,
                color: Colors.green.shade700,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Ingredients to avoid
            Text(
              'Bahan yang Sebaiknya Dihindari',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _recommendationData!['ingredients_to_avoid'] ?? '',
              style: GoogleFonts.poppins(
                fontSize: 14,
                height: 1.5,
                color: Colors.red.shade700,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Extra tips
            Text(
              'Tips Tambahan',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _recommendationData!['extra_tips'] ?? '',
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

  Widget _buildRecommendationItem({
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
                    'Analisis ini berdasarkan informasi yang Anda berikan dan dapat berubah seiring waktu atau kondisi. Jika memiliki masalah kulit serius, konsultasikan dengan dokter kulit profesional.',
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
                            child: _buildProgressCircle(
                              _analysisResult!['analysis']['match_percentage'], 
                              _analysisResult!['analysis']['top_skin_type'],
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
                              'Hasil analisis jenis kulit:',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 8),
                      
                      // Nama jenis kulit
                      if (_analysisResult != null)
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Center(
                            child: Text(
                              _analysisResult!['analysis']['primary_skin_type'],
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: _getSkinTypeColor(_analysisResult!['analysis']['top_skin_type']),
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
                            'Detail Jenis Kulit',
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
                      
                      // Rekomendasi perawatan kulit
                      if (_recommendationData != null)
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Text(
                            'Rekomendasi Perawatan Kulit',
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
  }
}

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