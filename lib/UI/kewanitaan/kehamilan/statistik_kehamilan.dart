import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:primafit/UI/kewanitaan/kehamilan/model_kehamilan.dart';
import 'package:primafit/database/kewanitaan/database_kehamilan.dart';

class PregnancyStatisticsPage extends StatefulWidget {
  final int pregnancyId;

  const PregnancyStatisticsPage({
    Key? key,
    required this.pregnancyId,
  }) : super(key: key);

  @override
  _PregnancyStatisticsPageState createState() => _PregnancyStatisticsPageState();
}

class _PregnancyStatisticsPageState extends State<PregnancyStatisticsPage> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  Pregnancy? _pregnancy;
  Map<PregnancySymptomType, int> _symptomStats = {};
  Map<String, dynamic> _weightStats = {};

  late TabController _tabController;

  final DateFormat _dateFormat = DateFormat('d MMM yyyy');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load pregnancy data
      final pregnancies = await DatabaseHelperPregnancy.instance.getAllPregnancies();
      final pregnancy = pregnancies.firstWhere((p) => p.id == widget.pregnancyId);

      // Load symptom statistics
      final symptomStats = await DatabaseHelperPregnancy.instance.getSymptomStatistics(widget.pregnancyId);

      // Load weight statistics
      final weightStats = await DatabaseHelperPregnancy.instance.getWeightStatistics(widget.pregnancyId);

      if (mounted) {
        setState(() {
          _pregnancy = pregnancy;
          _symptomStats = symptomStats;
          _weightStats = weightStats;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading statistics: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE9458D),
        elevation: 0,
        title: Text(
          'Statistik Kehamilan',
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
            icon: const Icon(CupertinoIcons.refresh, color: Colors.white),
            onPressed: _loadData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          labelStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          tabs: const [
            Tab(text: 'Ringkasan'),
            Tab(text: 'Gejala'),
            Tab(text: 'Berat Badan'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE9458D)))
          : (_pregnancy == null
              ? Center(
                  child: Text(
                    'Data kehamilan tidak ditemukan',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildSummaryTab(),
                    _buildSymptomsTab(),
                    _buildWeightTab(),
                  ],
                )),
    );
  }

  // Helper functions for building tabs
  Widget _buildSummaryTab() {
    if (_pregnancy == null) return const SizedBox.shrink();

    final totalDays = _pregnancy!.dueDate.difference(_pregnancy!.startDate).inDays;
    final completedDays = DateTime.now().difference(_pregnancy!.startDate).inDays;
    final progressPercent = (completedDays / totalDays).clamp(0.0, 1.0);
    final daysLeft = _pregnancy!.dueDate.difference(DateTime.now()).inDays;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pregnancy progress card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE9458D), Color(0xFF4A8799)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE9458D).withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Kemajuan Kehamilan',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Minggu ${_pregnancy!.currentWeek}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Minggu 1',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        Text(
                          'Minggu 40',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progressPercent,
                        minHeight: 8,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(progressPercent * 100).toInt()}% selesai',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildDateBox(
                      label: 'HPHT',
                      date: _pregnancy!.startDate,
                      icon: CupertinoIcons.calendar,
                    ),
                    _buildDateBox(
                      label: 'HPL',
                      date: _pregnancy!.dueDate,
                      icon: CupertinoIcons.flag_fill,
                      additionalText: '$daysLeft hari lagi',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Kemajuan Trimester',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          _pregnancy!.weightRecords.isEmpty
              ? _buildEmptyState(
                  icon: CupertinoIcons.arrow_up_right_square,
                  message: 'Belum ada data berat badan',
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _pregnancy!.weightRecords.length,
                  itemBuilder: (context, index) {
                    final record = _pregnancy!.weightRecords[_pregnancy!.weightRecords.length - 1 - index];
                    return _buildWeightHistoryItem(record, index > 0 ? _pregnancy!.weightRecords[_pregnancy!.weightRecords.length - index] : null);
                  },
                ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

Widget _buildWeightHistoryItem(PregnancyWeight record, PregnancyWeight? previousRecord) {
    double? change;
    if (previousRecord != null) {
      change = record.weight - previousRecord.weight;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 0,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              CupertinoIcons.arrow_up_right_square,
              color: Colors.blue.shade700,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${record.weight} kg',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  _dateFormat.format(record.date),
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (record.notes.isNotEmpty)
                  Text(
                    record.notes,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Minggu ${_pregnancy?.getWeekForDate(record.date) ?? 0}',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFE9458D),
                ),
              ),
              if (change != null) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: change > 0 
                        ? Colors.green.shade100 
                        : (change < 0 ? Colors.red.shade100 : Colors.grey.shade100),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    change > 0 
                        ? '+${change.toStringAsFixed(1)} kg' 
                        : '${change.toStringAsFixed(1)} kg',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: change > 0 
                          ? Colors.green.shade700 
                          : (change < 0 ? Colors.red.shade700 : Colors.grey.shade700),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(
              icon,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateBox({
    required String label,
    required DateTime date,
    required IconData icon,
    String? additionalText,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        Text(
          _dateFormat.format(date),
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        if (additionalText != null)
          Text(
            additionalText,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
      ],
    );
  }

  Widget _buildSymptomsTab() {
    if (_pregnancy == null) return const SizedBox.shrink();
    
    // Group symptoms by type
    final Map<PregnancySymptomType, List<PregnancySymptom>> groupedSymptoms = {};
    
    for (var symptom in _pregnancy!.symptoms) {
      if (groupedSymptoms.containsKey(symptom.type)) {
        groupedSymptoms[symptom.type]!.add(symptom);
      } else {
        groupedSymptoms[symptom.type] = [symptom];
      }
    }
    
    // Sort by frequency
    final sortedTypes = _symptomStats.keys.toList()
      ..sort((a, b) => _symptomStats[b]!.compareTo(_symptomStats[a]!));
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Symptoms chart
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 1),
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
                ),
                
                const SizedBox(height: 16),
                
                _symptomStats.isEmpty
                    ? _buildEmptyState(
                        icon: CupertinoIcons.bandage,
                        message: 'Belum ada gejala tercatat',
                      )
                    : SizedBox(
                        height: 220,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: (_symptomStats.values.reduce((a, b) => a > b ? a : b) + 2).toDouble(),
                            barTouchData: BarTouchData(
                              enabled: true,
                              touchTooltipData: BarTouchTooltipData(
                                // tooltipBgColor: Colors.blueGrey.shade800,
                                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                  if (groupIndex >= sortedTypes.length) return null;
                                  final type = sortedTypes[groupIndex];
                                  return BarTooltipItem(
                                    '${type.displayName}: ${_symptomStats[type]} kali',
                                    GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  );
                                },
                              ),
                            ),
                            titlesData: FlTitlesData(
                              show: true,
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    if (value.toInt() >= sortedTypes.length) return const SizedBox();
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Icon(
                                        sortedTypes[value.toInt()].icon,
                                        size: 18,
                                        color: Colors.red.shade400,
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
                                    if (value == 0) return const SizedBox();
                                    return Text(
                                      value.toInt().toString(),
                                      style: GoogleFonts.poppins(
                                        color: Colors.grey.shade600,
                                        fontSize: 10,
                                      ),
                                    );
                                  },
                                  reservedSize: 24,
                                ),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(show: false),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: 1,
                              getDrawingHorizontalLine: (value) => FlLine(
                                color: Colors.grey.shade200,
                                strokeWidth: 1,
                              ),
                            ),
                            barGroups: List.generate(
                              sortedTypes.length > 5 ? 5 : sortedTypes.length,
                              (index) {
                                final type = sortedTypes[index];
                                return BarChartGroupData(
                                  x: index,
                                  barRods: [
                                    BarChartRodData(
                                      toY: _symptomStats[type]!.toDouble(),
                                      color: Colors.red.shade400,
                                      width: 20,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(6),
                                        topRight: Radius.circular(6),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                
                if (_symptomStats.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  // Chart Legend
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: sortedTypes.take(5).map((type) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            type.icon,
                            size: 14,
                            color: Colors.red.shade400,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            type.displayName,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Symptoms list by type
          Text(
            'Riwayat Gejala',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          
          const SizedBox(height: 12),
          
          _pregnancy!.symptoms.isEmpty
              ? _buildEmptyState(
                  icon: CupertinoIcons.bandage,
                  message: 'Belum ada gejala tercatat',
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sortedTypes.length,
                  itemBuilder: (context, index) {
                    final type = sortedTypes[index];
                    final symptoms = groupedSymptoms[type] ?? [];
                    return _buildSymptomGroup(type, symptoms);
                  },
                ),
                
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildWeightTab() {
  if (_pregnancy == null) return const SizedBox.shrink();

  final weightRecords = List.from(_pregnancy!.weightRecords)
    ..sort((a, b) => a.date.compareTo(b.date));

  // Prepare data for chart
  List<FlSpot> weightSpots = [];
  List<String> weekLabels = [];

  for (int i = 0; i < weightRecords.length; i++) {
    final record = weightRecords[i];
    final week = _pregnancy!.getWeekForDate(record.date);
    weightSpots.add(FlSpot(i.toDouble(), record.weight));
    weekLabels.add('W$week');
  }

  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Weight stats card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ringkasan Berat Badan',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              weightRecords.isEmpty
                  ? _buildEmptyState(
                      icon: CupertinoIcons.arrow_up_right_square,
                      message: 'Belum ada data berat badan',
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildWeightStat(
                          label: 'Awal',
                          value: '${_weightStats['first_weight']?.toStringAsFixed(1) ?? "0.0"} kg',
                          icon: CupertinoIcons.arrow_down_right_square,
                          color: Colors.blue.shade400,
                        ),
                        _buildWeightStat(
                          label: 'Saat Ini',
                          value: '${_weightStats['current_weight']?.toStringAsFixed(1) ?? "0.0"} kg',
                          icon: CupertinoIcons.person_fill,
                          color: Colors.teal.shade400,
                        ),
                        _buildWeightStat(
                          label: 'Perubahan',
                          value: '${_weightStats['total_gain'] > 0 ? "+" : ""}${_weightStats['total_gain']?.toStringAsFixed(1) ?? "0.0"} kg',
                          icon: CupertinoIcons.arrow_up_right_square,
                          color: _weightStats['total_gain'] > 0
                              ? Colors.green.shade400
                              : Colors.red.shade400,
                        ),
                      ],
                    ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Weight chart
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Grafik Perubahan Berat Badan',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              weightRecords.length < 2
                  ? _buildEmptyState(
                      icon: CupertinoIcons.graph_square,
                      message: 'Minimal 2 data berat badan diperlukan untuk menampilkan grafik',
                    )
                  : SizedBox(
                      height: 240,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            horizontalInterval: 1,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: Colors.grey.shade200,
                              strokeWidth: 1,
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value.toInt() >= weekLabels.length) return const SizedBox();
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      weekLabels[value.toInt()],
                                      style: GoogleFonts.poppins(
                                        fontSize: 10,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  );
                                },
                                reservedSize: 24,
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey.shade600,
                                      fontSize: 10,
                                    ),
                                  );
                                },
                                reservedSize: 30,
                              ),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          minY: (_weightStats['min_weight'] as double) - 1,
                          maxY: (_weightStats['max_weight'] as double) + 1,
                          lineBarsData: [
                            LineChartBarData(
                              spots: weightSpots,
                              isCurved: true,
                              color: Colors.blue.shade400,
                              barWidth: 3,
                              isStrokeCapRound: true,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 4,
                                    color: Colors.blue.shade400,
                                    strokeWidth: 2,
                                    strokeColor: Colors.white,
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                color: Colors.blue.shade400.withOpacity(0.1),
                              ),
                            ),
                          ],
                          lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                              // tooltipBgColor: Colors.blueGrey.shade800,
                              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                                return touchedSpots.map((spot) {
                                  final record = weightRecords[spot.x.toInt()];
                                  final date = _dateFormat.format(record.date);
                                  final week = _pregnancy!.getWeekForDate(record.date);

                                  return LineTooltipItem(
                                    '$date (W$week)\n${spot.y.toStringAsFixed(1)} kg',
                                    GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Weight history
        Text(
          'Riwayat Berat Badan',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        _pregnancy!.weightRecords.isEmpty
            ? _buildEmptyState(
                icon: CupertinoIcons.arrow_up_right_square,
                message: 'Belum ada data berat badan',
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: weightRecords.length,
                itemBuilder: (context, index) {
                  final record = weightRecords[weightRecords.length - 1 - index];
                  return _buildWeightHistoryItem(record, index > 0 ? weightRecords[weightRecords.length - index] : null);
                },
              ),
      ],
    ),
  );
}

Widget _buildWeightStat({
  required String label,
  required String value,
  required IconData icon,
  required Color color,
}) {
  return Column(
    children: [
      Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: color,
          size: 24,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        value,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
      Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      ),
    ],
  );
}

Widget _buildSymptomGroup(PregnancySymptomType type, List<PregnancySymptom> symptoms) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          spreadRadius: 0,
          offset: const Offset(0, 1),
        ),
      ],
    ),
    child: ExpansionTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(
          type.icon,
          size: 18,
          color: Colors.red.shade700,
        ),
      ),
      title: Text(
        type.displayName,
        style: GoogleFonts.poppins(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        '${symptoms.length} kali tercatat',
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          symptoms.length.toString(),
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.red.shade700,
          ),
        ),
      ),
      childrenPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      expandedCrossAxisAlignment: CrossAxisAlignment.start,
      children: symptoms.map((symptom) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Text(
                _dateFormat.format(symptom.date),
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(width: 12),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < symptom.intensity
                        ? CupertinoIcons.circle_fill
                        : CupertinoIcons.circle,
                    size: 8,
                    color: index < symptom.intensity
                        ? Colors.red.shade700
                        : Colors.red.shade200,
                  );
                }),
              ),
              if (symptom.notes.isNotEmpty) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    symptom.notes,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    ),
  );
}
}
