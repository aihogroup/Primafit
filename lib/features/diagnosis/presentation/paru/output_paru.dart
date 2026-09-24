import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:primafit/features/diagnosis/data/database_paru.dart';
import 'package:share_plus/share_plus.dart';
// ignore: unused_import
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:primafit/features/diagnosis/presentation/paru/list_penyakit.dart';

class OutputPage extends StatefulWidget {
  const OutputPage({super.key});

  @override
  _OutputPageState createState() => _OutputPageState();
}

class _OutputPageState extends State<OutputPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  late Animation<double> _fadeAnimation;
  Map<String, dynamic> getTopResult(List<Map<String, dynamic>> results) {
  if (results.isEmpty) return {};
  return results.reduce((curr, next) => curr['persentase'] > next['persentase'] ? curr : next);
  }
  List<Map<String, dynamic>> _diagnosisResults = [];
  bool _isLoading = true;
  bool _noResults = false;
  final double _threshold = 50.0; // 50% threshold untuk meningkatkan kemungkinan mendapatkan hasil

  // Map gejala untuk tampilan sesuai dengan list_pertanyaan.dart
  // final Map<String, String> _gejalaMapping = {
  //   'batuk': 'Batuk',
  //   'batuk_berdahak': 'Batuk Berdahak',
  //   'dahak_kuning': 'Dahak Berwarna Kuning',
  //   'dahak_hijau': 'Dahak Berwarna Hijau',
  //   'batuk_berdarah': 'Batuk Berdarah',
  //   'batuk_kronis': 'Batuk Kronis',
  //   'sesak_nafas': 'Sesak Nafas',
  //   'sesak_saat_istirahat': 'Sesak Saat Istirahat',
  //   'sesak_saat_berbaring': 'Sesak Saat Berbaring',
  //   'nyeri_dada': 'Nyeri Dada',
  //   'nyeri_pleuritik': 'Nyeri Pleuritik',
  //   'bunyi_nafas': 'Bunyi Pada Nafas',
  //   'bunyi_mengi': 'Bunyi Mengi (Seperti Siulan)',
  //   'bunyi_ronchi': 'Bunyi Ronchi (Seperti Dengkuran)',
  //   'penurunan_bb_drastis': 'Penurunan BB Drastis',
  //   'demam': 'Demam',
  //   'demam_pola': 'Demam Berpola',
  //   'keringat_malam': 'Keringat Malam',
  //   'kelelahan_berkepanjangan': 'Kelelahan Berkepanjangan',
  //   'sianosis': 'Sianosis (Bibir/Ujung Jari Membiru)',
  //   'riwayat_merokok': 'Riwayat Merokok',
  // };
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
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
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'HASIL DIAGNOSA PENYAKIT PARU',
                  style: pw.TextStyle(
                    fontSize: 18, 
                    fontWeight: pw.FontWeight.bold
                  ),
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Tanggal: ${DateFormat('dd MMMM yyyy, HH:mm').format(DateTime.now())}'),
              pw.SizedBox(height: 20),
              pw.Text(
                'Kemungkinan Penyakit:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                _diagnosisResults.isNotEmpty ? _diagnosisResults[0]['penyakit'] : 'Tidak ada hasil',
                style: pw.TextStyle(fontSize: 16),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'Persentase kecocokan: ${_diagnosisResults.isNotEmpty ? _diagnosisResults[0]['persentase'].toStringAsFixed(1) : 0}%',
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Catatan Penting:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 5),
              pw.Text(
                'Hasil diagnosa ini hanya sebagai rujukan awal. Konsultasikan dengan dokter atau tenaga medis profesional untuk diagnosis dan pengobatan yang tepat.',
                style: pw.TextStyle(
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
              pw.SizedBox(height: 20),
              if (_diagnosisResults.isNotEmpty && PenyakitParu.penyakitInfo.containsKey(_diagnosisResults[0]['penyakit']))
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Deskripsi Penyakit:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      PenyakitParu.penyakitInfo[_diagnosisResults[0]['penyakit']]!['description'] ?? '',
                    ),
                    pw.SizedBox(height: 10),
                    pw.Text(
                      'Penanganan:',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(height: 5),
                    pw.Text(
                      PenyakitParu.penyakitInfo[_diagnosisResults[0]['penyakit']]!['treatment'] ?? '',
                    ),
                  ],
                ),
            ],
          );
        },
      ),
    );
    
    // Simpan PDF
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/hasil_diagnosa_paru.pdf');
    await file.writeAsBytes(await pdf.save());
    
    return file;
  }

  // Bagikan hasil diagnosa
  Future<void> _shareResults() async {
    try {
      final pdfFile = await _generatePDF();
      
      await Share.shareXFiles(
        [XFile(pdfFile.path)],
        text: 'Hasil Diagnosa Penyakit Paru',
        subject: 'Hasil Diagnosa Penyakit Paru - ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
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
      final results = await DatabaseHelper.instance.getDiagnosisResult(_threshold);
      
      setState(() {
        _diagnosisResults = results;
        _isLoading = false;
        _noResults = results.isEmpty;
      });
      
      if (results.isNotEmpty) {
        _animationController.forward();
      }
    } catch (e) {
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
      case 'arrow_circlepath':
        return CupertinoIcons.arrow_2_circlepath;
      case 'bed_double_fill':
        return CupertinoIcons.bed_double_fill;
      default:
        return CupertinoIcons.question_circle;
    }
  }

  Widget _buildProgressCircle(double percentage) {
  return AnimatedBuilder(
    animation: _progressAnimation,
    builder: (context, child) {
      return CustomPaint(
        size: const Size(250, 250), // Ubah ukuran di sini
        painter: CircleProgressPainter(
          percentage: _progressAnimation.value * percentage / 100,
          strokeWidth: 30,
          backgroundColor: Colors.grey.shade200,
          progressColor: const Color(0xFF64D1DE),
        ),
        child: SizedBox(
          width: 250,
          height: 250,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(_progressAnimation.value * percentage).toInt()}%',
                  style: GoogleFonts.poppins(
                    fontSize: 40, // Perbesar juga teks biar proporsional
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF64D1DE),
                  ),
                ),
                Text(
                  'Kecocokan',
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
    final Map<String, String>? info = PenyakitParu.penyakitInfo[penyakit];
    
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      elevation: 5,
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
                    color: const Color(0xFF64D1DE).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    info != null ? _getIconData(info['icon'] ?? 'waveform_path') : CupertinoIcons.waveform_path,
                    size: 30,
                    color: const Color(0xFF64D1DE),
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
                            'Kemungkinan: ${persentase.toStringAsFixed(1)}%',
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
                'Penanganan:',
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
      color: Colors.orange.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.orange.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(CupertinoIcons.exclamationmark_triangle_fill, 
                 color: Colors.orange.shade800),
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
                      color: Colors.orange.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hasil diagnosa ini hanya sebagai rujukan awal. Konsultasikan dengan dokter atau tenaga medis profesional untuk diagnosis dan pengobatan yang tepat.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.orange.shade900,
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
              'Tidak ditemukan diagnosa yang cocok',
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
                'Gejala yang Anda alami tidak memiliki kecocokan lebih dari 50% dengan penyakit dalam database kami.',
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
    final topResult = getTopResult(_diagnosisResults); // 'results' adalah list Map hasil diagnosa
    final now = DateTime.now();
    final dateFormat = DateFormat('dd MMMM yyyy, HH:mm');
    final formattedDate = dateFormat.format(now);
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFF64D1DE),
        elevation: 0,
        title: Text(
          'Hasil Diagnosa',
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
      // floatingActionButton: _isLoading || _noResults ? null : FloatingActionButton.extended(
      //   onPressed: () {
      //     Navigator.pop(context);
      //   },
      //   backgroundColor: const Color(0xFF64D1DE),
      //   icon: const Icon(CupertinoIcons.refresh),
      //   label: Text(
      //     'Diagnosa Ulang',
      //     style: GoogleFonts.poppins(),
      //   ),
      // ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CupertinoActivityIndicator(radius: 20),
                  const SizedBox(height: 20),
                  Text(
                    'Menganalisis hasil diagnosa...',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
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
                            'Tanggal diagnosa: $formattedDate',
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
                            child: _buildProgressCircle(_diagnosisResults[0]['persentase']),
                          ),
                        ),
                      
                      const SizedBox(height: 16),
                      
                      // Hasil diagnosa
                      if (_diagnosisResults.isNotEmpty)
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Center(
                            child: Text(
                              'Kemungkinan penyakit:',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 8),
                      
                      // Nama penyakit utama
                      if (_diagnosisResults.isNotEmpty)
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Center(
                            child: Text(
                              _diagnosisResults[0]['penyakit'],
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
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
                            'Detail Hasil Diagnosa',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 8),
                      
                      // Card detail penyakit
                      // if (_diagnosisResults.isNotEmpty)
                      //   ...List.generate(_diagnosisResults.length, (index) {
                      //     return FadeTransition(
                      //       opacity: _fadeAnimation,
                      //       child: _buildResultCard(topResult),
                      //     );
                      //   }),
                      if (topResult.isNotEmpty)
                      _buildResultCard(topResult),

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
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    
    canvas.drawCircle(center, radius, backgroundPaint);

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
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}