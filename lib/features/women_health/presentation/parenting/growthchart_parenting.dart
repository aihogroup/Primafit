import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:primafit/features/women_health/data/database_parenting.dart';

class GrowthChartPage extends StatefulWidget {
  final int childId;
  final String childName;

  const GrowthChartPage({
    super.key,
    required this.childId,
    required this.childName,
  });

  @override
  State<GrowthChartPage> createState() => _GrowthChartPageState();
}

class _GrowthChartPageState extends State<GrowthChartPage>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _slideAnimationController;
  late AnimationController _fadeAnimationController;
  late AnimationController _chartAnimationController;
  late AnimationController _fabAnimationController;

  // Animations
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _chartAnimation;
  late Animation<double> _fabScaleAnimation;

  // Database and Data
  final DatabaseParenting _database = DatabaseParenting.instance;
  List<Map<String, dynamic>> _growthRecords = [];
  Map<String, dynamic>? _latestRecord;

  // UI State
  bool _isLoading = true;
  bool _isAddingRecord = false;
  String _selectedChartType = 'weight'; // weight, height, bmi
  String _selectedPeriod = '6m'; // 3m, 6m, 1y, all

  // Chart Colors
  final Color _primaryColor = const Color(0xFFE9458D);
  final Color _secondaryColor = const Color(0xFF6C63FF);
  final Color _accentColor = const Color(0xFF00BFA5);

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadData();
  }

  @override
  void dispose() {
    _slideAnimationController.dispose();
    _fadeAnimationController.dispose();
    _chartAnimationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  // ============ INITIALIZATION ============

  void _initializeAnimations() {
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _chartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeOut,
    ));

    _chartAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _chartAnimationController,
      curve: Curves.elasticOut,
    ));

    _fabScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.elasticOut,
    ));

    // Start animations
    _fadeAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _slideAnimationController.forward();
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _fabAnimationController.forward();
    });
  }

  // ============ DATA METHODS ============

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      // Load child data

      // Load growth records
      _growthRecords = await _database.getGrowthRecords(widget.childId);

      // Sort by date (newest first for display, but we'll reverse for charts)
      _growthRecords.sort((a, b) => 
        DateTime.parse(b['record_date']).compareTo(DateTime.parse(a['record_date'])));

      // Get latest record
      _latestRecord = _growthRecords.isNotEmpty ? _growthRecords.first : null;

      // Start chart animation
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) _chartAnimationController.forward();
      });
    } catch (e) {
      _showErrorDialog('Gagal memuat data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  // ============ CRUD OPERATIONS ============

  void _showAddRecordDialog() {
    final weightController = TextEditingController();
    final heightController = TextEditingController();
    final headController = TextEditingController();
    final notesController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDialogHeader(
                      icon: CupertinoIcons.chart_bar_alt_fill,
                      title: 'Tambah Data Pertumbuhan',
                      onClose: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 24),

                    // Date Picker
                    _buildDatePicker(
                      label: 'Tanggal Pengukuran',
                      selectedDate: selectedDate,
                      onDateSelected: (date) => setState(() => selectedDate = date!),
                    ),
                    const SizedBox(height: 16),

                    // Weight and Height Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildNumberField(
                            label: 'Berat Badan (kg)',
                            controller: weightController,
                            hint: '12.5',
                            icon: CupertinoIcons.heart_fill,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildNumberField(
                            label: 'Tinggi Badan (cm)',
                            controller: heightController,
                            hint: '85.0',
                            icon: CupertinoIcons.arrow_up_circle_fill,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Head Circumference
                    _buildNumberField(
                      label: 'Lingkar Kepala (cm)',
                      controller: headController,
                      hint: '46.5',
                      icon: CupertinoIcons.circle,
                    ),
                    const SizedBox(height: 16),

                    // Notes
                    _buildTextField(
                      label: 'Catatan (Opsional)',
                      controller: notesController,
                      hint: 'Catatan tambahan...',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    _buildDialogActions(
                      onCancel: () => Navigator.pop(context),
                      onSave: () => _addGrowthRecord(
                        selectedDate,
                        weightController.text,
                        heightController.text,
                        headController.text,
                        notesController.text,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _addGrowthRecord(
    DateTime date,
    String weight,
    String height,
    String headCircumference,
    String notes,
  ) async {
    // Validation
    if (weight.isEmpty && height.isEmpty && headCircumference.isEmpty) {
      _showErrorDialog('Minimal satu pengukuran harus diisi');
      return;
    }

    setState(() => _isAddingRecord = true);

    try {
      final weightValue = weight.isNotEmpty ? double.tryParse(weight) : null;
      final heightValue = height.isNotEmpty ? double.tryParse(height) : null;
      final headValue = headCircumference.isNotEmpty ? double.tryParse(headCircumference) : null;

      // Calculate BMI if both weight and height are provided
      double? bmi;
      if (weightValue != null && heightValue != null && heightValue > 0) {
        final heightInMeters = heightValue / 100;
        bmi = weightValue / (heightInMeters * heightInMeters);
      }

      final recordData = {
        'child_id': widget.childId,
        'record_date': date.toIso8601String().split('T')[0],
        'weight': weightValue,
        'height': heightValue,
        'head_circumference': headValue,
        'bmi': bmi,
        'notes': notes.trim(),
      };

      await _database.insertGrowthRecord(recordData);

      if (!mounted) return;
      Navigator.pop(context);
      _showSuccessDialog('Data pertumbuhan berhasil ditambahkan!');
      await _refreshData();
    } catch (e) {
      _showErrorDialog('Gagal menambahkan data: $e');
    } finally {
      setState(() => _isAddingRecord = false);
    }
  }

  void _showEditRecordDialog(Map<String, dynamic> record) {
    final weightController = TextEditingController(
      text: record['weight']?.toString() ?? '',
    );
    final heightController = TextEditingController(
      text: record['height']?.toString() ?? '',
    );
    final headController = TextEditingController(
      text: record['head_circumference']?.toString() ?? '',
    );
    final notesController = TextEditingController(
      text: record['notes'] ?? '',
    );
    DateTime selectedDate = DateTime.parse(record['record_date']);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDialogHeader(
                      icon: CupertinoIcons.pencil,
                      title: 'Edit Data Pertumbuhan',
                      onClose: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 24),

                    // Date Picker
                    _buildDatePicker(
                      label: 'Tanggal Pengukuran',
                      selectedDate: selectedDate,
                      onDateSelected: (date) => setState(() => selectedDate = date!),
                    ),
                    const SizedBox(height: 16),

                    // Weight and Height Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildNumberField(
                            label: 'Berat Badan (kg)',
                            controller: weightController,
                            hint: '12.5',
                            icon: CupertinoIcons.heart_fill,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildNumberField(
                            label: 'Tinggi Badan (cm)',
                            controller: heightController,
                            hint: '85.0',
                            icon: CupertinoIcons.arrow_up_circle_fill,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Head Circumference
                    _buildNumberField(
                      label: 'Lingkar Kepala (cm)',
                      controller: headController,
                      hint: '46.5',
                      icon: CupertinoIcons.circle,
                    ),
                    const SizedBox(height: 16),

                    // Notes
                    _buildTextField(
                      label: 'Catatan',
                      controller: notesController,
                      hint: 'Catatan tambahan...',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    _buildDialogActions(
                      onCancel: () => Navigator.pop(context),
                      onSave: () => _updateGrowthRecord(
                        record['id'],
                        selectedDate,
                        weightController.text,
                        heightController.text,
                        headController.text,
                        notesController.text,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _updateGrowthRecord(
    int recordId,
    DateTime date,
    String weight,
    String height,
    String headCircumference,
    String notes,
  ) async {
    if (weight.isEmpty && height.isEmpty && headCircumference.isEmpty) {
      _showErrorDialog('Minimal satu pengukuran harus diisi');
      return;
    }

    setState(() => _isAddingRecord = true);

    try {
      final weightValue = weight.isNotEmpty ? double.tryParse(weight) : null;
      final heightValue = height.isNotEmpty ? double.tryParse(height) : null;
      final headValue = headCircumference.isNotEmpty ? double.tryParse(headCircumference) : null;

      // Calculate BMI if both weight and height are provided
      double? bmi;
      if (weightValue != null && heightValue != null && heightValue > 0) {
        final heightInMeters = heightValue / 100;
        bmi = weightValue / (heightInMeters * heightInMeters);
      }

      final recordData = {
        'record_date': date.toIso8601String().split('T')[0],
        'weight': weightValue,
        'height': heightValue,
        'head_circumference': headValue,
        'bmi': bmi,
        'notes': notes.trim(),
      };

      await _database.updateGrowthRecord(recordId, recordData);

      if (!mounted) return;
      Navigator.pop(context);
      _showSuccessDialog('Data pertumbuhan berhasil diupdate!');
      await _refreshData();
    } catch (e) {
      _showErrorDialog('Gagal mengupdate data: $e');
    } finally {
      setState(() => _isAddingRecord = false);
    }
  }

  void _confirmDeleteRecord(Map<String, dynamic> record) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Hapus Data',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus data pertumbuhan pada ${_formatDate(record['record_date'])}?',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteGrowthRecord(record['id']);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(
              'Hapus',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteGrowthRecord(int recordId) async {
    try {
      await _database.deleteGrowthRecord(recordId);
      _showSuccessDialog('Data pertumbuhan berhasil dihapus!');
      await _refreshData();
    } catch (e) {
      _showErrorDialog('Gagal menghapus data: $e');
    }
  }

  // ============ CHART DATA PROCESSING ============

  List<FlSpot> _getChartData(String type) {
    if (_growthRecords.isEmpty) return [];

    final List<Map<String, dynamic>> filteredRecords = _getFilteredRecords();
    final List<FlSpot> spots = [];

    for (int i = 0; i < filteredRecords.length; i++) {
      final record = filteredRecords[i];
      double? value;

      switch (type) {
        case 'weight':
          value = record['weight']?.toDouble();
          break;
        case 'height':
          value = record['height']?.toDouble();
          break;
        case 'bmi':
          value = record['bmi']?.toDouble();
          break;
        case 'head':
          value = record['head_circumference']?.toDouble();
          break;
      }

      if (value != null) {
        spots.add(FlSpot(i.toDouble(), value));
      }
    }

    return spots;
  }

  List<Map<String, dynamic>> _getFilteredRecords() {
    final List<Map<String, dynamic>> filtered = List.from(_growthRecords);
    filtered.sort((a, b) => 
      DateTime.parse(a['record_date']).compareTo(DateTime.parse(b['record_date'])));

    DateTime cutoffDate;
    final DateTime now = DateTime.now();

    switch (_selectedPeriod) {
      case '3m':
        cutoffDate = now.subtract(const Duration(days: 90));
        break;
      case '6m':
        cutoffDate = now.subtract(const Duration(days: 180));
        break;
      case '1y':
        cutoffDate = now.subtract(const Duration(days: 365));
        break;
      default:
        return filtered;
    }

    return filtered.where((record) {
      final DateTime recordDate = DateTime.parse(record['record_date']);
      return recordDate.isAfter(cutoffDate);
    }).toList();
  }

  // ============ UI BUILD METHODS ============

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: _isLoading ? _buildLoadingWidget() : _buildBody(isTablet),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _primaryColor,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(CupertinoIcons.back, color: Colors.white),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Growth Chart',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Text(
            widget.childName,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: _refreshData,
          icon: const Icon(CupertinoIcons.refresh, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE9458D)),
          ),
          SizedBox(height: 16),
          Text(
            'Memuat data pertumbuhan...',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(bool isTablet) {
    return AnimatedBuilder(
      animation: _fadeAnimationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Summary Stats
                SliverToBoxAdapter(child: _buildSummaryStats(isTablet)),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Chart Controls
                SliverToBoxAdapter(child: _buildChartControls()),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Chart Section
                SliverToBoxAdapter(child: _buildChartSection()),

                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                // Records List
                SliverToBoxAdapter(child: _buildRecordsListTitle()),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Records
                if (_growthRecords.isEmpty)
                  SliverToBoxAdapter(child: _buildEmptyState())
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildRecordItem(_growthRecords[index], index),
                      childCount: _growthRecords.length,
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryStats(bool isTablet) {
    if (_latestRecord == null) return const SizedBox.shrink();

    final weight = _latestRecord!['weight']?.toDouble() ?? 0.0;
    final height = _latestRecord!['height']?.toDouble() ?? 0.0;
    final bmi = _latestRecord!['bmi']?.toDouble() ?? 0.0;

    return Container(
      margin: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (weight > 0)
            Expanded(
              child: _buildStatCard(
                'Berat Badan',
                '${weight.toStringAsFixed(1)} kg',
                CupertinoIcons.heart_fill,
                _primaryColor,
              ),
            ),
          if (weight > 0 && height > 0) const SizedBox(width: 12),
          if (height > 0)
            Expanded(
              child: _buildStatCard(
                'Tinggi Badan',
                '${height.toStringAsFixed(1)} cm',
                CupertinoIcons.arrow_up_circle_fill,
                _secondaryColor,
              ),
            ),
          if ((weight > 0 || height > 0) && bmi > 0) const SizedBox(width: 12),
          if (bmi > 0)
            Expanded(
              child: _buildStatCard(
                'BMI',
                bmi.toStringAsFixed(1),
                CupertinoIcons.chart_bar_square_fill,
                _accentColor,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
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
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChartControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Chart Type Selector
          Row(
            children: [
              Text(
                'Jenis Data:',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildChartTypeButton('weight', 'Berat', CupertinoIcons.heart_fill),
                      _buildChartTypeButton('height', 'Tinggi', CupertinoIcons.arrow_up_circle_fill),
                      _buildChartTypeButton('bmi', 'BMI', CupertinoIcons.chart_bar_square_fill),
                      _buildChartTypeButton('head', 'Lingkar Kepala', CupertinoIcons.circle),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Period Selector
          Row(
            children: [
              Text(
                'Periode:',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    _buildPeriodButton('3m', '3 Bulan'),
                    _buildPeriodButton('6m', '6 Bulan'),
                    _buildPeriodButton('1y', '1 Tahun'),
                    _buildPeriodButton('all', 'Semua'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartTypeButton(String type, String label, IconData icon) {
    final isSelected = _selectedChartType == type;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedChartType = type;
          });
          _chartAnimationController.reset();
          _chartAnimationController.forward();
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? _primaryColor : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodButton(String period, String label) {
    final isSelected = _selectedPeriod == period;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedPeriod = period;
            });
            _chartAnimationController.reset();
            _chartAnimationController.forward();
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? _primaryColor.withValues(alpha: 0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? _primaryColor : Colors.grey.shade300,
              ),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? _primaryColor : Colors.grey.shade600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChartSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Icon(
                _getChartIcon(_selectedChartType),
                color: _primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _getChartTitle(_selectedChartType),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          if (_growthRecords.isEmpty)
            _buildEmptyChart()
          else
            AnimatedBuilder(
              animation: _chartAnimationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _chartAnimation.value,
                  child: SizedBox(
                    height: 200,
                    child: _buildLineChart(),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyChart() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.chart_bar_alt_fill,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Belum Ada Data Grafik',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan data pertumbuhan untuk melihat grafik',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    final spots = _getChartData(_selectedChartType);
    if (spots.isEmpty) return _buildEmptyChart();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 1,
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
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (double value, TitleMeta meta) {
                final records = _getFilteredRecords();
                if (value.toInt() >= 0 && value.toInt() < records.length) {
                  // return SideTitleWidget(
                  //   axisSide: meta.axisSide,
                  //   child: Text(
                  //     '${date.day}/${date.month}',
                  //     style: GoogleFonts.poppins(
                  //       fontSize: 10,
                  //       color: Colors.grey.shade600,
                  //     ),
                  //   ),
                  // );
                }
                return Container();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: _getYAxisInterval(_selectedChartType),
              reservedSize: 42,
              getTitlesWidget: (double value, TitleMeta meta) {
                return Text(
                  value.toStringAsFixed(1),
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.shade200),
        ),
        minX: 0,
        maxX: spots.length > 1 ? spots.length - 1.0 : 1.0,
        minY: _getMinY(spots),
        maxY: _getMaxY(spots),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            gradient: LinearGradient(
              colors: [_primaryColor, _primaryColor.withValues(alpha: 0.3)],
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: _primaryColor,
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  _primaryColor.withValues(alpha: 0.3),
                  _primaryColor.withValues(alpha: 0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            // backgroundcolor: Colors.black87,
            tooltipRoundedRadius: 8,
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final records = _getFilteredRecords();
                if (barSpot.spotIndex < records.length) {
                  final record = records[barSpot.spotIndex];
                  final date = _formatDate(record['record_date']);
                  return LineTooltipItem(
                    '$date\n${barSpot.y.toStringAsFixed(1)} ${_getUnit(_selectedChartType)}',
                    GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }
                return null;
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRecordsListTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(
            'Riwayat Data Pertumbuhan',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          Text(
            '${_growthRecords.length} data',
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(32),
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              CupertinoIcons.chart_bar_alt_fill,
              size: 48,
              color: _primaryColor,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Belum Ada Data Pertumbuhan',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mulai catat pertumbuhan ${widget.childName} dengan menambahkan data berat, tinggi, dan lingkar kepala.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _showAddRecordDialog,
            icon: const Icon(CupertinoIcons.add),
            label: Text(
              'Tambah Data Pertama',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordItem(Map<String, dynamic> record, int index) {
    final date = _formatDate(record['record_date']);
    final weight = record['weight']?.toDouble();
    final height = record['height']?.toDouble();
    final bmi = record['bmi']?.toDouble();
    final headCircumference = record['head_circumference']?.toDouble();
    final notes = record['notes'];

    return Container(
      margin: EdgeInsets.fromLTRB(20, 0, 20, index == _growthRecords.length - 1 ? 0 : 12),
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
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            CupertinoIcons.calendar,
            color: _primaryColor,
            size: 20,
          ),
        ),
        title: Text(
          date,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          _buildRecordSubtitle(weight, height, bmi, headCircumference),
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              _showEditRecordDialog(record);
            } else if (value == 'delete') {
              _confirmDeleteRecord(record);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  const Icon(CupertinoIcons.pencil, size: 16),
                  const SizedBox(width: 8),
                  Text('Edit', style: GoogleFonts.poppins(fontSize: 14)),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(CupertinoIcons.trash, size: 16, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(
                    'Hapus',
                    style: GoogleFonts.poppins(fontSize: 14, color: Colors.red),
                  ),
                ],
              ),
            ),
          ],
          child: Icon(
            CupertinoIcons.ellipsis_vertical,
            color: Colors.grey.shade400,
            size: 20,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              children: [
                if (weight != null || height != null || bmi != null || headCircumference != null)
                  Row(
                    children: [
                      if (weight != null)
                        Expanded(
                          child: _buildDetailItem(
                            'Berat',
                            '${weight.toStringAsFixed(1)} kg',
                            CupertinoIcons.heart_fill,
                            _primaryColor,
                          ),
                        ),
                      if (weight != null && height != null) const SizedBox(width: 12),
                      if (height != null)
                        Expanded(
                          child: _buildDetailItem(
                            'Tinggi',
                            '${height.toStringAsFixed(1)} cm',
                            CupertinoIcons.arrow_up_circle_fill,
                            _secondaryColor,
                          ),
                        ),
                    ],
                  ),
                if ((weight != null || height != null) && (bmi != null || headCircumference != null))
                  const SizedBox(height: 12),
                if (bmi != null || headCircumference != null)
                  Row(
                    children: [
                      if (bmi != null)
                        Expanded(
                          child: _buildDetailItem(
                            'BMI',
                            bmi.toStringAsFixed(1),
                            CupertinoIcons.chart_bar_square_fill,
                            _accentColor,
                          ),
                        ),
                      if (bmi != null && headCircumference != null) const SizedBox(width: 12),
                      if (headCircumference != null)
                        Expanded(
                          child: _buildDetailItem(
                            'Lingkar Kepala',
                            '${headCircumference.toStringAsFixed(1)} cm',
                            CupertinoIcons.circle,
                            Colors.orange,
                          ),
                        ),
                    ],
                  ),
                if (notes != null && notes.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Catatan:',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notes,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return AnimatedBuilder(
      animation: _fabScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _fabScaleAnimation.value,
          child: FloatingActionButton.extended(
            onPressed: _isAddingRecord ? null : _showAddRecordDialog,
            backgroundColor: _primaryColor,
            elevation: 8,
            icon: _isAddingRecord
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(CupertinoIcons.add, color: Colors.white),
            label: Text(
              _isAddingRecord ? 'Menyimpan...' : 'Tambah Data',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }

  // ============ DIALOG HELPER WIDGETS ============

  Widget _buildDialogHeader({
    required IconData icon,
    required String title,
    required VoidCallback onClose,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: _primaryColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        IconButton(
          onPressed: onClose,
          icon: const Icon(CupertinoIcons.xmark),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _primaryColor),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          style: GoogleFonts.poppins(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildNumberField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            prefixIcon: Icon(icon, color: _primaryColor, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _primaryColor),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          style: GoogleFonts.poppins(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime selectedDate,
    required Function(DateTime?) onDateSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: selectedDate,
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (date != null) onDateSelected(date);
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(CupertinoIcons.calendar, color: _primaryColor),
                const SizedBox(width: 12),
                Text(
                  _formatDate(selectedDate.toIso8601String()),
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDialogActions({
    required VoidCallback onCancel,
    required VoidCallback onSave,
  }) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onCancel,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey.shade600,
              side: BorderSide(color: Colors.grey.shade300),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'Simpan',
              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  // ============ SUCCESS/ERROR DIALOGS ============

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _buildStatusDialog(
        icon: CupertinoIcons.check_mark_circled_solid,
        iconColor: _primaryColor,
        title: 'Berhasil!',
        message: message,
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _buildStatusDialog(
        icon: CupertinoIcons.exclamationmark_triangle,
        iconColor: Colors.red,
        title: 'Error',
        message: message,
      ),
    );
  }

  Widget _buildStatusDialog({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String message,
  }) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: iconColor, size: 32),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: iconColor == Colors.red ? Colors.red : _primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'OK',
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============ UTILITY METHODS ============

  String _formatDate(String dateString) {
    try {
      final DateTime date = DateTime.parse(dateString);
      final List<String> months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      return '${date.day} ${months[date.month]} ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _buildRecordSubtitle(double? weight, double? height, double? bmi, double? headCircumference) {
    final List<String> parts = [];
    
    if (weight != null) {
      parts.add('${weight.toStringAsFixed(1)} kg');
    }
    if (height != null) {
      parts.add('${height.toStringAsFixed(1)} cm');
    }
    if (bmi != null) {
      parts.add('BMI ${bmi.toStringAsFixed(1)}');
    }
    if (headCircumference != null) {
      parts.add('LK ${headCircumference.toStringAsFixed(1)} cm');
    }
    
    return parts.isNotEmpty ? parts.join(' • ') : 'Data tidak lengkap';
  }

  IconData _getChartIcon(String type) {
    switch (type) {
      case 'weight':
        return CupertinoIcons.heart_fill;
      case 'height':
        return CupertinoIcons.arrow_up_circle_fill;
      case 'bmi':
        return CupertinoIcons.chart_bar_square_fill;
      case 'head':
        return CupertinoIcons.circle;
      default:
        return CupertinoIcons.chart_bar_alt_fill;
    }
  }

  String _getChartTitle(String type) {
    switch (type) {
      case 'weight':
        return 'Grafik Berat Badan';
      case 'height':
        return 'Grafik Tinggi Badan';
      case 'bmi':
        return 'Grafik BMI';
      case 'head':
        return 'Grafik Lingkar Kepala';
      default:
        return 'Grafik Pertumbuhan';
    }
  }

  String _getUnit(String type) {
    switch (type) {
      case 'weight':
        return 'kg';
      case 'height':
        return 'cm';
      case 'bmi':
        return '';
      case 'head':
        return 'cm';
      default:
        return '';
    }
  }

  double _getYAxisInterval(String type) {
    switch (type) {
      case 'weight':
        return 1.0;
      case 'height':
        return 5.0;
      case 'bmi':
        return 1.0;
      case 'head':
        return 2.0;
      default:
        return 1.0;
    }
  }

  double _getMinY(List<FlSpot> spots) {
    if (spots.isEmpty) return 0;
    double min = spots.first.y;
    for (var spot in spots) {
      if (spot.y < min) min = spot.y;
    }
    return (min * 0.9).floorToDouble();
  }

  double _getMaxY(List<FlSpot> spots) {
    if (spots.isEmpty) return 10;
    double max = spots.first.y;
    for (var spot in spots) {
      if (spot.y > max) max = spot.y;
    }
    return (max * 1.1).ceilToDouble();
  }

  // ============ GROWTH PERCENTILE CALCULATIONS ============



  // ============ EXPORT FUNCTIONALITY ============


  // ============ GROWTH REMINDERS ============


  // ============ MILESTONE INTEGRATION ============


  // ============ GROWTH RECOMMENDATIONS ============



  // ============ GROWTH MILESTONES INTEGRATION ============


}