import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primafit/features/women_health/data/database_parenting.dart';

class MilestoneParentingPage extends StatefulWidget {
  final int childId;
  final String childName;

  const MilestoneParentingPage({
    super.key,
    required this.childId,
    required this.childName,
  });

  @override
  State<MilestoneParentingPage> createState() => _MilestoneParentingPageState();
}

class _MilestoneParentingPageState extends State<MilestoneParentingPage>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _headerAnimationController;
  late AnimationController _listAnimationController;
  late AnimationController _fabAnimationController;
  
  // Animations
  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _fabScaleAnimation;

  // Database and Data
  final DatabaseParenting _database = DatabaseParenting.instance;
  List<Map<String, dynamic>> _childMilestones = [];
  List<Map<String, dynamic>> _availableTemplates = [];
  Map<String, dynamic>? _childData;
  
  // State Variables
  bool _isLoading = true;
  String _selectedCategory = 'All';
  int _childAgeInMonths = 0;
  
  // Constants
  final List<String> _categories = ['All', 'Motor', 'Kognitif', 'Bahasa', 'Sosial'];
  final List<Color> _categoryColors = [
    const Color(0xFFE9458D),
    const Color(0xFF6C63FF),
    const Color(0xFF00BFA5),
    const Color(0xFFFF6B35),
    const Color(0xFF9C27B0),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadData();
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _listAnimationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  // ============ INITIALIZATION METHODS ============
  
  void _initializeAnimations() {
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _headerFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    ));
    
    _headerSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    ));
    
    _fabScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.elasticOut,
    ));
    
    // Start animations
    _headerAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _listAnimationController.forward();
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
      _childData = await _database.getChildById(widget.childId);
      
      if (_childData != null) {
        final DateTime birthDate = DateTime.parse(_childData!['date_of_birth']);
        _childAgeInMonths = DateTime.now().difference(birthDate).inDays ~/ 30;
      }

      // Load child milestones
      _childMilestones = await _database.getChildMilestones(widget.childId);
      
      // Load available milestone templates
      _availableTemplates = await _database.getMilestoneTemplates(
        ageMonths: _childAgeInMonths + 6,
      );

      // Create missing milestone entries
      await _createMissingMilestoneEntries();
      
      // Reload child milestones after creating missing entries
      _childMilestones = await _database.getChildMilestones(widget.childId);
      
    } catch (e) {
      _showErrorDialog('Gagal memuat data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _createMissingMilestoneEntries() async {
    for (var template in _availableTemplates) {
      final bool exists = _childMilestones.any(
        (milestone) => milestone['milestone_template_id'] == template['id']
      );
      
      if (!exists) {
        await _database.insertChildMilestone({
          'child_id': widget.childId,
          'milestone_template_id': template['id'],
          'is_achieved': 0,
        });
      }
    }
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  // ============ COMPUTED PROPERTIES ============
  
  List<Map<String, dynamic>> get _filteredMilestones {
    if (_selectedCategory == 'All') {
      return _childMilestones;
    }
    return _childMilestones.where(
      (milestone) => milestone['category'] == _selectedCategory
    ).toList();
  }

  Map<String, dynamic> get _milestoneStats {
    final int total = _childMilestones.length;
    final int achieved = _childMilestones.where(
      (milestone) => milestone['is_achieved'] == 1
    ).length;
    
    final double percentage = total > 0 ? (achieved / total) * 100 : 0;
    
    return {
      'total': total,
      'achieved': achieved,
      'remaining': total - achieved,
      'percentage': percentage,
    };
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
      elevation: 0,
      backgroundColor: const Color(0xFFE9458D),
      leading: IconButton(
        icon: const Icon(CupertinoIcons.chevron_left, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'Milestone Tracker',
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(CupertinoIcons.refresh, color: Colors.white),
          onPressed: _refreshData,
        ),
        IconButton(
          icon: const Icon(CupertinoIcons.info, color: Colors.white),
          onPressed: _showInfoDialog,
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
            'Memuat data milestone...',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(bool isTablet) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: const Color(0xFFE9458D),
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header Section
          SliverToBoxAdapter(
            child: AnimatedBuilder(
              animation: _headerAnimationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _headerFadeAnimation,
                  child: SlideTransition(
                    position: _headerSlideAnimation,
                    child: _buildHeaderSection(isTablet),
                  ),
                );
              },
            ),
          ),
          
          // Category Filter
          SliverToBoxAdapter(
            child: _buildCategoryFilter(),
          ),
          
          // Milestone List
          _buildMilestoneList(),
          
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(bool isTablet) {
    final stats = _milestoneStats;
    
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE9458D), Color(0xFFD63384)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFE9458D).withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderInfo(isTablet),
          const SizedBox(height: 24),
          _buildProgressSection(stats),
          const SizedBox(height: 16),
          _buildProgressBar(stats),
          const SizedBox(height: 16),
          _buildQuickStats(stats),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo(bool isTablet) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          child: const Icon(
            CupertinoIcons.person_fill,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.childName,
                style: GoogleFonts.poppins(
                  fontSize: isTablet ? 20 : 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Text(
                '$_childAgeInMonths bulan',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(Map<String, dynamic> stats) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Progress Milestone',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${stats['achieved']} dari ${stats['total']} milestone',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              '${stats['percentage'].round()}%',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(Map<String, dynamic> stats) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LinearProgressIndicator(
        value: stats['percentage'] / 100,
        backgroundColor: Colors.white.withValues(alpha: 0.2),
        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
        minHeight: 8,
      ),
    );
  }

  Widget _buildQuickStats(Map<String, dynamic> stats) {
    return Row(
      children: [
        _buildQuickStat(
          'Tercapai',
          '${stats['achieved']}',
          CupertinoIcons.check_mark_circled_solid,
          Colors.white,
        ),
        const SizedBox(width: 16),
        _buildQuickStat(
          'Tersisa',
          '${stats['remaining']}',
          CupertinoIcons.clock_solid,
          Colors.white.withValues(alpha: 0.7),
        ),
      ],
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: color.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          final color = _categoryColors[index % _categoryColors.length];
          
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _buildCategoryChip(category, isSelected, color),
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip(String category, bool isSelected, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: InkWell(
        onTap: () => setState(() => _selectedCategory = category),
        borderRadius: BorderRadius.circular(25),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
            ),
            boxShadow: isSelected ? [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : [],
          ),
          child: Text(
            category,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMilestoneList() {
    return AnimatedBuilder(
      animation: _listAnimationController,
      builder: (context, child) {
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final milestone = _filteredMilestones[index];
              final delay = index * 0.1;
              final animation = Tween<double>(
                begin: 0.0,
                end: 1.0,
              ).animate(CurvedAnimation(
                parent: _listAnimationController,
                curve: Interval(delay, 1.0, curve: Curves.easeOutBack),
              ));
              
              return AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: animation.value,
                    child: _buildMilestoneCard(milestone),
                  );
                },
              );
            },
            childCount: _filteredMilestones.length,
          ),
        );
      },
    );
  }

  Widget _buildMilestoneCard(Map<String, dynamic> milestone) {
    final isAchieved = milestone['is_achieved'] == 1;
    final isCritical = milestone['is_critical'] == 1;
    final ageInMonths = milestone['age_months'] ?? 0;
    final canAchieve = ageInMonths <= _childAgeInMonths;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isCritical ? Border.all(
          color: const Color(0xFFE9458D).withValues(alpha: 0.3),
          width: 2,
        ) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showMilestoneDetail(milestone),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMilestoneCheckbox(milestone, isAchieved, canAchieve),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMilestoneContent(milestone, isAchieved, isCritical, ageInMonths),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMilestoneCheckbox(Map<String, dynamic> milestone, bool isAchieved, bool canAchieve) {
    return GestureDetector(
      onTap: canAchieve ? () => _toggleMilestone(milestone) : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isAchieved 
              ? const Color(0xFFE9458D)
              : (canAchieve ? Colors.transparent : Colors.grey.shade300),
          border: Border.all(
            color: isAchieved 
                ? const Color(0xFFE9458D)
                : (canAchieve ? const Color(0xFFE9458D) : Colors.grey.shade400),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: isAchieved 
            ? const Icon(
                CupertinoIcons.check_mark,
                color: Colors.white,
                size: 16,
              )
            : null,
      ),
    );
  }

  Widget _buildMilestoneContent(Map<String, dynamic> milestone, bool isAchieved, bool isCritical, int ageInMonths) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildMilestoneBadges(milestone, isCritical, ageInMonths),
        const SizedBox(height: 8),
        _buildMilestoneTitle(milestone, isAchieved),
        const SizedBox(height: 4),
        _buildMilestoneDescription(milestone),
        if (milestone['achieved_date'] != null) ...[
          const SizedBox(height: 8),
          _buildAchievedDate(milestone),
        ],
      ],
    );
  }

  Widget _buildMilestoneBadges(Map<String, dynamic> milestone, bool isCritical, int ageInMonths) {
    return Row(
      children: [
        // Age Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getCategoryColor(milestone['category']).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${ageInMonths}m',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _getCategoryColor(milestone['category']),
            ),
          ),
        ),
        
        const SizedBox(width: 8),
        
        // Category Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            milestone['category'] ?? '',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        
        if (isCritical) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE9458D).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  CupertinoIcons.star_fill,
                  size: 12,
                  color: Color(0xFFE9458D),
                ),
                const SizedBox(width: 4),
                Text(
                  'Penting',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFE9458D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMilestoneTitle(Map<String, dynamic> milestone, bool isAchieved) {
    return Text(
      milestone['title'] ?? '',
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: isAchieved ? Colors.grey.shade600 : Colors.black87,
        decoration: isAchieved ? TextDecoration.lineThrough : null,
      ),
    );
  }

  Widget _buildMilestoneDescription(Map<String, dynamic> milestone) {
    return Text(
      milestone['description'] ?? '',
      style: GoogleFonts.poppins(
        fontSize: 14,
        color: Colors.grey.shade600,
        height: 1.4,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildAchievedDate(Map<String, dynamic> milestone) {
    return Row(
      children: [
        Icon(
          CupertinoIcons.calendar,
          size: 14,
          color: Colors.grey.shade500,
        ),
        const SizedBox(width: 4),
        Text(
          'Tercapai: ${_formatDate(milestone['achieved_date'])}',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton() {
    return AnimatedBuilder(
      animation: _fabScaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _fabScaleAnimation.value,
          child: FloatingActionButton(
            onPressed: _showAddMilestoneDialog,
            backgroundColor: const Color(0xFFE9458D),
            elevation: 8,
            child: const Icon(
              CupertinoIcons.add,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  // ============ MILESTONE DETAIL SHEET ============
  
  void _showMilestoneDetail(Map<String, dynamic> milestone) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildMilestoneDetailSheet(milestone),
    );
  }

  Widget _buildMilestoneDetailSheet(Map<String, dynamic> milestone) {
    final isAchieved = milestone['is_achieved'] == 1;
    final ageInMonths = milestone['age_months'] ?? 0;
    final canAchieve = ageInMonths <= _childAgeInMonths;
    
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSheetHandle(),
          const SizedBox(height: 20),
          _buildDetailHeader(milestone),
          const SizedBox(height: 24),
          _buildDetailDescription(milestone),
          const SizedBox(height: 24),
          _buildDetailStatus(milestone, isAchieved),
          const SizedBox(height: 24),
          _buildDetailActions(milestone, isAchieved, canAchieve),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSheetHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildDetailHeader(Map<String, dynamic> milestone) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _getCategoryColor(milestone['category']).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getCategoryIcon(milestone['category']),
            color: _getCategoryColor(milestone['category']),
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                milestone['title'] ?? '',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(milestone['category']).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${milestone['age_months']} bulan',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _getCategoryColor(milestone['category']),
                      ),
                    ),
                  ),
                  if (milestone['is_critical'] == 1) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9458D).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            CupertinoIcons.star_fill,
                            size: 12,
                            color: Color(0xFFE9458D),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Penting',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFE9458D),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailDescription(Map<String, dynamic> milestone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Deskripsi',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          milestone['description'] ?? '',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey.shade700,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailStatus(Map<String, dynamic> milestone, bool isAchieved) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isAchieved 
            ? const Color(0xFFE9458D).withValues(alpha: 0.1)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAchieved 
              ? const Color(0xFFE9458D).withValues(alpha: 0.3)
              : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isAchieved 
                ? CupertinoIcons.check_mark_circled_solid
                : CupertinoIcons.clock,
            color: isAchieved 
                ? const Color(0xFFE9458D)
                : Colors.grey.shade600,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAchieved ? 'Milestone Tercapai' : 'Belum Tercapai',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isAchieved 
                        ? const Color(0xFFE9458D)
                        : Colors.grey.shade700,
                  ),
                ),
                if (isAchieved && milestone['achieved_date'] != null)
                  Text(
                    'Tanggal: ${_formatDate(milestone['achieved_date'])}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
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

  Widget _buildDetailActions(Map<String, dynamic> milestone, bool isAchieved, bool canAchieve) {
    return Row(
      children: [
        if (canAchieve) ...[
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _toggleMilestone(milestone);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isAchieved 
                    ? Colors.grey.shade400
                    : const Color(0xFFE9458D),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isAchieved 
                        ? CupertinoIcons.minus_circle
                        : CupertinoIcons.check_mark_circled,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isAchieved ? 'Batalkan' : 'Tandai Tercapai',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: OutlinedButton(
            onPressed: () => _showEditMilestoneDialog(milestone),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFE9458D),
              side: const BorderSide(color: Color(0xFFE9458D)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(CupertinoIcons.pencil, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Edit',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============ DIALOG METHODS ============
  
  void _showInfoDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _buildInfoDialog(),
    );
  }

  Widget _buildInfoDialog() {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDialogHeader(
              icon: CupertinoIcons.info,
              title: 'Tentang Milestone',
              onClose: () => Navigator.pop(context),
            ),
            const SizedBox(height: 20),
            Text(
              'Milestone adalah pencapaian perkembangan penting yang dicapai anak pada usia tertentu. Fitur ini membantu Anda:',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            ..._buildInfoItems(),
            const SizedBox(height: 20),
            _buildWarningNote(),
            const SizedBox(height: 20),
            _buildDialogButton(
              text: 'Mengerti',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildInfoItems() {
    final items = [
      {
        'icon': CupertinoIcons.chart_bar_alt_fill,
        'title': 'Memantau Progress',
        'description': 'Melacak perkembangan anak sesuai usianya',
      },
      {
        'icon': CupertinoIcons.star_fill,
        'title': 'Milestone Penting',
        'description': 'Menandai milestone kritis yang perlu perhatian khusus',
      },
      {
        'icon': CupertinoIcons.calendar,
        'title': 'Pencatatan Tanggal',
        'description': 'Mencatat kapan milestone tercapai untuk referensi',
      },
      {
        'icon': CupertinoIcons.doc_text,
        'title': 'Catatan Personal',
        'description': 'Menambahkan catatan khusus untuk setiap milestone',
      },
    ];

    return items.map((item) => _buildInfoItem(
      item['icon'] as IconData,
      item['title'] as String,
      item['description'] as String,
    )).toList();
  }

  Widget _buildInfoItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE9458D).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFFE9458D), size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
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

  Widget _buildWarningNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(CupertinoIcons.info_circle, color: Colors.orange, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Konsultasikan dengan dokter anak jika ada kekhawatiran tentang perkembangan anak.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.orange.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMilestoneDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildAddMilestoneDialog(),
    );
  }

  Widget _buildAddMilestoneDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = 'Motor';
    int selectedAge = _childAgeInMonths;
    bool isCritical = false;
    
    return StatefulBuilder(
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
                    icon: CupertinoIcons.add_circled,
                    title: 'Tambah Milestone',
                    onClose: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(
                    label: 'Judul Milestone',
                    controller: titleController,
                    hint: 'Masukkan judul milestone...',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    label: 'Deskripsi',
                    controller: descriptionController,
                    hint: 'Masukkan deskripsi milestone...',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdownField(
                          label: 'Kategori',
                          value: selectedCategory,
                          items: ['Motor', 'Kognitif', 'Bahasa', 'Sosial'],
                          onChanged: (value) => setState(() => selectedCategory = value!),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDropdownField(
                          label: 'Usia (bulan)',
                          value: selectedAge,
                          items: List.generate(37, (index) => index),
                          onChanged: (value) => setState(() => selectedAge = value!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildCheckboxField(
                    label: 'Milestone penting/kritis',
                    value: isCritical,
                    onChanged: (value) => setState(() => isCritical = value!),
                  ),
                  const SizedBox(height: 24),
                  _buildDialogActions(
                    onCancel: () => Navigator.pop(context),
                    onSave: () => _addCustomMilestone(
                      titleController.text,
                      descriptionController.text,
                      selectedCategory,
                      selectedAge,
                      isCritical,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEditMilestoneDialog(Map<String, dynamic> milestone) {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => _buildEditMilestoneDialog(milestone),
    );
  }

  Widget _buildEditMilestoneDialog(Map<String, dynamic> milestone) {
    final notesController = TextEditingController(text: milestone['notes'] ?? '');
    DateTime? selectedDate;
    
    if (milestone['achieved_date'] != null) {
      try {
        selectedDate = DateTime.parse(milestone['achieved_date']);
      } catch (e) {
        selectedDate = null;
      }
    }

    return StatefulBuilder(
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
                    title: 'Edit Milestone',
                    onClose: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 24),
                  _buildMilestoneInfo(milestone),
                  const SizedBox(height: 16),
                  if (milestone['is_achieved'] == 1) ...[
                    _buildDatePicker(
                      label: 'Tanggal Tercapai',
                      selectedDate: selectedDate,
                      onDateSelected: (date) => setState(() => selectedDate = date),
                    ),
                    const SizedBox(height: 16),
                  ],
                  _buildTextField(
                    label: 'Catatan',
                    controller: notesController,
                    hint: 'Tambahkan catatan...',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 24),
                  _buildDialogActions(
                    onCancel: () => Navigator.pop(context),
                    onSave: () => _updateMilestone(milestone, notesController.text, selectedDate),
                  ),
                ],
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
            color: const Color(0xFFE9458D).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFFE9458D), size: 24),
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
              borderSide: const BorderSide(color: Color(0xFFE9458D)),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          style: GoogleFonts.poppins(fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T value,
    required List<T> items,
    required Function(T?) onChanged,
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
        DropdownButtonFormField<T>(
          initialValue: value,
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: items.map((item) => DropdownMenuItem(
            value: item,
            child: Text('$item', style: GoogleFonts.poppins(fontSize: 14)),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildCheckboxField({
    required String label,
    required bool value,
    required Function(bool?) onChanged,
  }) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFFE9458D),
        ),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? selectedDate,
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
              initialDate: selectedDate ?? DateTime.now(),
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
                const Icon(CupertinoIcons.calendar),
                const SizedBox(width: 12),
                Text(
                  selectedDate != null
                      ? _formatDate(selectedDate.toIso8601String())
                      : 'Pilih tanggal',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMilestoneInfo(Map<String, dynamic> milestone) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            milestone['title'] ?? '',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            milestone['description'] ?? '',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
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
              backgroundColor: const Color(0xFFE9458D),
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

  Widget _buildDialogButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFE9458D),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // ============ BUSINESS LOGIC METHODS ============
  
  Future<void> _toggleMilestone(Map<String, dynamic> milestone) async {
    final isCurrentlyAchieved = milestone['is_achieved'] == 1;
    final newStatus = isCurrentlyAchieved ? 0 : 1;
    
    try {
      await _database.updateChildMilestone(
        milestone['id'],
        {
          'is_achieved': newStatus,
          'achieved_date': newStatus == 1 ? DateTime.now().toIso8601String() : null,
        },
      );
      
      _showSuccessDialog(
        isCurrentlyAchieved 
            ? 'Milestone dibatalkan'
            : 'Selamat! Milestone tercapai! 🎉',
      );
      
      await _loadData();
    } catch (e) {
      _showErrorDialog('Gagal mengupdate milestone: $e');
    }
  }

  Future<void> _addCustomMilestone(
    String title,
    String description,
    String category,
    int ageMonths,
    bool isCritical,
  ) async {
    if (title.trim().isEmpty) {
      _showErrorDialog('Judul milestone tidak boleh kosong');
      return;
    }

    try {
      final templateId = await _database.insertMilestoneTemplate({
        'age_months': ageMonths,
        'category': category,
        'title': title.trim(),
        'description': description.trim(),
        'is_critical': isCritical ? 1 : 0,
      });

      await _database.insertChildMilestone({
        'child_id': widget.childId,
        'milestone_template_id': templateId,
        'is_achieved': 0,
      });

      if (!mounted) return;
      Navigator.pop(context);
      _showSuccessDialog('Milestone berhasil ditambahkan!');
      await _loadData();
    } catch (e) {
      _showErrorDialog('Gagal menambahkan milestone: $e');
    }
  }

  Future<void> _updateMilestone(
    Map<String, dynamic> milestone,
    String notes,
    DateTime? achievedDate,
  ) async {
    try {
      await _database.updateChildMilestone(
        milestone['id'],
        {
          'notes': notes.trim(),
          'achieved_date': achievedDate?.toIso8601String(),
        },
      );

      if (!mounted) return;
      Navigator.pop(context);
      _showSuccessDialog('Milestone berhasil diupdate!');
      await _loadData();
    } catch (e) {
      _showErrorDialog('Gagal mengupdate milestone: $e');
    }
  }

  // ============ SUCCESS/ERROR DIALOGS ============
  
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _buildStatusDialog(
        icon: CupertinoIcons.check_mark_circled_solid,
        iconColor: const Color(0xFFE9458D),
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
                backgroundColor: iconColor == Colors.red ? Colors.red : const Color(0xFFE9458D),
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
  
  IconData _getCategoryIcon(String? category) {
    switch (category) {
      case 'Motor':
        return CupertinoIcons.circle_grid_hex;
      case 'Kognitif':
        return CupertinoIcons.lab_flask;
      case 'Bahasa':
        return CupertinoIcons.chat_bubble_text;
      case 'Sosial':
        return CupertinoIcons.group;
      default:
        return CupertinoIcons.star;
    }
  }

  Color _getCategoryColor(String? category) {
    switch (category) {
      case 'Motor':
        return const Color(0xFF6C63FF);
      case 'Kognitif':
        return const Color(0xFF00BFA5);
      case 'Bahasa':
        return const Color(0xFFFF6B35);
      case 'Sosial':
        return const Color(0xFF9C27B0);
      default:
        return const Color(0xFFE9458D);
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final DateTime date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}

// ============ DATABASE EXTENSION ============

extension DatabaseParentingMilestone on DatabaseParenting {
  Future<int> insertMilestoneTemplate(Map<String, dynamic> template) async {
    final db = await database;
    template['created_at'] = DateTime.now().toIso8601String();
    return await db.insert('milestone_templates', template);
  }
}