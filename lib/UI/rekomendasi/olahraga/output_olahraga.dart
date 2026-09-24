import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:primafit/database/rekomendasi/database_olahraga.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class ExerciseCategories {
  // Map untuk informasi tambahan setiap kategori program olahraga
  static final Map<String, Map<String, dynamic>> categoryInfo = {
    'dewasa_aktif': {
      'title': 'Dewasa Aktif',
      'description': 'Program olahraga untuk dewasa usia 19-50 tahun dengan level aktivitas sedang hingga tinggi.',
      'icon': 'flame',
      'color': Colors.orange,
      'karakteristik': [
        'Kapasitas pemulihan optimal',
        'Kemampuan adaptasi tinggi terhadap stimulus latihan',
        'Kebutuhan variasi program untuk mencegah kebosanan',
        'Kemampuan menanggapi intensitas tinggi',
        'Toleransi beban latihan yang baik'
      ],
      'fokus_latihan': [
        'Kombinasi latihan kardio dan kekuatan',
        'Latihan intensitas tinggi untuk efisiensi waktu',
        'Variasi stimulus untuk adaptasi optimal',
        'Periodisasi program untuk mencapai tujuan spesifik',
        'Fleksibilitas dan mobilitas untuk mencegah cedera'
      ],
    },
    'dewasa_senior': {
      'title': 'Dewasa Senior',
      'description': 'Program olahraga untuk dewasa usia 51-64 tahun dengan fokus pada kesehatan jangka panjang dan pemeliharaan fungsi tubuh.',
      'icon': 'person_crop_circle',
      'color': Colors.blue,
      'karakteristik': [
        'Pemulihan lebih lama setelah latihan intensif',
        'Penurunan kepadatan tulang dan massa otot alami',
        'Penurunan fleksibilitas dan mobilitas sendi',
        'Potensi kondisi kesehatan yang perlu dipertimbangkan',
        'Pengalaman dan kesadaran tubuh yang baik'
      ],
      'fokus_latihan': [
        'Latihan kekuatan untuk mencegah sarcopenia',
        'Latihan keseimbangan untuk mencegah jatuh',
        'Aktivitas kardio moderat untuk kesehatan jantung',
        'Fleksibilitas dan ROM untuk mobilitas',
        'Konsistensi di atas intensitas'
      ],
    },
    'lansia': {
      'title': 'Lansia',
      'description': 'Program olahraga untuk lansia usia 65+ tahun dengan fokus pada kemandirian, keseimbangan, dan pencegahan jatuh.',
      'icon': 'person_crop_circle',
      'color': Colors.purple,
      'karakteristik': [
        'Kebutuhan lebih besar untuk latihan keseimbangan',
        'Waktu pemulihan yang lebih lama',
        'Penurunan densitas tulang dan kekuatan otot',
        'Koordinasi dan waktu reaksi yang berkurang',
        'Potensi keterbatasan gerakan pada sendi tertentu'
      ],
      'fokus_latihan': [
        'Latihan fungsional untuk kemandirian sehari-hari',
        'Latihan keseimbangan dan stabilitas',
        'Kekuatan otot dengan beban ringan-sedang',
        'Aktivitas kardio dengan dampak rendah',
        'Mobilitas dan ROM sendi'
      ],
    },
    'remaja': {
      'title': 'Remaja',
      'description': 'Program olahraga untuk remaja usia 13-18 tahun dengan fokus pada perkembangan keterampilan dasar dan kebiasaan sehat.',
      'icon': 'person_2',
      'color': Colors.green,
      'karakteristik': [
        'Pertumbuhan cepat yang dapat mempengaruhi koordinasi',
        'Adaptasi cepat terhadap stimulus latihan',
        'Pemulihan relatif cepat',
        'Motivasi fluktuatif dan pengaruh teman sebaya',
        'Pembentukan kebiasaan jangka panjang'
      ],
      'fokus_latihan': [
        'Pengembangan pola gerak fundamental',
        'Variasi aktivitas untuk menemukan minat',
        'Keterampilan olahraga dasar dan koordinasi',
        'Kekuatan dengan teknik yang tepat',
        'Aktivitas sosial dan tim'
      ],
    },
    'anak': {
      'title': 'Anak-anak',
      'description': 'Program aktivitas fisik untuk anak usia 6-12 tahun dengan fokus pada kesenangan, keterampilan motorik, dan sosialisasi.',
      'icon': 'person_crop_circle_badge_plus',
      'color': Colors.teal,
      'karakteristik': [
        'Pengembangan keterampilan motorik dasar',
        'Kebutuhan aktivitas berbasis permainan',
        'Rentang perhatian yang lebih pendek',
        'Semangat dan energi tinggi',
        'Fleksibilitas alami tapi kekuatan terbatas'
      ],
      'fokus_latihan': [
        'Aktivitas bermain yang menyenangkan',
        'Pengembangan keterampilan gerakan dasar',
        'Variasi aktivitas untuk perkembangan menyeluruh',
        'Aktivitas kelompok untuk pengembangan sosial',
        'Membangun kesenangan dalam aktivitas fisik'
      ],
    },
    'kardio': {
      'title': 'Kesehatan Kardiovaskular',
      'description': 'Program olahraga untuk meningkatkan dan menjaga kesehatan jantung dan pembuluh darah.',
      'icon': 'heart',
      'color': Colors.red,
      'karakteristik': [
        'Kebutuhan monitoring intensitas yang cermat',
        'Progresi latihan yang sangat bertahap',
        'Penting memperhatikan tanda peringatan',
        'Pemanasan dan pendinginan lebih panjang',
        'Pertimbangan obat-obatan yang mungkin digunakan'
      ],
      'fokus_latihan': [
        'Kardio intensitas rendah-moderat berkelanjutan',
        'Interval training dengan intensitas terkontrol',
        'Latihan pernapasan',
        'Kekuatan dengan beban ringan dan repetisi lebih tinggi',
        'Manajemen stres melalui yoga dan meditasi'
      ],
    },
    'diabetes': {
      'title': 'Manajemen Diabetes',
      'description': 'Program olahraga untuk membantu mengontrol kadar gula darah dan meningkatkan sensitivitas insulin.',
      'icon': 'gauge',
      'color': Colors.amber,
      'karakteristik': [
        'Kebutuhan monitoring kadar gula darah',
        'Respons glukosa terhadap berbagai jenis latihan',
        'Pertimbangan komplikasi seperti neuropati',
        'Pentingnya rutinitas dan konsistensi',
        'Hidrasi yang adekuat'
      ],
      'fokus_latihan': [
        'Kombinasi kardio dan latihan kekuatan',
        'Latihan teratur dengan jadwal konsisten',
        'Aktivitas sepanjang hari versus satu sesi panjang',
        'Perhatian khusus pada kaki (untuk neuropati)',
        'Manajemen intensitas berbasis pembacaan glukosa'
      ],
    },
    'sendi': {
      'title': 'Kesehatan Sendi & Tulang',
      'description': 'Program olahraga untuk orang dengan masalah sendi atau tulang, fokus pada aktivitas low-impact dan penguatan.',
      'icon': 'bandage',
      'color': Colors.indigo,
      'karakteristik': [
        'Keterbatasan ROM pada sendi tertentu',
        'Potensi nyeri saat gerakan tertentu',
        'Kebutuhan pemulihan lebih lama',
        'Pentingnya stabilitas otot sekitar sendi',
        'Pertimbangan kondisi spesifik (artritis, osteoporosis)'
      ],
      'fokus_latihan': [
        'Aktivitas low-impact seperti berenang dan bersepeda',
        'Latihan stabilitas untuk mendukung sendi',
        'Kekuatan untuk otot-otot sekitar sendi yang bermasalah',
        'Fleksibilitas dan ROM dengan pendekatan hati-hati',
        'Hidrasi dan nutrisi untuk kesehatan tulang dan sendi'
      ],
    },
    'prenatal': {
      'title': 'Ibu Hamil & Pasca Melahirkan',
      'description': 'Program olahraga yang aman untuk ibu hamil dan pasca melahirkan dengan fokus pada kenyamanan dan kesehatan.',
      'icon': 'heart_circle',
      'color': Colors.pink,
      'karakteristik': [
        'Perubahan pusat gravitasi dan keseimbangan',
        'Peningkatan elastisitas ligamen (risiko cedera)',
        'Keterbatasan posisi tertentu berdasarkan trimester',
        'Kebutuhan kekuatan core dan dasar panggul',
        'Perubahan kapasitas kardiovaskular'
      ],
      'fokus_latihan': [
        'Latihan dasar panggul untuk pencegahan inkontinensia',
        'Aktivitas kardio low-impact',
        'Kekuatan untuk persiapan persalinan dan pemulihan',
        'Postur dan keseimbangan saat tubuh berubah',
        'Persiapan fisik untuk persalinan dan perawatan bayi'
      ],
    },
  };
}

class OutputPageExercise extends StatefulWidget {
  const OutputPageExercise({Key? key}) : super(key: key);

  @override
  _OutputPageExerciseState createState() => _OutputPageExerciseState();
}

class _OutputPageExerciseState extends State<OutputPageExercise> with SingleTickerProviderStateMixin {
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
                  'REKOMENDASI PROGRAM OLAHRAGA',
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
                  'Tingkat Program: ${_analysisResult!['analysis']['exercise_level']}',
                ),
              pw.SizedBox(height: 5),
              if (_analysisResult != null)
                pw.Text(
                  'Frekuensi: ${_analysisResult!['analysis']['recommended_frequency']} kali/minggu | Durasi: ${_analysisResult!['analysis']['recommended_exercise_minutes']} menit/sesi',
                ),
              pw.SizedBox(height: 5),
              if (_analysisResult != null)
                pw.Text(
                  'Intensitas: ${_analysisResult!['analysis']['recommended_intensity']} | Target HR: ${_analysisResult!['analysis']['targetHeartRate']['min']}-${_analysisResult!['analysis']['targetHeartRate']['max']} bpm',
                ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Rekomendasi Program:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 10),
              
              // Rekomendasi program
              if (_recommendationData != null)
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Program Kardio:'),
                    pw.Text(_recommendationData!['cardio_program'] ?? ''),
                    pw.SizedBox(height: 5),
                    pw.Text('Program Kekuatan:'),
                    pw.Text(_recommendationData!['strength_program'] ?? ''),
                    pw.SizedBox(height: 5),
                    pw.Text('Program Fleksibilitas:'),
                    pw.Text(_recommendationData!['flexibility_program'] ?? ''),
                    pw.SizedBox(height: 5),
                    pw.Text('Panduan Intensitas:'),
                    pw.Text(_recommendationData!['intensity_guidance'] ?? ''),
                    pw.SizedBox(height: 5),
                    pw.Text('Tips Pemanasan:'),
                    pw.Text(_recommendationData!['warm_up_tips'] ?? ''),
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
                'Rekomendasi program ini berdasarkan informasi yang Anda berikan. Selalu mulai pada level intensitas yang nyaman dan tingkatkan secara bertahap. Konsultasikan dengan profesional kesehatan sebelum memulai program olahraga baru jika Anda memiliki kondisi kesehatan khusus.',
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
    final file = File('${output.path}/rekomendasi_program_olahraga.pdf');
    await file.writeAsBytes(await pdf.save());
    
    return file;
  }

  // Bagikan hasil rekomendasi
  Future<void> _shareResults() async {
    try {
      final pdfFile = await _generatePDF();
      
      await Share.shareXFiles(
        [XFile(pdfFile.path)],
        text: 'Rekomendasi Program Olahraga Untukmu',
        subject: 'Rekomendasi Olahraga - ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
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
      final result = await DatabaseHelperExercise.instance.getLatestAnalysisResult();
      
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
    return ExerciseCategories.categoryInfo[category]?['title'] ?? 'Dewasa Aktif';
  }

  Color _getCategoryColor(String category) {
    return ExerciseCategories.categoryInfo[category]?['color'] ?? const Color(0xFF64D1DE);
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
      case 'heart':
        return CupertinoIcons.heart_fill;
      case 'gauge':
        return CupertinoIcons.gauge_badge_plus;
      case 'bandage':
        return CupertinoIcons.bandage_fill;
      default:
        return CupertinoIcons.circle_grid_3x3_fill;
    }
  }
  
  Widget _buildFrequencyProgressCircle(int frequency, String category) {
    final Color progressColor = _getCategoryColor(category);
    // Assuming max frequency around 7 for visualization purposes
    final double percentage = frequency / 7;
    
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
                    '${(_progressAnimation.value * frequency).toInt()}',
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: progressColor,
                    ),
                  ),
                  Text(
                    'kali/minggu',
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
    final int frequency = analysis['recommended_frequency'];
    final int minutes = analysis['recommended_exercise_minutes'];
    final String intensity = analysis['recommended_intensity'];
    final Map<String, dynamic> heartRate = analysis['targetHeartRate'];
    final String exerciseLevel = analysis['exercise_level'];
    
    final Map<String, dynamic>? info = ExerciseCategories.categoryInfo[category];
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
                            CupertinoIcons.arrow_2_circlepath,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Frekuensi: $frequency kali/minggu, $minutes menit/sesi',
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
                            CupertinoIcons.heart,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Intensitas: $intensity (${heartRate['min']}-${heartRate['max']} bpm)',
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
                            'Level Program: $exerciseLevel',
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
                'Fokus Latihan:',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              ...List.generate(
                (info['fokus_latihan'] as List<String>).length,
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
                          info['fokus_latihan'][index],
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
              'Rekomendasi Program Olahraga',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: categoryColor,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            
            // Cardio Program
            _buildProgramItem(
              icon: CupertinoIcons.heart,
              title: 'Program Kardio',
              description: _recommendationData!['cardio_program'] ?? '',
              color: categoryColor,
            ),
            
            // Strength Program
            _buildProgramItem(
              icon: CupertinoIcons.arrow_up_arrow_down,
              title: 'Program Kekuatan',
              description: _recommendationData!['strength_program'] ?? '',
              color: categoryColor,
            ),
            
            // Flexibility Program
            _buildProgramItem(
              icon: CupertinoIcons.arrow_uturn_right_circle,
              title: 'Program Fleksibilitas',
              description: _recommendationData!['flexibility_program'] ?? '',
              color: categoryColor,
            ),
            
            // Weekly Plan
            _buildProgramItem(
              icon: CupertinoIcons.calendar,
              title: 'Contoh Jadwal Mingguan',
              description: _recommendationData!['sample_weekly_plan'] ?? '',
              color: categoryColor,
            ),
            
            const Divider(),
            const SizedBox(height: 16),
            
            // Warm-up Tips
            Text(
              'Tips Pemanasan',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _recommendationData!['warm_up_tips'] ?? '',
              style: GoogleFonts.poppins(
                fontSize: 14,
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Recovery Focus
            Text(
              'Fokus Pemulihan',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _recommendationData!['recovery_focus'] ?? '',
              style: GoogleFonts.poppins(
                fontSize: 14,
                height: 1.5,
              ),
            ),
            
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            
            // Intensity Guidance
            Text(
              'Panduan Intensitas',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _recommendationData!['intensity_guidance'] ?? '',
              style: GoogleFonts.poppins(
                fontSize: 14,
                height: 1.5,
                color: Colors.orange.shade800,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Progression Tips
            Text(
              'Tips Progresi',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _recommendationData!['progression_tips'] ?? '',
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

  Widget _buildProgramItem({
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
              color: color.withOpacity(0.1),
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
                  'Rekomendasi program ini berdasarkan informasi yang Anda berikan. Selalu mulai pada level intensitas yang nyaman dan tingkatkan secara bertahap. Konsultasikan dengan profesional kesehatan sebelum memulai program baru jika Anda memiliki kondisi kesehatan khusus.',
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
        'Rekomendasi Program Olahraga',
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
                          child: _buildFrequencyProgressCircle(
                            _analysisResult!['analysis']['recommended_frequency'], 
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
                            'Hasil analisis kebutuhan olahraga:',
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
                          'Detail Kebutuhan Olahraga',
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
                    
                    // Rekomendasi program
                    if (_recommendationData != null)
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Text(
                          'Rekomendasi Program Olahraga',
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