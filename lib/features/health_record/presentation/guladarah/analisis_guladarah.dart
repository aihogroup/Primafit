import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'package:intl/intl.dart';

// Import database helper
import 'package:primafit/features/health_record/data/database_guladarah.dart';

class GrafikGulaDarah extends StatefulWidget {
  final VoidCallback onTap;
  
  const GrafikGulaDarah({
    super.key,
    required this.onTap,
  });

  @override
  State<GrafikGulaDarah> createState() => _GrafikGulaDarahState();
}

class _GrafikGulaDarahState extends State<GrafikGulaDarah> with SingleTickerProviderStateMixin {
  // Theme color
  final Color themeColor = const Color(0xFF64D1DE);
  final Color secondaryColor = const Color(0xFFBA68C8);
  
  // Category colors
  final Color hypoglycemiaColor = Colors.purple.shade700;
  final Color normalColor = Colors.green.shade700;
  final Color prediabetesColor = Colors.amber.shade700;
  final Color diabetesColor = Colors.red.shade700;
  
  // Data loading state
  bool _isLoading = true;
  
  // Data for chart
  List<GulaDarah> _gulaDarahData = [];
  
  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Min/Max values for Y axis
  double _minY = 0;
  double _maxY = 200;
  
  // Toggle for display unit
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
      // Load Gula Darah data
      final data = await GulaDarahDatabaseHelper.instance.getAllGulaDarah();
      
      
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
          final double value = item.getHasilInMgdL();
          if (value < minValue) minValue = value;
          if (value > maxValue) maxValue = value;
        }
        
        // Add padding to min/max values
        _minY = 0; // Always start from 0 for better visualization
        _maxY = math.max(200, maxValue * 1.2); // At least 200 or 20% above max value
      }
      
      setState(() {
        _gulaDarahData = data;
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
        title: 'Gula Darah',
        subtitle: 'Grafik perkembangan gula darah',
        isLoading: _isLoading,
        onTap: widget.onTap,
        chartWidget: _gulaDarahData.isEmpty 
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
                        // Toggle unit button
                        if (!isLoading && _gulaDarahData.isNotEmpty)
                          InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: _toggleUnit,
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
                if (!isLoading && _gulaDarahData.isNotEmpty) ...[
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

  // Toggle between mg/dL and mmol/L
  void _toggleUnit() {
    setState(() {
      _showAsMgdL = !_showAsMgdL;
      
      // Recalculate Y-axis based on new unit
      if (_gulaDarahData.isNotEmpty) {
        double maxValue = 0;
        
        for (var item in _gulaDarahData) {
          final double value = _showAsMgdL 
              ? item.getHasilInMgdL()
              : item.getHasilInMmolL();
          if (value > maxValue) maxValue = value;
        }
        
        // Add padding to max value
        _minY = 0; // Always start from 0
        if (_showAsMgdL) {
          _maxY = math.max(200, maxValue * 1.2); // 20% padding, minimum 200 mg/dL
        } else {
          _maxY = math.max(11, maxValue * 1.2); // 20% padding, minimum 11 mmol/L
        }
      }
    });
  }

  // Method to build chart legend
  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem('Gula Darah Anda', themeColor),
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
    final data = _processGulaDarahData();
    final actualData = data[0];
    final referenceData = data[1];
    
    // Generate X-axis labels based on dates
    final List<String> xLabels = _generateXLabels();
    
    // Calculate Y-axis interval based on current unit and range
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
                  if (_gulaDarahData.length > 5) {
                    if (value.toInt() % math.max(1, (_gulaDarahData.length / 5).round()) != 0 &&
                        value.toInt() != _gulaDarahData.length - 1) {
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
                  
                  final String label = _showAsMgdL
                      ? value.toInt().toString()
                      : value.toStringAsFixed(1);
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 5),
                    child: Text(
                      label,
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
                  if (touchedSpot.x.toInt() >= _gulaDarahData.length) {
                    return null;
                  }
                  
                  final bool isActualValue = touchedSpot.barIndex == 0;
                  final String label = isActualValue ? 'Nilai' : 'Normal';
                  
                  double value;
                  final String unit = _showAsMgdL ? 'mg/dL' : 'mmol/L';
                  
                  if (isActualValue) {
                    // Actual value from data
                    value = _showAsMgdL
                        ? _gulaDarahData[touchedSpot.x.toInt()].getHasilInMgdL()
                        : _gulaDarahData[touchedSpot.x.toInt()].getHasilInMmolL();
                        
                    // Get status for this value
                    final status = _getGulaDarahStatus(
                      _gulaDarahData[touchedSpot.x.toInt()].getHasilInMgdL(), 
                      inMgdL: true
                    );
                    
                    return LineTooltipItem(
                      '$label: ${_showAsMgdL ? value.toStringAsFixed(0) : value.toStringAsFixed(1)} $unit',
                      GoogleFonts.poppins(
                        color: themeColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      children: [
                        TextSpan(
                          text: '\nStatus: ${status['status']}',
                          style: GoogleFonts.poppins(
                            color: status['color'],
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    );
                  } else {
                    // Normal reference value
                    value = _showAsMgdL
                        ? _getNormalValue()
                        : convertMgdLToMmolL(_getNormalValue());
                    
                    return LineTooltipItem(
                      '$label: ${_showAsMgdL ? value.toStringAsFixed(0) : value.toStringAsFixed(1)} $unit',
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

  // Calculate appropriate Y-axis interval based on range and unit
  double _calculateYInterval() {
    if (_showAsMgdL) {
      if (_maxY <= 100) return 10.0;
      if (_maxY <= 200) return 20.0;
      if (_maxY <= 300) return 50.0;
      return 100.0;
    } else {
      if (_maxY <= 6) return 1.0;
      if (_maxY <= 12) return 2.0;
      return 3.0;
    }
  }

  // Generate X-axis labels from dates
  List<String> _generateXLabels() {
    final List<String> labels = [];
    
    for (int i = 0; i < _gulaDarahData.length; i++) {
      final date = DateFormat('yyyy-MM-dd').parse(_gulaDarahData[i].tanggal);
      labels.add(DateFormat('dd/MM').format(date));
    }
    
    return labels;
  }

  // Process Gula Darah data for chart
  List<List<FlSpot>> _processGulaDarahData() {
    final int dataPointsCount = _gulaDarahData.length;
    final List<FlSpot> actualLine = [];
    final List<FlSpot> normalLine = [];
    
    final double normalValue = _showAsMgdL 
        ? _getNormalValue() 
        : convertMgdLToMmolL(_getNormalValue());
    
    for (int i = 0; i < dataPointsCount; i++) {
      // Get value based on selected unit
      final double value = _showAsMgdL
          ? _gulaDarahData[i].getHasilInMgdL()
          : _gulaDarahData[i].getHasilInMmolL();
      
      actualLine.add(FlSpot(i.toDouble(), value));
      
      // Normal reference line
      normalLine.add(FlSpot(i.toDouble(), normalValue));
    }
    
    return [actualLine, normalLine];
  }
  
  // Get normal value (using upper limit of normal range: 99 mg/dL)
  double _getNormalValue() {
    return 99.0; // Upper limit of normal range for fasting blood glucose
  }
  
  // Fungsi untuk menentukan status gula darah berdasarkan nilai - consistent with read_guladarah.dart
  Map<String, dynamic> _getGulaDarahStatus(double value, {bool inMgdL = true}) {
    // Konversi nilai ke mg/dL jika perlu
    final double mgdLValue = inMgdL ? value : convertMmolLToMgdL(value);
    
    // Kategori berdasarkan gula darah puasa (FPG)
    if (mgdLValue < 70) {
      return {
        'status': 'Hipoglikemia', 
        'color': hypoglycemiaColor,
        'bgColor': Colors.purple.shade50,
        'range': inMgdL ? '< 70 mg/dL' : '< 3.9 mmol/L'
      };
    } else if (mgdLValue >= 70 && mgdLValue < 100) {
      return {
        'status': 'Normal', 
        'color': normalColor,
        'bgColor': Colors.green.shade50,
        'range': inMgdL ? '70 - 99 mg/dL' : '3.9 - 5.5 mmol/L'
      };
    } else if (mgdLValue >= 100 && mgdLValue < 126) {
      return {
        'status': 'Prediabetes', 
        'color': prediabetesColor,
        'bgColor': Colors.amber.shade50,
        'range': inMgdL ? '100 - 125 mg/dL' : '5.6 - 6.9 mmol/L'
      };
    } else {
      return {
        'status': 'Diabetes', 
        'color': diabetesColor,
        'bgColor': Colors.red.shade50,
        'range': inMgdL ? '≥ 126 mg/dL' : '≥ 7.0 mmol/L'
      };
    }
  }
  
  // Fungsi untuk mengkonversi mmol/L ke mg/dL
  double convertMmolLToMgdL(double mmolL) {
    // Faktor konversi: 1 mmol/L = 18.018 mg/dL untuk glukosa
    return mmolL * 18.018;
  }
  
  // Fungsi untuk mengkonversi mg/dL ke mmol/L
  double convertMgdLToMmolL(double mgdL) {
    // Faktor konversi: 1 mg/dL = 0.0555 mmol/L untuk glukosa
    return mgdL * 0.0555;
  }
  
  // Show information dialog
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
              Expanded(
                child: Text(
                  'Kategori Gula Darah Puasa',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.end,
                //   children: [
                //     TextButton.icon(
                //       onPressed: () {
                //         setState(() {
                //           _showAsMgdL = !_showAsMgdL;
                //         });
                //         Navigator.pop(context);
                //         _showInfoDialog(context);
                //       },
                //       icon: Icon(
                //         CupertinoIcons.arrow_2_circlepath,
                //         size: 16,
                //         color: themeColor,
                //       ),
                //       label: Text(
                //         _showAsMgdL ? 'Tampilkan dalam mmol/L' : 'Tampilkan dalam mg/dL',
                //         style: GoogleFonts.poppins(
                //           fontSize: 12,
                //           color: themeColor,
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  'Hipoglikemia', 
                  _showAsMgdL ? '< 70 mg/dL' : '< 3.9 mmol/L', 
                  hypoglycemiaColor
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  'Normal', 
                  _showAsMgdL ? '70 - 99 mg/dL' : '3.9 - 5.5 mmol/L', 
                  normalColor
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  'Prediabetes', 
                  _showAsMgdL ? '100 - 125 mg/dL' : '5.6 - 6.9 mmol/L', 
                  prediabetesColor
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  'Diabetes', 
                  _showAsMgdL ? '≥ 126 mg/dL' : '≥ 7.0 mmol/L', 
                  diabetesColor
                ),
                
                const SizedBox(height: 16),
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
                        'Nilai di atas adalah untuk gula darah puasa. Konsultasikan dengan dokter jika nilai gula darah Anda tidak normal. Pemeriksaan HbA1c diperlukan untuk diagnosis diabetes yang definitif.',
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