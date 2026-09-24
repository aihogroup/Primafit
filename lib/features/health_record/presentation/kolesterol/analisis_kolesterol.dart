import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';

// Import database helper
import 'package:primafit/features/health_record/data/database_kolesterol.dart';
import 'package:primafit/features/profile/data/database_profile.dart';

class GrafikKolesterol extends StatefulWidget {
  final VoidCallback onTap;
  
  const GrafikKolesterol({
    super.key,
    required this.onTap,
  });

  @override
  State<GrafikKolesterol> createState() => _GrafikKolesterolState();
}

class _GrafikKolesterolState extends State<GrafikKolesterol> with SingleTickerProviderStateMixin {
  // Theme color
  final Color themeColor = const Color(0xFF64D1DE);
  final Color secondaryColor = const Color(0xFFBA68C8);
  
  // Data loading state
  bool _isLoading = true;
  
  // Data for chart
  List<Kolesterol> _kolesterolData = [];
  Map<String, dynamic>? _userProfile;
  
  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Min/Max values for Y axis
  double _minY = 0;
  double _maxY = 300;
  
  // Toggle untuk tampilan satuan (mg/dL atau mmol/L)
  bool _showAsMgdL = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    _loadData();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Load Kolesterol data
      final data = await KolesterolDatabaseHelper.instance.getAllKolesterol();
      
      // Load user profile data for normal ranges
      final profiles = await ProfileDatabaseHelper().getProfiles();
      final userProfile = profiles.isNotEmpty ? profiles.first : null;
      
      // Sort data by date (oldest first for correct x-axis progression)
      data.sort((a, b) {
        final DateTime dateA = DateFormat('yyyy-MM-dd').parse(a.tanggal);
        final DateTime dateB = DateFormat('yyyy-MM-dd').parse(b.tanggal);
        return dateA.compareTo(dateB); // Oldest to newest for left-to-right graph
      });
      
      // Find min and max values for better Y-axis scaling
      if (data.isNotEmpty) {
        double minValue = double.infinity;
        double maxValue = 0;
        
        for (var item in data) {
          final double value = double.tryParse(item.hasil) ?? 0;
          if (value < minValue) minValue = value;
          if (value > maxValue) maxValue = value;
        }
        
        // Add padding to min/max values
        _minY = 0; // Always start from 0 for better visualization
        _maxY = math.max(300, maxValue * 1.2); // 20% padding, minimum 300 mg/dL for context
      }
      
      setState(() {
        _kolesterolData = data;
        _userProfile = userProfile;
        _isLoading = false;
      });
      
      _animationController.forward();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: _buildChartCard(
        title: 'Kolesterol',
        subtitle: 'Grafik perkembangan kolesterol',
        isLoading: _isLoading,
        onTap: widget.onTap,
        chartWidget: _kolesterolData.isEmpty 
          ? _buildEmptyDataView()
          : _buildLineChart(),
      ),
    );
  }

  Widget _buildEmptyDataView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.chart_bar_alt_fill,
            color: Colors.grey.shade300,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada data',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard({
    required String title,
    required String subtitle,
    required bool isLoading,
    required VoidCallback onTap,
    required Widget chartWidget,}
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 2,
        shadowColor: Colors.black12,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // Toggle satuan
                        if (!isLoading && _kolesterolData.isNotEmpty)
                          InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: _toggleSatuan,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: themeColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _showAsMgdL ? 'mg/dL' : 'mmol/L',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: themeColor,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        // Info button
                        Tooltip(
                          message: 'Informasi rentang normal',
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () => _showInfoDialog(context),
                            child: const Icon(
                              CupertinoIcons.info_circle,
                              color: Colors.grey,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF64D1DE),
                          ),
                        )
                      : chartWidget,
                ),
                if (!isLoading && _kolesterolData.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildLegend(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Toggle satuan display
  void _toggleSatuan() {
    setState(() {
      _showAsMgdL = !_showAsMgdL;
      
      // Recalculate Y-axis based on new unit
      if (_kolesterolData.isNotEmpty) {
        double maxValue = 0;
        
        for (var item in _kolesterolData) {
          final double value = _showAsMgdL 
              ? double.tryParse(item.hasil) ?? 0
              : _convertMgdLToMmolL(double.tryParse(item.hasil) ?? 0);
          if (value > maxValue) maxValue = value;
        }
        
        // Add padding to max value
        _minY = 0; // Always start from 0
        if (_showAsMgdL) {
          _maxY = math.max(300, maxValue * 1.2); // 20% padding, minimum 300 mg/dL
        } else {
          _maxY = math.max(8, maxValue * 1.2); // 20% padding, minimum 8 mmol/L
        }
      }
    });
  }

  // Method to build chart legend
  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('Kolesterol Anda', themeColor),
        const SizedBox(width: 24),
        _buildLegendItem('Batas Normal', secondaryColor),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  // Method to build a line chart with the provided data
  Widget _buildLineChart() {
    // Process data for chart
    final data = _processKolesterolData();
    final actualData = data[0];
    final referenceData = data[1];
    
    // Generate X-axis labels based on dates
    final List<String> xLabels = _generateXLabels();
    
    // Determine Y-axis interval based on current unit and range
    final double yInterval = _calculateYInterval();
    
    return Padding(
      padding: const EdgeInsets.only(right: 16, top: 8),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            drawVerticalLine: true,
            horizontalInterval: yInterval,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withValues(alpha: 0.1),
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Colors.grey.withValues(alpha: 0.1),
                strokeWidth: 1,
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final style = TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                    fontSize: 10,
                  );
                  
                  // Show only a subset of dates if there are many data points
                  if (_kolesterolData.length > 5) {
                    if (value.toInt() % math.max(1, (_kolesterolData.length / 5).round()) != 0 &&
                        value.toInt() != _kolesterolData.length - 1) {
                      return const SizedBox();
                    }
                  }
                  
                  if (value.toInt() < 0 || value.toInt() >= xLabels.length) {
                    return const SizedBox();
                  }
                  
                  return Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Text(
                      xLabels[value.toInt()],
                      style: style,
                      textAlign: TextAlign.center,
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value % yInterval != 0) return const SizedBox();
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: Text(
                      _showAsMgdL 
                        ? '${value.toInt()}'
                        : value.toStringAsFixed(1),
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  );
                },
                reservedSize: 35,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: false,
          ),
          minX: 0,
          maxX: actualData.length - 1.0,
          minY: _minY,
          maxY: _maxY,
          lineBarsData: [
            // Actual values line (blue)
            LineChartBarData(
              spots: actualData,
              isCurved: true,
              curveSmoothness: 0.3,
              color: themeColor,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 4,
                  color: themeColor,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                color: themeColor.withValues(alpha: 0.1),
              ),
            ),
            // Reference/Normal line (purple)
            LineChartBarData(
              spots: referenceData,
              isCurved: false,
              color: secondaryColor,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: false,
              ),
              dashArray: [5, 5], // Add dashed line for reference
              belowBarData: BarAreaData(show: false),
            ),
          ],
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipRoundedRadius: 8,
              tooltipBorder: BorderSide(color: Colors.grey.shade300),
              tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((LineBarSpot touchedSpot) {
                  if (touchedSpot.x.toInt() >= _kolesterolData.length) {
                    return null;
                  }
                  
                  final bool isActualValue = touchedSpot.barIndex == 0;
                  final String label = isActualValue ? 'Nilai' : 'Normal';
                  
                  double value;
                  String unit;
                  
                  if (isActualValue) {
                    // Actual value from data
                    value = _showAsMgdL
                        ? double.parse(_kolesterolData[touchedSpot.x.toInt()].hasil)
                        : _convertMgdLToMmolL(double.parse(_kolesterolData[touchedSpot.x.toInt()].hasil));
                  } else {
                    // Normal reference value
                    value = _showAsMgdL
                        ? _getNormalValue(_kolesterolData[touchedSpot.x.toInt()].tanggal)
                        : _convertMgdLToMmolL(_getNormalValue(_kolesterolData[touchedSpot.x.toInt()].tanggal));
                  }
                  
                  unit = _showAsMgdL ? 'mg/dL' : 'mmol/L';
                  
                  return LineTooltipItem(
                    '$label: ${_showAsMgdL ? value.toStringAsFixed(0) : value.toStringAsFixed(1)} $unit',
                    GoogleFonts.poppins(
                      color: isActualValue ? themeColor : secondaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  // Calculate appropriate Y-axis interval based on range
  double _calculateYInterval() {
    if (_showAsMgdL) {
      if (_maxY <= 200) return 50.0;
      if (_maxY <= 400) return 100.0;
      return 200.0;
    } else {
      if (_maxY <= 5) return 1.0;
      if (_maxY <= 10) return 2.0;
      return 5.0;
    }
  }

  // Generate X-axis labels from dates
  List<String> _generateXLabels() {
    final List<String> labels = [];
    
    for (int i = 0; i < _kolesterolData.length; i++) {
      final date = DateFormat('yyyy-MM-dd').parse(_kolesterolData[i].tanggal);
      labels.add(DateFormat('dd/MM').format(date));
    }
    
    return labels;
  }

  // Process Kolesterol data for chart
  List<List<FlSpot>> _processKolesterolData() {
    final int dataPointsCount = _kolesterolData.length;
    final List<FlSpot> actualLine = [];
    final List<FlSpot> normalLine = [];
    
    for (int i = 0; i < dataPointsCount; i++) {
      // Get value based on selected unit
      final double value = _showAsMgdL
          ? double.tryParse(_kolesterolData[i].hasil) ?? 0
          : _convertMgdLToMmolL(double.tryParse(_kolesterolData[i].hasil) ?? 0);
      
      actualLine.add(FlSpot(i.toDouble(), value));
      
      // Get normal reference value for this date
      final double normalValue = _showAsMgdL
          ? _getNormalValue(_kolesterolData[i].tanggal)
          : _convertMgdLToMmolL(_getNormalValue(_kolesterolData[i].tanggal));
      
      normalLine.add(FlSpot(i.toDouble(), normalValue));
    }
    
    return [actualLine, normalLine];
  }
  
  // Get normal value based on user profile and date (aligned with read_kolesterol.dart)
  double _getNormalValue(String dateString) {
    // Default if profile not available
    if (_userProfile == null || _userProfile!['tanggalLahir'] == null || _userProfile!['gender'] == null) {
      return 200.0; // Standard normal value in mg/dL
    }
    
    final int age = _calculateAge(_userProfile!['tanggalLahir']);
    final String gender = _userProfile!['gender'].toLowerCase();
    
    // Menggunakan logika yang sama dengan di read_kolesterol.dart
    if (gender == 'pria' || gender == 'laki-laki') {
      if (age < 20) {
        return 170.0; // Anak-anak dan remaja pria
      } else {
        return 200.0; // Pria dewasa (semua usia)
      }
    } else { // Wanita
      if (age < 20) {
        return 170.0; // Anak-anak dan remaja wanita
      } else {
        return 200.0; // Wanita dewasa (semua usia)
      }
    }
  }
  
  // Fungsi untuk mengkonversi mg/dL ke mmol/L (untuk output tampilan)
  double _convertMgdLToMmolL(double mgdL) {
    // Faktor konversi: 1 mg/dL = 0.02586 mmol/L
    return mgdL * 0.02586;
  }
  
  // Calculate age from birthdate (using consistent format from read_kolesterol.dart)
  int _calculateAge(String birthDateString) {
    try {
      // Parsing dari format dd-MM-yyyy sesuai dengan read_kolesterol.dart
      final DateTime birthDate = DateFormat('dd-MM-yyyy').parseStrict(birthDateString);
      final DateTime now = DateTime.now();

      int age = now.year - birthDate.year;

      if (now.month < birthDate.month ||
          (now.month == birthDate.month && now.day < birthDate.day)) {
        age--;
      }

      if (age < 0 || age > 120) {
        return 30; // Default jika hasil tidak valid
      }

      return age;
    } catch (e) {
      return 30; // Default jika format tanggal tidak valid
    }
  }
  
  // Show information dialog with correct ranges
  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                CupertinoIcons.info_circle_fill,
                color: themeColor,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                'Informasi Kolesterol',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rentang normal kadar kolesterol:',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                
                if (_userProfile != null && _userProfile!['gender'] != null) ...[
                  Text(
                    'Berdasarkan profil Anda:',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_userProfile!['gender']}${_userProfile!['tanggalLahir'] != null ? ', ${_calculateAge(_userProfile!['tanggalLahir'])} tahun' : ''}',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
                
                const SizedBox(height: 12),
                
                // Status normal based on age and gender
                _buildInfoRow(
                  'Normal', 
                  _getNormalRanges()['normal']!, 
                  Colors.green.shade700
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  'Borderline', 
                  _getNormalRanges()['borderline']!, 
                  Colors.amber.shade700
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  'Tinggi', 
                  _getNormalRanges()['tinggi']!, 
                  Colors.red.shade700
                ),
                
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.exclamationmark_triangle,
                            size: 16,
                            color: Colors.amber.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Perhatian',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: Colors.amber.shade800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Kolesterol tinggi dapat meningkatkan risiko penyakit jantung dan stroke. Konsultasikan dengan dokter jika nilai kolesterol Anda tinggi.',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 12),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     TextButton.icon(
                //       onPressed: () {
                //         // Toggle satuan dalam dialog
                //         setState(() {
                //           _showAsMgdL = !_showAsMgdL;
                //         });
                //         // Tutup dialog lama dan buka yang baru dengan satuan yang sudah diupdate
                //         Navigator.pop(context);
                //         _showInfoDialog(context);
                //       },
                //       icon: Icon(
                //         CupertinoIcons.arrow_2_circlepath,
                //         size: 16,
                //         color: themeColor,
                //       ),
                //       label: Text(
                //         'Tampilkan dalam ${_showAsMgdL ? 'mmol/L' : 'mg/dL'}',
                //         style: GoogleFonts.poppins(
                //           fontSize: 12,
                //           color: themeColor,
                //           fontWeight: FontWeight.w500,
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Tutup',
                style: GoogleFonts.poppins(
                  color: themeColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: color,
                  fontSize: 14,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  color: Colors.grey.shade700,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  // Get appropriate normal ranges based on profile
Map<String, String> _getNormalRanges() {
  if (_userProfile == null || _userProfile!['tanggalLahir'] == null || _userProfile!['gender'] == null) {
    // Nilai standar umum
    return {
      'normal': _showAsMgdL ? '< 200 mg/dL' : '< 5.2 mmol/L',
      'borderline': _showAsMgdL ? '200 - 239 mg/dL' : '5.2 - 6.2 mmol/L',
      'tinggi': _showAsMgdL ? '≥ 240 mg/dL' : '≥ 6.2 mmol/L'
    };
  }
  
  final int age = _calculateAge(_userProfile!['tanggalLahir']);
  
  if (age < 20) {
    // Anak-anak dan remaja (laki-laki dan perempuan)
    return {
      'normal': _showAsMgdL ? '< 170 mg/dL' : '< 4.4 mmol/L',
      'borderline': _showAsMgdL ? '170 - 199 mg/dL' : '4.4 - 5.2 mmol/L',
      'tinggi': _showAsMgdL ? '≥ 200 mg/dL' : '≥ 5.2 mmol/L'
    };
  } else {
    // Dewasa (laki-laki dan perempuan)
    return {
      'normal': _showAsMgdL ? '< 200 mg/dL' : '< 5.2 mmol/L',
      'borderline': _showAsMgdL ? '200 - 239 mg/dL' : '5.2 - 6.2 mmol/L',
      'tinggi': _showAsMgdL ? '≥ 240 mg/dL' : '≥ 6.2 mmol/L'
    };
  }
}
}