import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primafit/database/pengingat/database_obat.dart';
import 'package:primafit/UI/pengingat/obat/alarm_service.dart';
import 'package:primafit/UI/pengingat/obat/detail_obat.dart';
import 'package:primafit/UI/pengingat/obat/update_obat.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'dart:async';

class ObatPage extends StatefulWidget {
  const ObatPage({Key? key}) : super(key: key);

  @override
  State<ObatPage> createState() => _ObatPageState();
}

class _ObatPageState extends State<ObatPage> with SingleTickerProviderStateMixin {
  final Color _themeColor = const Color(0xFF64D1DE);
  List<Map<String, dynamic>> _obatList = [];
  List<Map<String, dynamic>> _filteredObatList = [];
  bool _isLoading = true;
  bool _isSearching = false;
  late AnimationController _animationController;
  final _refreshKey = GlobalKey<RefreshIndicatorState>();
  final TextEditingController _searchController = TextEditingController();
  
  // Sorting options
  String _currentSortField = 'nama';
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _searchController.addListener(_filterObatList);
    
    _refreshObatList();
    
    // Check and update alarms when the page loads
    _checkAndUpdateAlarms();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _searchController.removeListener(_filterObatList);
    _searchController.dispose();
    super.dispose();
  }

  // Check and update all medication alarms
  Future<void> _checkAndUpdateAlarms() async {
    try {
      await AlarmService.instance.checkAndUpdateAlarms();
    } catch (e) {
      print('Error checking alarms: $e');
    }
  }

  // Filter the obat list based on search query
  void _filterObatList() {
    final query = _searchController.text.toLowerCase();
    
    setState(() {
      if (query.isEmpty) {
        _filteredObatList = List.from(_obatList);
      } else {
        _filteredObatList = _obatList.where((obat) {
          final namaLower = obat['nama'].toString().toLowerCase();
          final jenisLower = obat['jenis'].toString().toLowerCase();
          final dosisLower = obat['dosis'].toString().toLowerCase();
          final deskripsiLower = (obat['deskripsi'] ?? '').toString().toLowerCase();
          
          return namaLower.contains(query) || 
                 jenisLower.contains(query) ||
                 dosisLower.contains(query) ||
                 deskripsiLower.contains(query);
        }).toList();
      }
      
      // Apply the current sort to filtered list
      _applySorting();
    });
  }

  // Apply sorting to the filtered list
  void _applySorting() {
    _filteredObatList.sort((a, b) {
      dynamic valueA = a[_currentSortField] ?? '';
      dynamic valueB = b[_currentSortField] ?? '';
      
      // Handle numeric sorting for stok
      if (_currentSortField == 'stok') {
        valueA = int.tryParse(valueA.toString()) ?? 0;
        valueB = int.tryParse(valueB.toString()) ?? 0;
      }
      
      // Compare values
      int result;
      if (valueA is String && valueB is String) {
        result = valueA.toLowerCase().compareTo(valueB.toLowerCase());
      } else {
        result = valueA.compareTo(valueB);
      }
      
      // Apply sort direction
      return _sortAscending ? result : -result;
    });
  }

  // Show sort options menu
  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Urutkan Berdasarkan',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        _sortAscending 
                            ? CupertinoIcons.sort_up
                            : CupertinoIcons.sort_down,
                        color: _themeColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _sortAscending = !_sortAscending;
                          _applySorting();
                        });
                        Navigator.pop(context);
                      },
                      tooltip: _sortAscending ? 'Urutkan Naik' : 'Urutkan Turun',
                    ),
                  ],
                ),
              ),
              _buildSortOption('Nama Obat', 'nama'),
              _buildSortOption('Jenis', 'jenis'),
              _buildSortOption('Stok', 'stok'),
              _buildSortOption('Frekuensi', 'frekuensi_harian'),
            ],
          ),
        );
      },
    );
  }

  // Build sort option item
  Widget _buildSortOption(String label, String field) {
    return ListTile(
      title: Text(
        label,
        style: GoogleFonts.poppins(
          color: _currentSortField == field ? _themeColor : Colors.black87,
          fontWeight: _currentSortField == field ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      leading: Radio<String>(
        value: field,
        groupValue: _currentSortField,
        activeColor: _themeColor,
        onChanged: (value) {
          if (value != null) {
            setState(() {
              _currentSortField = value;
              _applySorting();
            });
            Navigator.pop(context);
          }
        },
      ),
      onTap: () {
        setState(() {
          _currentSortField = field;
          _applySorting();
        });
        Navigator.pop(context);
      },
    );
  }

  // Toggle search mode
  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
      }
    });
  }

  // Metode untuk refresh data obat
  Future<void> _refreshObatList() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await DatabaseObatHelper.instance.getAllObat();
      setState(() {
        _obatList = data;
        _filteredObatList = List.from(data); // Copy the list
        _applySorting(); // Apply current sort
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Gagal memuat data: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'TUTUP',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  String _getTruncatedText(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.doc_text_search,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            _isSearching 
                ? 'Tidak ada hasil pencarian'
                : 'Tidak ada data obat',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isSearching
                ? 'Coba dengan kata kunci lain'
                : 'Tambahkan obat baru untuk memulai',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          if (!_isSearching)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/input_obat').then((_) {
                  _refreshObatList();
                });
              },
              icon: const Icon(CupertinoIcons.add),
              label: Text(
                'Tambah Obat Baru',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _themeColor,
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

  Widget _buildStockIndicator(String stock) {
    final stockNum = int.tryParse(stock) ?? 0;
    
    Color bgColor;
    Color textColor;
    
    if (stockNum <= 0) {
      bgColor = Colors.red[100]!;
      textColor = Colors.red[700]!;
    } else if (stockNum <= 5) {
      bgColor = Colors.amber[100]!;
      textColor = Colors.amber[800]!;
    } else {
      bgColor = _themeColor.withOpacity(0.1);
      textColor = _themeColor;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Stok: $stock',
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildObatCard(Map<String, dynamic> obat, int index) {
    // Memanfaatkan animasi untuk item card
    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 375),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 3,
            shadowColor: _themeColor.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailObat(obatId: obat['id']),
                  ),
                ).then((_) => _refreshObatList());
              },
              borderRadius: BorderRadius.circular(16),
              splashColor: _themeColor.withOpacity(0.1),
              highlightColor: _themeColor.withOpacity(0.05),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Hero(
                                tag: 'medicine_icon_${obat['id']}',
                                child: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: _themeColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Center(
                                    child: Icon(
                                      _getObatIcon(obat['jenis'] ?? ''),
                                      color: _themeColor,
                                      size: 28,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      obat['nama'] ?? 'Tidak ada nama',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Dosis: ${obat['dosis'] ?? '-'}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildStockIndicator(obat['stok'] ?? '0'),
                            const SizedBox(height: 8),
                            Text(
                              'Freq: ${obat['frekuensi_harian'] ?? '-'}/hari',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            _getTruncatedText(obat['deskripsi'] ?? 'Tidak ada deskripsi', 50),
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(CupertinoIcons.pencil),
                              color: Colors.amber[700],
                              tooltip: 'Edit',
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => UpdateObatScreen(obatId: obat['id']),
                                  ),
                                ).then((_) => _refreshObatList());
                              },
                            ),
                            IconButton(
                              icon: const Icon(CupertinoIcons.delete),
                              color: Colors.red[700],
                              tooltip: 'Hapus',
                              onPressed: () {
                                _showDeleteConfirmationDialog(obat);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getObatIcon(String jenis) {
    switch (jenis.toLowerCase()) {
      case 'tablet':
        return CupertinoIcons.capsule_fill;
      case 'sirup':
        return CupertinoIcons.drop_fill;
      case 'kapsul':
        return CupertinoIcons.capsule;
      case 'oral':
        return CupertinoIcons.capsule;
      case 'salep':
        return CupertinoIcons.bandage_fill;
      case 'tetes':
        return CupertinoIcons.eyedropper;
      case 'injeksi':
        return CupertinoIcons.waveform_path;
      case 'topikal':
        return CupertinoIcons.bandage_fill;
      case 'krim':
        return CupertinoIcons.bandage_fill;
      default:
        return CupertinoIcons.doc_chart;
    }
  }

  void _showObatDetailDialog(Map<String, dynamic> obat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          obat['nama'] ?? 'Detail Obat',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow('Jenis', obat['jenis'] ?? '-'),
                _buildDetailRow('Dosis', obat['dosis'] ?? '-'),
                _buildDetailRow('Stok', obat['stok'] ?? '-'),
                _buildDetailRow('Frekuensi', '${obat['frekuensi_harian']} kali sehari'),
                _buildDetailRow('Instruksi', obat['instruksi'] ?? '-'),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
                Text(
                  'Deskripsi:',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  obat['deskripsi'] ?? 'Tidak ada deskripsi',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(CupertinoIcons.bell, color: Colors.amber),
                    const SizedBox(width: 8),
                    Text(
                      'Nada Alarm: ${obat['nada'] ?? 'Default'}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Tutup',
              style: GoogleFonts.poppins(
                color: Colors.grey[700],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailObat(obatId: obat['id']),
                ),
              ).then((_) => _refreshObatList());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _themeColor,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Lihat Detail',
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(Map<String, dynamic> obat) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Konfirmasi Hapus',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus obat "${obat['nama']}"? Semua jadwal alarm terkait juga akan terhapus.',
          style: GoogleFonts.poppins(),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(
                color: Colors.grey[700],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _deleteObat(obat['id']);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[700],
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Hapus',
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteObat(int obatId) async {
    try {
      // Cancel alarms first
      await AlarmService.instance.cancelAlarmsForObat(obatId);
      
      // Then delete the medication
      await DatabaseObatHelper.instance.deleteObat(obatId);
      
      // Display success notification
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Obat berhasil dihapus',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green[700],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      
      // Refresh data
      _refreshObatList();
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Gagal menghapus obat: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _isSearching
          ? AppBar(
              elevation: 0,
              backgroundColor: _themeColor,
              title: TextField(
                controller: _searchController,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                ),
                cursorColor: Colors.white,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Cari obat...',
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.8),
                  ),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(CupertinoIcons.clear, color: Colors.white),
                    onPressed: () {
                      _searchController.clear();
                    },
                  ),
                ),
              ),
              leading: IconButton(
                icon: const Icon(CupertinoIcons.back, color: Colors.white),
                onPressed: _toggleSearch,
              ),
            )
          : AppBar(
              elevation: 0,
              backgroundColor: _themeColor,
              title: Text(
                'Daftar Obat',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(CupertinoIcons.search),
                  onPressed: _toggleSearch,
                  tooltip: 'Cari obat',
                ),
                IconButton(
                  icon: const Icon(CupertinoIcons.sort_down),
                  onPressed: _showSortOptions,
                  tooltip: 'Urutkan',
                ),
              ],
            ),
      body: RefreshIndicator(
        key: _refreshKey,
        color: _themeColor,
        onRefresh: _refreshObatList,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF64D1DE),
                ),
              )
            : _filteredObatList.isEmpty
                ? _buildEmptyState()
                : AnimationLimiter(
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(top: 16, bottom: 88),
                      itemCount: _filteredObatList.length,
                      itemBuilder: (context, index) {
                        return _buildObatCard(_filteredObatList[index], index);
                      },
                    ),
                  ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _themeColor,
        foregroundColor: Colors.white,
        elevation: 4,
        onPressed: () {
          Navigator.pushNamed(context, '/input_obat').then((_) {
            _refreshObatList();
          });
        },
        child: const Icon(CupertinoIcons.add),
        tooltip: 'Tambah Obat Baru',
      ),
    );
  }
}