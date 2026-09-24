import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';

// Import database helper
import 'package:primafit/features/health_record/data/database_bmi.dart';
import 'package:primafit/features/profile/data/database_profile.dart';

class GrafikBmi extends StatefulWidget {
  final VoidCallback onTap;
  
  const GrafikBmi({
    super.key,
    required this.onTap,
  });

  @override
  State<GrafikBmi> createState() => _GrafikBmiState();
}

class _GrafikBmiState extends State<GrafikBmi> with SingleTickerProviderStateMixin {
  // Theme color
  final Color themeColor = const Color(0xFF64D1DE);
  final Color secondaryColor = const Color(0xFFBA68C8);
  
  // Data loading state
  bool _isLoading = true;
  
  // Data for chart
  List<IndeksMassaTubuh> _bmiData = [];
  Map<String, dynamic>? _userProfile;
  
  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Min/Max values for Y axis
  double _minY = 0;
  double _maxY = 40;

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
      // Load BMI data
      final data = await IndeksMassaTubuhDatabaseHelper.instance.getAllIndeksMassaTubuh();
      
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
          final double value = double.tryParse(item.bmi) ?? 0;
          if (value < minValue) minValue = value;
          if (value > maxValue) maxValue = value;
        }
        
        // Add padding to min/max values
        _minY = 0; // Always start from 0 for better visualization
        _maxY = math.max(40, maxValue * 1.2); // At least 40 or 20% above max value
      }
      
      setState(() {
        _bmiData = data;
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
        title: 'Indeks Massa Tubuh',
        subtitle: 'Grafik perkembangan Indeks Massa Tubuh',
        isLoading: _isLoading,
        onTap: widget.onTap,
        chartWidget: _bmiData.isEmpty 
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
                if (!isLoading && _bmiData.isNotEmpty) ...[
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

  // Method to build chart legend
  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('BMI Anda', themeColor),
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

  // Method to build a line chart with the provided data
  Widget _buildLineChart() {
    // Process data for chart
    final data = _processBmiData();
    final actualData = data[0];
    final referenceData = data[1];
    
    // Generate X-axis labels based on dates
    final List<String> xLabels = _generateXLabels();
    
    // Determine Y-axis interval based on data range
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
                  if (_bmiData.length > 5) {
                    if (value.toInt() % math.max(1, (_bmiData.length / 5).round()) != 0 &&
                        value.toInt() != _bmiData.length - 1) {
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
                      value.toStringAsFixed(1),
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
                  if (touchedSpot.x.toInt() >= _bmiData.length) {
                    return null;
                  }
                  
                  final bool isActualValue = touchedSpot.barIndex == 0;
                  final String label = isActualValue ? 'BMI' : 'Normal';
                  
                  double value;
                  
                  if (isActualValue) {
                    // Actual value from data
                    value = double.parse(_bmiData[touchedSpot.x.toInt()].bmi);
                    
                    // Calculate BMI status
                    final statusMap = _getBmiStatus(value);
                    final String statusText = statusMap['status'];
                    final Color statusColor = statusMap['color'];
                    
                    return LineTooltipItem(
                      '$label: ${value.toStringAsFixed(1)}',
                      GoogleFonts.poppins(
                        color: themeColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      children: [
                        TextSpan(
                          text: '\nStatus: $statusText',
                          style: GoogleFonts.poppins(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    );
                  } else {
                    // Normal reference value
                    value = _getNormalValue();
                    
                    return LineTooltipItem(
                      '$label: ${value.toStringAsFixed(1)}',
                      GoogleFonts.poppins(
                        color: secondaryColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    );
                  }
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
    if (_maxY <= 10) return 1.0;
    if (_maxY <= 20) return 2.0;
    if (_maxY <= 40) return 5.0;
    return 10.0;
  }

  // Generate X-axis labels from dates
  List<String> _generateXLabels() {
    final List<String> labels = [];
    
    for (int i = 0; i < _bmiData.length; i++) {
      final date = DateFormat('yyyy-MM-dd').parse(_bmiData[i].tanggal);
      labels.add(DateFormat('dd/MM').format(date));
    }
    
    return labels;
  }

  // Process BMI data for chart
  List<List<FlSpot>> _processBmiData() {
    final int dataPointsCount = _bmiData.length;
    final List<FlSpot> actualLine = [];
    final List<FlSpot> normalLine = [];
    
    final double normalValue = _getNormalValue();
    
    for (int i = 0; i < dataPointsCount; i++) {
      // Original actual value
      final double value = double.tryParse(_bmiData[i].bmi) ?? 0;
      actualLine.add(FlSpot(i.toDouble(), value));
      
      // Normal reference line
      normalLine.add(FlSpot(i.toDouble(), normalValue));
    }
    
    return [actualLine, normalLine];
  }
  
  // Get normal value based on user profile (mid-point of normal range)
  double _getNormalValue() {
    // Default if profile not available - middle of normal BMI range for adults
    if (_userProfile == null || _userProfile!['tanggalLahir'] == null || _userProfile!['gender'] == null) {
      return 21.75; // Middle of normal range (18.5-25.0)
    }
    
    final int age = _calculateAge(_userProfile!['tanggalLahir']);
    final String gender = _userProfile!['gender'].toLowerCase();
    
    // For children and teens (under 20 years)
    if (age < 20) {
      if (gender == 'laki-laki' || gender == 'pria') {
        if (age < 10) return 17.0; // Middle of normal range for young boys
        if (age < 15) return 18.5; // Middle of normal range for adolescent boys
        return 20.0; // Middle of normal range for teen boys
      } else { // Girls
        if (age < 10) return 17.0; // Middle of normal range for young girls
        if (age < 15) return 18.5; // Middle of normal range for adolescent girls
        return 20.0; // Middle of normal range for teen girls
      }
    }
    
    // For adults (20 years and above) - middle of normal BMI range
    return 21.75; // Middle of normal range (18.5-25.0)
  }
  
  // Determine status of BMI based on value (consistent with read_bmi.dart)
  Map<String, dynamic> _getBmiStatus(double bmiValue) {
    // Default for adults if profile not available
    if (_userProfile == null || _userProfile!['tanggalLahir'] == null || _userProfile!['gender'] == null) {
      return _getAdultBmiStatus(bmiValue);
    }
    
    final int age = _calculateAge(_userProfile!['tanggalLahir']);
    final String gender = _userProfile!['gender'].toLowerCase();
    
    // For children and teens (under 20 years)
    if (age < 20) {
      return _getChildBmiStatus(bmiValue, age, gender);
    }
    
    // For adults (20 years and above)
    return _getAdultBmiStatus(bmiValue);
  }
  
  // Status BMI for adults (WHO standard)
  Map<String, dynamic> _getAdultBmiStatus(double bmiValue) {
    if (bmiValue < 16.0) {
      return {
        'status': 'Sangat Kurus', 
        'color': Colors.red.shade800,
        'bgColor': Colors.red.shade50
      };
    } else if (bmiValue < 17.0) {
      return {
        'status': 'Kurus Sedang', 
        'color': Colors.orange.shade800,
        'bgColor': Colors.orange.shade50
      };
    } else if (bmiValue < 18.5) {
      return {
        'status': 'Kurus Ringan', 
        'color': Colors.amber.shade800,
        'bgColor': Colors.amber.shade50
      };
    } else if (bmiValue < 25.0) {
      return {
        'status': 'Normal', 
        'color': Colors.green.shade800,
        'bgColor': Colors.green.shade50
      };
    } else if (bmiValue < 30.0) {
      return {
        'status': 'Gemuk', 
        'color': Colors.amber.shade800,
        'bgColor': Colors.amber.shade50
      };
    } else if (bmiValue < 35.0) {
      return {
        'status': 'Obesitas I', 
        'color': Colors.orange.shade800,
        'bgColor': Colors.orange.shade50
      };
    } else if (bmiValue < 40.0) {
      return {
        'status': 'Obesitas II', 
        'color': Colors.deepOrange.shade800,
        'bgColor': Colors.deepOrange.shade50
      };
    } else {
      return {
        'status': 'Obesitas III', 
        'color': Colors.red.shade800,
        'bgColor': Colors.red.shade50
      };
    }
  }
  
  // Status BMI for children and teens (simplified version)
  Map<String, dynamic> _getChildBmiStatus(double bmiValue, int age, String gender) {
    // Thresholds vary based on age and gender
    double underweightThreshold;
    double normalLowerThreshold;
    double normalUpperThreshold;
    double overweightThreshold;
    
    if (gender == 'laki-laki' || gender == 'pria') {
      if (age < 10) {
        underweightThreshold = 14.0;
        normalLowerThreshold = 15.5;
        normalUpperThreshold = 19.0;
        overweightThreshold = 22.0;
      } else if (age < 15) {
        underweightThreshold = 15.0;
        normalLowerThreshold = 16.5;
        normalUpperThreshold = 21.0;
        overweightThreshold = 24.0;
      } else {
        underweightThreshold = 16.0;
        normalLowerThreshold = 17.5;
        normalUpperThreshold = 23.0;
        overweightThreshold = 27.0;
      }
    } else { // Girls
      if (age < 10) {
        underweightThreshold = 13.5;
        normalLowerThreshold = 15.0;
        normalUpperThreshold = 19.0;
        overweightThreshold = 22.0;
      } else if (age < 15) {
        underweightThreshold = 14.5;
        normalLowerThreshold = 16.0;
        normalUpperThreshold = 21.0;
        overweightThreshold = 24.0;
      } else {
        underweightThreshold = 15.0;
        normalLowerThreshold = 17.0;
        normalUpperThreshold = 23.0;
        overweightThreshold = 27.0;
      }
    }
    
    if (bmiValue < underweightThreshold) {
      return {
        'status': 'Sangat Kurus', 
        'color': Colors.red.shade800,
        'bgColor': Colors.red.shade50
      };
    } else if (bmiValue < normalLowerThreshold) {
      return {
        'status': 'Kurus', 
        'color': Colors.orange.shade800,
        'bgColor': Colors.orange.shade50
      };
    } else if (bmiValue < normalUpperThreshold) {
      return {
        'status': 'Normal', 
        'color': Colors.green.shade800,
        'bgColor': Colors.green.shade50
      };
    } else if (bmiValue < overweightThreshold) {
      return {
        'status': 'Gemuk', 
        'color': Colors.amber.shade800,
        'bgColor': Colors.amber.shade50
      };
    } else {
      return {
        'status': 'Obesitas', 
        'color': Colors.red.shade800,
        'bgColor': Colors.red.shade50
      };
    }
  }
  
  // Calculate age from birthdate (consistent with read_bmi.dart)
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
        return 30; // Default if invalid age
      }

      return age;
    } catch (e) {
      return 30; // Default if invalid date format
    }
  }
  
  // Show information dialog
void _showInfoDialog(BuildContext context) {
  Widget categoryContent;

  if (_userProfile == null || _userProfile!['tanggalLahir'] == null || _userProfile!['gender'] == null) {
    // Show adult categories
    categoryContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kategori BMI untuk Dewasa:',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        _buildInfoRow('Sangat Kurus', '< 16.0', Colors.red.shade700),
        const SizedBox(height: 8),
        _buildInfoRow('Kurus Sedang', '16.0 - 17.0', Colors.orange.shade700),
        const SizedBox(height: 8),
        _buildInfoRow('Kurus Ringan', '17.0 - 18.5', Colors.amber.shade700),
        const SizedBox(height: 8),
        _buildInfoRow('Normal', '18.5 - 25.0', Colors.green.shade700),
        const SizedBox(height: 8),
        _buildInfoRow('Gemuk', '25.0 - 30.0', Colors.amber.shade700),
        const SizedBox(height: 8),
        _buildInfoRow('Obesitas I', '30.0 - 35.0', Colors.orange.shade700),
        const SizedBox(height: 8),
        _buildInfoRow('Obesitas II', '35.0 - 40.0', Colors.deepOrange.shade700),
        const SizedBox(height: 8),
        _buildInfoRow('Obesitas III', '> 40.0', Colors.red.shade700),
      ],
    );
  } else {
    final int age = _calculateAge(_userProfile!['tanggalLahir']);
    final String gender = _userProfile!['gender'].toLowerCase();

    if (age < 20) {
      String ageRange;
      final String genderText = (gender == 'laki-laki' || gender == 'pria') ? 'Laki-laki' : 'Perempuan';

      if (age < 10) {
        ageRange = '< 10 tahun';
      } else if (age < 15) {
        ageRange = '10-14 tahun';
      } else {
        ageRange = '15-19 tahun';
      }

      categoryContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kategori BMI untuk Anak & Remaja:',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$genderText, $ageRange',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w400,
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Sangat Kurus', 'BMI terlalu rendah', Colors.red.shade700),
          const SizedBox(height: 8),
          _buildInfoRow('Kurus', 'BMI di bawah normal', Colors.orange.shade700),
          const SizedBox(height: 8),
          _buildInfoRow('Normal', 'BMI dalam rentang sehat', Colors.green.shade700),
          const SizedBox(height: 8),
          _buildInfoRow('Gemuk', 'BMI di atas normal', Colors.amber.shade700),
          const SizedBox(height: 8),
          _buildInfoRow('Obesitas', 'BMI terlalu tinggi', Colors.red.shade700),
        ],
      );
    } else {
      categoryContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kategori BMI untuk Dewasa:',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${gender == 'laki-laki' || gender == 'pria' ? 'Laki-laki' : 'Perempuan'}, $age tahun',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w400,
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Sangat Kurus', '< 16.0', Colors.red.shade700),
          const SizedBox(height: 8),
          _buildInfoRow('Kurus Sedang', '16.0 - 17.0', Colors.orange.shade700),
          const SizedBox(height: 8),
          _buildInfoRow('Kurus Ringan', '17.0 - 18.5', Colors.amber.shade700),
          const SizedBox(height: 8),
          _buildInfoRow('Normal', '18.5 - 25.0', Colors.green.shade700),
          const SizedBox(height: 8),
          _buildInfoRow('Gemuk', '25.0 - 30.0', Colors.amber.shade700),
          const SizedBox(height: 8),
          _buildInfoRow('Obesitas I', '30.0 - 35.0', Colors.orange.shade700),
          const SizedBox(height: 8),
          _buildInfoRow('Obesitas II', '35.0 - 40.0', Colors.deepOrange.shade700),
          const SizedBox(height: 8),
          _buildInfoRow('Obesitas III', '> 40.0', Colors.red.shade700),
        ],
      );
    }
  }

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
              color: themeColor, // <- pastikan kamu sudah deklarasi themeColor
              size: 24,
            ),
            const SizedBox(width: 10),
            Text(
              'Informasi BMI',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: categoryContent,
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
}