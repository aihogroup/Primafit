import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:primafit/database/navigasi/database_fitur.dart';

class SemuaFiturPage extends StatefulWidget {
  const SemuaFiturPage({Key? key}) : super(key: key);

  @override
  State<SemuaFiturPage> createState() => _SemuaFiturPageState();
}

class _SemuaFiturPageState extends State<SemuaFiturPage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final Color primaryColor = const Color(0xFF64D1DE);
  bool _isLoading = false;
  bool _isEditMode = false;
  bool _hasChanges = false;
  
  // Controller untuk scroll position
  final ScrollController _scrollController = ScrollController();
  
  // Simpan list category user preference
  List<CategoryData> _categories = [];
  List<CategoryData> _originalCategories = [];
  
  // Instance dari FiturDatabase
  final FiturDatabase _fiturDb = FiturDatabase();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load kategori dan preferensi user dari database
      _categories = await _fiturDb.getCategories();
      // Simpan salinan original untuk deteksi perubahan
      _originalCategories = _deepCopyCategories(_categories);
    } catch (e) {
      // Handle error silently and use default data as fallback
      print('Error loading data: $e');
      _categories = FiturDatabase.getDefaultCategories();
      _originalCategories = _deepCopyCategories(_categories);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  // Deep copy untuk mendeteksi perubahan
  List<CategoryData> _deepCopyCategories(List<CategoryData> source) {
    return source.map((category) => CategoryData(
      title: category.title,
      isHidden: category.isHidden,
      items: category.items.map((item) => FeatureItem(
        name: item.name,
        imageAsset: item.imageAsset,
        route: item.route,
        isHidden: item.isHidden,
      )).toList(),
    )).toList();
  }

  // Cek apakah ada perubahan
  bool _checkForChanges() {
    if (_categories.length != _originalCategories.length) return true;
    
    for (int i = 0; i < _categories.length; i++) {
      if (_categories[i].title != _originalCategories[i].title ||
          _categories[i].isHidden != _originalCategories[i].isHidden ||
          _categories[i].items.length != _originalCategories[i].items.length) {
        return true;
      }
      
      for (int j = 0; j < _categories[i].items.length; j++) {
        if (_categories[i].items[j].isHidden != _originalCategories[i].items[j].isHidden) {
          return true;
        }
      }
    }
    
    return false;
  }

  Future<void> _saveData() async {
    setState(() => _isLoading = true);
    
    try {
      await _fiturDb.saveCategories(_categories);
      _originalCategories = _deepCopyCategories(_categories);
      _hasChanges = false;
      
      // Feedback sukses dengan SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Pengaturan fitur berhasil disimpan',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: primaryColor,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
    } catch (e) {
      // Feedback gagal dengan SnackBar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal menyimpan pengaturan',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isEditMode = false;
        });
      }
    }
  }

  // Fungsi konfirmasi keluar dari mode edit
  Future<bool> _confirmExitEditMode() async {
    _hasChanges = _checkForChanges();
    
    if (!_hasChanges) {
      setState(() {
        _isEditMode = false;
      });
      return true;
    }
    
    bool shouldExit = false;
    
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 5,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header dengan animasi
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 800),
                  builder: (context, double value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.scale(
                        scale: value,
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            CupertinoIcons.exclamationmark_triangle,
                            color: primaryColor,
                            size: 50,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                // Judul dialog
                Text(
                  'Peringatan!',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                // Pesan dialog
                Text(
                  'Anda memiliki perubahan yang belum tersimpan. Apakah Anda ingin menyimpan perubahan tersebut?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 25),
                // Tombol aksi
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Tombol tidak simpan
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          // Tidak simpan perubahan
                          _categories = _deepCopyCategories(_originalCategories);
                          shouldExit = true;
                          Navigator.of(context).pop();
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.grey.shade400),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.xmark,
                              color: Colors.grey.shade700,
                              size: 18,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Tidak',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Tombol simpan
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          // Simpan perubahan
                          Navigator.of(context).pop();
                          await _saveData();
                          shouldExit = true;
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              CupertinoIcons.check_mark,
                              size: 18,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Simpan',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                // Tombol batal
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Batal',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    
    if (shouldExit) {
      setState(() {
        _isEditMode = false;
      });
    }
    
    return shouldExit;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _navigateToFeature(String route) {
    if (_isEditMode) return;
    
    setState(() => _isLoading = true);
    
    // Simulate navigation feedback
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.pushNamed(context, route);
      }
    });
  }

  // Header button yang ikut scroll
  Widget _buildHeaderButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SizedBox(
        width: double.infinity,
        child: TextButton.icon(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            backgroundColor: primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          icon: Icon(
            _isEditMode ? CupertinoIcons.refresh : CupertinoIcons.slider_horizontal_3,
            color: Colors.white,
            size: 20,
          ),
          label: Text(
            _isEditMode ? 'Reset Default' : 'Sesuaikan Preferensi Anda',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          onPressed: () {
            if (_isEditMode) {
              // Tampilkan dialog reset
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Text(
                    'Reset Pengaturan',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                  content: Text(
                    'Apakah Anda yakin ingin mengembalikan semua pengaturan fitur ke tampilan awal?',
                    style: GoogleFonts.poppins(),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Batal',
                        style: GoogleFonts.poppins(color: Colors.grey),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _categories = FiturDatabase.getDefaultCategories();
                          _hasChanges = true;
                        });
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Reset',
                        style: GoogleFonts.poppins(color: primaryColor),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              // Masuk ke mode edit
              setState(() => _isEditMode = true);
            }
          },
        ),
      ),
    );
  }

  Widget _buildFeatureSection(CategoryData category, int sectionIndex, {bool forReorderable = false}) {
    // Jika kategori disembunyikan dan bukan dalam mode edit, return widget kosong
    if (category.isHidden && !_isEditMode && !forReorderable) {
      return forReorderable 
        ? const SizedBox.shrink() 
        : SliverToBoxAdapter(child: const SizedBox.shrink());
    }

    // Jika kategori disembunyikan tapi dalam mode edit, tampilkan tile khusus
    if (category.isHidden && _isEditMode) {
      Widget hiddenCategoryTile = _buildHiddenCategoryTile(category, sectionIndex);
      return forReorderable 
        ? hiddenCategoryTile 
        : SliverToBoxAdapter(child: hiddenCategoryTile);
    }

    // Hanya tampilkan fitur yang visible
    final visibleItems = category.items.where((item) => !item.isHidden).toList();

    // Jika tidak ada item visible dan bukan mode edit, return widget kosong
    if (visibleItems.isEmpty && !_isEditMode) {
      return forReorderable 
        ? const SizedBox.shrink() 
        : SliverToBoxAdapter(child: const SizedBox.shrink());
    }

    // Widget konten utama
    Widget content = Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 12.0),
            child: _isEditMode 
              ? _buildEditableCategoryHeader(category, sectionIndex)
              : Text(
                  category.title,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  semanticsLabel: 'Bagian ${category.title}',
                ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0),
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 12.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _isEditMode
              ? _buildFeatureGrid(category.items) // Tidak menggunakan grid yang dapat diurutkan
              : _buildFeatureGrid(visibleItems),
          ),
        ],
      ),
    );

    // Return sesuai dengan konteks penggunaan
    return forReorderable 
      ? content 
      : SliverToBoxAdapter(child: content);
  }

  Widget _buildHiddenCategoryTile(CategoryData category, int sectionIndex) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Material(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            category.title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          leading: const Icon(CupertinoIcons.eye_slash, color: Colors.black45),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(CupertinoIcons.eye, color: primaryColor),
                onPressed: () {
                  setState(() {
                    _categories[sectionIndex].isHidden = false;
                    _hasChanges = true;
                  });
                },
                tooltip: 'Tampilkan kategori',
              ),
              ReorderableDragStartListener(
                index: sectionIndex,
                child: const Icon(CupertinoIcons.bars, color: Colors.black38),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableCategoryHeader(CategoryData category, int index) {
    return Row(
      children: [
        Expanded(
          child: Text(
            category.title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
        IconButton(
          icon: Icon(
            category.isHidden ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
            color: category.isHidden ? Colors.grey : primaryColor,
          ),
          onPressed: () {
            setState(() {
              _categories[index].isHidden = !_categories[index].isHidden;
              _hasChanges = true;
            });
          },
          tooltip: category.isHidden ? 'Tampilkan kategori' : 'Sembunyikan kategori',
        ),
        ReorderableDragStartListener(
          index: index,
          child: const Icon(CupertinoIcons.arrow_up_down, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildFeatureGrid(List<FeatureItem> items) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: constraints.maxWidth > 600 ? 5 : 4,
            childAspectRatio: 0.9,
            crossAxisSpacing: 8,
            mainAxisSpacing: 16,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            return _isEditMode 
                ? _buildEditableFeatureItem(items[index]) 
                : _buildFeatureItem(items[index]);
          },
        );
      },
    );
  }

  Widget _buildFeatureItem(FeatureItem item) {
    return GestureDetector(
      onTap: () => _navigateToFeature('/${item.route}'),
      child: Hero(
        tag: 'feature_${item.route}',
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  splashColor: primaryColor.withOpacity(0.3),
                  highlightColor: primaryColor.withOpacity(0.1),
                  onTap: () => _navigateToFeature('/${item.route}'),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Image.asset(
                      'assets/fitur/${item.imageAsset}.png',
                      width: 36,
                      height: 36,
                      // color: primaryColor,
                      color: const Color(0xFF333333),
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          CupertinoIcons.app_fill,
                          color: primaryColor,
                          size: 36,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.name,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableFeatureItem(FeatureItem item) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Image.asset(
                    'assets/fitur/${item.imageAsset}.png',
                    width: 36,
                    height: 36,
                    // color: primaryColor,
                    color: const Color(0xFF333333),
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        CupertinoIcons.app_fill,
                        color: primaryColor,
                        size: 36,
                      );
                    },
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {
                      setState(() {
                        item.isHidden = !item.isHidden;
                        _hasChanges = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: item.isHidden ? Colors.grey.shade300 : primaryColor.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item.isHidden ? CupertinoIcons.eye_slash : CupertinoIcons.eye,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          item.name,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: item.isHidden ? Colors.black38 : Colors.black87,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildDisclaimerCard() {
  return Card(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    elevation: 3,
    shadowColor: Colors.black.withOpacity(0.05),
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon(
          //   CupertinoIcons.pencil_circle,
          //   color: const Color(0xFF64D1DE).withOpacity(0.8),
          //   size: 28,
          // ),
          // const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text(
                //   'Tutorial Fitur',
                //   style: GoogleFonts.poppins(
                //     fontSize: 16,
                //     fontWeight: FontWeight.w600,
                //     color: const Color(0xFF64D1DE).withOpacity(0.9),
                //   ),
                // ),
                // const SizedBox(height: 6),
                Text(
                  'Tahan dan lepas untuk mengurutkan posisi kategori sesuai preferensi Anda.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    height: 1.5,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isEditMode) {
          return await _confirmExitEditMode();
        }
        // Mengarahkan kembali ke halaman utama ketika tombol kembali ditekan
        Navigator.pushReplacementNamed(context, '/home');
        return false; // Mencegah pop default
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        body: Stack(
          children: [
            Column(
              children: [
                // Content area
                Expanded(
                  child: SafeArea(
                    child: RefreshIndicator(
                      color: primaryColor,
                      onRefresh: _loadData,
                      child: _isEditMode
                        ? _buildEditableLayout()
                        : _buildNormalLayout(),
                    ),
                  ),
                ),
                
                // Bottom bar untuk mode edit dengan tombol simpan dan batal
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: _isEditMode ? 80 : 0,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, -2),
                      )
                    ],
                  ),
                  child: _isEditMode ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              await _confirmExitEditMode();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade200,
                              foregroundColor: Colors.black87,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              textStyle: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            child: const Text('Batalkan'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveData,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              textStyle: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            child: const Text('Simpan'),
                          ),
                        ),
                      ],
                    ),
                  ) : null,
                ),
              ],
            ),
            
            // Loading indicator
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.1),
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNormalLayout() {
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Header button sebagai item pertama yang ikut scroll
        SliverToBoxAdapter(
          child: _buildHeaderButton(),
        ),
        ...List.generate(_categories.length, (index) {
          return _buildFeatureSection(_categories[index], index);
        }),
        SliverToBoxAdapter(
          child: SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ),
      ],
    );
  }

  Widget _buildEditableLayout() {
    return Column(
      children: [
        // Header button ikut scroll sebagai item pertama
        _buildHeaderButton(),
        _buildDisclaimerCard(),
        
        Expanded(
          child: ReorderableListView.builder(
            proxyDecorator: (Widget child, int index, Animation<double> animation) {
              return AnimatedBuilder(
                animation: animation,
                builder: (BuildContext context, Widget? child) {
                  final double animValue = Curves.easeInOut.transform(animation.value);
                  final double elevation = lerpDouble(0, 6, animValue)!;
                  return Material(
                    elevation: elevation,
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: child,
                  );
                },
                child: child,
              );
            },
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (oldIndex < newIndex) {
                  newIndex -= 1;
                }
                final CategoryData item = _categories.removeAt(oldIndex);
                _categories.insert(newIndex, item);
                _hasChanges = true;
              });
            },
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              return Container(
                key: ValueKey(_categories[index].title),
                margin: const EdgeInsets.only(bottom: 16),
                child: _buildFeatureSection(_categories[index], index, forReorderable: true),
              );
            },
            padding: const EdgeInsets.only(bottom: 80), // Tambahkan padding untuk kompensasi bottom bar
          ),
        ),
      ],
    );
  }
}

// Extension method to make lerpDouble available
double? lerpDouble(double a, double b, double t) {
  return a + (b - a) * t;
}