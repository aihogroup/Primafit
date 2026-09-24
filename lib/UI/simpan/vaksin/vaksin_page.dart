import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
// ignore: unused_import
import 'package:intl/intl.dart';
import 'package:primafit/database/simpan/database_vaksin.dart';
import 'package:primafit/UI/simpan/vaksin/input_vaksin.dart';
import 'package:primafit/UI/simpan/vaksin/edit_vaksin.dart';

class VaksinListPage extends StatefulWidget {
  const VaksinListPage({Key? key}) : super(key: key);

  @override
  State<VaksinListPage> createState() => _VaksinListPageState();
}

class _VaksinListPageState extends State<VaksinListPage> with SingleTickerProviderStateMixin {
  final dbHelper = DatabaseVaksinHelper.instance;
  List<Map<String, dynamic>> vaksinList = [];
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
    
    // Memuat data Vaksin
    _loadVaksinData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Fungsi untuk memuat data Vaksin dari database
  Future<void> _loadVaksinData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = await dbHelper.getAllVaksin();
      setState(() {
        vaksinList = data;
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

  // Fungsi untuk melakukan pencarian data Vaksin
  void _searchVaksin(String query) {
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
  Future<void> _confirmDelete(int id, String nama) async {
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
          'Apakah Anda yakin ingin menghapus data vaksin untuk $nama?',
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
              _deleteVaksin(id);
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

  // Fungsi untuk menghapus data Vaksin
  Future<void> _deleteVaksin(int id) async {
    try {
      await dbHelper.deleteVaksin(id);
      
      // Tampilkan animasi sukses hapus
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(CupertinoIcons.check_mark_circled, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                'Data vaksin berhasil dihapus',
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
      _loadVaksinData();
    } catch (e) {
      _showErrorDialog('Error deleting data: $e');
    }
  }

  // Fungsi untuk menavigasi ke halaman edit Vaksin
  void _navigateToEditVaksin(int id) async {
    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => EditVaksinPage(vaksinId: id),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );

    if (result == true) {
      _loadVaksinData();
    }
  }

  // Fungsi untuk menavigasi ke halaman tambah Vaksin
  void _navigateToAddVaksin() async {
    final result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const InputVaksinPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );

    if (result == true) {
      _loadVaksinData();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter list berdasarkan pencarian
    List<Map<String, dynamic>> filteredList = vaksinList.where((vaksin) {
      final nama = vaksin['nama_vaksin'].toString().toLowerCase();
      final nomor = vaksin['nomor_vaksin'].toString().toLowerCase();
      final tanggal = vaksin['tanggal_vaksin'].toString().toLowerCase();
      
      return nama.contains(searchQuery) || 
             nomor.contains(searchQuery) ||
             tanggal.contains(searchQuery);
    }).toList();

    return Scaffold(
      appBar: AppBar(
  backgroundColor: const Color(0xFF64D1DE),
  elevation: 0,
  scrolledUnderElevation: 0,
  centerTitle: true,
  title: !isSearching
      ? Text(
          'Data Vaksin',
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
            hintText: 'Cari vaksin...',
            hintStyle: GoogleFonts.poppins(
              color: Colors.white70,
              fontWeight: FontWeight.w400,
            ),
            border: InputBorder.none,
          ),
          onChanged: _searchVaksin,
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
        Navigator.pushReplacementNamed(context, '/semua');
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
      onPressed: _loadVaksinData,
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
                            ? 'Data vaksin tidak ditemukan'
                            : 'Belum ada kartu vaksin tersimpan',
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
                                'Daftar Kartu Vaksin',
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF64D1DE).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${filteredList.length} Kartu',
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
                              final vaksin = filteredList[index];
                              Uint8List? fotoBytes;
                              if (vaksin['foto'] != null) {
                                fotoBytes = vaksin['foto'];
                              }
                              
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
                                    child: VaksinCard(
                                      vaksin: vaksin,
                                      fotoBytes: fotoBytes,
                                      onDelete: () => _confirmDelete(vaksin['id'], vaksin['nama_vaksin']),
                                      onEdit: () => _navigateToEditVaksin(vaksin['id']),
                                      onTap: () {
                                        // Animasi ketika card diklik
                                        HapticFeedback.lightImpact();
                                        _navigateToEditVaksin(vaksin['id']);
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
              onPressed: () => _navigateToAddVaksin(),
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

// Widget untuk menampilkan kartu Vaksin dengan desain yang lebih modern
class VaksinCard extends StatelessWidget {
  final Map<String, dynamic> vaksin;
  final Uint8List? fotoBytes;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onTap;

  const VaksinCard({
    Key? key,
    required this.vaksin,
    this.fotoBytes,
    required this.onDelete,
    required this.onEdit,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
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
                decoration: const BoxDecoration(
                  color: Color(0xFF64D1DE),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          CupertinoIcons.bandage,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Kartu Vaksin',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      vaksin['tanggal_vaksin'],
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Foto kartu Vaksin
              if (fotoBytes != null)
                Stack(
                  children: [
                    Image.memory(
                      fotoBytes!,
                      height: 180,
                      width: double.infinity,
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
                              Colors.black.withOpacity(0.3),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // View button
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Material(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(16),
                                          child: Image.memory(
                                            fotoBytes!,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          top: 10,
                                          right: 10,
                                          child: GestureDetector(
                                            onTap: () => Navigator.pop(context),
                                            child: Container(
                                              padding: const EdgeInsets.all(6),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.8),
                                                shape: BoxShape.circle,
                                              ),
                                              child: const Icon(
                                                CupertinoIcons.clear,
                                                color: Colors.black,
                                                size: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
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
                        CupertinoIcons.bandage,
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
                    // Nomor Vaksin dengan format
                    Text(
                      'Nomor Vaksin',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatNomorVaksin(vaksin['nomor_vaksin']),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Nama vaksin
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nama Vaksin',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          vaksin['nama_vaksin'],
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
  
  // Format nomor Vaksin untuk tampilan lebih baik
  String _formatNomorVaksin(String nomor) {
    if (nomor.length < 8) return nomor;
    
    // Format: XXXX XXXX XXXX
    final formattedNomor = StringBuffer();
    for (int i = 0; i < nomor.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formattedNomor.write(' ');
      }
      formattedNomor.write(nomor[i]);
    }
    
    return formattedNomor.toString();
  }
}