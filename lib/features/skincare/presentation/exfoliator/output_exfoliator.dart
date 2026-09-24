import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:primafit/features/skincare/data/database_exfoliator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ExfoliatorCategories {
  // Map untuk informasi tambahan setiap kategori produk
  static final Map<String, Map<String, String>> categoryInfo = {
    'untuk_kulit_berminyak': {
      'title': 'Exfoliator untuk Kulit Berminyak',
      'description': 'Exfoliator ini diformulasikan khusus untuk kulit berminyak dengan kandungan BHA (Salicylic Acid) yang dapat mengontrol minyak berlebih dan membersihkan pori-pori tersumbat.',
      'recommendation': 'Gunakan 2-3 kali seminggu pada malam hari. Selalu ikuti dengan pelembab dan gunakan sunscreen di pagi hari karena exfoliator dapat membuat kulit lebih sensitif terhadap sinar matahari.',
      'icon': 'drop_fill',
    },
    'untuk_kulit_kering': {
      'title': 'Exfoliator untuk Kulit Kering',
      'description': 'Formula lembut dengan kandungan AHA (seperti Lactic Acid) dan bahan pelembab tambahan yang membantu mengangkat sel kulit mati tanpa membuat kulit semakin kering.',
      'recommendation': 'Gunakan 1-2 kali seminggu pada malam hari. Pastikan selalu mengaplikasikan pelembab yang kaya setelah penggunaan. Hindari exfoliant fisik yang terlalu kasar untuk kulit kering.',
      'icon': 'waveform_path',
    },
    'untuk_kulit_sensitif': {
      'title': 'Exfoliator untuk Kulit Sensitif',
      'description': 'Exfoliator lembut dengan konsentrasi asam rendah atau berbahan enzim. Diformulasikan tanpa alkohol, pewangi, atau bahan iritan lainnya untuk meminimalkan reaksi sensitif.',
      'recommendation': 'Mulai dengan frekuensi rendah (sekali seminggu) dan tingkatkan secara bertahap jika toleransi meningkat. Lakukan patch test sebelum penggunaan pertama. Jika terjadi iritasi, hentikan penggunaan.',
      'icon': 'exclamationmark_shield',
    },
    'untuk_anti_jerawat': {
      'title': 'Exfoliator Anti Jerawat',
      'description': 'Mengandung BHA (Salicylic Acid) yang bekerja dalam pori-pori untuk membersihkan minyak dan sel kulit mati, serta membantu mencegah timbulnya jerawat baru.',
      'recommendation': 'Gunakan 2-3 kali seminggu pada area berjerawat. Hindari penggunaan bersamaan dengan retinoid atau benzoyl peroxide untuk menghindari iritasi berlebih. Fokuskan pada area berjerawat atau zona-T.',
      'icon': 'bandage',
    },
    'untuk_anti_aging': {
      'title': 'Exfoliator Anti Aging',
      'description': 'Exfoliator dengan AHA (Glycolic Acid, Lactic Acid) yang membantu merangsang pergantian sel kulit, mengurangi tampilan garis halus, dan meningkatkan produksi kolagen.',
      'recommendation': 'Gunakan 2-3 kali seminggu di malam hari. Sangat penting menggunakan sunscreen setiap hari saat menggunakan exfoliator anti-aging karena AHA dapat meningkatkan sensitivitas terhadap sinar UV.',
      'icon': 'arrow_2_circlepath',
    },
    'untuk_kulit_kusam': {
      'title': 'Exfoliator untuk Kulit Kusam',
      'description': 'Formulasi dengan AHA yang efektif mengangkat sel kulit mati di permukaan kulit, mencerahkan warna kulit, dan memberikan kilau alami pada kulit kusam.',
      'recommendation': 'Gunakan 2-3 kali seminggu di malam hari. Untuk hasil maksimal, kombinasikan dengan serum vitamin C di pagi hari untuk meningkatkan kecerahan kulit.',
      'icon': 'sun_max',
    },
    'untuk_kulit_kombinasi': {
      'title': 'Exfoliator untuk Kulit Kombinasi',
      'description': 'Exfoliator dengan formula seimbang yang mengandung kombinasi BHA dan AHA untuk mengatasi area berminyak sekaligus tidak mengeringkan area kering.',
      'recommendation': 'Aplikasikan 1-2 kali seminggu. Bisa digunakan secara menyeluruh atau hanya pada zona tertentu sesuai kebutuhan (misalnya BHA pada area berminyak seperti T-zone).',
      'icon': 'waveform_circle_fill',
    },
    'untuk_penggunaan_harian': {
      'title': 'Exfoliator untuk Penggunaan Harian',
      'description': 'Exfoliator lembut dengan konsentrasi asam rendah atau berbasis enzim yang cukup ringan untuk digunakan setiap hari tanpa mengiritasi kulit.',
      'recommendation': 'Dapat digunakan setiap hari, pilih waktu pagi atau malam (konsisten). Jika terjadi iritasi, kurangi frekuensi penggunaan. Tetap perhatikan reaksi kulit Anda.',
      'icon': 'clock',
    },
    'untuk_penggunaan_mingguan': {
      'title': 'Exfoliator untuk Penggunaan Mingguan',
      'description': 'Exfoliator dengan konsentrasi asam lebih tinggi untuk hasil yang lebih intensif. Digunakan sebagai perawatan mingguan untuk pembaharuan kulit yang lebih dalam.',
      'recommendation': 'Gunakan maksimal 1-2 kali seminggu. Jangan menggunakan produk ini berdekatan dengan retinoid atau produk eksfoliasi lainnya. Hindari penggunaan pada kulit yang terluka atau teriritasi.',
      'icon': 'calendar',
    },
  };
}

class OutputPageExfoliator extends StatefulWidget {
  const OutputPageExfoliator({super.key});

  @override
  _OutputPageExfoliatorState createState() => _OutputPageExfoliatorState();
}

class _OutputPageExfoliatorState extends State<OutputPageExfoliator> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  late Animation<double> _fadeAnimation;
  
  Map<String, dynamic>? _recommendationResult;
  List<Map<String, dynamic>> _recommendedProducts = [];
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
    
    _loadRecommendationResults();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Fungsi untuk membuat PDF hasil rekomendasi
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
                  'REKOMENDASI EXFOLIATOR WAJAH',
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
                'Hasil Rekomendasi:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 5),
              if (_recommendationResult != null)
                pw.Text(
                  _recommendationResult!['recommendation']['product_type'].toString(),
                  style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
                ),
              pw.SizedBox(height: 5),
              if (_recommendationResult != null)
                pw.Text(
                  'Kesesuaian: ${_recommendationResult!['recommendation']['match_percentage'].toStringAsFixed(1)}%',
                ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Rekomendasi Produk:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              
              // Daftar produk yang direkomendasikan
              if (_recommendedProducts.isNotEmpty)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: _recommendedProducts.take(3).map((product) {
                    return pw.Container(
                      margin: const pw.EdgeInsets.only(bottom: 10),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            product['name'],
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                          pw.SizedBox(height: 3),
                          pw.Text(product['description']),
                          pw.SizedBox(height: 3),
                          pw.Text('Harga: ${product['price']}'),
                          pw.SizedBox(height: 3),
                          pw.Text('Tipe: ${product['exfoliant_type']}'),
                          pw.SizedBox(height: 3),
                          pw.Text('Kandungan: ${product['ingredients']}'),
                          pw.Divider(),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              
              pw.SizedBox(height: 20),
              if (_recommendationResult != null && _recommendationResult!['recommendation']['top_category'] != null)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Informasi Tambahan:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      ExfoliatorCategories.categoryInfo[_recommendationResult!['recommendation']['top_category']]?['description'] ?? '',
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'Rekomendasi Penggunaan:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      ExfoliatorCategories.categoryInfo[_recommendationResult!['recommendation']['top_category']]?['recommendation'] ?? '',
                    ),
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
                'Rekomendasi ini berdasarkan informasi yang Anda berikan. Selalu lakukan patch test sebelum menggunakan exfoliator baru. Gunakan sunscreen setiap hari karena exfoliator dapat membuat kulit lebih sensitif terhadap sinar matahari. Hentikan penggunaan jika terjadi iritasi, kemerahan, atau reaksi alergi.',
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
    final file = File('${output.path}/rekomendasi_exfoliator.pdf');
    await file.writeAsBytes(await pdf.save());
    
    return file;
  }

  // Bagikan hasil rekomendasi
  Future<void> _shareResults() async {
    try {
      final pdfFile = await _generatePDF();
      
      await Share.shareXFiles(
        [XFile(pdfFile.path)],
        text: 'Rekomendasi Exfoliator Untukmu',
        subject: 'Rekomendasi Exfoliator - ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
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

  Future<void> _loadRecommendationResults() async {
    try {
      final result = await DatabaseHelperExfoliator.instance.getLatestRecommendation();
      
      if (!mounted) return;
      
      setState(() {
        _recommendationResult = result;
        if (result != null && result['products'] != null) {
          _recommendedProducts = List<Map<String, dynamic>>.from(result['products']);
        }
        _isLoading = false;
        _noResults = result == null || result['products'] == null || result['products'].isEmpty;
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
      debugPrint('Error loading recommendation results: $e');
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'waveform_path':
        return CupertinoIcons.waveform_path;
      case 'drop_fill':
        return CupertinoIcons.drop_fill;
      case 'bandage':
        return CupertinoIcons.bandage;
      case 'exclamationmark_shield':
        return CupertinoIcons.exclamationmark_shield;
      case 'sun_max':
        return CupertinoIcons.sun_max;
      case 'arrow_2_circlepath':
        return CupertinoIcons.arrow_2_circlepath;
      case 'waveform_circle_fill':
        return CupertinoIcons.waveform_circle_fill;
      case 'clock':
        return CupertinoIcons.clock;
      case 'calendar':
        return CupertinoIcons.calendar;
      default:
        return CupertinoIcons.question_circle;
    }
  }

  // Mendapatkan warna berdasarkan kategori produk
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'untuk_kulit_berminyak':
        return Colors.green;
      case 'untuk_kulit_kering':
        return Colors.orange;
      case 'untuk_kulit_sensitif':
        return Colors.red;
      case 'untuk_anti_jerawat':
        return Colors.blue;
      case 'untuk_anti_aging':
        return Colors.pink;
      case 'untuk_kulit_kusam':
        return Colors.amber;
      case 'untuk_kulit_kombinasi':
        return Colors.teal;
      case 'untuk_penggunaan_harian':
        return Colors.indigo;
      case 'untuk_penggunaan_mingguan':
        return Colors.deepPurple;
      default:
        return const Color(0xFF9C27B0); // Purple color for default
    }
  }

  Widget _buildProgressCircle(double percentage, String category) {
    final Color progressColor = _getCategoryColor(category);
    
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

  Widget _buildRecommendationCard() {
    if (_recommendationResult == null) return const SizedBox();
    
    final recommendation = _recommendationResult!['recommendation'];
    final String category = recommendation['top_category'];
    final double percentage = recommendation['match_percentage'];
    final String productType = recommendation['product_type'];
    
    final Map<String, String>? info = ExfoliatorCategories.categoryInfo[category];
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
                    info != null ? _getIconData(info['icon'] ?? 'question_circle') : CupertinoIcons.question_circle,
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
                        productType,
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
                'Keterangan:',
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
                'Rekomendasi Penggunaan:',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                info['recommendation'] ?? '',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDisclaimerCard() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      elevation: 2,
      color: Colors.purple.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.purple.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(CupertinoIcons.exclamationmark_triangle_fill, 
                 color: Colors.purple.shade800),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Penting',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.purple.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Exfoliator mengandung bahan aktif yang dapat membuat kulit lebih sensitif terhadap sinar matahari. Gunakan selalu sunscreen setiap hari dan mulai dengan frekuensi rendah (1-2 kali seminggu) untuk melihat reaksi kulit Anda.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.purple.shade900,
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
              'Tidak ditemukan hasil rekomendasi',
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
                'Terjadi kesalahan saat memproses jawaban Anda. Silakan coba lagi dengan melakukan rekomendasi ulang.',
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
              label: const Text('Kembali ke Rekomendasi'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF9C27B0),
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

  Widget _buildProductCard(Map<String, dynamic> product) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      CupertinoIcons.cube_box,
                      size: 40,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['name'],
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.tag,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            product['price'],
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
                            CupertinoIcons.star_fill,
                            size: 14,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${product['rating']}',
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
                            CupertinoIcons.person,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            product['skin_type'],
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
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              'Deskripsi:',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              product['description'],
              style: GoogleFonts.poppins(
                fontSize: 13,
                height: 1.5,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Kandungan Utama:',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              product['ingredients'],
              style: GoogleFonts.poppins(
                fontSize: 13,
                height: 1.5,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.lab_flask,
                      size: 14,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Tipe: ${product['exfoliant_type']}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(product['category']).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    product['acid_type'] ?? 'N/A',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: _getCategoryColor(product['category']),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  CupertinoIcons.time,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  'Frekuensi: ${product['usage_frequency']}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                // Menambahkan aksi untuk melihat detail atau membeli produk
                // Implementasi bisa dilakukan sesuai kebutuhan
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C27B0),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                'Lihat Detail Produk',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
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
        backgroundColor: const Color(0xFF9C27B0),
        elevation: 0,
        title: Text(
          'Rekomendasi Exfoliator',
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
            onPressed: _recommendationResult == null ? null : _shareResults,
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
                      // Tanggal rekomendasi
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
                      if (_recommendationResult != null)
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Center(
                            child: _buildProgressCircle(
                              _recommendationResult!['recommendation']['match_percentage'], 
                              _recommendationResult!['recommendation']['top_category'],
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 16),
                      
                      // Hasil rekomendasi
                      if (_recommendationResult != null)
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Center(
                            child: Text(
                              'Hasil rekomendasi:',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 8),
                      
                      // Nama kategori produk
                      if (_recommendationResult != null)
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Center(
                            child: Text(
                              _recommendationResult!['recommendation']['product_type'],
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: _getCategoryColor(_recommendationResult!['recommendation']['top_category']),
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
                      
                      // Detail rekomendasi
                      if (_recommendationResult != null)
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Text(
                            'Detail Rekomendasi',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 8),
                      
                      // Card detail rekomendasi
                      if (_recommendationResult != null)
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildRecommendationCard(),
                        ),
                      
                      const SizedBox(height: 16),
                      
                      // Produk yang direkomendasikan
                      if (_recommendedProducts.isNotEmpty)
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Produk yang Direkomendasikan',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ..._recommendedProducts.map((product) => _buildProductCard(product)),
                            ],
                          ),
                        ),
                      
                      const SizedBox(height: 16),
                      
                      // Tombol tindakan
                      if (_recommendationResult != null)
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            children: [
                              ElevatedButton.icon(
                                onPressed: _shareResults,
                                icon: const Icon(CupertinoIcons.share),
                                label: Text(
                                  'Bagikan Rekomendasi',
                                  style: GoogleFonts.poppins(),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF9C27B0),
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
                                  'Coba Lagi',
                                  style: GoogleFonts.poppins(),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF9C27B0),
                                  side: const BorderSide(color: Color(0xFF9C27B0)),
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