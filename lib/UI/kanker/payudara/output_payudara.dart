import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:primafit/database/kanker/database_payudara.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class PenyakitPayudara {
  // Map untuk informasi tambahan setiap kategori risiko
  static final Map<String, Map<String, String>> penyakitInfo = {
    'Risiko Tinggi': { //Persentase lebih dari 80%
      'description': 'Anda memiliki faktor risiko yang signifikan untuk kanker payudara. Diperlukan pemeriksaan lanjutan seperti mammografi dan konsultasi ke spesialis onkologi segera.',
      'treatment': 'Segera lakukan pemeriksaan mammografi/USG payudara, konsultasi dengan dokter spesialis, dan pertimbangkan melakukan SADARI (pemeriksaan payudara sendiri) secara rutin.',
      'icon': 'exclamationmark_shield_fill',
    },
    'Risiko Sedang': { //Persentase lebih dari 50% dan kurang dari 80%
      'description': 'Anda memiliki beberapa faktor risiko untuk kanker payudara. Disarankan untuk melakukan pemantauan rutin dan pemeriksaan lebih lanjut.',
      'treatment': 'Lakukan pemeriksaan payudara secara rutin, konsultasi dengan dokter untuk penjadwalan mammografi/USG, dan pelajari cara SADARI yang benar.',
      'icon': 'exclamationmark_shield',
    },
    'Risiko Rendah': { //Persentase lebih dari 20% dan kurang dari 50%
      'description': 'Faktor risiko Anda terhadap kanker payudara terdeteksi minimal. Tetap jaga gaya hidup sehat dan lakukan pemeriksaan rutin.',
      'treatment': 'Lakukan SADARI setiap bulan setelah menstruasi, pertahankan berat badan ideal, dan lakukan pemeriksaan payudara klinis setiap tahun.',
      'icon': 'waveform_path',
    },
    'Tidak Ada Risiko': { //Persentase kurang dari 20%
      'description': 'Tidak ditemukan faktor risiko signifikan kanker payudara berdasarkan jawaban Anda. Tetap lakukan pemeriksaan rutin untuk pencegahan.',
      'treatment': 'Tetap jaga gaya hidup sehat, hindari alkohol, pertahankan berat badan ideal, dan tetap waspada dengan SADARI secara berkala.',
      'icon': 'checkmark_shield_fill',
    },
  };
}

class OutputPagePayudara extends StatefulWidget {
  const OutputPagePayudara({Key? key}) : super(key: key);

  @override
  _OutputPagePayudaraState createState() => _OutputPagePayudaraState();
}

class _OutputPagePayudaraState extends State<OutputPagePayudara> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  late Animation<double> _fadeAnimation;
  
  List<Map<String, dynamic>> _diagnosisResults = [];
  bool _isLoading = true;
  bool _noResults = false;
  final double _threshold = 20.0; // Sesuaikan threshold untuk setidaknya mendapatkan kategori "Risiko Rendah"
  
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
                  'HASIL DIAGNOSA RISIKO KANKER PAYUDARA',
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
                'Hasil Evaluasi Risiko:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                _diagnosisResults.isNotEmpty ? _diagnosisResults[0]['penyakit'] : 'Tidak ada hasil',
                style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'Persentase risiko: ${_diagnosisResults.isNotEmpty ? _diagnosisResults[0]['persentase'].toStringAsFixed(1) : 0}%',
              ),
              pw.SizedBox(height: 20),
              if (_diagnosisResults.isNotEmpty && PenyakitPayudara.penyakitInfo.containsKey(_diagnosisResults[0]['penyakit']))
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Keterangan:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      PenyakitPayudara.penyakitInfo[_diagnosisResults[0]['penyakit']]!['description'] ?? '',
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'Rekomendasi:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      PenyakitPayudara.penyakitInfo[_diagnosisResults[0]['penyakit']]!['treatment'] ?? '',
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
                'Hasil diagnosa ini hanya sebagai rujukan awal berdasarkan faktor risiko yang diidentifikasi. Konsultasikan dengan dokter atau tenaga medis profesional untuk diagnosis dan pengobatan yang tepat. SADARI (Periksa Payudara Sendiri) sebaiknya dilakukan secara rutin setiap bulan.',
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
    final file = File('${output.path}/hasil_analisis_risiko_kanker_payudara.pdf');
    await file.writeAsBytes(await pdf.save());
    
    return file;
  }

  // Bagikan hasil diagnosa
  Future<void> _shareResults() async {
    try {
      final pdfFile = await _generatePDF();
      
      await Share.shareXFiles(
        [XFile(pdfFile.path)],
        text: 'Hasil Analisis Risiko Kanker Payudara',
        subject: 'Analisis Risiko Kanker Payudara - ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal membagikan hasil diagnosa: $e',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _loadDiagnosisResults() async {
    try {
      final results = await DatabaseHelperPayudara.instance.getDiagnosisResult(_threshold);
      
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

  // Mendapatkan warna berdasarkan kategori risiko
  Color _getRiskColor(String riskCategory) {
    switch (riskCategory) {
      case 'Risiko Tinggi':
        return Colors.red;
      case 'Risiko Sedang':
        return Colors.orange;
      case 'Risiko Rendah':
        return Colors.yellow.shade700;
      case 'Tidak Ada Risiko':
        return Colors.green;
      default:
        return const Color(0xFF64D1DE); // Pink color for breast cancer theme
    }
  }

  Widget _buildProgressCircle(double percentage, String riskCategory) {
    final Color progressColor = _getRiskColor(riskCategory);
    
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
                    'Risiko',
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
    final String penyakit = result['penyakit'];
    final double persentase = result['persentase'];
    final Map<String, String>? info = PenyakitPayudara.penyakitInfo[penyakit];
    final Color riskColor = _getRiskColor(penyakit);
    
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
                    color: riskColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    info != null ? _getIconData(info['icon'] ?? 'waveform_path') : CupertinoIcons.waveform_path,
                    size: 30,
                    color: riskColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        penyakit,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: riskColor,
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
                            'Tingkat risiko: ${persentase.toStringAsFixed(1)}%',
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
      color: Colors.pink.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.pink.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(CupertinoIcons.exclamationmark_triangle_fill, 
                 color: Colors.pink.shade800),
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
                      color: Colors.pink.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hasil diagnosa ini hanya sebagai rujukan awal berdasarkan faktor risiko yang diidentifikasi. Konsultasikan dengan dokter atau tenaga medis profesional untuk diagnosis dan pengobatan yang tepat.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.pink.shade900,
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
                'Terjadi kesalahan saat memproses jawaban Anda. Silakan coba lagi dengan melakukan diagnosa ulang.',
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
          'Hasil Analisis Risiko',
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
                              _diagnosisResults[0]['penyakit']
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
                      
                      // Nama kategori risiko
                      if (_diagnosisResults.isNotEmpty)
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Center(
                            child: Text(
                              _diagnosisResults[0]['penyakit'],
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: _getRiskColor(_diagnosisResults[0]['penyakit']),
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
                      
                      // Card detail risiko
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