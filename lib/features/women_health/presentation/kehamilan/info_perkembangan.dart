import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primafit/features/women_health/presentation/kehamilan/model_kehamilan.dart';

class DevelopmentInfoPage extends StatefulWidget {
  final int weekNumber;
  
  const DevelopmentInfoPage({
    super.key,
    required this.weekNumber,
  });

  @override
  _DevelopmentInfoPageState createState() => _DevelopmentInfoPageState();
}

class _DevelopmentInfoPageState extends State<DevelopmentInfoPage> {
  late int _currentWeek;
  final Pregnancy _dummyPregnancy = Pregnancy(
    id: 0,
    startDate: DateTime.now(),
    dueDate: DateTime.now().add(const Duration(days: 280)),
    currentWeek: 1,
  );
  
  @override
  void initState() {
    super.initState();
    _currentWeek = widget.weekNumber;
  }
  
  void _changeWeek(int newWeek) {
    if (newWeek >= 1 && newWeek <= 40) {
      setState(() {
        _currentWeek = newWeek;
      });
    }
  }
  
  String _getTrimester(int week) {
    if (week <= 13) {
      return 'Trimester 1';
    } else if (week <= 27) {
      return 'Trimester 2';
    } else {
      return 'Trimester 3';
    }
  }
  
  Color _getTrimesterColor(int week) {
    if (week <= 13) {
      return Colors.blue.shade400; // Trimester 1
    } else if (week <= 27) {
      return Colors.green.shade400; // Trimester 2
    } else {
      return Colors.purple.shade400; // Trimester 3
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final String babySize = _dummyPregnancy.getBabySize(_currentWeek);
    final double babyWeight = _dummyPregnancy.getBabyWeight(_currentWeek);
    final String babyDevelopment = _dummyPregnancy.getBabyDevelopment(_currentWeek);
    final String motherTips = _dummyPregnancy.getMotherTips(_currentWeek);
    final String trimester = _getTrimester(_currentWeek);
    final Color trimesterColor = _getTrimesterColor(_currentWeek);
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE9458D),
        elevation: 0,
        title: Text(
          'Perkembangan Minggu $_currentWeek',
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Week selector banner
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              color: const Color(0xFFE9458D),
              child: Column(
                children: [
                  // Week selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () => _changeWeek(_currentWeek - 1),
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                        padding: EdgeInsets.zero,
                        splashRadius: 20,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Minggu $_currentWeek',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFE9458D),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: trimesterColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                trimester,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: trimesterColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => _changeWeek(_currentWeek + 1),
                        icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                        padding: EdgeInsets.zero,
                        splashRadius: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Week progress bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: _currentWeek / 40,
                            minHeight: 8,
                            backgroundColor: Colors.white.withValues(alpha: 0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Mulai',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                            Text(
                              '40 minggu',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Baby Size & Weight
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.teal.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.child_friendly,
                                  color: Colors.teal.shade700,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Ukuran & Berat Janin',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildInfoCard(
                                  icon: CupertinoIcons.resize,
                                  title: 'Ukuran',
                                  value: babySize,
                                  color: Colors.blue.shade400,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildInfoCard(
                                  icon: CupertinoIcons.graph_square,
                                  title: 'Berat',
                                  value: babyWeight < 1000 
                                      ? '${babyWeight.toStringAsFixed(1)} gram' 
                                      : '${(babyWeight / 1000).toStringAsFixed(2)} kg',
                                  color: Colors.green.shade400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Baby Development
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.purple.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.favorite,
                                  color: Colors.purple.shade700,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Perkembangan Janin',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            babyDevelopment,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Baby Illustration Placeholder
                          Container(
                            height: 180,
                            decoration: BoxDecoration(
                              color: Colors.purple.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.child_care,
                                    size: 64,
                                    color: Colors.purple.shade300,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Ilustrasi Janin Minggu $_currentWeek',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.purple.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Mother Tips
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.pink.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  CupertinoIcons.lightbulb_fill,
                                  color: Colors.pink.shade700,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Tips untuk Ibu',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            motherTips,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Common Symptoms & Changes
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  CupertinoIcons.bandage,
                                  color: Colors.orange.shade700,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Gejala Umum pada Minggu Ini',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildCommonSymptomsList(),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Important things to know
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade100,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  CupertinoIcons.info,
                                  color: Colors.amber.shade700,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Hal Penting yang Perlu Diketahui',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildImportantThingsList(),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Disclaimer
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Text(
                      'Catatan: Informasi ini bersifat umum dan mungkin tidak berlaku untuk semua kehamilan. Selalu konsultasikan dengan dokter atau bidan untuk informasi yang lebih spesifik tentang kehamilan Anda.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey.shade700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildCommonSymptomsList() {
    // Common symptoms by trimester
    List<String> symptoms = [];
    
    if (_currentWeek <= 13) {
      // First trimester symptoms
      symptoms = [
        'Mual dan muntah pagi hari',
        'Kelelahan',
        'Sering buang air kecil',
        'Payudara membesar dan nyeri',
        'Perubahan mood',
        'Kembung dan sembelit',
        'Pusing atau sakit kepala',
      ];
    } else if (_currentWeek <= 27) {
      // Second trimester symptoms
      symptoms = [
        'Energi meningkat',
        'Nafsu makan meningkat',
        'Perut mulai membesar',
        'Kulit menjadi lebih cerah',
        'Merasakan gerakan janin',
        'Nyeri punggung',
        'Garis hitam di perut (linea nigra)',
      ];
    } else {
      // Third trimester symptoms
      symptoms = [
        'Susah tidur',
        'Sesak napas',
        'Kram kaki',
        'Kontraksi Braxton Hicks',
        'Pembengkakan pada kaki dan tangan',
        'Sering buang air kecil',
        'Nyeri punggung lebih intens',
        'Gerakan janin lebih kuat',
      ];
    }
    
    return Column(
      children: symptoms.map((symptom) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.orange.shade700,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  symptom,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildImportantThingsList() {
    // Important things to know by trimester
    List<String> importantThings = [];
    
    if (_currentWeek <= 13) {
      // First trimester
      importantThings = [
        'Mulai konsumsi vitamin prenatal yang mengandung asam folat',
        'Hindari alkohol, rokok, dan obat-obatan tanpa resep dokter',
        'Batasi konsumsi kafein',
        'Jadwalkan pemeriksaan kehamilan secara rutin',
        'Istirahat yang cukup',
      ];
    } else if (_currentWeek <= 27) {
      // Second trimester
      importantThings = [
        'Lakukan USG anomali untuk memeriksa perkembangan organ janin',
        'Pertimbangkan untuk mengikuti kelas persiapan melahirkan',
        'Tidur miring ke kiri untuk meningkatkan sirkulasi',
        'Mulai persiapkan perlengkapan bayi',
        'Tetap aktif dengan olahraga ringan yang aman untuk ibu hamil',
      ];
    } else {
      // Third trimester
      importantThings = [
        'Siapkan tas untuk dibawa ke rumah sakit',
        'Kenali tanda-tanda persalinan',
        'Hindari perjalanan jauh menjelang HPL',
        'Pantau gerakan janin setiap hari',
        'Diskusikan rencana persalinan dengan dokter atau bidan',
        'Dapatkan vaksinasi yang direkomendasikan (seperti TDaP)',
      ];
    }
    
    return Column(
      children: importantThings.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 4),
                child: Icon(
                  Icons.check_circle,
                  size: 16,
                  color: Colors.amber.shade700,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}