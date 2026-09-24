import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';

// Import database helper
import 'package:primafit/database/catat/database_asamurat.dart';
import 'package:primafit/database/navigasi/database_profile.dart';

class GrafikAsamUrat extends StatefulWidget {
  final VoidCallback onTap;
  
  const GrafikAsamUrat({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  State<GrafikAsamUrat> createState() => _GrafikAsamUratState();
}

class _GrafikAsamUratState extends State<GrafikAsamUrat> with SingleTickerProviderStateMixin {
  // Theme color
  final Color themeColor = const Color(0xFF64D1DE);
  final Color secondaryColor = const Color(0xFFBA68C8);
  
  // Data loading state
  bool _isLoading = true;
  
  // Data for chart
  List<AsamUrat> _asamUratData = [];
  Map<String, dynamic>? _userProfile;
  
  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Min/Max values for Y axis
  double _minY = 0;
  double _maxY = 10; // Rentang asam urat umumnya 2-10 mg/dL
  
  // Satuan yang ditampilkan
  bool _showAsMgdL = true; // Default mg/dL

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
      // Load AsamUrat data
      final data = await AsamUratDatabaseHelper.instance.getAllAsamUrat();
      
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
          // Konversi nilai ke mg/dL untuk konsistensi
          final double value = item.getHasilInMgdL();
          if (value < minValue) minValue = value;
          if (value > maxValue) maxValue = value;
        }
        
        // Add padding to min/max values
        _minY = 0; // Always start from 0 as requested
        _maxY = math.max(10.0, maxValue * 1.2); // 20% padding, minimum 10 mg/dL
      }
      
      setState(() {
        _asamUratData = data;
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
        title: 'Asam Urat',
        subtitle: 'Grafik perkembangan asam urat',
        isLoading: _isLoading,
        onTap: widget.onTap,
        chartWidget: _asamUratData.isEmpty 
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
                        if (!isLoading && _asamUratData.isNotEmpty)
                          InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: _toggleSatuan,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: themeColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _showAsMgdL ? 'mg/dL' : 'µmol/L',
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
                if (!isLoading && _asamUratData.isNotEmpty) ...[
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
      if (_asamUratData.isNotEmpty) {
        double maxValue = 0;
        
        for (var item in _asamUratData) {
          final double value = _showAsMgdL 
              ? item.getHasilInMgdL() 
              : item.getHasilInMicroMolL();
          if (value > maxValue) maxValue = value;
        }
        
        // Add padding to max value
        _minY = 0; // Always start from 0
        _maxY = maxValue * 1.2; // 20% padding
      }
    });
  }

  // Method to build chart legend
  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('Asam Urat Anda', themeColor),
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
    final data = _processAsamUratData();
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
                  if (_asamUratData.length > 5) {
                    if (value.toInt() % math.max(1, (_asamUratData.length / 5).round()) != 0 &&
                        value.toInt() != _asamUratData.length - 1) {
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
                  
                  // Format based on current unit
                  String valueText;
                  if (_showAsMgdL) {
                    valueText = value.toStringAsFixed(value < 10 ? 1 : 0);
                  } else {
                    valueText = value.toInt().toString();
                  }
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: Text(
                      valueText,
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
              // tooltipBgColor: Colors.white,
              tooltipRoundedRadius: 8,
              tooltipBorder: BorderSide(color: Colors.grey.shade300),
              tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((LineBarSpot touchedSpot) {
                  if (touchedSpot.x.toInt() >= _asamUratData.length) {
                    return null;
                  }
                  
                  final bool isActualValue = touchedSpot.barIndex == 0;
                  final String label = isActualValue ? 'Nilai' : 'Normal';
                  
                  double value;
                  String unit;
                  
                  if (isActualValue) {
                    // Actual value from data
                    value = _showAsMgdL
                        ? _asamUratData[touchedSpot.x.toInt()].getHasilInMgdL()
                        : _asamUratData[touchedSpot.x.toInt()].getHasilInMicroMolL();
                  } else {
                    // Normal reference value
                    value = _showAsMgdL
                        ? _getNormalValue(_asamUratData[touchedSpot.x.toInt()].tanggal)
                        : convertMgdLToMicroMolL(_getNormalValue(_asamUratData[touchedSpot.x.toInt()].tanggal));
                  }
                  
                  unit = _showAsMgdL ? 'mg/dL' : 'µmol/L';
                  
                  return LineTooltipItem(
                    '$label: ${value.toStringAsFixed(_showAsMgdL ? 1 : 0)} $unit',
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
      if (_maxY <= 10) return 1.0;
      if (_maxY <= 20) return 2.0;
      return 5.0;
    } else {
      if (_maxY <= 500) return 50.0;
      if (_maxY <= 1000) return 100.0;
      return 200.0;
    }
  }

  // Generate X-axis labels from dates
  List<String> _generateXLabels() {
    List<String> labels = [];
    
    for (int i = 0; i < _asamUratData.length; i++) {
      final date = DateFormat('yyyy-MM-dd').parse(_asamUratData[i].tanggal);
      labels.add(DateFormat('dd/MM').format(date));
    }
    
    return labels;
  }

  // Process AsamUrat data for chart
  List<List<FlSpot>> _processAsamUratData() {
    final int dataPointsCount = _asamUratData.length;
    List<FlSpot> actualLine = [];
    List<FlSpot> normalLine = [];
    
    for (int i = 0; i < dataPointsCount; i++) {
      // Get actual value based on selected unit
      double value = _showAsMgdL
          ? _asamUratData[i].getHasilInMgdL()
          : _asamUratData[i].getHasilInMicroMolL();
      
      actualLine.add(FlSpot(i.toDouble(), value));
      
      // Get normal reference value for this date
      double normalValue = _showAsMgdL
          ? _getNormalValue(_asamUratData[i].tanggal)
          : convertMgdLToMicroMolL(_getNormalValue(_asamUratData[i].tanggal));
      
      normalLine.add(FlSpot(i.toDouble(), normalValue));
    }
    
    return [actualLine, normalLine];
  }
  
  // Get normal value based on user profile and date
  double _getNormalValue(String dateString) {
    // Default if profile not available
    if (_userProfile == null || _userProfile!['tanggalLahir'] == null || _userProfile!['gender'] == null) {
      return 6.0; // Standard normal value in mg/dL
    }
    
    final int age = _calculateAge(_userProfile!['tanggalLahir']);
    final String gender = _userProfile!['gender'].toLowerCase();
    
    // Menggunakan logika yang sama dengan di read_asamurat.dart
    if (gender == 'pria' || gender == 'laki-laki') {
      if (age < 18) {
        return 5.5; // Anak laki-laki
      } else {
        return 7.0; // Pria dewasa
      }
    } else { // Wanita
      if (age < 18) {
        return 4.5; // Anak perempuan
      } else if (age < 50) {
        return 6.0; // Wanita pra-menopause
      } else {
        return 6.5; // Wanita post-menopause
      }
    }
  }
  
  // Calculate age from birthdate (using consistent format from read_asamurat.dart)
  int _calculateAge(String birthDateString) {
    try {
      // Parsing dari format dd-MM-yyyy sesuai dengan read_asamurat.dart
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
    // Menentukan rentang normal berdasarkan profil
    List<Map<String, dynamic>> normalRanges = _getNormalRanges();

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
                'Informasi Asam Urat',
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
                  'Rentang normal kadar asam urat:',
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
                
                for (var range in normalRanges) ...[
                  _buildInfoRow(
                    range['status'], 
                    _showAsMgdL ? range['range'] : range['range_si'], 
                    range['color']
                  ),
                  const SizedBox(height: 8),
                ],
                
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
                        'Asam urat tinggi dapat menyebabkan gout arthritis, batu ginjal, dan gangguan ginjal. Konsultasikan dengan dokter jika nilai asam urat Anda tinggi.',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // const SizedBox(height: 12),
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
                //         'Tampilkan dalam ${_showAsMgdL ? 'µmol/L' : 'mg/dL'}',
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
    crossAxisAlignment: CrossAxisAlignment.start, // Memastikan alignment yang konsisten
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
  List<Map<String, dynamic>> _getNormalRanges() {
    if (_userProfile == null || _userProfile!['tanggalLahir'] == null || _userProfile!['gender'] == null) {
      // Nilai standar umum
      return [
        {
          'status': 'Normal',
          'range': '< 6.0 mg/dL',
          'range_si': '< 357 µmol/L',
          'color': Colors.green.shade700
        },
        {
          'status': 'Borderline',
          'range': '6.0 - 7.0 mg/dL',
          'range_si': '357 - 416 µmol/L',
          'color': Colors.amber.shade700
        },
        {
          'status': 'Tinggi',
          'range': '> 7.0 mg/dL',
          'range_si': '> 416 µmol/L',
          'color': Colors.red.shade700
        }
      ];
    }
    
    final int age = _calculateAge(_userProfile!['tanggalLahir']);
    final String gender = _userProfile!['gender'].toLowerCase();
    
    if (gender == 'pria' || gender == 'laki-laki') {
      if (age < 18) {
        // Anak laki-laki
        return [
          {
            'status': 'Normal',
            'range': '< 5.5 mg/dL',
            'range_si': '< 327 µmol/L',
            'color': Colors.green.shade700
          },
          {
            'status': 'Borderline',
            'range': '5.5 - 6.5 mg/dL',
            'range_si': '327 - 387 µmol/L',
            'color': Colors.amber.shade700
          },
          {
            'status': 'Tinggi',
            'range': '> 6.5 mg/dL',
            'range_si': '> 387 µmol/L',
            'color': Colors.red.shade700
          }
        ];
      } else {
        // Pria dewasa
        return [
          {
            'status': 'Normal',
            'range': '< 7.0 mg/dL',
            'range_si': '< 416 µmol/L',
            'color': Colors.green.shade700
          },
          {
            'status': 'Borderline',
            'range': '7.0 - 8.0 mg/dL',
            'range_si': '416 - 476 µmol/L',
            'color': Colors.amber.shade700
          },
          {
            'status': 'Tinggi',
            'range': '> 8.0 mg/dL',
            'range_si': '> 476 µmol/L',
            'color': Colors.red.shade700
          }
        ];
      }
    } else { // Wanita
      if (age < 18) {
        // Anak perempuan
        return [
          {
            'status': 'Normal',
            'range': '< 4.5 mg/dL',
            'range_si': '< 268 µmol/L',
            'color': Colors.green.shade700
          },
          {
            'status': 'Borderline',
            'range': '4.5 - 5.5 mg/dL',
            'range_si': '268 - 327 µmol/L',
            'color': Colors.amber.shade700
          },
          {
            'status': 'Tinggi',
            'range': '> 5.5 mg/dL',
            'range_si': '> 327 µmol/L',
            'color': Colors.red.shade700
          }
        ];
      } else if (age < 50) {
        // Wanita pra-menopause
        return [
          {
            'status': 'Normal',
            'range': '< 6.0 mg/dL',
            'range_si': '< 357 µmol/L',
            'color': Colors.green.shade700
          },
          {
            'status': 'Borderline',
            'range': '6.0 - 7.0 mg/dL',
            'range_si': '357 - 416 µmol/L',
            'color': Colors.amber.shade700
          },
          {
            'status': 'Tinggi',
            'range': '> 7.0 mg/dL',
            'range_si': '> 416 µmol/L',
            'color': Colors.red.shade700
          }
        ];
      } else {
        // Wanita post-menopause
        return [
          {
            'status': 'Normal',
            'range': '< 6.5 mg/dL',
            'range_si': '< 387 µmol/L',
            'color': Colors.green.shade700
          },
          {
            'status': 'Borderline',
            'range': '6.5 - 7.5 mg/dL',
            'range_si': '387 - 446 µmol/L',
            'color': Colors.amber.shade700
          },
          {
            'status': 'Tinggi',
            'range': '> 7.5 mg/dL',
            'range_si': '> 446 µmol/L',
            'color': Colors.red.shade700
          }
        ];
      }
    }
  }
}