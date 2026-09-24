import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:primafit/database/kewanitaan/database_testpack.dart'; // Sesuaikan dengan path database
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class StatusKehamilan {
  // Map untuk informasi tambahan setiap kategori
  static final Map<String, Map<String, String>> kategoriInfo = {
    'Kemungkinan Besar Hamil': {
      'description': 'Berdasarkan gejala yang Anda alami, terdapat kemungkinan besar Anda sedang hamil. Sebagian besar gejala umum kehamilan terdeteksi.',
      'treatment': 'Segera lakukan tes kehamilan atau konsultasi dengan dokter atau bidan untuk konfirmasi kehamilan dan pemeriksaan lebih lanjut.',
      'icon': 'checkmark_shield_fill',
    },
    'Kemungkinan Hamil': {
      'description': 'Berdasarkan gejala yang Anda alami, terdapat kemungkinan Anda sedang hamil. Beberapa gejala kehamilan terdeteksi namun belum cukup untuk konfirmasi kehamilan.',
      'treatment': 'Sebaiknya lakukan tes kehamilan rumahan terlebih dahulu, dan jika positif atau meragukan, konsultasikan dengan tenaga medis profesional.',
      'icon': 'exclamationmark_shield',
    },
    'Kemungkinan Kecil Hamil': {
      'description': 'Berdasarkan gejala yang Anda alami, kemungkinan kehamilan ada namun relatif kecil. Hanya sedikit gejala kehamilan yang terdeteksi.',
      'treatment': 'Anda bisa menunggu beberapa hari lagi dan memperhatikan gejala lain yang muncul. Jika ragu, lakukan tes kehamilan rumahan.',
      'icon': 'waveform_path',
    },
    'Kemungkinan Tidak Hamil': {
      'description': 'Berdasarkan jawaban Anda, hampir tidak ada gejala kehamilan yang terdeteksi. Kemungkinan Anda tidak dalam kondisi hamil saat ini.',
      'treatment': 'Jika ada keterlambatan menstruasi yang berkelanjutan tanpa gejala kehamilan, bisa jadi disebabkan oleh faktor lain seperti stres atau gangguan hormonal. Konsultasikan dengan dokter jika kekhawatiran berlanjut.',
      'icon': 'exclamationmark_shield_fill',
    },
  };
}

class OutputPageKehamilan extends StatefulWidget {
  const OutputPageKehamilan({Key? key}) : super(key: key);

  @override
  _OutputPageKehamilanState createState() => _OutputPageKehamilanState();
}

class _OutputPageKehamilanState extends State<OutputPageKehamilan> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  late Animation<double> _fadeAnimation;
  
  List<Map<String, dynamic>> _diagnosisResults = [];
  bool _isLoading = true;
  bool _noResults = false;
  final double _threshold = 20.0; // Sesuaikan threshold untuk setidaknya mendapatkan kategori "Kemungkinan Kecil Hamil"
  
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
    
    _loadDiagnosisResults();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Fungsi untuk membuat PDF hasil diagnosis
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
                  'HASIL ANALISIS KEMUNGKINAN KEHAMILAN',
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
                'Hasil Evaluasi:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                _diagnosisResults.isNotEmpty ? _diagnosisResults[0]['kategori'] : 'Tidak ada hasil',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'Persentase kemungkinan: ${_diagnosisResults.isNotEmpty ? _diagnosisResults[0]['persentase'].toStringAsFixed(1) : 0}%',
              ),
              pw.SizedBox(height: 20),
              if (_diagnosisResults.isNotEmpty && StatusKehamilan.kategoriInfo.containsKey(_diagnosisResults[0]['kategori']))
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Keterangan:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      StatusKehamilan.kategoriInfo[_diagnosisResults[0]['kategori']]!['description'] ?? '',
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'Rekomendasi:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      StatusKehamilan.kategoriInfo[_diagnosisResults[0]['kategori']]!['treatment'] ?? '',
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
                'Hasil analisis ini hanya sebagai rujukan awal berdasarkan gejala yang diidentifikasi. Tes kehamilan resmi dan konsultasi dengan dokter atau bidan adalah satu-satunya cara untuk mengkonfirmasi kehamilan dengan tepat. Segera hubungi profesional kesehatan untuk diagnosis akurat.',
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
    final file = File('${output.path}/hasil_analisis_kehamilan.pdf');
    await file.writeAsBytes(await pdf.save());
    
    return file;
  }

  // Bagikan hasil diagnosa
  Future<void> _shareResults() async {
    try {
      final pdfFile = await _generatePDF();
      
      await Share.shareXFiles(
        [XFile(pdfFile.path)],
        text: 'Hasil Analisis Kemungkinan Kehamilan',
        subject: 'Analisis Kemungkinan Kehamilan - ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal membagikan hasil analisis: $e',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadDiagnosisResults() async {
    try {
      final results = await DatabaseHelperKehamilan.instance.getDiagnosisResult(_threshold);
      
      if (!mounted) return;
      
      setState(() {
        _diagnosisResults = results;
        _isLoading = false;
        _noResults = results.isEmpty;
      });
      
      if (results.isNotEmpty) {
        _animationController.forward();
      }
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isLoading = false;
        _noResults = true;
      });
      debugPrint('Error loading diagnosis results: $e');
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'waveform_path':
        return CupertinoIcons.waveform_path;
      case 'waveform_path_ecg':
        return CupertinoIcons.waveform_path_ecg;
      case 'wind':
        return CupertinoIcons.wind;
      case 'drop_fill':
        return CupertinoIcons.drop_fill;
      case 'exclamationmark_shield':
        return CupertinoIcons.exclamationmark_shield;
      case 'exclamationmark_shield_fill':
        return CupertinoIcons.exclamationmark_shield_fill;
      case 'checkmark_shield_fill':
        return CupertinoIcons.checkmark_shield_fill;
      case 'arrow_circlepath':
        return CupertinoIcons.arrow_2_circlepath;
      case 'bed_double_fill':
        return CupertinoIcons.bed_double_fill;
      default:
        return CupertinoIcons.question_circle;
    }
  }

  // Mendapatkan warna berdasarkan kategori kehamilan
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Kemungkinan Besar Hamil':
        return Colors.green;
      case 'Kemungkinan Hamil':
        return Colors.blue;
      case 'Kemungkinan Kecil Hamil':
        return Colors.orange;
      case 'Kemungkinan Tidak Hamil':
        return Colors.grey.shade700;
      default:
        return const Color(0xFFE9458D); // Warna default biru untuk tema kehamilan
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
                    'Kemungkinan',
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

  Widget _buildResultCard(Map<String, dynamic> result) {
    final String kategori = result['kategori'];
    final double persentase = result['persentase'];
    final Map<String, String>? info = StatusKehamilan.kategoriInfo[kategori];
    final Color categoryColor = _getCategoryColor(kategori);
    
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
                    info != null ? _getIconData(info['icon'] ?? 'waveform_path') : CupertinoIcons.waveform_path,
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
                        kategori,
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
                            'Tingkat kemungkinan: ${persentase.toStringAsFixed(1)}%',
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
                'Rekomendasi:',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                info['treatment'] ?? '',
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
                    'Peringatan Medis',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hasil analisis ini hanya sebagai rujukan awal berdasarkan gejala yang diidentifikasi. Tes kehamilan resmi dan konsultasi dengan dokter atau bidan adalah satu-satunya cara untuk mengkonfirmasi kehamilan dengan tepat.',
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
              label: const Text('Kembali ke Diagnosa'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFFE9458D),
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
        backgroundColor: const Color(0xFFE9458D),
        elevation: 0,
        title: Text(
          'Hasil Analisis Kehamilan',
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
            onPressed: _diagnosisResults.isEmpty ? null : _shareResults,
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
                      // Tanggal diagnosa
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.calendar,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Tanggal analisis: $formattedDate',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Visual circle progress
                      if (_diagnosisResults.isNotEmpty)
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Center(
                            child: _buildProgressCircle(
                              _diagnosisResults[0]['persentase'], 
                              _diagnosisResults[0]['kategori']
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 16),
                      
                      // Hasil diagnosa
                      if (_diagnosisResults.isNotEmpty)
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Center(
                            child: Text(
                              'Hasil analisis:',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 8),
                      
                      // Nama kategori
                      if (_diagnosisResults.isNotEmpty)
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Center(
                            child: Text(
                              _diagnosisResults[0]['kategori'],
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: _getCategoryColor(_diagnosisResults[0]['kategori']),
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
                      
                      // Detail hasil
                      if (_diagnosisResults.isNotEmpty)
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Text(
                            'Detail Hasil Analisis',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 8),
                      
                      // Card detail
                      if (_diagnosisResults.isNotEmpty)
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: _buildResultCard(_diagnosisResults[0]),
                        ),
                      
                      const SizedBox(height: 16),
                      
                      // Tombol tindakan
                      if (_diagnosisResults.isNotEmpty)
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
                                  backgroundColor: const Color(0xFFE9458D),
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
                                  foregroundColor: const Color(0xFFE9458D),
                                  side: const BorderSide(color: Color(0xFFE9458D)),
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