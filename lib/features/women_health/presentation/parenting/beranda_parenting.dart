import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primafit/features/women_health/data/database_parenting.dart';

class ParentingHomePage extends StatefulWidget {
  const ParentingHomePage({super.key});

  @override
  State<ParentingHomePage> createState() => _ParentingHomePageState();
}

class _ParentingHomePageState extends State<ParentingHomePage>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _headerAnimationController;
  late AnimationController _menuAnimationController;
  late AnimationController _fabAnimationController;
  
  // Animations
  late Animation<double> _headerFadeAnimation;
  late Animation<Offset> _headerSlideAnimation;
  late Animation<double> _fabScaleAnimation;
  
  // Controllers and Data
  final PageController _pageController = PageController();
  final DatabaseParenting _database = DatabaseParenting.instance;
  
  // State Variables
  int _currentBannerIndex = 0;
  bool _isLoading = true;
  int? _selectedChildId;
  String _selectedChildName = 'Pilih Anak';
  List<Map<String, dynamic>> _children = [];
  Map<String, dynamic> _childStatistics = {};

  // Banner Data
  final List<Map<String, dynamic>> _bannerData = [
    {
      'title': 'Milestone Tracker',
      'subtitle': 'Pantau perkembangan si kecil',
      'icon': CupertinoIcons.chart_bar_alt_fill,
      'color': Color(0xFFE9458D),
    },
    {
      'title': 'Growth Chart',
      'subtitle': 'Monitor pertumbuhan optimal',
      'icon': CupertinoIcons.graph_circle_fill,
      'color': Color(0xFF6C63FF),
    },
    {
      'title': 'Health Tips',
      'subtitle': 'Tips kesehatan dari ahli',
      'icon': CupertinoIcons.heart_fill,
      'color': Color(0xFF00BFA5),
    },
  ];

  // Menu Items
  final List<Map<String, dynamic>> _menuItems = [
    {
      'title': 'Milestone\nTracker',
      'subtitle': 'Catat pencapaian\nperkembangan',
      'icon': CupertinoIcons.calendar_badge_plus,
      'color': Color(0xFFE9458D),
      'route': '/milestone',
    },
    {
      'title': 'Growth\nChart',
      'subtitle': 'Grafik tinggi\n& berat badan',
      'icon': CupertinoIcons.chart_bar_square_fill,
      'color': Color(0xFF6C63FF),
      'route': '/growth',
    },
    {
      'title': 'Vaccination\nSchedule',
      'subtitle': 'Jadwal imunisasi\ndan reminder',
      'icon': CupertinoIcons.calendar_circle_fill,
      'color': Color(0xFF00BFA5),
      'route': '/vaccination',
    },
    {
      'title': 'Health\nRecords',
      'subtitle': 'Catatan kesehatan\nlengkap',
      'icon': CupertinoIcons.doc_chart_fill,
      'color': Color(0xFFFF6B35),
      'route': '/health',
    },
    {
      'title': 'Photo\nMemories',
      'subtitle': 'Album tumbuh\nkembang',
      'icon': CupertinoIcons.camera_fill,
      'color': Color(0xFFE91E63),
      'route': '/photos',
    },
    {
      'title': 'Parenting\nTips',
      'subtitle': 'Panduan dari\nahli parenting',
      'icon': CupertinoIcons.book_circle_fill,
      'color': Color(0xFF9C27B0),
      'route': '/tips',
    },
    {
      'title': 'Sleep\nTracker',
      'subtitle': 'Monitor pola\ntidur anak',
      'icon': CupertinoIcons.moon_fill,
      'color': Color(0xFF3F51B5),
      'route': '/sleep',
    },
    {
      'title': 'Nutrition\nGuide',
      'subtitle': 'Panduan gizi\nseimbang',
      'icon': CupertinoIcons.heart_circle_fill,
      'color': Color(0xFF4CAF50),
      'route': '/nutrition',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadData();
    _startBannerAutoScroll();
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _menuAnimationController.dispose();
    _fabAnimationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // ============ INITIALIZATION METHODS ============
  
  void _initializeAnimations() {
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _menuAnimationController = AnimationController(
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
      if (mounted) _menuAnimationController.forward();
    });
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _fabAnimationController.forward();
    });
  }

  void _startBannerAutoScroll() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _currentBannerIndex = (_currentBannerIndex + 1) % _bannerData.length;
        });
        _pageController.animateToPage(
          _currentBannerIndex,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
        _startBannerAutoScroll();
      }
    });
  }

  // ============ DATA METHODS ============
  
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load children data
      _children = await _database.getAllChildren();
      
      // Set selected child if exists
      if (_children.isNotEmpty && _selectedChildId == null) {
        _selectedChildId = _children.first['id'];
        _selectedChildName = _children.first['name'];
      }
      
      // Load child statistics if child is selected
      if (_selectedChildId != null) {
        await _loadChildStatistics();
      }
      
    } catch (e) {
      _showErrorDialog('Gagal memuat data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadChildStatistics() async {
    if (_selectedChildId == null) return;
    
    try {
      _childStatistics = await _database.getChildStatistics(_selectedChildId!);
    } catch (e) {
      debugPrint('Error loading statistics: $e');
      _childStatistics = {};
    }
  }


  // ============ CHILD CRUD METHODS ============
  
  void _showAddChildDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildAddChildDialog(),
    );
  }

  Widget _buildAddChildDialog() {
    final nameController = TextEditingController();
    final parentNameController = TextEditingController();
    final notesController = TextEditingController();
    DateTime? selectedDate;
    String selectedGender = 'Laki-laki';
    String? selectedBloodType;
    double? birthWeight;
    double? birthHeight;
    
    final bloodTypes = ['A', 'B', 'AB', 'O', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

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
                    icon: CupertinoIcons.person_add,
                    title: 'Tambah Data Anak',
                    onClose: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 24),
                  
                  // Name Field
                  _buildTextField(
                    label: 'Nama Anak',
                    controller: nameController,
                    hint: 'Masukkan nama anak...',
                  ),
                  const SizedBox(height: 16),
                  
                  // Date of Birth
                  _buildDatePicker(
                    label: 'Tanggal Lahir',
                    selectedDate: selectedDate,
                    onDateSelected: (date) => setState(() => selectedDate = date),
                    isRequired: true,
                  ),
                  const SizedBox(height: 16),
                  
                  // Gender
                  _buildDropdownField(
                    label: 'Jenis Kelamin',
                    value: selectedGender,
                    items: ['Laki-laki', 'Perempuan'],
                    onChanged: (value) => setState(() => selectedGender = value!),
                  ),
                  const SizedBox(height: 16),
                  
                  // Blood Type
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Golongan Darah (Opsional)',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: selectedBloodType,
                        onChanged: (value) => setState(() => selectedBloodType = value),
                        decoration: InputDecoration(
                          hintText: 'Pilih golongan darah',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        items: [
                          const DropdownMenuItem<String>(
                            value: null,
                            child: Text('Belum diketahui'),
                          ),
                          ...bloodTypes.map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type, style: GoogleFonts.poppins(fontSize: 14)),
                          )),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Birth Weight and Height
                  Row(
                    children: [
                      Expanded(
                        child: _buildNumberField(
                          label: 'Berat Lahir (kg)',
                          hint: '3.2',
                          onChanged: (value) => birthWeight = double.tryParse(value),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildNumberField(
                          label: 'Tinggi Lahir (cm)',
                          hint: '50',
                          onChanged: (value) => birthHeight = double.tryParse(value),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Parent Name
                  _buildTextField(
                    label: 'Nama Orang Tua',
                    controller: parentNameController,
                    hint: 'Masukkan nama orang tua...',
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
                    onSave: () => _addChild(
                      nameController.text,
                      selectedDate,
                      selectedGender,
                      selectedBloodType,
                      birthWeight,
                      birthHeight,
                      parentNameController.text,
                      notesController.text,
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

  Future<void> _addChild(
    String name,
    DateTime? dateOfBirth,
    String gender,
    String? bloodType,
    double? birthWeight,
    double? birthHeight,
    String parentName,
    String notes,
  ) async {
    if (name.trim().isEmpty) {
      _showErrorDialog('Nama anak tidak boleh kosong');
      return;
    }
    
    if (dateOfBirth == null) {
      _showErrorDialog('Tanggal lahir harus dipilih');
      return;
    }

    try {
      final childData = {
        'name': name.trim(),
        'date_of_birth': dateOfBirth.toIso8601String(),
        'gender': gender,
        'blood_type': bloodType,
        'birth_weight': birthWeight,
        'birth_height': birthHeight,
        'parent_name': parentName.trim(),
        'notes': notes.trim(),
        'is_active': 1,
      };

      final childId = await _database.insertChild(childData);
      
      if (!mounted) return;
      Navigator.pop(context);
      _showSuccessDialog('Data anak berhasil ditambahkan!');
      
      // Set as selected child and reload data
      setState(() {
        _selectedChildId = childId;
        _selectedChildName = name.trim();
      });
      
      await _loadData();
    } catch (e) {
      _showErrorDialog('Gagal menambahkan data anak: $e');
    }
  }

  void _showEditChildDialog(Map<String, dynamic> child) {
    final nameController = TextEditingController(text: child['name']);
    final parentNameController = TextEditingController(text: child['parent_name'] ?? '');
    final notesController = TextEditingController(text: child['notes'] ?? '');
    DateTime selectedDate = DateTime.parse(child['date_of_birth']);
    String selectedGender = child['gender'];
    String? selectedBloodType = child['blood_type'];
    double? birthWeight = child['birth_weight']?.toDouble();
    double? birthHeight = child['birth_height']?.toDouble();
    
    final bloodTypes = ['A', 'B', 'AB', 'O', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

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
                      title: 'Edit Data Anak',
                      onClose: () => Navigator.pop(context),
                    ),
                    const SizedBox(height: 24),
                    
                    // Name Field
                    _buildTextField(
                      label: 'Nama Anak',
                      controller: nameController,
                      hint: 'Masukkan nama anak...',
                    ),
                    const SizedBox(height: 16),
                    
                    // Date of Birth
                    _buildDatePicker(
                      label: 'Tanggal Lahir',
                      selectedDate: selectedDate,
                      onDateSelected: (date) => setState(() => selectedDate = date!),
                      isRequired: true,
                    ),
                    const SizedBox(height: 16),
                    
                    // Gender
                    _buildDropdownField(
                      label: 'Jenis Kelamin',
                      value: selectedGender,
                      items: ['Laki-laki', 'Perempuan'],
                      onChanged: (value) => setState(() => selectedGender = value!),
                    ),
                    const SizedBox(height: 16),
                    
                    // Blood Type
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Golongan Darah',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: selectedBloodType,
                          onChanged: (value) => setState(() => selectedBloodType = value),
                          decoration: InputDecoration(
                            hintText: 'Pilih golongan darah',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          items: [
                            const DropdownMenuItem<String>(
                              value: null,
                              child: Text('Belum diketahui'),
                            ),
                            ...bloodTypes.map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type, style: GoogleFonts.poppins(fontSize: 14)),
                            )),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Birth Weight and Height
                    Row(
                      children: [
                        Expanded(
                          child: _buildNumberField(
                            label: 'Berat Lahir (kg)',
                            hint: '3.2',
                            initialValue: birthWeight?.toString(),
                            onChanged: (value) => birthWeight = double.tryParse(value),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildNumberField(
                            label: 'Tinggi Lahir (cm)',
                            hint: '50',
                            initialValue: birthHeight?.toString(),
                            onChanged: (value) => birthHeight = double.tryParse(value),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Parent Name
                    _buildTextField(
                      label: 'Nama Orang Tua',
                      controller: parentNameController,
                      hint: 'Masukkan nama orang tua...',
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
                      onSave: () => _updateChild(
                        child['id'],
                        nameController.text,
                        selectedDate,
                        selectedGender,
                        selectedBloodType,
                        birthWeight,
                        birthHeight,
                        parentNameController.text,
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

  Future<void> _updateChild(
    int childId,
    String name,
    DateTime dateOfBirth,
    String gender,
    String? bloodType,
    double? birthWeight,
    double? birthHeight,
    String parentName,
    String notes,
  ) async {
    if (name.trim().isEmpty) {
      _showErrorDialog('Nama anak tidak boleh kosong');
      return;
    }

    try {
      final childData = {
        'name': name.trim(),
        'date_of_birth': dateOfBirth.toIso8601String(),
        'gender': gender,
        'blood_type': bloodType,
        'birth_weight': birthWeight,
        'birth_height': birthHeight,
        'parent_name': parentName.trim(),
        'notes': notes.trim(),
      };

      await _database.updateChild(childId, childData);
      
      if (!mounted) return;
      Navigator.pop(context);
      _showSuccessDialog('Data anak berhasil diupdate!');
      
      // Update selected child name if this is the selected child
      if (_selectedChildId == childId) {
        setState(() {
          _selectedChildName = name.trim();
        });
      }
      
      await _loadData();
    } catch (e) {
      _showErrorDialog('Gagal mengupdate data anak: $e');
    }
  }

  void _confirmDeleteChild(Map<String, dynamic> child) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Hapus Data Anak',
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus data ${child['name']}? Semua data terkait akan ikut terhapus.',
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
              _deleteChild(child['id']);
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

  Future<void> _deleteChild(int childId) async {
    try {
      await _database.deleteChild(childId);
      
      _showSuccessDialog('Data anak berhasil dihapus!');
      
      // Reset selected child if this is the selected child
      if (_selectedChildId == childId) {
        setState(() {
          _selectedChildId = null;
          _selectedChildName = 'Pilih Anak';
          _childStatistics = {};
        });
      }
      
      await _loadData();
    } catch (e) {
      _showErrorDialog('Gagal menghapus data anak: $e');
    }
  }

  // ============ NAVIGATION METHODS ============
  
  void _navigateToMenu(String route, String menuTitle) async {
    if (_selectedChildId == null && route != '/tips') {
      _showErrorDialog('Silakan pilih atau tambah data anak terlebih dahulu');
      return;
    }
    
    setState(() => _isLoading = true);
    
    await Future.delayed(const Duration(milliseconds: 200));
    
    if (mounted) {
      if (route == '/milestone') {
        // Navigate to milestone page with child data
        Navigator.pushNamed(
          context, 
          route,
          arguments: {
            'childId': _selectedChildId,
            'childName': _selectedChildName,
          },
        );
      } else {
        _showComingSoonDialog(menuTitle);
      }
      setState(() => _isLoading = false);
    }
  }

  // ============ UI BUILD METHODS ============
  
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;
    final crossAxisCount = isTablet ? 4 : 2;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: _isLoading ? _buildLoadingWidget() : _buildBody(isTablet, crossAxisCount),
      ),
      floatingActionButton: _buildFloatingActionButton(),
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
            'Memuat data...',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(bool isTablet, int crossAxisCount) {
    return CustomScrollView(
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
        
        // Quick Stats Section
        if (_selectedChildId != null) 
          SliverToBoxAdapter(child: _buildQuickStatsSection()),
        
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        
        // Menu Section Title
        SliverToBoxAdapter(child: _buildMenuSectionTitle(isTablet)),
        
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
        
        // Menu Grid
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: _buildMenuGrid(crossAxisCount, isTablet),
        ),
        
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildHeaderSection(bool isTablet) {
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
          _buildHeaderTop(isTablet),
          const SizedBox(height: 20),
          _buildBannerCarousel(),
          const SizedBox(height: 16),
          _buildBannerIndicators(),
        ],
      ),
    );
  }

  Widget _buildHeaderTop(bool isTablet) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selamat Datang, Bunda!',
              style: GoogleFonts.poppins(
                fontSize: isTablet ? 22 : 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: _showChildSelector,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedChildName,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      CupertinoIcons.chevron_down,
                      color: Colors.white,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            CupertinoIcons.bell_fill,
            color: Colors.white,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildBannerCarousel() {
    return SizedBox(
      height: 120,
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentBannerIndex = index;
          });
        },
        itemCount: _bannerData.length,
        itemBuilder: (context, index) {
          final banner = _bannerData[index];
          return Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    banner['icon'],
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        banner['title'],
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        banner['subtitle'],
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBannerIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: _bannerData.asMap().entries.map((entry) {
        return Container(
          width: _currentBannerIndex == entry.key ? 24 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: _currentBannerIndex == entry.key
                ? Colors.white
                : Colors.white.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickStatsSection() {
    final milestoneProgress = _childStatistics['milestone_progress'] ?? {};
    final latestGrowth = _childStatistics['latest_growth'] ?? {};
    
    final totalMilestones = milestoneProgress['total_milestones'] ?? 0;
    final achievedMilestones = milestoneProgress['achieved_milestones'] ?? 0;
    final weight = latestGrowth['weight'] ?? 0.0;
    final height = latestGrowth['height'] ?? 0.0;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _buildQuickStat(
              'Milestone',
              '$achievedMilestones/$totalMilestones',
              CupertinoIcons.chart_bar_alt_fill,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickStat(
              'Tinggi',
              height > 0 ? '${height.toStringAsFixed(1)} cm' : '-',
              CupertinoIcons.arrow_up_circle_fill,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickStat(
              'Berat',
              weight > 0 ? '${weight.toStringAsFixed(1)} kg' : '-',
              CupertinoIcons.heart_fill,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String title, String value, IconData icon, Color color) {
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
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSectionTitle(bool isTablet) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Menu Parenting',
            style: GoogleFonts.poppins(
              fontSize: isTablet ? 20 : 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          TextButton(
            onPressed: () => _showComingSoonDialog('Menu Lengkap'),
            child: Text(
              'Lihat Semua',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFE9458D),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGrid(int crossAxisCount, bool isTablet) {
    return AnimatedBuilder(
      animation: _menuAnimationController,
      builder: (context, child) {
        return SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: isTablet ? 1.1 : 0.9,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final delay = index * 0.1;
              final animation = Tween<double>(
                begin: 0.0,
                end: 1.0,
              ).animate(CurvedAnimation(
                parent: _menuAnimationController,
                curve: Interval(delay, 1.0, curve: Curves.easeOutBack),
              ));
              
              return AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: animation.value,
                    child: _buildMenuCard(_menuItems[index], isTablet),
                  );
                },
              );
            },
            childCount: _menuItems.length,
          ),
        );
      },
    );
  }

  Widget _buildMenuCard(Map<String, dynamic> menu, bool isTablet) {
    return InkWell(
      onTap: () => _navigateToMenu(menu['route'], menu['title']),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(isTablet ? 20 : 16),
              decoration: BoxDecoration(
                color: menu['color'].withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                menu['icon'],
                color: menu['color'],
                size: isTablet ? 36 : 32,
              ),
            ),
            SizedBox(height: isTablet ? 16 : 12),
            Text(
              menu['title'],
              style: GoogleFonts.poppins(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: isTablet ? 8 : 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                menu['subtitle'],
                style: GoogleFonts.poppins(
                  fontSize: isTablet ? 12 : 11,
                  color: Colors.grey.shade600,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
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
            onPressed: () => _showComingSoonDialog('Emergency Contact'),
            backgroundColor: const Color(0xFFE9458D),
            elevation: 8,
            icon: const Icon(
              CupertinoIcons.phone_fill,
              color: Colors.white,
            ),
            label: Text(
              'Emergency',
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

  // ============ CHILD SELECTOR DIALOG ============
  
  void _showChildSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildChildSelectorSheet(),
    );
  }

  Widget _buildChildSelectorSheet() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          
          // Title with Add Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pilih Anak',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showAddChildDialog();
                },
                icon: const Icon(
                  CupertinoIcons.add_circled_solid,
                  color: Color(0xFFE9458D),
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Children List
          if (_children.isEmpty) 
            _buildEmptyChildrenState()
          else
            ..._children.map((child) => _buildChildItem(child)),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildEmptyChildrenState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(
            CupertinoIcons.person_add,
            size: 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Belum Ada Data Anak',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan data anak untuk mulai menggunakan fitur parenting',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showAddChildDialog();
            },
            icon: const Icon(CupertinoIcons.add),
            label: Text(
              'Tambah Anak',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE9458D),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildItem(Map<String, dynamic> child) {
    final isSelected = child['id'] == _selectedChildId;
    final birthDate = DateTime.parse(child['date_of_birth']);
    final ageInMonths = DateTime.now().difference(birthDate).inDays ~/ 30;
    final ageInYears = ageInMonths ~/ 12;
    final remainingMonths = ageInMonths % 12;
    
    String ageText;
    if (ageInYears > 0) {
      ageText = remainingMonths > 0 
          ? '$ageInYears tahun $remainingMonths bulan'
          : '$ageInYears tahun';
    } else {
      ageText = '$ageInMonths bulan';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedChildId = child['id'];
            _selectedChildName = child['name'];
          });
          Navigator.pop(context);
          _loadChildStatistics();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected 
                ? const Color(0xFFE9458D).withValues(alpha: 0.1)
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected 
                  ? const Color(0xFFE9458D)
                  : Colors.grey.shade200,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: isSelected 
                    ? const Color(0xFFE9458D)
                    : Colors.grey.shade400,
                child: Text(
                  child['name'][0].toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child['name'],
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: isSelected 
                            ? FontWeight.w600 
                            : FontWeight.w500,
                        color: isSelected 
                            ? const Color(0xFFE9458D)
                            : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          child['gender'] == 'Laki-laki' 
                              ? CupertinoIcons.person_fill
                              : CupertinoIcons.person_fill,
                          size: 14,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${child['gender']} • $ageText',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected)
                    const Icon(
                      CupertinoIcons.checkmark_circle_fill,
                      color: Color(0xFFE9458D),
                      size: 24,
                    ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        Navigator.pop(context);
                        _showEditChildDialog(child);
                      } else if (value == 'delete') {
                        Navigator.pop(context);
                        _confirmDeleteChild(child);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            const Icon(CupertinoIcons.pencil, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'Edit',
                              style: GoogleFonts.poppins(fontSize: 14),
                            ),
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
                ],
              ),
            ],
          ),
        ),
      ),
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

  Widget _buildNumberField({
    required String label,
    required String hint,
    String? initialValue,
    required Function(String) onChanged,
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
          controller: TextEditingController(text: initialValue),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: onChanged,
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

  Widget _buildDatePicker({
    required String label,
    required DateTime? selectedDate,
    required Function(DateTime?) onDateSelected,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label${isRequired ? ' *' : ''}',
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

  void _showComingSoonDialog(String featureName) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 8,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  const Color(0xFFE9458D).withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE9458D).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    CupertinoIcons.sparkles,
                    color: Color(0xFFE9458D),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Segera Hadir!',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Fitur $featureName sedang dalam pengembangan dan akan segera tersedia untuk membantu Anda.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE9458D),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Mengerti',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
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

  // ============ UTILITY METHODS ============
  
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