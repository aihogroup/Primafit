import 'package:primafit/app/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:primafit/features/health_record/data/database_bmi.dart';
import 'package:primafit/features/profile/data/database_profile.dart';
import 'package:primafit/features/health_record/presentation/bmi/update_bmi.dart';
import 'package:primafit/features/health_record/presentation/bmi/input_bmi.dart';

class ReadBmiScreen extends StatefulWidget {
  const ReadBmiScreen({super.key});

  @override
  State<ReadBmiScreen> createState() => _ReadBmiScreenState();
}

class _ReadBmiScreenState extends State<ReadBmiScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  List<IndeksMassaTubuh> _BmiData = [];
  Map<String, dynamic>? _userProfile; // Simpan data profil pengguna
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
      // Load Bmi data
      final data = await IndeksMassaTubuhDatabaseHelper.instance.getAllIndeksMassaTubuh();
      
      // Load user profile data
      final profiles = await ProfileDatabaseHelper().getProfiles();
      final userProfile = profiles.isNotEmpty ? profiles.first : null;
      
      setState(() {
        _BmiData = data;
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
      _BmiData.sort((a, b) {
        final DateTime dateA = DateFormat('yyyy-MM-dd').parse(a.tanggal);
        final DateTime dateB = DateFormat('yyyy-MM-dd').parse(b.tanggal);
        
        if (_sortAscending) {
          return dateA.compareTo(dateB);
        } else {
          return dateB.compareTo(dateA);
        }
      });
    } else {
      // Sort berdasarkan nilai Bmi
      _BmiData.sort((a, b) {
        final double valueA = double.tryParse(a.bmi) ?? 0;
        final double valueB = double.tryParse(b.bmi) ?? 0;
        
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
          : 'Mengurutkan berdasarkan nilai BMI'
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
        debugPrint('Usia tidak valid: $age');
        return 30;
      }

      return age;
    } catch (e) {
      debugPrint('Gagal parsing tanggal lahir: $e');
      return 30;
    }
  }

  // Fungsi untuk menentukan status BMI berdasarkan nilai, usia, dan gender
  Map<String, dynamic> _getBmiStatus(double bmiValue) {
    // Default jika profil tidak tersedia
    if (_userProfile == null || _userProfile!['tanggalLahir'] == null || _userProfile!['gender'] == null) {
      // Standar umum untuk dewasa
      return _getAdultBmiStatus(bmiValue);
    }
    
    final int age = _calculateAge(_userProfile!['tanggalLahir']);
    final String gender = _userProfile!['gender'].toLowerCase();
    
    // Untuk anak-anak dan remaja (di bawah 20 tahun)
    if (age < 20) {
      return _getChildBmiStatus(bmiValue, age, gender);
    }
    
    // Untuk orang dewasa (20 tahun ke atas)
    return _getAdultBmiStatus(bmiValue);
  }
  
  // Status BMI untuk dewasa (standar WHO)
  Map<String, dynamic> _getAdultBmiStatus(double bmiValue) {
    if (bmiValue < 16.0) {
      return {
        'status': 'Sangat Kurus', 
        'color': Colors.red.shade800,
        'bgColor': Colors.red.shade50
      };
    } else if (bmiValue < 17.0) {
      return {
        'status': 'Kurus Sedang', 
        'color': Colors.orange.shade800,
        'bgColor': Colors.orange.shade50
      };
    } else if (bmiValue < 18.5) {
      return {
        'status': 'Kurus Ringan', 
        'color': Colors.amber.shade800,
        'bgColor': Colors.amber.shade50
      };
    } else if (bmiValue < 25.0) {
      return {
        'status': 'Normal', 
        'color': Colors.green.shade800,
        'bgColor': Colors.green.shade50
      };
    } else if (bmiValue < 30.0) {
      return {
        'status': 'Gemuk', 
        'color': Colors.amber.shade800,
        'bgColor': Colors.amber.shade50
      };
    } else if (bmiValue < 35.0) {
      return {
        'status': 'Obesitas I', 
        'color': Colors.orange.shade800,
        'bgColor': Colors.orange.shade50
      };
    } else if (bmiValue < 40.0) {
      return {
        'status': 'Obesitas II', 
        'color': Colors.deepOrange.shade800,
        'bgColor': Colors.deepOrange.shade50
      };
    } else {
      return {
        'status': 'Obesitas III', 
        'color': Colors.red.shade800,
        'bgColor': Colors.red.shade50
      };
    }
  }
  
  // Status BMI untuk anak-anak dan remaja
  // Catatan: Ini adalah simplifikasi, BMI untuk anak-anak seharusnya menggunakan persentil berdasarkan usia dan jenis kelamin
  Map<String, dynamic> _getChildBmiStatus(double bmiValue, int age, String gender) {
    // Nilai ambang batas berbeda berdasarkan usia dan jenis kelamin
    double underweightThreshold;
    double normalLowerThreshold;
    double normalUpperThreshold;
    double overweightThreshold;
    
    if (gender == 'laki-laki' || gender == 'pria') {
      if (age < 10) {
        underweightThreshold = 14.0;
        normalLowerThreshold = 15.5;
        normalUpperThreshold = 19.0;
        overweightThreshold = 22.0;
      } else if (age < 15) {
        underweightThreshold = 15.0;
        normalLowerThreshold = 16.5;
        normalUpperThreshold = 21.0;
        overweightThreshold = 24.0;
      } else {
        underweightThreshold = 16.0;
        normalLowerThreshold = 17.5;
        normalUpperThreshold = 23.0;
        overweightThreshold = 27.0;
      }
    } else { // Perempuan
      if (age < 10) {
        underweightThreshold = 13.5;
        normalLowerThreshold = 15.0;
        normalUpperThreshold = 19.0;
        overweightThreshold = 22.0;
      } else if (age < 15) {
        underweightThreshold = 14.5;
        normalLowerThreshold = 16.0;
        normalUpperThreshold = 21.0;
        overweightThreshold = 24.0;
      } else {
        underweightThreshold = 15.0;
        normalLowerThreshold = 17.0;
        normalUpperThreshold = 23.0;
        overweightThreshold = 27.0;
      }
    }
    
    if (bmiValue < underweightThreshold) {
      return {
        'status': 'Sangat Kurus', 
        'color': Colors.red.shade800,
        'bgColor': Colors.red.shade50
      };
    } else if (bmiValue < normalLowerThreshold) {
      return {
        'status': 'Kurus', 
        'color': Colors.orange.shade800,
        'bgColor': Colors.orange.shade50
      };
    } else if (bmiValue < normalUpperThreshold) {
      return {
        'status': 'Normal', 
        'color': Colors.green.shade800,
        'bgColor': Colors.green.shade50
      };
    } else if (bmiValue < overweightThreshold) {
      return {
        'status': 'Gemuk', 
        'color': Colors.amber.shade800,
        'bgColor': Colors.amber.shade50
      };
    } else {
      return {
        'status': 'Obesitas', 
        'color': Colors.red.shade800,
        'bgColor': Colors.red.shade50
      };
    }
  }
  
  Future<void> _deleteItem(int id) async {
    setState(() {
      _isDeleting = true;
    });
    
    try {
      await IndeksMassaTubuhDatabaseHelper.instance.deleteIndeksMassaTubuh(id);
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
      MaterialPageRoute(builder: (context) => const InputBmiScreen()),
    );
    
    if (result == true) {
      _loadData();
    }
  }
  
  Future<void> _navigateToEdit(int id) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UpdateBmiScreen(BmiId: id)),
    );
    
    if (result == true) {
      _loadData();
    }
  }
  
  // Widget untuk menampilkan panel informasi rentang BMI
  Widget _buildInfoPanel() {
    if (_userProfile == null || _userProfile!['tanggalLahir'] == null || _userProfile!['gender'] == null) {
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
                  Icon(
                    CupertinoIcons.info_circle_fill,
                    color: const Color(0xFF64D1DE),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Kategori BMI untuk Dewasa',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildNormalRangeText('Sangat Kurus', '< 16.0', Colors.red.shade700),
              const SizedBox(height: 4),
              _buildNormalRangeText('Kurus', '16.0 - 18.5', Colors.orange.shade700),
              const SizedBox(height: 4),
              _buildNormalRangeText('Normal', '18.5 - 25.0', Colors.green.shade700),
              const SizedBox(height: 4),
              _buildNormalRangeText('Gemuk', '25.0 - 30.0', Colors.amber.shade700),
              const SizedBox(height: 4),
              _buildNormalRangeText('Obesitas', '> 30.0', Colors.red.shade700),
            ],
          ),
        ),
      );
    }
    
    // Jika profil tersedia, tampilkan informasi berdasarkan usia dan gender
    final int age = _calculateAge(_userProfile!['tanggalLahir']);
    final String gender = _userProfile!['gender'].toLowerCase();
    
    // Rentang BMI untuk anak-anak atau dewasa
    Widget categoryList;
    
    if (age < 20) {
      // Rentang untuk anak-anak
      String ageRange;
      final String genderText = (gender == 'laki-laki' || gender == 'pria') ? 'Laki-laki' : 'Perempuan';
      
      if (age < 10) {
        ageRange = '< 10 tahun';
      } else if (age < 15) {
        ageRange = '10-14 tahun';
      } else {
        ageRange = '15-19 tahun';
      }
      
      categoryList = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$genderText, $ageRange',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          _buildNormalRangeText('Sangat Kurus', 'BMI: Rendah', Colors.red.shade700),
          const SizedBox(height: 4),
          _buildNormalRangeText('Kurus', 'BMI: Di bawah normal', Colors.orange.shade700),
          const SizedBox(height: 4),
          _buildNormalRangeText('Normal', 'BMI: Normal untuk usia', Colors.green.shade700),
          const SizedBox(height: 4),
          _buildNormalRangeText('Gemuk', 'BMI: Di atas normal', Colors.amber.shade700),
          const SizedBox(height: 4),
          _buildNormalRangeText('Obesitas', 'BMI: Sangat tinggi', Colors.red.shade700),
        ],
      );
    } else {
      // Rentang untuk dewasa
      categoryList = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dewasa, ${gender == 'laki-laki' || gender == 'pria' ? 'Laki-laki' : 'Perempuan'}, $age tahun',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 12),
          _buildNormalRangeText('Sangat Kurus', '< 16.0', Colors.red.shade700),
          const SizedBox(height: 4),
          _buildNormalRangeText('Kurus', '16.0 - 18.5', Colors.orange.shade700),
          const SizedBox(height: 4),
          _buildNormalRangeText('Normal', '18.5 - 25.0', Colors.green.shade700),
          const SizedBox(height: 4),
          _buildNormalRangeText('Gemuk', '25.0 - 30.0', Colors.amber.shade700),
          const SizedBox(height: 4),
          _buildNormalRangeText('Obesitas', '> 30.0', Colors.red.shade700),
        ],
      );
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
                Icon(
                  CupertinoIcons.info_circle_fill,
                  color: const Color(0xFF64D1DE),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Kategori BMI',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            categoryList,
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
        Text(
          value,
          style: GoogleFonts.poppins(
            color: Colors.grey.shade800,
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
          'Riwayat BMI',
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
            tooltip: 'Informasi Kategori BMI',
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
          : _BmiData.isEmpty
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
                        'Belum ada data BMI',
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
                                      : 'Diurutkan berdasarkan nilai BMI',
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
                          
                          // List data Bmi
                          Expanded(
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: _BmiData.length,
                              itemBuilder: (context, index) {
                                final item = _BmiData[index];
                                // Parse tanggal to display formatted
                                final DateTime date = DateFormat('yyyy-MM-dd').parse(item.tanggal);
                                final String formattedDate = DateFormat('dd MMM yyyy').format(date);
                                
                                // Determine background color and status based on BMI value
                                final double? bmiValue = double.tryParse(item.bmi);
                                Color cardColor = Colors.white;
                                Color textColor = Colors.black;
                                String statusText = 'Unknown';
                                
                                if (bmiValue != null) {
                                  final status = _getBmiStatus(bmiValue);
                                  cardColor = status['bgColor'];
                                  textColor = status['color'];
                                  statusText = status['status'];
                                }
                                
                                // Calculate additional info from BMI data
                                final double heightCm = double.tryParse(item.tinggi) ?? 0;
                                final String heightInMeter = (heightCm / 100).toStringAsFixed(2);
                                
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
                                                        'Indeks Massa Tubuh (BMI)',
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 14,
                                                          color: Colors.grey.shade700,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        item.bmi,
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
                                                            CupertinoIcons.arrow_up_right_circle,
                                                            size: 16,
                                                            color: Colors.grey.shade600,
                                                          ),
                                                          const SizedBox(width: 4),
                                                          Text(
                                                            'TB: $heightInMeter m',
                                                            style: GoogleFonts.poppins(
                                                              fontSize: 13,
                                                              color: Colors.grey.shade600,
                                                            ),
                                                          ),
                                                          const SizedBox(width: 8),
                                                          Icon(
                                                            CupertinoIcons.arrow_down_right_circle,
                                                            size: 16,
                                                            color: Colors.grey.shade600,
                                                          ),
                                                          const SizedBox(width: 4),
                                                          Text(
                                                            'BB: ${item.berat} kg',
                                                            style: GoogleFonts.poppins(
                                                              fontSize: 13,
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