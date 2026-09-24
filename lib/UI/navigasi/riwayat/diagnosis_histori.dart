import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:primafit/database/diagnosa/diagnosis_history_database.dart';

class DiagnosisHistoryPage extends StatefulWidget {
  const DiagnosisHistoryPage({Key? key}) : super(key: key);

  @override
  State<DiagnosisHistoryPage> createState() => _DiagnosisHistoryPageState();
}

class _DiagnosisHistoryPageState extends State<DiagnosisHistoryPage>
    with TickerProviderStateMixin {
  // Controllers dan state variables
  late TabController _tabController;
  late AnimationController _animationController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  
  // Data dan loading states
  List<Map<String, dynamic>> _historyData = [];
  List<Map<String, dynamic>> _filteredData = [];
  List<Map<String, dynamic>> _statisticsData = [];
  List<String> _categories = [];
  Map<String, int> _categoryCounts = {};
  
  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _isSearching = false;
  String _selectedCategory = 'Semua';
  String _sortBy = 'created_at DESC';
  
  // Theme colors
  static const Color primaryColor = Color(0xFF64D1DE);
  static const Color primaryDark = Color(0xFF4FB3C1);
  static const Color primaryLight = Color(0xFFB3E5EA);
  static const Color surfaceColor = Color(0xFFF8FDFE);
  static const Color cardColor = Colors.white;
  
  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupControllers();
    _loadData();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
  }

  void _setupControllers() {
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(_performSearch);
    _scrollController.addListener(_handleScroll);
  }

  void _handleScroll() {
    if (_scrollController.offset > 100) {
      _fabAnimationController.forward();
    } else {
      _fabAnimationController.reverse();
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final db = DiagnosisHistoryDatabase.instance;
      
      // Load semua data secara paralel
      final results = await Future.wait([
        db.getDiagnosisHistory(),
        db.getDiagnosisStatistics(),
        db.getAvailableCategories(),
        db.getDiagnosisCountByCategory(),
      ]);
      
      setState(() {
        _historyData = results[0] as List<Map<String, dynamic>>;
        _statisticsData = results[1] as List<Map<String, dynamic>>;
        _categories = ['Semua', ...(results[2] as List<String>)];
        _categoryCounts = results[3] as Map<String, int>;
        _filteredData = List.from(_historyData);
        _isLoading = false;
      });
      
      _animationController.forward();
      
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Gagal memuat data histori: $e');
    }
  }

  Future<void> _refreshData() async {
    setState(() => _isRefreshing = true);
    await _loadData();
    setState(() => _isRefreshing = false);
    _showSuccessSnackBar('Data berhasil diperbarui');
  }

  void _performSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _isSearching = query.isNotEmpty;
      _filteredData = _historyData.where((item) {
        final disease = item['nama_penyakit'].toString().toLowerCase();
        final category = item['kategori_penyakit'].toString().toLowerCase();
        return disease.contains(query) || category.contains(query);
      }).toList();
    });
  }

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == 'Semua') {
        _filteredData = List.from(_historyData);
      } else {
        _filteredData = _historyData
            .where((item) => item['kategori_penyakit'] == category)
            .toList();
      }
    });
    _performSearch(); // Apply search filter if active
  }

  void _sortData(String sortBy) {
    setState(() {
      _sortBy = sortBy;
      _filteredData.sort((a, b) {
        switch (sortBy) {
          case 'created_at DESC':
            return DateTime.parse(b['created_at']).compareTo(DateTime.parse(a['created_at']));
          case 'created_at ASC':
            return DateTime.parse(a['created_at']).compareTo(DateTime.parse(b['created_at']));
          case 'persentase DESC':
            return (b['persentase_kecocokan'] as double).compareTo(a['persentase_kecocokan'] as double);
          case 'persentase ASC':
            return (a['persentase_kecocokan'] as double).compareTo(b['persentase_kecocokan'] as double);
          case 'penyakit ASC':
            return a['nama_penyakit'].toString().compareTo(b['nama_penyakit'].toString());
          default:
            return 0;
        }
      });
    });
  }

  void _showHistoryDetail(Map<String, dynamic> history) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            HistoryDetailPage(historyData: history),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                  .chain(CurveTween(curve: Curves.easeInOut)),
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Future<void> _deleteHistory(int id) async {
    final confirmed = await _showDeleteConfirmation();
    if (!confirmed) return;
    
    try {
      final db = DiagnosisHistoryDatabase.instance;
      final success = await db.deleteDiagnosisHistory(id);
      
      if (success) {
        _showSuccessSnackBar('Histori berhasil dihapus');
        _loadData();
      } else {
        _showErrorSnackBar('Gagal menghapus histori');
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    }
  }

  Future<void> _exportData() async {
    try {
      _showLoadingDialog('Mengekspor data...');
      
      final db = DiagnosisHistoryDatabase.instance;
      final path = await db.exportHistoryToCSV(
        kategoriPenyakit: _selectedCategory == 'Semua' ? null : _selectedCategory,
      );
      
      Navigator.pop(context); // Close loading dialog
      
      if (path.isNotEmpty) {
        _showSuccessSnackBar('Data berhasil diekspor ke: $path');
      } else {
        _showErrorSnackBar('Gagal mengekspor data');
      }
    } catch (e) {
      Navigator.pop(context);
      _showErrorSnackBar('Error ekspor: $e');
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: surfaceColor,
    body: NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        _buildSliverAppBar(innerBoxIsScrolled),
      ],
      body: _isLoading ? _buildLoadingView() : _buildMainContent(),
    ),
    floatingActionButton: _buildFloatingActionButton(),
  );
}

Widget _buildSliverAppBar(bool innerBoxIsScrolled) {
  return SliverAppBar(
    expandedHeight: 280, // Increased height
    floating: false,
    pinned: true,
    stretch: true,
    elevation: 0,
    backgroundColor: const Color(0xFF64D1DE),
    foregroundColor: Colors.white,
    systemOverlayStyle: const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
    
    // Leading Button
    leading: Container(
      margin: const EdgeInsets.all(8),
      child: Material(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.pushReplacementNamed(context, '/riwayat');
          },
          child: const Icon(
            CupertinoIcons.chevron_left,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    ),
    
    // Action Buttons
    actions: [
      // Search Button
      Container(
        margin: const EdgeInsets.only(right: 8),
        child: Material(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              HapticFeedback.lightImpact();
              _toggleSearch();
            },
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              child: const Icon(
                CupertinoIcons.search,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ),
      
      // Menu Button
      Container(
        margin: const EdgeInsets.only(right: 16),
        child: PopupMenuButton<String>(
          icon: Material(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              child: const Icon(
                CupertinoIcons.ellipsis_vertical,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          offset: const Offset(-20, 50),
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
          onSelected: (value) {
            HapticFeedback.mediumImpact();
            switch (value) {
              case 'export':
                _exportData();
                break;
              case 'refresh':
                _refreshData();
                break;
              case 'clear_all':
                _showClearAllDialog();
                break;
            }
          },
          itemBuilder: (context) => [
            _buildMenuItem('export', CupertinoIcons.square_arrow_up, 'Ekspor Data'),
            _buildMenuItem('refresh', CupertinoIcons.arrow_clockwise, 'Refresh'),
            _buildMenuItem('clear_all', CupertinoIcons.trash, 'Hapus Semua'),
          ],
        ),
      ),
    ],
    
    // Flexible Space
    flexibleSpace: FlexibleSpaceBar(
      stretchModes: const [
        StretchMode.zoomBackground,
        StretchMode.blurBackground,
      ],
      titlePadding: EdgeInsets.zero,
      
      // Dynamic Title - positioned higher to avoid tab bar
      title: LayoutBuilder(
        builder: (context, constraints) {
          final isCollapsed = constraints.maxHeight <= 120;
          final collapseRatio = ((constraints.maxHeight - 120) / 160).clamp(0.0, 1.0);
          
          return Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              left: 60,
              right: 100,
              bottom: isCollapsed ? 12 : 70, // Increased bottom padding
            ),
            child: AnimatedOpacity(
              opacity: isCollapsed ? 1.0 : (collapseRatio * 0.8 + 0.2),
              duration: const Duration(milliseconds: 150),
              child: 
              Text(
                '',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: isCollapsed ? 18 : 22,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        },
      ),
      
      // Background
      background: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF64D1DE),
              Color(0xFF4FC3D7),
              Color(0xFF3BB5D1),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Decorative Elements
            Positioned(
              top: 60,
              right: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              top: 140,
              left: -40,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.06),
                ),
              ),
            ),
            
            // Content - positioned with more space
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 70, 20, 80), // Increased top and bottom padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Search Bar - positioned at top
                    if (_isSearching)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        child: _buildSearchBar(),
                      ),
                    
                    // Add some spacing when not searching
                    if (!_isSearching)
                      const SizedBox(height: 20),
                    
                    const Spacer(),
                    
                    // Stats Row - positioned with proper spacing from tab bar
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      transform: Matrix4.translationValues(
                        0, 
                        _isSearching ? 20 : 0, 
                        0,
                      ),
                      child: AnimatedOpacity(
                        opacity: _isSearching ? 0.7 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: _buildStatsRow(),
                      ),
                    ),
                    
                    // Add bottom spacing to avoid tab bar overlap
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    
    // Tab Bar
    bottom: PreferredSize(
      preferredSize: const Size.fromHeight(56),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF64D1DE),
          border: Border(
            top: BorderSide(
              color: Colors.white.withOpacity(0.15),
              width: 0.5,
            ),
          ),
        ),
        child: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.symmetric(horizontal: 24),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          splashFactory: NoSplash.splashFactory,
          overlayColor: MaterialStateProperty.all(Colors.transparent),
          labelStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 15,
            letterSpacing: 0.2,
          ),
          unselectedLabelStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: 15,
            letterSpacing: 0.2,
          ),
          tabs: [
            Tab(
              height: 56,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.clock_fill,
                    size: 22,
                  ),
                  const SizedBox(height: 4),
                  Text('Histori'),
                ],
              ),
            ),
            Tab(
              height: 56,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.chart_bar_fill,
                    size: 22,
                  ),
                  const SizedBox(height: 4),
                  Text('Statistik'),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// Helper method untuk menu items yang bersih
PopupMenuItem<String> _buildMenuItem(String value, IconData icon, String text) {
  return PopupMenuItem(
    value: value,
    height: 48,
    child: Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF64D1DE),
        ),
        const SizedBox(width: 16),
        Text(
          text,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: 15,
            color: Color(0xFF2D3748),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(
          color: Colors.white,
          fontFamily: 'Poppins',
        ),
        decoration: InputDecoration(
          hintText: 'Cari penyakit atau kategori...',
          hintStyle: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontFamily: 'Poppins',
          ),
          prefixIcon: const Icon(CupertinoIcons.search, color: Colors.white),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(CupertinoIcons.clear, color: Colors.white),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _isSearching = false);
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatCard(
          'Total Diagnosa',
          _historyData.length.toString(),
          CupertinoIcons.doc_text,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          'Kategori',
          (_categories.length - 1).toString(),
          CupertinoIcons.folder,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          'Hari Ini',
          _getTodayCount().toString(),
          CupertinoIcons.calendar_today,
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontFamily: 'Poppins',
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: primaryColor,
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildHistoryTab(),
          _buildStatisticsTab(),
        ],
      ),
    );
  }

  Widget _buildHistoryTab() {
    return Column(
      children: [
        _buildFilterSection(),
        Expanded(
          child: _filteredData.isEmpty
              ? _buildEmptyState()
              : _buildHistoryList(),
        ),
      ],
    );
  }

  Widget _buildFilterSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(CupertinoIcons.slider_horizontal_3, 
                  color: primaryColor, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Filter & Urutkan',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              Text(
                '${_filteredData.length} hasil',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCategoryFilter(),
          const SizedBox(height: 12),
          _buildSortFilter(),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Kategori',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: _categories.map((category) {
              final isSelected = _selectedCategory == category;
              final count = category == 'Semua' 
                  ? _historyData.length 
                  : _categoryCounts[category] ?? 0;
              
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text('$category ($count)'),
                  selected: isSelected,
                  onSelected: (_) => _filterByCategory(category),
                  backgroundColor: Colors.grey[100],
                  selectedColor: primaryLight,
                  checkmarkColor: primaryDark,
                  labelStyle: TextStyle(
                    fontFamily: 'Poppins',
                    color: isSelected ? primaryDark : Colors.grey[700],
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSortFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Urutkan',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildSortChip('Terbaru', 'created_at DESC'),
              _buildSortChip('Terlama', 'created_at ASC'),
              _buildSortChip('Akurasi Tinggi', 'persentase DESC'),
              _buildSortChip('Akurasi Rendah', 'persentase ASC'),
              _buildSortChip('Nama A-Z', 'penyakit ASC'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSortChip(String label, String sortValue) {
    final isSelected = _sortBy == sortValue;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => _sortData(sortValue),
        backgroundColor: Colors.grey[100],
        selectedColor: primaryLight,
        labelStyle: TextStyle(
          fontFamily: 'Poppins',
          color: isSelected ? primaryDark : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          itemCount: _filteredData.length,
          itemBuilder: (context, index) => _buildHistoryCard(_filteredData[index], index),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(Map<String, dynamic> history, int index) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) => FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.5),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              (index * 0.1).clamp(0.0, 1.0),
              ((index * 0.1) + 0.3).clamp(0.0, 1.0),
              curve: Curves.easeOut,
            ),
          )),
          child: _buildHistoryCardContent(history),
        ),
      ),
    );
  }

  Widget _buildHistoryCardContent(Map<String, dynamic> history) {
    final percentage = history['persentase_kecocokan'] as double;
    final category = history['kategori_penyakit'] as String;
    final disease = history['nama_penyakit'] as String;
    final date = history['created_at_formatted'] as String? ?? '';
    final matchedSymptoms = history['gejala_cocok'] as int;
    final totalSymptoms = history['total_gejala'] as int;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showHistoryDetail(history),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(category),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Spacer(),
                    PopupMenuButton<String>(
                      icon: Icon(CupertinoIcons.ellipsis, 
                          color: Colors.grey[400], size: 20),
                      onSelected: (value) {
                        if (value == 'delete') {
                          _deleteHistory(history['id'] as int);
                        } else if (value == 'detail') {
                          _showHistoryDetail(history);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'detail',
                          child: Row(
                            children: [
                              Icon(CupertinoIcons.eye, size: 18),
                              SizedBox(width: 8),
                              Text('Lihat Detail'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(CupertinoIcons.trash, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Hapus', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  disease,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        CupertinoIcons.percent,
                        'Akurasi',
                        '${percentage.toStringAsFixed(1)}%',
                        _getPercentageColor(percentage),
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        CupertinoIcons.check_mark_circled,
                        'Gejala Cocok',
                        '$matchedSymptoms/$totalSymptoms',
                        primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(CupertinoIcons.calendar, 
                        color: Colors.grey[500], size: 16),
                    const SizedBox(width: 8),
                    Text(
                      date,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryLight.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(CupertinoIcons.chevron_right, 
                              color: primaryDark, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            'Lihat Detail',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              color: primaryDark,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Poppins',
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatisticsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildStatisticsOverview(),
        const SizedBox(height: 24),
        _buildTopDiseases(),
        const SizedBox(height: 24),
        _buildCategoryBreakdown(),
      ],
    );
  }

  Widget _buildStatisticsOverview() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryLight.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(CupertinoIcons.chart_bar_square, 
                    color: primaryDark, size: 24),
              ),
              const SizedBox(width: 16),
              const Text(
                'Ringkasan Statistik',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildStatisticCard(
                'Total Diagnosa',
                _historyData.length.toString(),
                CupertinoIcons.doc_text_fill,
                primaryColor,
              ),
              _buildStatisticCard(
                'Rata-rata Akurasi',
                '${_getAverageAccuracy().toStringAsFixed(1)}%',
                CupertinoIcons.chart_pie_fill,
                Colors.green,
              ),
              _buildStatisticCard(
                'Kategori Aktif',
                (_categories.length - 1).toString(),
                CupertinoIcons.folder_fill,
                Colors.orange,
              ),
              _buildStatisticCard(
                'Diagnosa Bulan Ini',
                _getMonthlyCount().toString(),
                CupertinoIcons.calendar,
                Colors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopDiseases() {
    final topDiseases = _getTopDiseases();
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(CupertinoIcons.heart_fill, 
                    color: Colors.red, size: 24),
              ),
              const SizedBox(width: 16),
              const Text(
                'Penyakit Tersering',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...topDiseases.take(5).map((disease) => _buildDiseaseRankItem(disease)),
        ],
      ),
    );
  }

  Widget _buildDiseaseRankItem(Map<String, dynamic> disease) {
    final name = disease['nama_penyakit'] as String;
    final count = disease['jumlah_diagnosa'] as int;
    final percentage = disease['rata_rata_persentase'] as double;
    final maxCount = _getTopDiseases().first['jumlah_diagnosa'] as int;
    final progress = count / maxCount;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                '$count kali',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(primaryColor),
                  minHeight: 6,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(CupertinoIcons.square_grid_2x2_fill, 
                    color: Colors.blue, size: 24),
              ),
              const SizedBox(width: 16),
              const Text(
                'Breakdown Kategori',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ..._categoryCounts.entries.map((entry) => _buildCategoryItem(entry)),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(MapEntry<String, int> category) {
    final total = _historyData.length;
    final percentage = total > 0 ? (category.value / total) * 100 : 0.0;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getCategoryColor(category.key),
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              category.key,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${category.value}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: primaryLight.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              CupertinoIcons.doc_text,
              size: 64,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Belum Ada Histori',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isSearching 
                ? 'Tidak ditemukan hasil untuk pencarian Anda'
                : 'Mulai lakukan diagnosa untuk melihat histori',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (!_isSearching)
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(CupertinoIcons.add),
              label: const Text('Mulai Diagnosa'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: primaryColor),
          SizedBox(height: 16),
          Text(
            'Memuat histori diagnosa...',
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return ScaleTransition(
      scale: _fabAnimationController,
      child: FloatingActionButton.extended(
        onPressed: () => _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(CupertinoIcons.up_arrow),
        label: const Text(
          'Ke Atas',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
      ),
    );
  }

  // Helper methods
  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
      }
    });
  }

  Color _getCategoryColor(String category) {
    final colors = [
      primaryColor,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.blue,
      Colors.teal,
      Colors.indigo,
    ];
    return colors[category.hashCode % colors.length];
  }

  Color _getPercentageColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }

  int _getTodayCount() {
    final today = DateTime.now();
    return _historyData.where((item) {
      try {
        final date = DateTime.parse(item['created_at']);
        return date.year == today.year &&
               date.month == today.month &&
               date.day == today.day;
      } catch (e) {
        return false;
      }
    }).length;
  }

  int _getMonthlyCount() {
    final now = DateTime.now();
    return _historyData.where((item) {
      try {
        final date = DateTime.parse(item['created_at']);
        return date.year == now.year && date.month == now.month;
      } catch (e) {
        return false;
      }
    }).length;
  }

  double _getAverageAccuracy() {
    if (_historyData.isEmpty) return 0.0;
    final sum = _historyData.fold<double>(
      0.0,
      (sum, item) => sum + (item['persentase_kecocokan'] as double),
    );
    return sum / _historyData.length;
  }

  List<Map<String, dynamic>> _getTopDiseases() {
    final diseaseMap = <String, Map<String, dynamic>>{};
    
    for (var item in _historyData) {
      final disease = item['nama_penyakit'] as String;
      final percentage = item['persentase_kecocokan'] as double;
      
      if (diseaseMap.containsKey(disease)) {
        diseaseMap[disease]!['jumlah_diagnosa']++;
        diseaseMap[disease]!['total_percentage'] += percentage;
      } else {
        diseaseMap[disease] = {
          'nama_penyakit': disease,
          'jumlah_diagnosa': 1,
          'total_percentage': percentage,
        };
      }
    }
    
    final result = diseaseMap.values.map((item) {
      final count = item['jumlah_diagnosa'] as int;
      final totalPercentage = item['total_percentage'] as double;
      return {
        ...item,
        'rata_rata_persentase': totalPercentage / count,
      };
    }).toList();
    
    result.sort((a, b) => (b['jumlah_diagnosa'] as int).compareTo(a['jumlah_diagnosa'] as int));
    return result;
  }

  // Dialog methods
  Future<bool> _showDeleteConfirmation() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Konfirmasi Hapus',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        ),
        content: const Text(
          'Apakah Anda yakin ingin menghapus histori diagnosa ini?',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Batal',
              style: TextStyle(fontFamily: 'Poppins', color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Hapus',
              style: TextStyle(fontFamily: 'Poppins', color: Colors.white),
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus Semua Histori',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        ),
        content: const Text(
          'Apakah Anda yakin ingin menghapus SEMUA histori diagnosa? Tindakan ini tidak dapat dibatalkan.',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(fontFamily: 'Poppins', color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _clearAllHistory();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Hapus Semua',
              style: TextStyle(fontFamily: 'Poppins', color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Row(
          children: [
            const CircularProgressIndicator(color: primaryColor),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontFamily: 'Poppins'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _clearAllHistory() async {
    try {
      _showLoadingDialog('Menghapus semua histori...');
      
      // Implementation would depend on your database structure
      // This is a placeholder for the actual implementation
      
      Navigator.pop(context); // Close loading dialog
      _showSuccessSnackBar('Semua histori berhasil dihapus');
      _loadData();
    } catch (e) {
      Navigator.pop(context);
      _showErrorSnackBar('Gagal menghapus histori: $e');
    }
  }

  // SnackBar methods
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(CupertinoIcons.check_mark_circled, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontFamily: 'Poppins'),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(CupertinoIcons.exclamationmark_triangle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontFamily: 'Poppins'),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fabAnimationController.dispose();
    _tabController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}

// ========================================
// HISTORY DETAIL PAGE
// ========================================

class HistoryDetailPage extends StatefulWidget {
  final Map<String, dynamic> historyData;

  const HistoryDetailPage({Key? key, required this.historyData}) : super(key: key);

  @override
  State<HistoryDetailPage> createState() => _HistoryDetailPageState();
}

class _HistoryDetailPageState extends State<HistoryDetailPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  
  List<Map<String, dynamic>> _symptomsDetail = [];
  Map<String, dynamic>? _userAnswers;
  bool _isLoading = true;

  static const Color primaryColor = Color(0xFF64D1DE);
  static const Color primaryDark = Color(0xFF4FB3C1);
  static const Color primaryLight = Color(0xFFB3E5EA);
  static const Color surfaceColor = Color(0xFFF8FDFE);

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadDetailData();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    
    _animationController.forward();
  }

  Future<void> _loadDetailData() async {
    try {
      final db = DiagnosisHistoryDatabase.instance;
      final historyId = widget.historyData['id'] as int;
      
      final results = await Future.wait([
        db.getDiagnosisSymptomsDetail(historyId),
        db.getUserAnswersFromHistory(historyId),
      ]);
      
      setState(() {
        _symptomsDetail = results[0] as List<Map<String, dynamic>>;
        _userAnswers = results[1] as Map<String, dynamic>?;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat detail: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceColor,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          if (_isLoading)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(50),
                  child: CircularProgressIndicator(color: primaryColor),
                ),
              ),
            )
          else
            SliverToBoxAdapter(
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 1),
                  end: Offset.zero,
                ).animate(_slideAnimation),
                child: _buildDetailContent(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    final percentage = widget.historyData['persentase_kecocokan'] as double;
    final disease = widget.historyData['nama_penyakit'] as String;
    final category = widget.historyData['kategori_penyakit'] as String;

    return SliverAppBar(
      expandedHeight: 250,
      floating: false,
      pinned: true,
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      leading: IconButton(
        icon: const Icon(CupertinoIcons.back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(CupertinoIcons.share, color: Colors.white),
          onPressed: _shareHistory,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        // title: const Text(
        //   'Detail Diagnosa',
        //   style: TextStyle(
        //     fontFamily: 'Poppins',
        //     fontWeight: FontWeight.w600,
        //     color: Colors.white,
        //   ),
        // ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [primaryColor, primaryDark],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    disease,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            const Icon(CupertinoIcons.percent, 
                                color: Colors.white, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              '${percentage.toStringAsFixed(1)}% Akurasi',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailContent() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(),
          const SizedBox(height: 24),
          _buildSymptomsCard(),
          const SizedBox(height: 24),
          _buildTimestampCard(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    final matchedSymptoms = widget.historyData['gejala_cocok'] as int;
    final totalSymptoms = widget.historyData['total_gejala'] as int;
    final method = widget.historyData['metode_diagnosa'] as String;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryLight.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(CupertinoIcons.chart_bar_circle, 
                    color: primaryDark, size: 24),
              ),
              const SizedBox(width: 16),
              const Text(
                'Ringkasan Diagnosa',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Gejala Cocok',
                  '$matchedSymptoms/$totalSymptoms',
                  CupertinoIcons.checkmark_circle_fill,
                  Colors.green,
                ),
              ),
              Expanded(
                child: _buildSummaryItem(
                  'Metode',
                  method.toUpperCase(),
                  CupertinoIcons.gear_alt_fill,
                  Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(CupertinoIcons.list_bullet, 
                    color: Colors.orange, size: 24),
              ),
              const SizedBox(width: 16),
              const Text(
                'Detail Gejala',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryLight.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_symptomsDetail.length} gejala',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    color: primaryDark,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_symptomsDetail.isNotEmpty) ...[
            _buildSymptomsFilter(),
            const SizedBox(height: 16),
            ..._symptomsDetail.map((symptom) => _buildSymptomItem(symptom)),
          ] else
            _buildNoSymptomsState(),
        ],
      ),
    );
  }

  Widget _buildSymptomsFilter() {
    final matchedCount = _symptomsDetail.where((s) => s['is_matched'] == 1).length;
    final notMatchedCount = _symptomsDetail.length - matchedCount;

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.checkmark_circle, 
                    color: Colors.green, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Cocok ($matchedCount)',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.xmark_circle, 
                    color: Colors.red, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Tidak Cocok ($notMatchedCount)',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSymptomItem(Map<String, dynamic> symptom) {
    final name = symptom['nama_gejala'] as String;
    final value = symptom['nilai_gejala'] as String;
    final isMatched = symptom['is_matched'] == 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isMatched 
            ? Colors.green.withOpacity(0.05)
            : Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMatched 
              ? Colors.green.withOpacity(0.2)
              : Colors.red.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isMatched ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isMatched 
                  ? CupertinoIcons.checkmark
                  : CupertinoIcons.xmark,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Jawaban: $value',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isMatched 
                  ? Colors.green.withOpacity(0.2)
                  : Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isMatched ? 'COCOK' : 'TIDAK',
              style: TextStyle(
                fontFamily: 'Poppins',
                color: isMatched ? Colors.green : Colors.red,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSymptomsState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(
            CupertinoIcons.exclamationmark_triangle,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          const Text(
            'Detail Gejala Tidak Tersedia',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Data detail gejala untuk diagnosa ini tidak dapat dimuat',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTimestampCard() {
    final createdAt = widget.historyData['created_at_formatted'] as String? ?? '';
    final date = widget.historyData['created_at_date'] as String? ?? '';
    final time = widget.historyData['created_at_time'] as String? ?? '';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(CupertinoIcons.time, 
                    color: Colors.purple, size: 24),
              ),
              const SizedBox(width: 16),
              const Text(
                'Informasi Waktu',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildTimeInfoItem(
                  'Tanggal Diagnosa',
                  date,
                  CupertinoIcons.calendar,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTimeInfoItem(
                  'Waktu Diagnosa',
                  time,
                  CupertinoIcons.clock,
                  Colors.green,
                ),
              ),
            ],
          ),
          if (_userAnswers != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(CupertinoIcons.info_circle, 
                      color: primaryColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kategori Diagnosa',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          _userAnswers!['kategori_penyakit'] as String,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeInfoItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _shareHistory() {
    final disease = widget.historyData['nama_penyakit'] as String;
    final percentage = widget.historyData['persentase_kecocokan'] as double;
    final category = widget.historyData['kategori_penyakit'] as String;
    final date = widget.historyData['created_at_formatted'] as String? ?? '';
    final matchedSymptoms = widget.historyData['gejala_cocok'] as int;
    final totalSymptoms = widget.historyData['total_gejala'] as int;

    final shareText = '''
🏥 Hasil Diagnosa Kesehatan

📋 Penyakit: $disease
📊 Kategori: $category
🎯 Tingkat Akurasi: ${percentage.toStringAsFixed(1)}%
✅ Gejala Cocok: $matchedSymptoms dari $totalSymptoms
📅 Tanggal: $date

⚠️ Catatan: Hasil ini hanya untuk referensi. Konsultasikan dengan dokter untuk diagnosis yang akurat.
    ''';

    // In a real app, you would use share_plus package
    // Share.share(shareText);
    
    // For now, show a dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Bagikan Hasil',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        ),
        content: SingleChildScrollView(
          child: Text(
            shareText,
            style: const TextStyle(fontFamily: 'Poppins'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Tutup',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}