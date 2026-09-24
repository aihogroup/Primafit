import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:primafit/database/skincare/database_toner.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class TonerCategories {
  // Map untuk informasi tambahan setiap kategori produk
  static final Map<String, Map<String, String>> categoryInfo = {
    'untuk_kulit_berminyak': {
      'title': 'Toner untuk Kulit Berminyak',
      'description': 'Toner ini dirancang khusus untuk menyeimbangkan produksi minyak berlebih, menyegarkan kulit, dan mengecilkan tampilan pori-pori.',
      'recommendation': 'Gunakan setelah mencuci wajah, pagi dan malam. Untuk hasil optimal, aplikasikan dengan tangan atau cotton pad, tepuk lembut hingga terserap.',
      'icon': 'drop_fill',
    },
    'untuk_kulit_kering': {
      'title': 'Toner untuk Kulit Kering',
      'description': 'Diperkaya dengan bahan-bahan pelembab seperti hyaluronic acid, glycerin, dan ceramide untuk memberikan hidrasi mendalam pada kulit kering.',
      'recommendation': 'Aplikasikan segera setelah mencuci wajah untuk mengunci kelembapan. Gunakan dengan metode 3-5 skin (lapisan) untuk hidrasi lebih intensif.',
      'icon': 'waveform_path',
    },
    'untuk_kulit_sensitif': {
      'title': 'Toner untuk Kulit Sensitif',
      'description': 'Formula lembut tanpa alkohol dan pewangi yang menenangkan kulit sensitif, mengurangi kemerahan, dan membantu memperkuat skin barrier.',
      'recommendation': 'Gunakan 1-2 kali sehari. Hindari menggosok kulit, cukup tepuk lembut. Lakukan patch test sebelum penggunaan pertama.',
      'icon': 'exclamationmark_shield',
    },
    'untuk_eksfoliasi': {
      'title': 'Toner Eksfoliasi',
      'description': 'Mengandung chemical exfoliant seperti AHA (glycolic acid, lactic acid), BHA (salicylic acid), atau PHA untuk mengangkat sel kulit mati dan memperbaiki tekstur kulit.',
      'recommendation': 'Gunakan 2-3 kali seminggu (pemula) atau sesuai toleransi kulit. Aplikasikan di malam hari dan gunakan sunscreen di pagi hari. Hindari penggunaan bersamaan dengan retinol.',
      'icon': 'arrow_2_circlepath',
    },
    'untuk_pencerah': {
      'title': 'Toner Pencerah',
      'description': 'Diformulasikan dengan bahan aktif pencerah seperti vitamin C, niacinamide, tranexamic acid, atau arbutin untuk mencerahkan dan meratakan warna kulit.',
      'recommendation': 'Gunakan 1-2 kali sehari secara konsisten untuk hasil optimal. Kombinasikan dengan sunscreen di pagi hari untuk mencegah hiperpigmentasi baru.',
      'icon': 'sun_max',
    },
    'untuk_hidrasi': {
      'title': 'Toner Hidrasi',
      'description': 'Diperkaya dengan multi-weight hyaluronic acid, beta-glucan, atau glycerin untuk memberikan hidrasi mendalam pada berbagai lapisan kulit.',
      'recommendation': 'Dapat digunakan dengan metode 7-skin (terapkan 7 lapisan tipis) untuk hidrasi intensif. Sempurna untuk semua jenis kulit, terutama di iklim kering atau ber-AC.',
      'icon': 'drop',
    },
    'untuk_menenangkan': {
      'title': 'Toner Menenangkan',
      'description': 'Mengandung bahan-bahan yang menenangkan seperti centella asiatica, panthenol, allantoin, atau madecassoside untuk meredakan kemerahan dan iritasi.',
      'recommendation': 'Ideal untuk digunakan setelah eksfoliasi, paparan sinar matahari, atau ketika kulit terasa sensitif. Dapat disimpan di kulkas untuk efek menenangkan ekstra.',
      'icon': 'bandage',
    },
    'untuk_anti_aging': {
      'title': 'Toner Anti-Aging',
      'description': 'Diperkaya dengan bahan aktif anti-aging seperti peptide, adenosine, fermented ingredients, atau antioksidan yang membantu memperlambat tanda-tanda penuaan.',
      'recommendation': 'Gunakan pagi dan malam, diikuti dengan serum dan pelembap. Teruskan dengan konsisten untuk melihat hasil yang optimal dalam jangka panjang.',
      'icon': 'arrow_clockwise',
    },
    'untuk_skin_barrier': {
      'title': 'Toner untuk Skin Barrier',
      'description': 'Dirancang untuk membantu memperbaiki dan memperkuat skin barrier yang rusak dengan ceramide, fatty acids, atau centella asiatica.',
      'recommendation': 'Gunakan 2 kali sehari sebagai bagian dari rutinitas minimal. Hindari produk dengan bahan aktif kuat seperti AHA/BHA sampai skin barrier pulih.',
      'icon': 'shield_lefthalf_fill',
    },
  };
}

class OutputPageToner extends StatefulWidget {
  const OutputPageToner({Key? key}) : super(key: key);

  @override
  _OutputPageTonerState createState() => _OutputPageTonerState();
}

class _OutputPageTonerState extends State<OutputPageToner> with SingleTickerProviderStateMixin {
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
                  'REKOMENDASI TONER WAJAH',
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
                          pw.Text('Volume: ${product['volume']}'),
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
                      TonerCategories.categoryInfo[_recommendationResult!['recommendation']['top_category']]?['description'] ?? '',
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'Rekomendasi Penggunaan:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      TonerCategories.categoryInfo[_recommendationResult!['recommendation']['top_category']]?['recommendation'] ?? '',
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
                'Rekomendasi ini berdasarkan informasi yang Anda berikan. Untuk hasil optimal, gunakan toner secara rutin dan konsisten. Lakukan patch test sebelum menggunakan produk baru, terutama jika memiliki kulit sensitif. Hentikan penggunaan jika terjadi iritasi, kemerahan, atau reaksi alergi.',
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
    final file = File('${output.path}/rekomendasi_toner.pdf');
    await file.writeAsBytes(await pdf.save());
    
    return file;
  }

  // Bagikan hasil rekomendasi
  Future<void> _shareResults() async {
    try {
      final pdfFile = await _generatePDF();
      
      await Share.shareXFiles(
        [XFile(pdfFile.path)],
        text: 'Rekomendasi Toner Untukmu',
        subject: 'Rekomendasi Toner - ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
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
      final result = await DatabaseHelperToner.instance.getLatestRecommendation();
      
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
      case 'drop':
        return CupertinoIcons.drop;
      case 'bandage':
        return CupertinoIcons.bandage;
      case 'exclamationmark_shield':
        return CupertinoIcons.exclamationmark_shield;
      case 'sun_max':
        return CupertinoIcons.sun_max;
      case 'arrow_2_circlepath':
        return CupertinoIcons.arrow_2_circlepath;
      case 'arrow_clockwise':
        return CupertinoIcons.arrow_clockwise;
      case 'shield_lefthalf_fill':
        return CupertinoIcons.shield_lefthalf_fill;
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
      case 'untuk_eksfoliasi':
        return Colors.purple;
      case 'untuk_pencerah':
        return Colors.amber;
      case 'untuk_hidrasi':
        return Colors.blue;
      case 'untuk_menenangkan':
        return Colors.teal;
      case 'untuk_anti_aging':
        return Colors.pink;
      case 'untuk_skin_barrier':
        return Colors.indigo;
      default:
        return const Color(0xFF64D1DE); // Blue color for default
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
    
    final Map<String, String>? info = TonerCategories.categoryInfo[category];
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
                    color: categoryColor.withOpacity(0.2),
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
                    'Penting',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Rekomendasi ini berdasarkan informasi yang Anda berikan. Setiap kulit memiliki karakteristik unik, oleh karenanya perlu diperhatikan reaksi kulit terhadap produk baru. Lakukan patch test dan hentikan penggunaan jika terjadi iritasi.',
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
              children: [
                Icon(
                  CupertinoIcons.drop,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  'Volume: ${product['volume']}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  CupertinoIcons.hand_raised,
                  size: 14,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  'Tekstur: ${product['texture']}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      product['contains_alcohol'] == 'Ya' 
                          ? CupertinoIcons.exclamationmark_circle
                          : CupertinoIcons.checkmark_circle,
                      size: 14,
                      color: product['contains_alcohol'] == 'Ya' 
                          ? Colors.orange
                          : Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Alkohol: ${product['contains_alcohol']}',
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
                    color: _getCategoryColor(product['category']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    product['category'].toString().split('_').map((word) => word[0].toUpperCase() + word.substring(1)).join(' '),
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
            ElevatedButton(
              onPressed: () {
                // Menambahkan aksi untuk melihat detail atau membeli produk
                // Implementasi bisa dilakukan sesuai kebutuhan
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF64D1DE),
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
        backgroundColor: const Color(0xFF64D1DE),
        elevation: 0,
        title: Text(
          'Rekomendasi Toner',
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
                              ..._recommendedProducts.map((product) => _buildProductCard(product)).toList(),
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
                                  'Coba Lagi',
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