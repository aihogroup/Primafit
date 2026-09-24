import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:primafit/database/catat/database_kolesterol.dart';
import 'package:primafit/database/navigasi/database_profile.dart';
import 'package:primafit/UI/catat/kolesterol/update_kolesterol.dart';
import 'package:primafit/UI/catat/kolesterol/input_kolesterol.dart';

class ReadKolesterolScreen extends StatefulWidget {
  const ReadKolesterolScreen({Key? key}) : super(key: key);

  @override
  State<ReadKolesterolScreen> createState() => _ReadKolesterolScreenState();
}

class _ReadKolesterolScreenState extends State<ReadKolesterolScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  List<Kolesterol> _kolesterolData = [];
  Map<String, dynamic>? _userProfile; // Simpan data profil pengguna
  bool _isLoading = true;
  bool _isDeleting = false;
  bool _showInfoPanel = false; // Toggle untuk panel informasi
  bool _showAsMgdL = true; // Toggle untuk tampilan satuan (mg/dL atau mmol/L)
  
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
      // Load kolesterol data
      final data = await KolesterolDatabaseHelper.instance.getAllKolesterol();
      
      // Load user profile data
      final profiles = await ProfileDatabaseHelper().getProfiles();
      final userProfile = profiles.isNotEmpty ? profiles.first : null;
      
      setState(() {
        _kolesterolData = data;
        _userProfile = userProfile;
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
      _kolesterolData.sort((a, b) {
        final DateTime dateA = DateFormat('yyyy-MM-dd').parse(a.tanggal);
        final DateTime dateB = DateFormat('yyyy-MM-dd').parse(b.tanggal);
        
        if (_sortAscending) {
          return dateA.compareTo(dateB);
        } else {
          return dateB.compareTo(dateA);
        }
      });
    } else {
      // Sort berdasarkan nilai kolesterol
      _kolesterolData.sort((a, b) {
        // Parse hasil sebagai double untuk perbandingan
        final double valueA = double.tryParse(a.hasil) ?? 0.0;
        final double valueB = double.tryParse(b.hasil) ?? 0.0;
        
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
          : 'Mengurutkan berdasarkan kadar kolesterol'
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
  
  // Toggle satuan
  void _toggleSatuan() {
    setState(() {
      _showAsMgdL = !_showAsMgdL;
    });
    
    // Tampilkan snackbar informasi
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_showAsMgdL 
          ? 'Menampilkan dalam mg/dL' 
          : 'Menampilkan dalam mmol/L'
        ),
        backgroundColor: const Color(0xFF64D1DE),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }
  
  // Fungsi untuk menghitung usia berdasarkan tanggal lahir
  int _calculateAge(String birthDateString) {
    try {
      // Parsing dari format dd-MM-yyyy
      final DateTime birthDate = DateFormat('dd-MM-yyyy').parseStrict(birthDateString);
      final DateTime now = DateTime.now();

      int age = now.year - birthDate.year;

      if (now.month < birthDate.month ||
          (now.month == birthDate.month && now.day < birthDate.day)) {
        age--;
      }

      if (age < 0 || age > 120) {
        print('Usia tidak valid: $age');
        return 30;
      }

      return age;
    } catch (e) {
      print('Gagal parsing tanggal lahir: $e');
      return 30;
    }
  }
  
// Fungsi untuk menentukan status kolesterol berdasarkan nilai, usia, dan gender
  Map<String, dynamic> _getKolesterolStatus(double value, {bool inMgdL = true}) {
    double mgdLValue = value;
    if (!inMgdL) {
      // Konversi mmol/L ke mg/dL jika perlu
      mgdLValue = value * 38.67; // Faktor konversi untuk kolesterol
    }
    
    // Default jika profil tidak tersedia
    if (_userProfile == null || _userProfile!['tanggalLahir'] == null || _userProfile!['gender'] == null) {
      // Standar umum tanpa mempertimbangkan usia/gender
      if (mgdLValue < 200) {
        return {
          'status': 'Normal', 
          'color': Colors.green.shade800,
          'bgColor': Colors.green.shade50,
          'range': '< 200 mg/dL'
        };
      } else if (mgdLValue < 240) {
        return {
          'status': 'Borderline', 
          'color': Colors.amber.shade800,
          'bgColor': Colors.amber.shade50,
          'range': '200-239 mg/dL'
        };
      } else {
        return {
          'status': 'Tinggi', 
          'color': Colors.red.shade800,
          'bgColor': Colors.red.shade50,
          'range': '≥ 240 mg/dL'
        };
      }
    }
    
    final int age = _calculateAge(_userProfile!['tanggalLahir']);
    final String gender = _userProfile!['gender'].toLowerCase();
    
    // Standar berdasarkan jurnal kesehatan untuk berbagai usia dan gender
    // Sumber: American Heart Association, European Society of Cardiology
    
    if (gender == 'pria' || gender == 'laki-laki') {
      if (age < 20) {
        // Anak-anak dan remaja pria
        if (mgdLValue < 170) {
          return {
            'status': 'Normal', 
            'color': Colors.green.shade800,
            'bgColor': Colors.green.shade50,
            'range': '< 170 mg/dL'
          };
        } else if (mgdLValue < 200) {
          return {
            'status': 'Borderline', 
            'color': Colors.amber.shade800,
            'bgColor': Colors.amber.shade50,
            'range': '170-199 mg/dL'
          };
        } else {
          return {
            'status': 'Tinggi', 
            'color': Colors.red.shade800,
            'bgColor': Colors.red.shade50,
            'range': '≥ 200 mg/dL'
          };
        }
      } else {
        // Pria dewasa (semua usia)
        if (mgdLValue < 200) {
          return {
            'status': 'Normal', 
            'color': Colors.green.shade800,
            'bgColor': Colors.green.shade50,
            'range': '< 200 mg/dL'
          };
        } else if (mgdLValue < 240) {
          return {
            'status': 'Borderline', 
            'color': Colors.amber.shade800,
            'bgColor': Colors.amber.shade50,
            'range': '200-239 mg/dL'
          };
        } else {
          return {
            'status': 'Tinggi', 
            'color': Colors.red.shade800,
            'bgColor': Colors.red.shade50,
            'range': '≥ 240 mg/dL'
          };
        }
      }
    } else { // Wanita
      if (age < 20) {
        // Anak-anak dan remaja wanita
        if (mgdLValue < 170) {
          return {
            'status': 'Normal', 
            'color': Colors.green.shade800,
            'bgColor': Colors.green.shade50,
            'range': '< 170 mg/dL'
          };
        } else if (mgdLValue < 200) {
          return {
            'status': 'Borderline', 
            'color': Colors.amber.shade800,
            'bgColor': Colors.amber.shade50,
            'range': '170-199 mg/dL'
          };
        } else {
          return {
            'status': 'Tinggi', 
            'color': Colors.red.shade800,
            'bgColor': Colors.red.shade50,
            'range': '≥ 200 mg/dL'
          };
        }
      } else {
        // Wanita dewasa (semua usia)
        if (mgdLValue < 200) {
          return {
            'status': 'Normal', 
            'color': Colors.green.shade800,
            'bgColor': Colors.green.shade50,
            'range': '< 200 mg/dL'
          };
        } else if (mgdLValue < 240) {
          return {
            'status': 'Borderline', 
            'color': Colors.amber.shade800,
            'bgColor': Colors.amber.shade50,
            'range': '200-239 mg/dL'
          };
        } else {
          return {
            'status': 'Tinggi', 
            'color': Colors.red.shade800,
            'bgColor': Colors.red.shade50,
            'range': '≥ 240 mg/dL'
          };
        }
      }
    }
  }
  
  Future<void> _deleteItem(int id) async {
    setState(() {
      _isDeleting = true;
    });
    
    try {
      await KolesterolDatabaseHelper.instance.deleteKolesterol(id);
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
      MaterialPageRoute(builder: (context) => const InputKolesterolScreen()),
    );
    
    if (result == true) {
      _loadData();
    }
  }
  
  Future<void> _navigateToEdit(int id) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UpdateKolesterolScreen(kolesterolId: id)),
    );
    
    if (result == true) {
      _loadData();
    }
  }
  
  // Widget untuk menampilkan panel informasi nilai normal kolesterol
Widget _buildInfoPanel() {
  final int? age = _userProfile != null && _userProfile!['tanggalLahir'] != null
      ? _calculateAge(_userProfile!['tanggalLahir'])
      : null;
  final String? gender =
      _userProfile != null ? _userProfile!['gender']?.toLowerCase() : null;

  List<Widget> _buildNormalRange() {
    if (age != null && age < 20) {
      // Anak-anak dan remaja (laki-laki dan perempuan)
      return [
        _buildNormalRangeText('Normal', _showAsMgdL ? '< 170 mg/dL' : '< 4.4 mmol/L', Colors.green.shade700),
        const SizedBox(height: 4),
        _buildNormalRangeText('Borderline', _showAsMgdL ? '170 - 199 mg/dL' : '4.4 - 5.2 mmol/L', Colors.amber.shade700),
        const SizedBox(height: 4),
        _buildNormalRangeText('Tinggi', _showAsMgdL ? '≥ 200 mg/dL' : '≥ 5.2 mmol/L', Colors.red.shade700),
      ];
    } else {
      // Dewasa (laki-laki dan perempuan)
      return [
        _buildNormalRangeText('Normal', _showAsMgdL ? '< 200 mg/dL' : '< 5.2 mmol/L', Colors.green.shade700),
        const SizedBox(height: 4),
        _buildNormalRangeText('Borderline', _showAsMgdL ? '200 - 239 mg/dL' : '5.2 - 6.2 mmol/L', Colors.amber.shade700),
        const SizedBox(height: 4),
        _buildNormalRangeText('Tinggi', _showAsMgdL ? '≥ 240 mg/dL' : '≥ 6.2 mmol/L', Colors.red.shade700),
      ];
    }
  }

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
                'Nilai Normal Kolesterol',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: _toggleSatuan,
                icon: Icon(
                  CupertinoIcons.arrow_2_circlepath,
                  size: 16,
                  color: const Color(0xFF64D1DE),
                ),
                label: Text(
                  _showAsMgdL ? 'mmol/L' : 'mg/dL',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF64D1DE),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (age != null && gender != null)
            Text(
              gender == 'pria' || gender == 'laki-laki' ? 'Pria, $age tahun' : 'Wanita, $age tahun',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          const SizedBox(height: 12),
          ..._buildNormalRange(),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
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
                  'Kolesterol tinggi dapat meningkatkan risiko penyakit jantung dan stroke. Konsultasikan dengan dokter jika nilai kolesterol Anda tinggi.',
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
  Widget _buildNormalRangeText(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.grey.shade800,
            ),
          ),
        ),
      ],
    );
  }
  
  // Fungsi untuk mengkonversi mg/dL ke mmol/L (untuk output tampilan)
  double _convertMgdLToMmolL(double mgdL) {
    // Faktor konversi: 1 mg/dL = 0.02586 mmol/L
    return mgdL * 0.02586;
  }
  
  // Fungsi untuk mendapatkan nilai dalam satuan yang dipilih
  String _getValueInSelectedUnit(String valueStr) {
    double? value = double.tryParse(valueStr);
    if (value == null) return valueStr;
    
    if (_showAsMgdL) {
      return '${value.toStringAsFixed(1)} mg/dL';
    } else {
      double mmolValue = _convertMgdLToMmolL(value);
      return '${mmolValue.toStringAsFixed(1)} mmol/L';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Riwayat Kolesterol',
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
            Navigator.pushReplacementNamed(context, '/analisis');
          },
        ),
        actions: [
          // Toggle untuk menampilkan panel info
          IconButton(
            icon: Icon(_showInfoPanel ? CupertinoIcons.info_circle_fill : CupertinoIcons.info_circle),
            onPressed: _toggleInfoPanel,
            tooltip: 'Informasi Rentang Normal',
          ),
          // Toggle satuan
          IconButton(
            icon: Text(
              _showAsMgdL ? 'mg/dL' : 'mmol/L',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            onPressed: _toggleSatuan,
            tooltip: 'Ubah Satuan',
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
          : _kolesterolData.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.doc_text_search,
                        size: 70,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada data kolesterol',
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
                                      : 'Diurutkan berdasarkan kadar kolesterol',
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
                          
                          // List data kolesterol
                          Expanded(
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: _kolesterolData.length,
                              itemBuilder: (context, index) {
                                final item = _kolesterolData[index];
                                // Parse tanggal to display formatted
                                final DateTime date = DateFormat('yyyy-MM-dd').parse(item.tanggal);
                                final String formattedDate = DateFormat('dd MMM yyyy').format(date);
                                
                                double? valueInMgdL = double.tryParse(item.hasil) ?? 0.0;
                                
                                // Determine background color and status based on kolesterol value
                                final status = _getKolesterolStatus(valueInMgdL, inMgdL: true);
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
                                                      Text(
                                                        'Kadar Kolesterol',
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 14,
                                                          color: Colors.grey.shade700,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        _getValueInSelectedUnit(item.hasil),
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 22,
                                                          fontWeight: FontWeight.w600,
                                                          color: textColor,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Row(
                                                        children: [
                                                          Icon(
                                                            CupertinoIcons.info_circle_fill,
                                                            size: 14,
                                                            color: Colors.grey.shade600,
                                                          ),
                                                          const SizedBox(width: 4),
                                                          Text(
                                                            'Batas normal: ${status['range']}',
                                                            style: GoogleFonts.poppins(
                                                              fontSize: 12,
                                                              color: Colors.grey.shade600,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: textColor.withOpacity(0.2),
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
                                              ],
                                            ),
                                            if (item.catatan.isNotEmpty) ...[
                                              const SizedBox(height: 12),
                                              Container(
                                                padding: const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.5),
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