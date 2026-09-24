import 'package:primafit/app/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:primafit/features/health_record/data/database_tensi.dart';
import 'package:primafit/features/health_record/presentation/tensi/update_tensi.dart';
import 'package:primafit/features/health_record/presentation/tensi/input_tensi.dart';

class ReadTensiScreen extends StatefulWidget {
  const ReadTensiScreen({super.key});

  @override
  State<ReadTensiScreen> createState() => _ReadTensiScreenState();
}

class _ReadTensiScreenState extends State<ReadTensiScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  List<TekananDarah> _tensiData = [];
   // Simpan data profil pengguna
  bool _isLoading = true;
  bool _isDeleting = false;
  bool _showInfoPanel = false; // Toggle untuk panel informasi
  
  // State untuk sorting
  bool _sortByDate = true; // Default sort by date
  bool _sortAscending = false; // Default descending (baru ke lama)
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    _loadData();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Load tekanan darah data
      final data = await TekananDarahDatabaseHelper.instance.getAllTekananDarah();
      
      
      setState(() {
        _tensiData = data;
        _isLoading = false;
        
        // Sort data setelah loading
        _sortData();
      });
      _animationController.forward();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
  
  // Function untuk sorting data
  void _sortData() {
    if (_sortByDate) {
      // Sort berdasarkan tanggal
      _tensiData.sort((a, b) {
        final DateTime dateA = DateFormat('yyyy-MM-dd').parse(a.tanggal);
        final DateTime dateB = DateFormat('yyyy-MM-dd').parse(b.tanggal);
        
        if (_sortAscending) {
          return dateA.compareTo(dateB);
        } else {
          return dateB.compareTo(dateA);
        }
      });
    } else {
      // Sort berdasarkan nilai tensi (sistolik)
      _tensiData.sort((a, b) {
        final double valueA = double.tryParse(a.sistolik) ?? 0;
        final double valueB = double.tryParse(b.sistolik) ?? 0;
        
        if (_sortAscending) {
          return valueA.compareTo(valueB);
        } else {
          return valueB.compareTo(valueA);
        }
      });
    }
  }
  
  // Fungsi untuk mengubah mode sorting
  void _toggleSortMode() {
    setState(() {
      _sortByDate = !_sortByDate;
      _sortData();
    });
    
    // Tampilkan snackbar informasi
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_sortByDate 
          ? 'Mengurutkan berdasarkan tanggal'
          : 'Mengurutkan berdasarkan nilai tekanan darah'
        ),
        backgroundColor: const Color(0xFF64D1DE),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }
  
  // Fungsi untuk mengubah arah sorting
  void _toggleSortDirection() {
    setState(() {
      _sortAscending = !_sortAscending;
      _sortData();
    });
    
    // Tampilkan snackbar informasi
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_sortAscending 
          ? 'Urutan naik' 
          : 'Urutan menurun'
        ),
        backgroundColor: const Color(0xFF64D1DE),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }
  
  // Toggle info panel
  void _toggleInfoPanel() {
    setState(() {
      _showInfoPanel = !_showInfoPanel;
    });
  }
  
  
  // Fungsi untuk menentukan status tekanan darah
  Map<String, dynamic> _getTekananDarahStatus(int sistolik, int diastolik) {
    // Kategori berdasarkan American Heart Association (AHA)
    if (sistolik < 120 && diastolik < 80) {
      return {
        'status': 'Normal',
        'color': Colors.green.shade800,
        'bgColor': Colors.green.shade50,
        'range': 'Sistolik < 120 mmHg dan Diastolik < 80 mmHg'
      };
    } else if ((sistolik >= 120 && sistolik <= 129) && diastolik < 80) {
      return {
        'status': 'Elevated',
        'color': Colors.blue.shade800,
        'bgColor': Colors.blue.shade50,
        'range': 'Sistolik 120-129 mmHg dan Diastolik < 80 mmHg'
      };
    } else if ((sistolik >= 130 && sistolik <= 139) || (diastolik >= 80 && diastolik <= 89)) {
      return {
        'status': 'Hipertensi Stage 1',
        'color': Colors.amber.shade800,
        'bgColor': Colors.amber.shade50,
        'range': 'Sistolik 130-139 mmHg atau Diastolik 80-89 mmHg'
      };
    } else if (sistolik >= 140 || diastolik >= 90) {
      return {
        'status': 'Hipertensi Stage 2',
        'color': Colors.orange.shade800,
        'bgColor': Colors.orange.shade50,
        'range': 'Sistolik ≥ 140 mmHg atau Diastolik ≥ 90 mmHg'
      };
    } else if (sistolik > 180 || diastolik > 120) {
      return {
        'status': 'Krisis Hipertensi',
        'color': Colors.red.shade800,
        'bgColor': Colors.red.shade50,
        'range': 'Sistolik > 180 mmHg atau Diastolik > 120 mmHg'
      };
    }
    
    // Default jika tidak masuk kategori di atas
    return {
      'status': 'Normal',
      'color': Colors.green.shade800,
      'bgColor': Colors.green.shade50,
      'range': 'Sistolik < 120 mmHg dan Diastolik < 80 mmHg'
    };
  }
  
  Future<void> _deleteItem(int id) async {
    setState(() {
      _isDeleting = true;
    });
    
    try {
      await TekananDarahDatabaseHelper.instance.deleteTekananDarah(id);
      await _loadData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data berhasil dihapus'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }
  
  Future<void> _confirmDelete(int id) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Konfirmasi Hapus',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus data ini?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(
                color: Colors.grey.shade700,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteItem(id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Hapus',
              style: GoogleFonts.poppins(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _refreshData() async {
    await _loadData();
  }
  
  Future<void> _navigateToAdd() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const InputTensiScreen()),
    );
    
    if (result == true) {
      _loadData();
    }
  }
  
  Future<void> _navigateToEdit(int id) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UpdateTensiScreen(TensiId: id)),
    );
    
    if (result == true) {
      _loadData();
    }
  }
  
  // Widget untuk menampilkan panel informasi nilai normal tekanan darah
  Widget _buildInfoPanel() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      color: const Color(0xFFE3F7F9),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  CupertinoIcons.info_circle_fill,
                  color: Color(0xFF64D1DE),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Kategori Tekanan Darah',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildRangeText('Normal', 'Sistolik < 120 mmHg dan Diastolik < 80 mmHg', Colors.green.shade700),
            const SizedBox(height: 8),
            _buildRangeText('Elevated', 'Sistolik 120-129 mmHg dan Diastolik < 80 mmHg', Colors.blue.shade700),
            const SizedBox(height: 8),
            _buildRangeText('Hipertensi Stage 1', 'Sistolik 130-139 mmHg atau Diastolik 80-89 mmHg', Colors.amber.shade700),
            const SizedBox(height: 8),
            _buildRangeText('Hipertensi Stage 2', 'Sistolik ≥ 140 mmHg atau Diastolik ≥ 90 mmHg', Colors.orange.shade700),
            const SizedBox(height: 8),
            _buildRangeText('Krisis Hipertensi', 'Sistolik > 180 mmHg atau Diastolik > 120 mmHg', Colors.red.shade700),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Catatan Penting:',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tekanan darah tinggi dapat meningkatkan risiko penyakit jantung, stroke, dan gagal ginjal. Konsultasikan dengan dokter jika tekanan darah Anda tinggi secara konsisten.',
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade700,
                      fontSize: 11,
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
  
  // Widget helper untuk teks rentang normal
  Widget _buildRangeText(String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 12,
          height: 12,
          margin: const EdgeInsets.only(top: 3),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(
        'Riwayat Tekanan Darah',
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: const Color(0xFF64D1DE),
      foregroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(CupertinoIcons.back, color: Colors.white),
        tooltip: 'Kembali',
        onPressed: () {
          Navigator.pushReplacementNamed(context, AppRoutes.analytics);
        },
      ),
      actions: [
        // Toggle untuk menampilkan panel info
        IconButton(
          icon: Icon(_showInfoPanel ? CupertinoIcons.info_circle_fill : CupertinoIcons.info_circle),
          onPressed: _toggleInfoPanel,
          tooltip: 'Informasi Kategori Tekanan Darah',
        ),
        // Menu untuk sorting
        PopupMenuButton(
          icon: const Icon(CupertinoIcons.sort_down),
          tooltip: 'Urutkan',
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          onSelected: (value) {
            if (value == 'sort_mode') {
              _toggleSortMode();
            } else if (value == 'sort_direction') {
              _toggleSortDirection();
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'sort_mode',
              child: Row(
                children: [
                  Icon(
                    _sortByDate ? CupertinoIcons.number : CupertinoIcons.calendar,
                    color: const Color(0xFF64D1DE),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _sortByDate 
                        ? 'Urutkan berdasarkan nilai' 
                        : 'Urutkan berdasarkan tanggal',
                    style: GoogleFonts.poppins(),
                  ),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'sort_direction',
              child: Row(
                children: [
                  Icon(
                    _sortAscending ? CupertinoIcons.arrow_up : CupertinoIcons.arrow_down,
                    color: const Color(0xFF64D1DE),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _sortAscending ? 'Urutkan menurun' : 'Urutkan naik',
                    style: GoogleFonts.poppins(),
                  ),
                ],
              ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(CupertinoIcons.refresh),
          onPressed: _isLoading ? null : _refreshData,
          tooltip: 'Refresh',
        ),
      ],
    ),
    body: _isLoading
        ? const Center(
            child: CircularProgressIndicator(
              color: Color(0xFF64D1DE),
            ),
          )
        : _tensiData.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      CupertinoIcons.heart_circle,
                      size: 70,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada data tekanan darah',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tambahkan data baru dengan menekan tombol di bawah',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            : FadeTransition(
                opacity: _fadeAnimation,
                child: RefreshIndicator(
                  onRefresh: _refreshData,
                  color: const Color(0xFF64D1DE),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        // Panel informasi ditampilkan di atas jika aktif
                        if (_showInfoPanel) ...[
                          _buildInfoPanel(),
                          const SizedBox(height: 8),
                        ],
                        
                        // Label informasi sorting aktif
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                          child: Row(
                            children: [
                              Icon(
                                _sortByDate ? CupertinoIcons.calendar : CupertinoIcons.chart_bar,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _sortByDate 
                                    ? 'Diurutkan berdasarkan tanggal' 
                                    : 'Diurutkan berdasarkan nilai tekanan darah',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                _sortAscending ? CupertinoIcons.arrow_up : CupertinoIcons.arrow_down,
                                size: 14,
                                color: Colors.grey.shade600,
                              ),
                            ],
                          ),
                        ),
                        
                        // List data tekanan darah
                        Expanded(
                          child: ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: _tensiData.length,
                            itemBuilder: (context, index) {
                              final item = _tensiData[index];
                              // Parse tanggal to display formatted
                              final DateTime date = DateFormat('yyyy-MM-dd').parse(item.tanggal);
                              final String formattedDate = DateFormat('dd MMM yyyy').format(date);
                              
                              // Parse nilai tekanan darah
                              final int sistolik = int.tryParse(item.sistolik) ?? 0;
                              final int diastolik = int.tryParse(item.diastolik) ?? 0;
                              
                              // Determine status and colors
                              final status = _getTekananDarahStatus(sistolik, diastolik);
                              final Color cardColor = status['bgColor'];
                              final Color textColor = status['color'];
                              final String statusText = status['status'];
                              
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Card(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                  color: cardColor,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () => _navigateToEdit(item.id!),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    CupertinoIcons.calendar,
                                                    size: 18,
                                                    color: Colors.grey.shade700,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    formattedDate,
                                                    style: GoogleFonts.poppins(
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.grey.shade700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Icon(
                                                    CupertinoIcons.clock,
                                                    size: 18,
                                                    color: Colors.grey.shade700,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    item.waktu,
                                                    style: GoogleFonts.poppins(
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.grey.shade700,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              PopupMenuButton(
                                                icon: Icon(
                                                  Icons.more_vert,
                                                  color: Colors.grey.shade700,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                itemBuilder: (context) => [
                                                  PopupMenuItem(
                                                    value: 'edit',
                                                    child: Row(
                                                      children: [
                                                        const Icon(
                                                          CupertinoIcons.pencil,
                                                          color: Color(0xFF64D1DE),
                                                          size: 18,
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Text(
                                                          'Edit',
                                                          style: GoogleFonts.poppins(),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  PopupMenuItem(
                                                    value: 'delete',
                                                    child: Row(
                                                      children: [
                                                        const Icon(
                                                          CupertinoIcons.delete,
                                                          color: Colors.red,
                                                          size: 18,
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Text(
                                                          'Hapus',
                                                          style: GoogleFonts.poppins(),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                                onSelected: (value) {
                                                  if (value == 'edit') {
                                                    _navigateToEdit(item.id!);
                                                  } else if (value == 'delete') {
                                                    _confirmDelete(item.id!);
                                                  }
                                                },
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Icon(
                                                          CupertinoIcons.arrow_up_circle,
                                                          size: 20,
                                                          color: textColor,
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              'Sistolik',
                                                              style: GoogleFonts.poppins(
                                                                fontSize: 14,
                                                                color: Colors.grey.shade700,
                                                              ),
                                                            ),
                                                            Text(
                                                              '${item.sistolik} mmHg',
                                                              style: GoogleFonts.poppins(
                                                                fontSize: 20,
                                                                fontWeight: FontWeight.w600,
                                                                color: textColor,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Row(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Icon(
                                                          CupertinoIcons.arrow_down_circle,
                                                          size: 20,
                                                          color: textColor,
                                                        ),
                                                        const SizedBox(width: 8),
                                                        Column(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              'Diastolik',
                                                              style: GoogleFonts.poppins(
                                                                fontSize: 14,
                                                                color: Colors.grey.shade700,
                                                              ),
                                                            ),
                                                            Text(
                                                              '${item.diastolik} mmHg',
                                                              style: GoogleFonts.poppins(
                                                                fontSize: 20,
                                                                fontWeight: FontWeight.w600,
                                                                color: textColor,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Column(
                                                children: [
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: textColor.withValues(alpha: 0.2),
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                    child: Text(
                                                      statusText,
                                                      style: GoogleFonts.poppins(
                                                        fontWeight: FontWeight.w500,
                                                        color: textColor,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 8),
                                                  // Container(
                                                  //   padding: const EdgeInsets.all(8),
                                                  //   decoration: BoxDecoration(
                                                  //     color: Colors.white.withOpacity(0.5),
                                                  //     borderRadius: BorderRadius.circular(10),
                                                  //     border: Border.all(color: Colors.grey.shade200),
                                                  //   ),
                                                  //   child: Icon(
                                                  //     CupertinoIcons.heart_fill,
                                                  //     color: textColor,
                                                  //     size: 24,
                                                  //   ),
                                                  // ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          if (item.catatan.isNotEmpty) ...[
                                            const SizedBox(height: 12),
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withValues(alpha: 0.5),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Catatan:',
                                                    style: GoogleFonts.poppins(
                                                      fontWeight: FontWeight.w500,
                                                      color: Colors.grey.shade700,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    item.catatan,
                                                    style: GoogleFonts.poppins(
                                                      color: Colors.grey.shade800,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    floatingActionButton: FloatingActionButton(
      onPressed: _navigateToAdd,
      backgroundColor: const Color(0xFF64D1DE),
      elevation: 4,
      child: const Icon(
        Icons.add,
        size: 32,
        color: Colors.white,
      ),
    ),

    // Show loading overlay when deleting
    bottomSheet: _isDeleting
        ? Container(
            width: double.infinity,
            height: 40,
            color: const Color(0xFF64D1DE),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Menghapus data...',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          )
        : null,
  );
  }
}