import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';

// Import database helper
import 'package:primafit/database/catat/database_tensi.dart';
import 'package:primafit/database/navigasi/database_profile.dart';

class GrafikTensi extends StatefulWidget {
  final VoidCallback onTap;
  
  const GrafikTensi({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  State<GrafikTensi> createState() => _GrafikTensiState();
}

class _GrafikTensiState extends State<GrafikTensi> with SingleTickerProviderStateMixin {
  // Theme color
  final Color themeColor = const Color(0xFF64D1DE);
  final Color secondaryColor = const Color(0xFFBA68C8);
  
  // Additional colors for different pressure categories
  final Color normalColor = Colors.green.shade700;
  final Color elevatedColor = Colors.blue.shade700;
  final Color stage1Color = Colors.amber.shade700;
  final Color stage2Color = Colors.orange.shade700;
  final Color crisisColor = Colors.red.shade700;
  
  // Data loading state
  bool _isLoading = true;
  
  // Data for chart
  List<TekananDarah> _tensiData = [];
  Map<String, dynamic>? _userProfile;
  
  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Min/Max values for Y axis
  double _minY = 0;
  double _maxY = 180;
  
  // Toggle for display mode
  bool _showSystolic = true; // Toggle between systolic and diastolic

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
      // Load tensi data
      final data = await TekananDarahDatabaseHelper.instance.getAllTekananDarah();
      
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
        double minSystolic = double.infinity;
        double maxSystolic = 0;
        double minDiastolic = double.infinity;
        double maxDiastolic = 0;
        
        for (var item in data) {
          final double systolic = double.tryParse(item.sistolik) ?? 0;
          final double diastolic = double.tryParse(item.diastolik) ?? 0;
          
          if (systolic < minSystolic) minSystolic = systolic;
          if (systolic > maxSystolic) maxSystolic = systolic;
          
          if (diastolic < minDiastolic) minDiastolic = diastolic;
          if (diastolic > maxDiastolic) maxDiastolic = diastolic;
        }
        
        // Add padding and ensure minimum ranges for visibility
        _minY = 0; // Always start Y axis from 0
        _maxY = math.max(180, math.max(maxSystolic, maxDiastolic) * 1.1); // At least 180 or 10% above max value
      }
      
      setState(() {
        _tensiData = data;
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
        title: 'Tekanan Darah',
        subtitle: 'Grafik perkembangan tekanan darah',
        isLoading: _isLoading,
        onTap: widget.onTap,
        chartWidget: _tensiData.isEmpty 
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
                        // Toggle between systolic and diastolic
                        if (!isLoading && _tensiData.isNotEmpty)
                          InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: _toggleDisplayMode,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: themeColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _showSystolic ? 'Sistolik' : 'Diastolik',
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
                          message: 'Informasi kategori tekanan darah',
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
                if (!isLoading && _tensiData.isNotEmpty) ...[
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

  // Toggle between systolic and diastolic display
  void _toggleDisplayMode() {
    setState(() {
      _showSystolic = !_showSystolic;
    });
  }

  // Method to build chart legend
  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(_showSystolic ? 'Sistolik' : 'Diastolik', themeColor),
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
    final data = _processTensiData();
    final actualData = data[0];
    final referenceData = data[1];
    
    // Generate X-axis labels based on dates
    final List<String> xLabels = _generateXLabels();
    
    // Calculate Y-axis interval based on data range
    final double yInterval = _calculateYInterval();
    
    return Padding(
      padding: const EdgeInsets.only(right: 16, top: 8),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawHorizontalLine: true,
            drawVerticalLine: true,
            horizontalInterval: yInterval, // Dynamic interval based on range
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.1),
                strokeWidth: 1,
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: Colors.grey.withOpacity(0.1),
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
                  if (_tensiData.length > 5) {
                    if (value.toInt() % math.max(1, (_tensiData.length / 5).round()) != 0 &&
                        value.toInt() != _tensiData.length - 1) {
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
                      '${value.toInt()}',
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
                color: themeColor.withOpacity(0.1),
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
                  if (touchedSpot.x.toInt() >= _tensiData.length) {
                    return null;
                  }
                  
                  final bool isActualValue = touchedSpot.barIndex == 0;
                  final String label = isActualValue
                      ? (_showSystolic ? 'Sistolik' : 'Diastolik')
                      : 'Normal';
                  
                  double value;
                  
                  if (isActualValue) {
                    // Actual value from data
                    value = _showSystolic
                        ? double.parse(_tensiData[touchedSpot.x.toInt()].sistolik)
                        : double.parse(_tensiData[touchedSpot.x.toInt()].diastolik);
                  } else {
                    // Normal reference value
                    value = _getNormalValue(_showSystolic);
                  }
                  
                  // Get status color based on values
                  final int systolic = double.parse(_tensiData[touchedSpot.x.toInt()].sistolik).toInt();
                  final int diastolic = double.parse(_tensiData[touchedSpot.x.toInt()].diastolik).toInt();
                  final status = _getTekananDarahStatus(systolic, diastolic);
                  
                  return LineTooltipItem(
                    '$label: ${value.toInt()} mmHg',
                    GoogleFonts.poppins(
                      color: isActualValue ? themeColor : secondaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                    children: isActualValue
                        ? [
                            TextSpan(
                              text: '\nStatus: ${status['status']}',
                              style: GoogleFonts.poppins(
                                color: status['color'],
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                            ),
                          ]
                        : null,
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
    if (_maxY <= 120) return 20.0;
    if (_maxY <= 180) return 30.0;
    return 40.0;
  }

  // Generate X-axis labels from dates
  List<String> _generateXLabels() {
    List<String> labels = [];
    
    for (int i = 0; i < _tensiData.length; i++) {
      final date = DateFormat('yyyy-MM-dd').parse(_tensiData[i].tanggal);
      labels.add(DateFormat('dd/MM').format(date));
    }
    
    return labels;
  }

  // Process tensi data for chart
  List<List<FlSpot>> _processTensiData() {
    final int dataPointsCount = _tensiData.length;
    List<FlSpot> actualLine = [];
    List<FlSpot> normalLine = [];
    
    for (int i = 0; i < dataPointsCount; i++) {
      // Get value based on current display mode (systolic or diastolic)
      double value = _showSystolic
          ? double.tryParse(_tensiData[i].sistolik) ?? 0
          : double.tryParse(_tensiData[i].diastolik) ?? 0;
      
      actualLine.add(FlSpot(i.toDouble(), value));
      
      // Normal reference line
      double normalValue = _getNormalValue(_showSystolic);
      normalLine.add(FlSpot(i.toDouble(), normalValue));
    }
    
    return [actualLine, normalLine];
  }
  
  // Get normal value based on current display mode
  double _getNormalValue(bool isSystolic) {
    // Based on American Heart Association guidelines
    return isSystolic ? 120.0 : 80.0; // Normal thresholds
  }
  
  // Determine status of blood pressure based on systolic and diastolic values
  // This matches the logic in read_tensi.dart
  Map<String, dynamic> _getTekananDarahStatus(int sistolik, int diastolik) {
    // Kategori berdasarkan American Heart Association (AHA)
    if (sistolik < 120 && diastolik < 80) {
      return {
        'status': 'Normal',
        'color': normalColor,
        'bgColor': Colors.green.shade50,
        'range': 'Sistolik < 120 mmHg dan Diastolik < 80 mmHg'
      };
    } else if ((sistolik >= 120 && sistolik <= 129) && diastolik < 80) {
      return {
        'status': 'Elevated',
        'color': elevatedColor,
        'bgColor': Colors.blue.shade50,
        'range': 'Sistolik 120-129 mmHg dan Diastolik < 80 mmHg'
      };
    } else if ((sistolik >= 130 && sistolik <= 139) || (diastolik >= 80 && diastolik <= 89)) {
      return {
        'status': 'Hipertensi Stage 1',
        'color': stage1Color,
        'bgColor': Colors.amber.shade50,
        'range': 'Sistolik 130-139 mmHg atau Diastolik 80-89 mmHg'
      };
    } else if (sistolik >= 140 || diastolik >= 90) {
      return {
        'status': 'Hipertensi Stage 2',
        'color': stage2Color,
        'bgColor': Colors.orange.shade50,
        'range': 'Sistolik ≥ 140 mmHg atau Diastolik ≥ 90 mmHg'
      };
    } else if (sistolik > 180 || diastolik > 120) {
      return {
        'status': 'Krisis Hipertensi',
        'color': crisisColor,
        'bgColor': Colors.red.shade50,
        'range': 'Sistolik > 180 mmHg atau Diastolik > 120 mmHg'
      };
    }
    
    // Default jika tidak masuk kategori di atas
    return {
      'status': 'Normal',
      'color': normalColor,
      'bgColor': Colors.green.shade50,
      'range': 'Sistolik < 120 mmHg dan Diastolik < 80 mmHg'
    };
  }
  
  // Calculate age from birthdate (consistent with read_tensi.dart)
  int _calculateAge(String birthDateString) {
    try {
      // Parsing dari format dd-MM-yyyy
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
  
  // Show information dialog with blood pressure categories
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
                'Kategori Tekanan Darah',
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
                  'Kategori tekanan darah berdasarkan American Heart Association (AHA):',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                
                _buildInfoRow(
                  'Normal',
                  'Sistolik < 120 mmHg dan Diastolik < 80 mmHg',
                  normalColor
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  'Elevated',
                  'Sistolik 120-129 mmHg dan Diastolik < 80 mmHg',
                  elevatedColor
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  'Hipertensi Stage 1',
                  'Sistolik 130-139 mmHg atau Diastolik 80-89 mmHg',
                  stage1Color
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  'Hipertensi Stage 2',
                  'Sistolik ≥ 140 mmHg atau Diastolik ≥ 90 mmHg',
                  stage2Color
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  'Krisis Hipertensi',
                  'Sistolik > 180 mmHg atau Diastolik > 120 mmHg',
                  crisisColor
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
                        'Tekanan darah tinggi dapat meningkatkan risiko penyakit jantung, stroke, dan gagal ginjal. Konsultasikan dengan dokter jika tekanan darah Anda tinggi secara konsisten.',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
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
          margin: const EdgeInsets.only(top: 3),
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
}