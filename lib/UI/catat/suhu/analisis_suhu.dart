import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';

// Import database helper
import 'package:primafit/database/catat/database_suhu.dart';
import 'package:primafit/database/navigasi/database_profile.dart';

class GrafikSuhu extends StatefulWidget {
  final VoidCallback onTap;
  
  const GrafikSuhu({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  State<GrafikSuhu> createState() => _GrafikSuhuState();
}

class _GrafikSuhuState extends State<GrafikSuhu> with SingleTickerProviderStateMixin {
  // Theme color
  final Color themeColor = const Color(0xFF64D1DE);
  final Color secondaryColor = const Color(0xFFF06292); // Pink shade for fever line
  final Color normalRangeColor = const Color(0xFF66BB6A); // Green shade for normal range
  
  // Data loading state
  bool _isLoading = true;
  
  // Data for chart
  List<SuhuTubuh> _suhuData = [];
  Map<String, dynamic>? _userProfile;
  
  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Min/Max values for Y axis
  double _minY = 0;
  double _maxY = 0;
  
  // Toggle untuk tampilan satuan (°C atau °F)
  bool _showAsCelsius = true;

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
      // Load suhu data
      final data = await SuhuDatabaseHelper.instance.getAllSuhu();
      
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
        double maxValue = -double.infinity;
        
        for (var item in data) {
          final double value = double.tryParse(item.hasil) ?? 0;
          if (value < minValue) minValue = value;
          if (value > maxValue) maxValue = value;
        }
        
        // Add padding to min/max values and set appropriate ranges for suhu
        if (_showAsCelsius) {
          _minY = math.max(32, minValue - 2); // Minimum should be at least 32°C with 2 degrees padding
          _maxY = math.min(42, maxValue + 2); // Maximum should be at most 42°C with 2 degrees padding
        } else {
          _minY = math.max(90, minValue - 3); // Minimum should be at least 90°F with 3 degrees padding
          _maxY = math.min(108, maxValue + 3); // Maximum should be at most 108°F with 3 degrees padding
        }
      } else {
        // Default ranges if no data
        _minY = _showAsCelsius ? 35.0 : 95.0;
        _maxY = _showAsCelsius ? 40.0 : 104.0;
      }
      
      setState(() {
        _suhuData = data;
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
        title: 'Suhu Tubuh',
        subtitle: 'Grafik perkembangan suhu tubuh',
        isLoading: _isLoading,
        onTap: widget.onTap,
        chartWidget: _suhuData.isEmpty 
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
                        if (!isLoading && _suhuData.isNotEmpty)
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
                                _showAsCelsius ? '°C' : '°F',
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
                if (!isLoading && _suhuData.isNotEmpty) ...[
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
      _showAsCelsius = !_showAsCelsius;
      
      // Recalculate Y-axis based on new unit
      if (_suhuData.isNotEmpty) {
        double minValue = double.infinity;
        double maxValue = -double.infinity;
        
        for (var item in _suhuData) {
          double value;
          if (item.satuan == '°C') {
            value = double.tryParse(item.hasil) ?? 0;
            if (!_showAsCelsius) {
              value = convertCelsiusToFahrenheit(value);
            }
          } else { // °F
            value = double.tryParse(item.hasil) ?? 0;
            if (_showAsCelsius) {
              value = convertFahrenheitToCelsius(value);
            }
          }
          
          if (value < minValue) minValue = value;
          if (value > maxValue) maxValue = value;
        }
        
        // Set appropriate ranges
        if (_showAsCelsius) {
          _minY = math.max(32, minValue - 2); // Minimum should be at least 32°C
          _maxY = math.min(42, maxValue + 2); // Maximum should be at most 42°C
        } else {
          _minY = math.max(90, minValue - 3); // Minimum should be at least 90°F
          _maxY = math.min(108, maxValue + 3); // Maximum should be at most 108°F
        }
      } else {
        // Default ranges if no data
        _minY = _showAsCelsius ? 35.0 : 95.0;
        _maxY = _showAsCelsius ? 40.0 : 104.0;
      }
    });
  }

  // Method to build chart legend
  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('Suhu Anda', themeColor),
        const SizedBox(width: 24),
        _buildLegendItem('Batas Normal', normalRangeColor),
        const SizedBox(width: 24),
        _buildLegendItem('Batas Demam', secondaryColor),
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
    final data = _processSuhuData();
    final actualData = data[0];
    final normalData = data[1];
    final feverData = data[2];
    
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
                  if (_suhuData.length > 5) {
                    if (value.toInt() % math.max(1, (_suhuData.length / 5).round()) != 0 &&
                        value.toInt() != _suhuData.length - 1) {
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
                color: themeColor.withOpacity(0.1),
              ),
            ),
            // Normal range line (green)
            LineChartBarData(
              spots: normalData,
              isCurved: false,
              color: normalRangeColor,
              barWidth: 2,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: false,
              ),
              dashArray: [5, 5], // Add dashed line for reference
              belowBarData: BarAreaData(show: false),
            ),
            // Fever threshold line (pink)
            LineChartBarData(
              spots: feverData,
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
                  if (touchedSpot.x.toInt() >= _suhuData.length) {
                    return null;
                  }
                  
                  final int barIndex = touchedSpot.barIndex;
                  
                  String label;
                  Color color;
                  
                  switch (barIndex) {
                    case 0:
                      label = 'Suhu';
                      color = themeColor;
                      break;
                    case 1:
                      label = 'Normal';
                      color = normalRangeColor;
                      break;
                    case 2:
                      label = 'Demam';
                      color = secondaryColor;
                      break;
                    default:
                      return null;
                  }
                  
                  // Display appropriate value
                  double value;
                  if (barIndex == 0) {
                    // Get actual value with proper unit conversion
                    final item = _suhuData[touchedSpot.x.toInt()];
                    if (item.satuan == '°C') {
                      value = double.parse(item.hasil);
                      if (!_showAsCelsius) {
                        value = convertCelsiusToFahrenheit(value);
                      }
                    } else { // °F
                      value = double.parse(item.hasil);
                      if (_showAsCelsius) {
                        value = convertFahrenheitToCelsius(value);
                      }
                    }
                  } else {
                    // For reference lines, use the Y value directly
                    value = touchedSpot.y;
                  }
                  
                  final String unit = _showAsCelsius ? '°C' : '°F';
                  
                  return LineTooltipItem(
                    '$label: ${value.toStringAsFixed(1)} $unit',
                    GoogleFonts.poppins(
                      color: color,
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
    if (_showAsCelsius) {
      if (_maxY - _minY <= 5) return 0.5;  // 0.5°C intervals if range is small
      return 1.0;  // 1.0°C intervals otherwise
    } else {
      if (_maxY - _minY <= 10) return 1.0;  // 1.0°F intervals if range is small
      return 2.0;  // 2.0°F intervals otherwise
    }
  }

  // Generate X-axis labels from dates
  List<String> _generateXLabels() {
    List<String> labels = [];
    
    for (int i = 0; i < _suhuData.length; i++) {
      final date = DateFormat('yyyy-MM-dd').parse(_suhuData[i].tanggal);
      labels.add(DateFormat('dd/MM').format(date));
    }
    
    return labels;
  }

  // Process suhu data for chart
  List<List<FlSpot>> _processSuhuData() {
    final int dataPointsCount = _suhuData.length;
    List<FlSpot> actualLine = [];
    List<FlSpot> normalLine = [];
    List<FlSpot> feverLine = [];
    
    for (int i = 0; i < dataPointsCount; i++) {
      // Get actual value with proper unit conversion
      double actualValue;
      final item = _suhuData[i];
      
      if (item.satuan == '°C') {
        actualValue = double.tryParse(item.hasil) ?? 0;
        if (!_showAsCelsius) {
          actualValue = convertCelsiusToFahrenheit(actualValue);
        }
      } else { // °F
        actualValue = double.tryParse(item.hasil) ?? 0;
        if (_showAsCelsius) {
          actualValue = convertFahrenheitToCelsius(actualValue);
        }
      }
      
      actualLine.add(FlSpot(i.toDouble(), actualValue));
      
      // Add normal temperature reference line
      double normalValue = _showAsCelsius ? 37.0 : 98.6;
      normalLine.add(FlSpot(i.toDouble(), normalValue));
      
      // Add fever threshold reference line
      double feverValue = _showAsCelsius ? 38.0 : 100.4;
      feverLine.add(FlSpot(i.toDouble(), feverValue));
    }
    
    return [actualLine, normalLine, feverLine];
  }
  
  // Convenience function to convert Celsius to Fahrenheit
  double convertCelsiusToFahrenheit(double celsius) {
    return (celsius * 9/5) + 32;
  }
  
  // Convenience function to convert Fahrenheit to Celsius
  double convertFahrenheitToCelsius(double fahrenheit) {
    return (fahrenheit - 32) * 5/9;
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
                'Informasi Suhu Tubuh',
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
                  'Rentang suhu tubuh normal:',
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
                
                // Suhu normal
                _buildInfoRow(
                  'Normal', 
                  _getNormalRanges()['normal']!, 
                  normalRangeColor
                ),
                const SizedBox(height: 8),
                
                // Indikasi demam ringan
                _buildInfoRow(
                  'Demam Ringan', 
                  _getNormalRanges()['demamRingan']!, 
                  Colors.orange
                ),
                const SizedBox(height: 8),
                
                // Indikasi demam tinggi
                _buildInfoRow(
                  'Demam', 
                  _getNormalRanges()['demam']!, 
                  secondaryColor
                ),
                const SizedBox(height: 8),
                
                // Indikasi demam sangat tinggi
                _buildInfoRow(
                  'Demam Tinggi', 
                  _getNormalRanges()['demamTinggi']!, 
                  Colors.red
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
                        'Demam tinggi bisa menjadi tanda infeksi atau masalah kesehatan lainnya. Konsultasikan dengan dokter jika Anda mengalami demam tinggi atau demam yang berlangsung lebih dari 3 hari.',
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
  
  // Get appropriate normal ranges based on profile and unit selection
  Map<String, String> _getNormalRanges() {
    bool isAdult = true;
    
    if (_userProfile != null && _userProfile!['tanggalLahir'] != null) {
      final int age = _calculateAge(_userProfile!['tanggalLahir']);
      isAdult = age >= 18;
    }
    
    if (_showAsCelsius) {
      // Ranges in Celsius
      if (isAdult) {
        return {
          'normal': '36.1°C - 37.2°C',
          'demamRingan': '37.3°C - 38.0°C',
          'demam': '38.1°C - 39.0°C',
          'demamTinggi': '> 39.0°C'
        };
      } else {
        // Children have slightly higher normal temperatures
        return {
          'normal': '36.6°C - 37.5°C',
          'demamRingan': '37.6°C - 38.3°C',
          'demam': '38.4°C - 39.5°C',
          'demamTinggi': '> 39.5°C'
        };
      }
    } else {
      // Ranges in Fahrenheit
      if (isAdult) {
        return {
          'normal': '97.0°F - 99.0°F',
          'demamRingan': '99.1°F - 100.4°F',
          'demam': '100.5°F - 102.2°F',
          'demamTinggi': '> 102.2°F'
        };
      } else {
        // Children have slightly higher normal temperatures
        return {
          'normal': '98.0°F - 99.5°F',
          'demamRingan': '99.6°F - 100.9°F',
          'demam': '101.0°F - 103.1°F',
          'demamTinggi': '> 103.1°F'
        };
      }
    }
  }
  
  // Calculate age from birthdate
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
}