import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:primafit/features/women_health/presentation/menstruasi/model_menstruasi.dart';
import 'package:primafit/features/women_health/data/database_menstruasi.dart';
import 'package:fl_chart/fl_chart.dart';

class MenstrualStatisticsPage extends StatefulWidget {
  const MenstrualStatisticsPage({super.key});

  @override
  _MenstrualStatisticsPageState createState() => _MenstrualStatisticsPageState();
}

class _MenstrualStatisticsPageState extends State<MenstrualStatisticsPage>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  List<MenstrualCycle> _cycles = [];
  Map<String, dynamic> _statistics = {};
  
  late AnimationController _fadeAnimationController;
  late AnimationController _scaleAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  final DateFormat _dateFormat = DateFormat('d MMM yyyy');
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadData();
  }
  
  void _initializeAnimations() {
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _scaleAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleAnimationController,
      curve: Curves.elasticOut,
    ));
  }
  
  @override
  void dispose() {
    _fadeAnimationController.dispose();
    _scaleAnimationController.dispose();
    super.dispose();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Load all cycles
      final cycles = await DatabaseHelperMenstrual.instance.getAllCycles();
      
      // Calculate statistics
      final stats = await DatabaseHelperMenstrual.instance.getCycleStatistics();
      
      if (mounted) {
        setState(() {
          _cycles = cycles;
          _statistics = stats;
          _isLoading = false;
        });
        
        // Start animations
        _fadeAnimationController.forward();
        _scaleAnimationController.forward();
        
        // Show success feedback
        _showSuccessFeedback();
      }
    } catch (e) {
      debugPrint('Error loading statistics: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorFeedback();
      }
    }
  }
  
  void _showSuccessFeedback() {
    if (_cycles.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(CupertinoIcons.checkmark_circle_fill, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Data berhasil dimuat (${_cycles.length} siklus)',
                  style: GoogleFonts.poppins(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }
  
  void _showErrorFeedback() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(CupertinoIcons.exclamationmark_triangle_fill, color: Colors.white),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Gagal memuat data. Coba lagi.',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        action: SnackBarAction(
          label: 'Coba Lagi',
          textColor: Colors.white,
          onPressed: _loadData,
        ),
      ),
    );
  }
  
  Widget _buildStatisticCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? subtitle,
    int animationDelay = 0,
  }) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + (animationDelay * 100)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, animationValue, child) {
        return Transform.scale(
          scale: animationValue,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        size: 18,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildCycleLengthChart() {
    // Check if we have enough data
    if (_cycles.length < 2) {
      return Container(
        height: 320,
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              duration: const Duration(seconds: 1),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Icon(
                    CupertinoIcons.chart_bar,
                    size: 60,
                    color: Colors.grey.shade400,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Belum Cukup Data',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Catat minimal 2 siklus untuk melihat grafik tren perubahan',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                overflow: TextOverflow.visible,
              ),
            ),
          ],
        ),
      );
    }
    
    // Prepare data
    List<FlSpot> cycleLengthSpots = [];
    List<FlSpot> periodLengthSpots = [];
    
    for (int i = 0; i < _cycles.length; i++) {
      cycleLengthSpots.add(FlSpot(i.toDouble(), _cycles[i].cycleLength.toDouble()));
      periodLengthSpots.add(FlSpot(i.toDouble(), _cycles[i].periodLength.toDouble()));
    }
    
    // Reverse to show oldest to newest (left to right)
    cycleLengthSpots = cycleLengthSpots.reversed.toList();
    periodLengthSpots = periodLengthSpots.reversed.toList();
    
    // Find min and max values
    final double minY = 0;
    final double maxY = 40; // Default max for cycle length
    
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 1000),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeInOut,
      builder: (context, animationValue, child) {
        return Transform.scale(
          scale: animationValue,
          child: Container(
            height: 350,
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tren Panjang Siklus',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Perkembangan panjang siklus dan periode',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: true,
                            horizontalInterval: 5,
                            verticalInterval: 1,
                            getDrawingHorizontalLine: (value) {
                              return FlLine(
                                color: Colors.grey.shade200,
                                strokeWidth: 1,
                              );
                            },
                            getDrawingVerticalLine: (value) {
                              return FlLine(
                                color: Colors.grey.shade200,
                                strokeWidth: 1,
                              );
                            },
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 30,
                                getTitlesWidget: (value, meta) {
                                  // Get cycle dates (oldest to newest)
                                  final cycles = _cycles.reversed.toList();
                                  if (value.toInt() >= 0 && value.toInt() < cycles.length) {
                                    final cycle = cycles[value.toInt()];
                                    final month = DateFormat('MMM').format(cycle.startDate);
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        month,
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          color: Colors.grey.shade600,
                                        ),
                                        textAlign: TextAlign.center,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }
                                  return const SizedBox();
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 5,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    '${value.toInt()}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: Colors.grey.shade600,
                                    ),
                                    textAlign: TextAlign.center,
                                  );
                                },
                              ),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          minX: 0,
                          maxX: _cycles.length.toDouble() - 1,
                          minY: minY,
                          maxY: maxY,
                          lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                              tooltipRoundedRadius: 8,
                              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                                return touchedSpots.map((spot) {
                                  final cycles = _cycles.reversed.toList();
                                  final cycle = cycles[spot.x.toInt()];
                                  final date = _dateFormat.format(cycle.startDate);
                                  
                                  String text;
                                  Color color;
                                  
                                  if (spot.barIndex == 0) {
                                    text = 'Panjang Siklus: ${spot.y.toInt()} hari';
                                    color = const Color(0xFFE9458D);
                                  } else {
                                    text = 'Lama Periode: ${spot.y.toInt()} hari';
                                    color = Colors.purple.shade400;
                                  }
                                  
                                  return LineTooltipItem(
                                    '$date\n$text',
                                    GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: color,
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                          ),
                          lineBarsData: [
                            // Cycle length line
                            LineChartBarData(
                              spots: cycleLengthSpots,
                              isCurved: true,
                              color: const Color(0xFFE9458D),
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 4,
                                    color: const Color(0xFFE9458D),
                                    strokeWidth: 2,
                                    strokeColor: Colors.white,
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                color: const Color(0xFFE9458D).withValues(alpha: 0.1),
                              ),
                            ),
                            // Period length line
                            LineChartBarData(
                              spots: periodLengthSpots,
                              isCurved: true,
                              color: Colors.purple.shade400,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 4,
                                    color: Colors.purple.shade400,
                                    strokeWidth: 2,
                                    strokeColor: Colors.white,
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                color: Colors.purple.shade400.withValues(alpha: 0.1),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildChartLegendItem(
                      'Panjang Siklus',
                      const Color(0xFFE9458D),
                    ),
                    const SizedBox(width: 24),
                    _buildChartLegendItem(
                      'Lama Periode',
                      Colors.purple.shade400,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildChartLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
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
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
  
  Widget _buildSymptomStats() {
    // Check if we have top symptoms
    final topSymptoms = _statistics['top_symptoms'] as List<Map<String, dynamic>>? ?? [];
    
    if (topSymptoms.isEmpty) {
      return TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 800),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.scale(
            scale: value,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    CupertinoIcons.heart_circle,
                    size: 50,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum Ada Data Gejala',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Catat gejala saat menstruasi untuk melihat statistik yang lebih detail',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
    
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gejala Paling Sering',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                ...topSymptoms.asMap().entries.map((entry) {
                  final index = entry.key;
                  final symptom = entry.value;
                  final type = symptom['type'] as SymptomType;
                  final count = symptom['count'] as int;
                  
                  return TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 600 + (index * 100)),
                    tween: Tween(begin: 0.0, end: 1.0),
                    curve: Curves.easeOutBack,
                    builder: (context, animValue, child) {
                      return Transform.translate(
                        offset: Offset(0, 20 * (1 - animValue)),
                        child: Opacity(
                          opacity: animValue,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    type.icon,
                                    size: 18,
                                    color: Colors.purple.shade700,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        type.displayName,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black87,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'Tercatat $count kali',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: Colors.purple.shade50,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$count',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.purple.shade700,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: Color(0xFFE9458D),
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'Memuat data statistik...',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              duration: const Duration(seconds: 1),
              tween: Tween(begin: 0.0, end: 1.0),
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Icon(
                    CupertinoIcons.chart_bar_circle,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Belum Ada Data Statistik',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Catat minimal satu siklus menstruasi untuk melihat statistik dan analisis yang mendalam',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(CupertinoIcons.add, size: 18),
              label: Text(
                'Mulai Catat Siklus',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE9458D),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
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
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE9458D),
        elevation: 0,
        title: Text(
          'Statistik Siklus',
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
          // Refresh data
          IconButton(
            icon: _isLoading 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(CupertinoIcons.refresh, color: Colors.white),
            onPressed: _isLoading ? null : _loadData,
          ),
        ],
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _loadData,
        color: const Color(0xFFE9458D),
        backgroundColor: Colors.white,
        child: _isLoading
            ? _buildLoadingIndicator()
            : _cycles.isEmpty
                ? _buildEmptyState()
                : FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Section
                            Text(
                              'Ringkasan Statistik',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Berdasarkan ${_cycles.length} siklus menstruasi yang tercatat',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                fontStyle: FontStyle.italic,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 20),
                            
                            // Statistics grid - Responsive layout
                            LayoutBuilder(
                              builder: (context, constraints) {
                                final int crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
                                final double childAspectRatio = constraints.maxWidth > 600 ? 1.2 : 1.3;
                                
                                return GridView.count(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  childAspectRatio: childAspectRatio,
                                  children: [
                                    _buildStatisticCard(
                                      title: 'Rata-rata Panjang Siklus',
                                      value: '${_statistics['avg_cycle_length']?.toStringAsFixed(1) ?? "-"} hari',
                                      icon: CupertinoIcons.arrow_2_circlepath,
                                      color: const Color(0xFFE9458D),
                                      subtitle: 'Dari awal ke awal periode',
                                      animationDelay: 0,
                                    ),
                                    _buildStatisticCard(
                                      title: 'Rata-rata Lama Periode',
                                      value: '${_statistics['avg_period_length']?.toStringAsFixed(1) ?? "-"} hari',
                                      icon: CupertinoIcons.calendar,
                                      color: Colors.purple.shade400,
                                      subtitle: 'Durasi menstruasi',
                                      animationDelay: 1,
                                    ),
                                    _buildStatisticCard(
                                      title: 'Siklus Terpanjang',
                                      value: '${_statistics['max_cycle_length'] ?? "-"} hari',
                                      icon: CupertinoIcons.arrow_up_right,
                                      color: Colors.blue.shade400,
                                      animationDelay: 2,
                                    ),
                                    _buildStatisticCard(
                                      title: 'Siklus Terpendek',
                                      value: '${_statistics['min_cycle_length'] ?? "-"} hari',
                                      icon: CupertinoIcons.arrow_down_right,
                                      color: Colors.teal.shade400,
                                      animationDelay: 3,
                                    ),
                                  ],
                                );
                              },
                            ),
                            
                            const SizedBox(height: 28),
                            
                            // Cycle length chart
                            _buildCycleLengthChart(),
                            
                            const SizedBox(height: 28),
                            
                            // Symptoms section header
                            Text(
                              'Analisis Gejala',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Symptom statistics
                            _buildSymptomStats(),
                            
                            const SizedBox(height: 28),
                            
                            // Cycle History header
                            Text(
                              'Riwayat Siklus',
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Cycle list with animation
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _cycles.length,
                              itemBuilder: (context, index) {
                                final cycle = _cycles[index];
                                return TweenAnimationBuilder<double>(
                                  duration: Duration(milliseconds: 600 + (index * 100)),
                                  tween: Tween(begin: 0.0, end: 1.0),
                                  curve: Curves.easeOutBack,
                                  builder: (context, animValue, child) {
                                    return Transform.translate(
                                      offset: Offset(0, 30 * (1 - animValue)),
                                      child: Opacity(
                                        opacity: animValue,
                                        child: Card(
                                          margin: const EdgeInsets.only(bottom: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          elevation: 2,
                                          shadowColor: Colors.black.withValues(alpha: 0.1),
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(16),
                                            onTap: () {
                                              // Add haptic feedback
                                              // HapticFeedback.lightImpact();
                                              // Show cycle details
                                              _showCycleDetails(cycle, index);
                                            },
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
                                                          color: const Color(0xFFE9458D).withValues(alpha: 0.1),
                                                          shape: BoxShape.circle,
                                                        ),
                                                        child: Icon(
                                                          CupertinoIcons.calendar,
                                                          size: 16,
                                                          color: const Color(0xFFE9458D),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      Expanded(
                                                        child: Text(
                                                          'Siklus ${_cycles.length - index}',
                                                          style: GoogleFonts.poppins(
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.w600,
                                                            color: Colors.black87,
                                                          ),
                                                          overflow: TextOverflow.ellipsis,
                                                        ),
                                                      ),
                                                      Icon(
                                                        CupertinoIcons.chevron_right,
                                                        size: 16,
                                                        color: Colors.grey.shade400,
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 16),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              'Mulai',
                                                              style: GoogleFonts.poppins(
                                                                fontSize: 12,
                                                                color: Colors.grey.shade600,
                                                              ),
                                                            ),
                                                            const SizedBox(height: 2),
                                                            Text(
                                                              _dateFormat.format(cycle.startDate),
                                                              style: GoogleFonts.poppins(
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.w500,
                                                                color: Colors.black87,
                                                              ),
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              'Selesai',
                                                              style: GoogleFonts.poppins(
                                                                fontSize: 12,
                                                                color: Colors.grey.shade600,
                                                              ),
                                                            ),
                                                            const SizedBox(height: 2),
                                                            Text(
                                                              cycle.endDate != null 
                                                                ? _dateFormat.format(cycle.endDate!)
                                                                : 'Berlangsung',
                                                              style: GoogleFonts.poppins(
                                                                fontSize: 14,
                                                                fontWeight: FontWeight.w500,
                                                                color: cycle.endDate != null 
                                                                  ? Colors.black87 
                                                                  : Colors.orange.shade700,
                                                              ),
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 16),
                                                  Container(
                                                    height: 1,
                                                    color: Colors.grey.shade200,
                                                  ),
                                                  const SizedBox(height: 16),
                                                  LayoutBuilder(
                                                    builder: (context, constraints) {
                                                      if (constraints.maxWidth < 350) {
                                                        // Stack layout for small screens
                                                        return Column(
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                              children: [
                                                                _buildCycleStat(
                                                                  label: 'Lama Periode',
                                                                  value: '${cycle.periodLength} hari',
                                                                  icon: CupertinoIcons.calendar,
                                                                ),
                                                                _buildCycleStat(
                                                                  label: 'Panjang Siklus',
                                                                  value: '${cycle.cycleLength} hari',
                                                                  icon: CupertinoIcons.arrow_2_circlepath,
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(height: 12),
                                                            _buildCycleStat(
                                                              label: 'Mood',
                                                              value: cycle.mood.displayName,
                                                              icon: cycle.mood.icon,
                                                            ),
                                                          ],
                                                        );
                                                      } else {
                                                        // Row layout for larger screens
                                                        return Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                          children: [
                                                            _buildCycleStat(
                                                              label: 'Lama Periode',
                                                              value: '${cycle.periodLength} hari',
                                                              icon: CupertinoIcons.calendar,
                                                            ),
                                                            _buildCycleStat(
                                                              label: 'Panjang Siklus',
                                                              value: '${cycle.cycleLength} hari',
                                                              icon: CupertinoIcons.arrow_2_circlepath,
                                                            ),
                                                            _buildCycleStat(
                                                              label: 'Mood',
                                                              value: cycle.mood.displayName,
                                                              icon: cycle.mood.icon,
                                                            ),
                                                          ],
                                                        );
                                                      }
                                                    },
                                                  ),
                                                  if (cycle.notes.isNotEmpty) ...[
                                                    const SizedBox(height: 16),
                                                    Container(
                                                      height: 1,
                                                      color: Colors.grey.shade200,
                                                    ),
                                                    const SizedBox(height: 12),
                                                    Row(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Icon(
                                                          CupertinoIcons.text_alignleft,
                                                          size: 14,
                                                          color: Colors.grey.shade600,
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Expanded(
                                                          child: Column(
                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                'Catatan:',
                                                                style: GoogleFonts.poppins(
                                                                  fontSize: 12,
                                                                  fontWeight: FontWeight.w500,
                                                                  color: Colors.grey.shade700,
                                                                ),
                                                              ),
                                                              const SizedBox(height: 4),
                                                              Text(
                                                                cycle.notes,
                                                                style: GoogleFonts.poppins(
                                                                  fontSize: 12,
                                                                  fontStyle: FontStyle.italic,
                                                                  color: Colors.grey.shade600,
                                                                  height: 1.4,
                                                                ),
                                                                maxLines: 3,
                                                                overflow: TextOverflow.ellipsis,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                            
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
  
  void _showCycleDetails(MenstrualCycle cycle, int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detail Siklus ${_cycles.length - index}',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Add detailed cycle information here
                    Text(
                      'Informasi lengkap tentang siklus menstruasi ini akan ditampilkan di sini.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCycleStat({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey.shade600,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}