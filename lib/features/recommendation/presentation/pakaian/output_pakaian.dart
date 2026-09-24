import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:primafit/features/recommendation/data/database_fashion.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class FashionCategories {
  // Map untuk informasi tambahan setiap kategori fashion
  static final Map<String, Map<String, dynamic>> categoryInfo = {
    'formal_pria': {
      'title': 'Formal Pria',
      'description': 'Rekomendasi fashion formal untuk pria dengan fokus pada ketepatan potongan dan elegance.',
      'icon': 'suit_diamond',
      'color': Colors.indigo,
      'karakteristik': [
        'Pakaian well-fitted dan tersusun rapi',
        'Material premium dengan finishing halus',
        'Pilihan warna konservatif dan muted',
        'Aksesoris minimal namun berkualitas',
        'Sepatu formal yang terawat'
      ],
      'focal_points': [
        'Ketepatan ukuran jas atau blazer di bahu',
        'Kemeja yang pas tanpa kerutan',
        'Panjang celana yang tepat',
        'Koordinasi warna yang harmonis',
        'Grooming rapi dan teratur'
      ],
    },
    'casual_pria': {
      'title': 'Casual Pria',
      'description': 'Rekomendasi fashion casual untuk pria dengan keseimbangan antara kenyamanan dan style.',
      'icon': 'person',
      'color': Colors.blue,
      'karakteristik': [
        'Potongan relaxed tapi tetap rapi',
        'Material breathable dan nyaman',
        'Versatilitas dalam mix and match',
        'Pilihan warna lebih beragam',
        'Kebebasan untuk ekspresi personal'
      ],
      'focal_points': [
        'Kualitas basic pieces seperti t-shirt dan jeans',
        'Layering yang proporsional',
        'Sepatu yang bersih dan terawat',
        'Aksesoris yang menambah dimensi',
        'Kesesuaian dengan aktivitas sehari-hari'
      ],
    },
    'formal_wanita': {
      'title': 'Formal Wanita',
      'description': 'Rekomendasi fashion formal untuk wanita dengan keseimbangan antara profesionalisme dan femininitas.',
      'icon': 'heart',
      'color': Colors.purple,
      'karakteristik': [
        'Siluet yang well-defined dan flattering',
        'Material premium dengan draping baik',
        'Warna yang sophisticated dan timeless',
        'Aksesoris elegan dan proporsional',
        'Detil yang menunjukkan presisi'
      ],
      'focal_points': [
        'Ketepatan ukuran dan fit yang menyanjung bentuk tubuh',
        'Balance antara modesty dan style modern',
        'Kualitas dan kerapian jahitan',
        'Sepatu yang elegant dan comfortable',
        'Grooming dan makeup yang polished'
      ],
    },
    'casual_wanita': {
      'title': 'Casual Wanita',
      'description': 'Rekomendasi fashion casual untuk wanita dengan fokus pada ekspresi diri dan kenyamanan.',
      'icon': 'heart_circle',
      'color': Colors.pink,
      'karakteristik': [
        'Mix and match dengan item versatile',
        'Material yang nyaman untuk mobilitas',
        'Permainan warna, pattern, dan tekstur',
        'Layer sesuai kebutuhan dan situasi',
        'Aksesoris yang menunjukkan personality'
      ],
      'focal_points': [
        'Proporsi antara loose dan fitted items',
        'Kenyamanan tanpa mengorbankan style',
        'Sepatu yang sesuai dengan aktivitas',
        'Personal statement pieces',
        'Transisi dari day to night look'
      ],
    },
    'semiformal_pria': {
      'title': 'Semi-Formal Pria',
      'description': 'Rekomendasi fashion smart casual untuk pria dengan keseimbangan antara formal dan casual elements.',
      'icon': 'star',
      'color': Colors.teal,
      'karakteristik': [
        'Perpaduan item casual dan formal',
        'Kemeja atau polo premium sebagai basis',
        'Layer dengan blazer atau outer casual-formal',
        'Celana dengan cut yang rapi',
        'Sepatu yang lebih versatile'
      ],
      'focal_points': [
        'Kualitas material dari masing-masing piece',
        'Konsistensi level formalitas antar items',
        'Color coordination yang sophisticated',
        'Aksesoris yang subtly statement',
        'Detail finishing seperti rolling sleeves dengan rapi'
      ],
    },
    'semiformal_wanita': {
      'title': 'Semi-Formal Wanita',
      'description': 'Rekomendasi fashion smart casual untuk wanita dengan balans antara dressy dan casual.',
      'icon': 'star_circle',
      'color': Colors.cyan,
      'karakteristik': [
        'Elevated basics dengan satu statement piece',
        'Dress atau separates dengan cut yang flattering',
        'Permainan tekstur yang menarik',
        'Aksesoris yang menambah dimensi',
        'Level kerapian yang lebih tinggi dari casual'
      ],
      'focal_points': [
        'Transisi dari work wear ke evening look',
        'Ketepatan ukuran terutama di pinggang dan bahu',
        'Balance proporsi atas dan bawah',
        'Versatilitas untuk berbagai occasion',
        'Detail seperti tucking dan draping'
      ],
    },
    'formal_neutral': {
      'title': 'Formal Gender-Neutral',
      'description': 'Rekomendasi fashion formal untuk gaya non-binary dengan fokus pada struktur dan lines yang clean.',
      'icon': 'square_stack_3d_down_right',
      'color': Colors.deepPurple,
      'karakteristik': [
        'Siluet terstruktur dengan minimal gendered elements',
        'Clean lines dan potongan yang presisi',
        'Material premium dengan weight dan drape yang baik',
        'Warna-warna solid dengan coordinate yang sophisticated',
        'Detail yang subtle namun impactful'
      ],
      'focal_points': [
        'Fit yang tidak terlalu ketat ataupun longgar',
        'Tailoring yang presisi dan rapi',
        'Penempatan seam dan struktur yang mindful',
        'Perpaduan elements structured dan flowing',
        'Experimentasi dengan proporsi non-tradisional'
      ],
    },
    'casual_neutral': {
      'title': 'Casual Gender-Neutral',
      'description': 'Rekomendasi fashion casual untuk gaya non-binary dengan keseimbangan antara comfort dan personal expression.',
      'icon': 'square_on_square',
      'color': Colors.blueGrey,
      'karakteristik': [
        'Siluet yang flexible dan non-restrictive',
        'Oversized maupun fitted items sesuai preferensi',
        'Material dengan texture dan weight yang beragam',
        'Permainan layer untuk dimensi visual',
        'Mix and match antara pieces dengan shape berbeda'
      ],
      'focal_points': [
        'Proporsi yang balance antara top dan bottom',
        'Experimentasi dengan silhouette non-tradisional',
        'Personal color palette yang konsisten',
        'Styling kreatif seperti half-tuck atau rolling',
        'Aksesoris yang menambah dimensi personal style'
      ],
    },
  };
}

class OutputPageFashion extends StatefulWidget {
  const OutputPageFashion({super.key});

  @override
  _OutputPageFashionState createState() => _OutputPageFashionState();
}

class _OutputPageFashionState extends State<OutputPageFashion> with SingleTickerProviderStateMixin {
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
                  'REKOMENDASI FASHION STYLE',
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
                'Hasil Analisis Preferensi:',
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
                  'Style Direction: ${_analysisResult!['analysis']['style_direction']}',
                ),
              pw.SizedBox(height: 5),
              if (_analysisResult != null)
                pw.Text(
                  'Color Palette: ${_analysisResult!['analysis']['color_palette']}',
                ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Rekomendasi Fashion:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              
              // Rekomendasi fashion
              if (_recommendationData != null)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Top Options:'),
                    pw.Text(_recommendationData!['top_options'] ?? ''),
                    pw.SizedBox(height: 5),
                    pw.Text('Bottom Options:'),
                    pw.Text(_recommendationData!['bottom_options'] ?? ''),
                    pw.SizedBox(height: 5),
                    pw.Text('Outer Options:'),
                    pw.Text(_recommendationData!['outer_options'] ?? ''),
                    pw.SizedBox(height: 5),
                    pw.Text('Shoes Options:'),
                    pw.Text(_recommendationData!['shoes_options'] ?? ''),
                    pw.SizedBox(height: 5),
                    pw.Text('Accessories Options:'),
                    pw.Text(_recommendationData!['accessories_options'] ?? ''),
                    pw.SizedBox(height: 5),
                    pw.Text('Styling Tips:'),
                    pw.Text(_recommendationData!['styling_tips'] ?? ''),
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
                'Rekomendasi fashion ini berdasarkan informasi yang Anda berikan. Gunakan sebagai inspirasi dan sesuaikan dengan preferensi personal Anda. Fashion adalah bentuk ekspresi diri, jadi jangan takut untuk bereksperimen dan menemukan gaya yang paling mencerminkan diri Anda.',
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
    final file = File('${output.path}/rekomendasi_fashion.pdf');
    await file.writeAsBytes(await pdf.save());
    
    return file;
  }

  // Bagikan hasil rekomendasi
  Future<void> _shareResults() async {
    try {
      final pdfFile = await _generatePDF();
      
      await Share.shareXFiles(
        [XFile(pdfFile.path)],
        text: 'Rekomendasi Fashion Style Untukmu',
        subject: 'Rekomendasi Fashion - ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
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
      final result = await DatabaseHelperFashion.instance.getLatestAnalysisResult();
      
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
    return FashionCategories.categoryInfo[category]?['title'] ?? 'Casual Style';
  }

  Color _getCategoryColor(String category) {
    return FashionCategories.categoryInfo[category]?['color'] ?? const Color(0xFF64D1DE);
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'suit_diamond':
        return CupertinoIcons.suit_diamond_fill;
      case 'person':
        return CupertinoIcons.person_fill;
      case 'heart':
        return CupertinoIcons.heart_fill;
      case 'heart_circle':
        return CupertinoIcons.heart_circle_fill;
      case 'star':
        return CupertinoIcons.star_fill;
      case 'star_circle':
        return CupertinoIcons.star_circle_fill;
      case 'square_stack_3d_down_right':
        return CupertinoIcons.square_stack_3d_down_right_fill;
      case 'square_on_square':
        return CupertinoIcons.square_on_square;
      default:
        return CupertinoIcons.person_crop_circle_fill;
    }
  }
  
  Widget _buildStyleDirectionWidget(String styleDirection, String category) {
    final Color categoryColor = _getCategoryColor(category);
    
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          margin: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                categoryColor.withValues(alpha: 0.7),
                categoryColor.withValues(alpha: 0.4),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: categoryColor.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Style Direction',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                styleDirection,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResultCard() {
    if (_analysisResult == null) return const SizedBox();
    
    final analysis = _analysisResult!['analysis'];
    final String category = analysis['main_category'];
    final String colorPalette = analysis['color_palette'];
    
    final Map<String, dynamic>? info = FashionCategories.categoryInfo[category];
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
                    info != null ? _getIconData(info['icon']) : CupertinoIcons.person_crop_circle_fill,
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
                            CupertinoIcons.paintbrush_fill,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              'Color Palette: $colorPalette',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
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
                'Focal Points:',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              ...List.generate(
                (info['focal_points'] as List<String>).length,
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
                          info['focal_points'][index],
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
              'Rekomendasi Outfit',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: categoryColor,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            
            // Top Options
            _buildFashionItem(
              icon: CupertinoIcons.person,
              title: 'Atasan',
              description: _recommendationData!['top_options'] ?? '',
              color: categoryColor,
            ),
            
            // Bottom Options
            _buildFashionItem(
              icon: CupertinoIcons.square_stack_fill,
              title: 'Bawahan',
              description: _recommendationData!['bottom_options'] ?? '',
              color: categoryColor,
            ),
            
            // Outer Options
            _buildFashionItem(
              icon: CupertinoIcons.square_line_vertical_square_fill,
              title: 'Outer Layer',
              description: _recommendationData!['outer_options'] ?? '',
              color: categoryColor,
            ),
            
            // Shoes Options
            _buildFashionItem(
              icon: CupertinoIcons.rectangle_fill_on_rectangle_angled_fill,
              title: 'Sepatu',
              description: _recommendationData!['shoes_options'] ?? '',
              color: categoryColor,
            ),
            
            // Accessories Options
            _buildFashionItem(
              icon: CupertinoIcons.bag_fill,
              title: 'Aksesoris',
              description: _recommendationData!['accessories_options'] ?? '',
              color: categoryColor,
            ),
            
            const Divider(),
            const SizedBox(height: 16),
            
            // Styling Tips
            Text(
              'Tips Styling',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _recommendationData!['styling_tips'] ?? '',
              style: GoogleFonts.poppins(
                fontSize: 14,
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Color Coordination
            Text(
              'Koordinasi Warna',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _recommendationData!['color_coordination'] ?? '',
              style: GoogleFonts.poppins(
                fontSize: 14,
                height: 1.5,
                color: Colors.indigo.shade700,
              ),
            ),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            
            // Occasion Specific
            Text(
              'Rekomendasi Spesifik per Acara',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _recommendationData!['occasion_specific'] ?? '',
              style: GoogleFonts.poppins(
                fontSize: 14,
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Body Type Tips
            Text(
              'Tips Berdasarkan Bentuk Tubuh',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _recommendationData!['body_type_tips'] ?? '',
              style: GoogleFonts.poppins(
                fontSize: 14,
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Seasonal Adaptation
            Text(
              'Adaptasi Musim',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _recommendationData!['seasonal_adaptation'] ?? '',
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

  Widget _buildFashionItem({
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
          Icon(CupertinoIcons.lightbulb_fill, 
               color: Colors.purple.shade800),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fashion Tip',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.purple.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rekomendasi ini adalah inspirasi untuk Anda. Fashion adalah bentuk ekspresi diri, jadi eksperimen dan adaptasi sesuai dengan personal style Anda adalah kunci untuk tampil percaya diri.',
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
            CupertinoIcons.person_crop_circle_badge_xmark,
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
                    
                    // Style direction visual
                    if (_analysisResult != null)
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildStyleDirectionWidget(
                          _analysisResult!['analysis']['style_direction'],
                          _analysisResult!['analysis']['main_category'],
                        ),
                      ),
                    
                    const SizedBox(height: 16),
                    
                    // Hasil analisis
                    if (_analysisResult != null)
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Center(
                          child: Text(
                            'Hasil analisis preferensi style:',
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
                          'Detail Style Recommendation',
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
                    
                    // Rekomendasi fashion
                    if (_recommendationData != null)
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          'Rekomendasi Outfit',
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