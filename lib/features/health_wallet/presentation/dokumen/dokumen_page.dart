import 'package:primafit/app/router/app_routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
// ignore: unused_import
import 'package:intl/intl.dart';
import 'package:primafit/features/health_wallet/data/database_dokumen.dart';
import 'package:primafit/features/health_wallet/presentation/dokumen/input_dokumen.dart';
import 'package:primafit/features/health_wallet/presentation/dokumen/edit_dokumen.dart';

class DokumenListPage extends StatefulWidget {
  const DokumenListPage({super.key});

  @override
  State<DokumenListPage> createState() => _DokumenListPageState();
}

class _DokumenListPageState extends State<DokumenListPage> with SingleTickerProviderStateMixin {
  final dbHelper = DatabaseDokumenHelper.instance;
  List<Map<String, dynamic>> dokumenList = [];
  Map<int, List<Map<String, dynamic>>> dokumenImages = {}; // Untuk menyimpan gambar-gambar tiap dokumen
  bool isLoading = true;
  bool isSearching = false;
  String searchQuery = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Controller untuk pencarian
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    // Inisialisasi controller animasi
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    // Animasi fade untuk item list
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Animasi slide untuk item list
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    
    // Memuat data Dokumen
    _loadDokumenData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Fungsi untuk memuat data Dokumen dari database
  Future<void> _loadDokumenData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = await dbHelper.getAllDokumen();
      
      // Inisialisasi map untuk gambar dokumen
      final Map<int, List<Map<String, dynamic>>> images = {};
      
      // Untuk setiap dokumen, ambil gambar-gambar terkait
      for (var dokumen in data) {
        final dokumenId = dokumen['id'] as int;
        final gambarList = await dbHelper.getGambarByDokumenId(dokumenId);
        images[dokumenId] = gambarList;
      }

      setState(() {
        dokumenList = data;
        dokumenImages = images;
        isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Error loading data: $e');
    }
  }

  // Fungsi untuk melakukan pencarian data Dokumen
  void _searchDokumen(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
    });
  }

  // Fungsi untuk menampilkan dialog error
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Error',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          message,
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: GoogleFonts.poppins(color: const Color(0xFF64D1DE)),
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk konfirmasi penghapusan data
  Future<void> _confirmDelete(int id, String judul) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Konfirmasi Hapus',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus dokumen $judul?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteDokumen(id);
            },
            child: Text(
              'Hapus',
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk menghapus data Dokumen
  Future<void> _deleteDokumen(int id) async {
    try {
      await dbHelper.deleteDokumen(id);
      
      // Tampilkan animasi sukses hapus
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(CupertinoIcons.check_mark_circled, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                'Dokumen berhasil dihapus',
                style: GoogleFonts.poppins(),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(12),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
      
      // Refresh data
      _loadDokumenData();
    } catch (e) {
      _showErrorDialog('Error deleting data: $e');
    }
  }

  // Fungsi untuk menavigasi ke halaman edit Dokumen
  void _navigateToEditDokumen(int id) async {
    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => EditDokumenPage(dokumenId: id),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          final offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );

    if (result == true) {
      _loadDokumenData();
    }
  }

  // Fungsi untuk menavigasi ke halaman tambah Dokumen
  void _navigateToAddDokumen() async {
    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const InputDokumenPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          final offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );

    if (result == true) {
      _loadDokumenData();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter list berdasarkan pencarian
    final List<Map<String, dynamic>> filteredList = dokumenList.where((dokumen) {
      final judul = dokumen['judul_dokumen'].toString().toLowerCase();
      final jenis = dokumen['jenis_dokumen'].toString().toLowerCase();
      final tanggal = dokumen['tanggal_dokumen'].toString().toLowerCase();
      final klinik = dokumen['nama_klinik'].toString().toLowerCase();
      
      return judul.contains(searchQuery) || 
             jenis.contains(searchQuery) ||
             tanggal.contains(searchQuery) ||
             klinik.contains(searchQuery);
    }).toList();

    return Scaffold(
      appBar: AppBar(
  backgroundColor: const Color(0xFF64D1DE),
  elevation: 0,
  scrolledUnderElevation: 0,
  centerTitle: true,
  title: !isSearching
      ? Text(
          'Dokumen Medis',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        )
      : TextField(
          controller: _searchController,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'Cari dokumen...',
            hintStyle: GoogleFonts.poppins(
              color: Colors.white70,
              fontWeight: FontWeight.w400,
            ),
            border: InputBorder.none,
          ),
          onChanged: _searchDokumen,
          autofocus: true,
        ),
  leading: IconButton(
    icon: AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return ScaleTransition(scale: animation, child: child);
      },
      child: isSearching
          ? const Icon(
              CupertinoIcons.arrow_left,
              key: ValueKey('back'),
              color: Colors.white,
              size: 24,
            )
          : const Icon(
              CupertinoIcons.chevron_back,
              key: ValueKey('menu'),
              color: Colors.white,
              size: 24,
            ),
    ),
    onPressed: () {
      if (isSearching) {
        setState(() {
          isSearching = false;
          searchQuery = '';
          _searchController.clear();
        });
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.allFeatures);
      }
    },
  ),
  actions: [
    IconButton(
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(scale: animation, child: child);
        },
        child: !isSearching
            ? const Icon(
                CupertinoIcons.search,
                key: ValueKey('search'),
                color: Colors.white,
                size: 24,
              )
            : const Icon(
                CupertinoIcons.clear,
                key: ValueKey('clear'),
                color: Colors.white,
                size: 24,
              ),
      ),
      onPressed: () {
        setState(() {
          if (isSearching) {
            isSearching = false;
            searchQuery = '';
            _searchController.clear();
          } else {
            isSearching = true;
          }
        });
      },
    ),
    IconButton(
      icon: const Icon(
        CupertinoIcons.refresh,
        color: Colors.white,
        size: 24,
      ),
      onPressed: _loadDokumenData,
    ),
  ],
  flexibleSpace: Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF64D1DE),
          Color(0xFF59BECA),
        ],
      ),
    ),
  ),
),

      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(
                    color: Color(0xFF64D1DE),
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Memuat data...',
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : filteredList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        searchQuery.isNotEmpty
                            ? CupertinoIcons.search
                            : CupertinoIcons.doc_text_search,
                        size: 70,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        searchQuery.isNotEmpty
                            ? 'Dokumen tidak ditemukan'
                            : 'Belum ada dokumen tersimpan',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                      if (searchQuery.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Coba kata kunci lain',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ),
                    ],
                  ),
                )
              : SafeArea(
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // Header section
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Daftar Dokumen Medis',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF64D1DE).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${filteredList.length} Dokumen',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF64D1DE),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Cards list
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final dokumen = filteredList[index];
                              final dokumenId = dokumen['id'] as int;
                              final gambarList = dokumenImages[dokumenId] ?? [];
                              
                              // Staggered animation for cards
                              // ignore: unused_local_variable
                              final itemAnimation = _animationController.drive(
                                CurveTween(
                                  curve: Interval(
                                    index * 0.05,
                                    0.5 + index * 0.05,
                                    curve: Curves.easeOut,
                                  ),
                                ),
                              );
                              
                              return SlideTransition(
                                position: SlideTransition(
                                  position: _slideAnimation,
                                  child: const SizedBox(),
                                ).position,
                                child: FadeTransition(
                                  opacity: _fadeAnimation.drive(CurveTween(curve: Interval(0, 0.5 + index * 0.1))),
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: DokumenCard(
                                      dokumen: dokumen,
                                      gambarList: gambarList,
                                      onDelete: () => _confirmDelete(dokumen['id'], dokumen['judul_dokumen']),
                                      onEdit: () => _navigateToEditDokumen(dokumen['id']),
                                      onTap: () {
                                        // Animasi ketika card diklik
                                        HapticFeedback.lightImpact();
                                        _navigateToEditDokumen(dokumen['id']);
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                            childCount: filteredList.length,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: () => _navigateToAddDokumen(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF64D1DE),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Tambahkan',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Widget untuk menampilkan kartu Dokumen dengan desain yang modern
class DokumenCard extends StatelessWidget {
  final Map<String, dynamic> dokumen;
  final List<Map<String, dynamic>> gambarList;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onTap;

  const DokumenCard({
    super.key,
    required this.dokumen,
    required this.gambarList,
    required this.onDelete,
    required this.onEdit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Mendapatkan warna berdasarkan jenis dokumen
    Color headerColor;
    IconData headerIcon;
    
    switch(dokumen['jenis_dokumen'].toLowerCase()) {
      case 'laboratorium':
        headerColor = const Color(0xFF4CAF50);
        headerIcon = CupertinoIcons.lab_flask;
        break;
      case 'radiologi':
        headerColor = const Color(0xFFE91E63);
        headerIcon = CupertinoIcons.radiowaves_right;
        break;
      case 'resep':
        headerColor = const Color(0xFFFF9800);
        headerIcon = CupertinoIcons.doc_text;
        break;
      default:
        headerColor = const Color(0xFF64D1DE);
        headerIcon = CupertinoIcons.doc_chart;
    }
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header badge
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: headerColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          headerIcon,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          dokumen['jenis_dokumen'],
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      dokumen['tanggal_dokumen'],
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Foto dokumen jika ada
              if (gambarList.isNotEmpty)
                SizedBox(
                  height: 180,
                  child: Stack(
                    children: [
                      // Gallery images
                      PageView.builder(
                        itemCount: gambarList.length,
                        itemBuilder: (context, index) {
                          final Uint8List imageData = gambarList[index]['gambar'];
                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.memory(
                                imageData,
                                fit: BoxFit.cover,
                              ),
                              // Overlay gradient
                              Positioned.fill(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: 0.3),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      
                      // Image counter indicator
                      if (gambarList.length > 1)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  CupertinoIcons.photo_on_rectangle,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${gambarList.length} Foto',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      
                      // View button
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: Material(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(20),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              _showGalleryDialog(context, gambarList);
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                CupertinoIcons.eye,
                                color: Color(0xFF64D1DE),
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  height: 100,
                  width: double.infinity,
                  color: const Color(0xFFEEF1FF),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.doc_text,
                        size: 40,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tidak ada foto',
                        style: GoogleFonts.poppins(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              
              // Info section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul dokumen
                    Text(
                      'Judul',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dokumen['judul_dokumen'],
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 16),
                    
                    // Informasi klinik
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Klinik / Rumah Sakit',
                                style: GoogleFonts.poppins(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                dokumen['nama_klinik'],
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (dokumen['hasil'] != null && dokumen['hasil'].toString().isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              // color: _getResultColor(dokumen['hasil']),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              dokumen['hasil'],
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    const Divider(),
                    
                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Edit button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: onEdit,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  const Icon(
                                    CupertinoIcons.pencil,
                                    color: Color(0xFF64D1DE),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Edit',
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFF64D1DE),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Delete button
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: onDelete,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  const Icon(
                                    CupertinoIcons.delete,
                                    color: Colors.red,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Hapus',
                                    style: GoogleFonts.poppins(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fungsi untuk menampilkan galeri gambar
  void _showGalleryDialog(BuildContext context, List<Map<String, dynamic>> images) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 30),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            color: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: const Color(0xFF64D1DE),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Galeri Foto Dokumen',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.white24,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            CupertinoIcons.clear,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Galeri Foto
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: PageView.builder(
                    itemCount: images.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          Expanded(
                            child: InteractiveViewer(
                              minScale: 0.5,
                              maxScale: 3.0,
                              child: Image.memory(
                                images[index]['gambar'],
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Foto ${index + 1} dari ${images.length}',
                              style: GoogleFonts.poppins(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                
                // Footer
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  color: const Color(0xFFF5F5F5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Indicator dots
                      Row(
                        children: List.generate(
                          images.length,
                          (index) => Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index == 0 ? 
                                  const Color(0xFF64D1DE) : 
                                  Colors.grey[300],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}