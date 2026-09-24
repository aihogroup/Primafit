import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:primafit/database/catat/database_suhu.dart';
import 'package:primafit/database/navigasi/database_profile.dart';
import 'package:primafit/UI/catat/suhu/update_suhu.dart';
import 'package:primafit/UI/catat/suhu/input_suhu.dart';

class ReadSuhuScreen extends StatefulWidget {
  const ReadSuhuScreen({Key? key}) : super(key: key);

  @override
  State<ReadSuhuScreen> createState() => _ReadSuhuScreenState();
}

class _ReadSuhuScreenState extends State<ReadSuhuScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  List<SuhuTubuh> _suhuData = [];
  Map<String, dynamic>? _userProfile; // Simpan data profil pengguna
  bool _isLoading = true;
  bool _isDeleting = false;
  bool _showInfoPanel = false; // Toggle untuk panel informasi
  bool _showAsCelsius = true; // Toggle untuk tampilan satuan (°C atau °F)
  
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
      // Load suhu data
      final data = await SuhuDatabaseHelper.instance.getAllSuhu();
      
      // Load user profile data
      final profiles = await ProfileDatabaseHelper().getProfiles();
      final userProfile = profiles.isNotEmpty ? profiles.first : null;
      
      setState(() {
        _suhuData = data;
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
      _suhuData.sort((a, b) {
        final DateTime dateA = DateFormat('yyyy-MM-dd').parse(a.tanggal);
        final DateTime dateB = DateFormat('yyyy-MM-dd').parse(b.tanggal);
        
        if (_sortAscending) {
          return dateA.compareTo(dateB);
        } else {
          return dateB.compareTo(dateA);
        }
      });
    } else {
      // Sort berdasarkan nilai suhu
      _suhuData.sort((a, b) {
        // Parse hasil sebagai double untuk perbandingan
        double valueA;
        double valueB;
        
        // Konversi ke sistem yang sama jika perlu (semua jadi Celsius)
        if (a.satuan == '°C') {
          valueA = double.tryParse(a.hasil) ?? 0.0;
        } else {
          valueA = convertFahrenheitToCelsius(double.tryParse(a.hasil) ?? 0.0);
        }
        
        if (b.satuan == '°C') {
          valueB = double.tryParse(b.hasil) ?? 0.0;
        } else {
          valueB = convertFahrenheitToCelsius(double.tryParse(b.hasil) ?? 0.0);
        }
        
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
          : 'Mengurutkan berdasarkan suhu tubuh'
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
      _showAsCelsius = !_showAsCelsius;
    });
    
    // Tampilkan snackbar informasi
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_showAsCelsius 
          ? 'Menampilkan dalam °C' 
          : 'Menampilkan dalam °F'
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
  
  // Fungsi untuk menentukan status suhu berdasarkan nilai
  Map<String, dynamic> _getSuhuStatus(double value, String satuan) {
    double celsius;
    
    // Konversi ke Celsius jika nilai dalam Fahrenheit
    if (satuan == '°F') {
      celsius = convertFahrenheitToCelsius(value);
    } else {
      celsius = value;
    }
    
    // Default kategori suhu tubuh
    if (celsius < 35.0) {
      return {
        'status': 'Hipotermia Berat', 
        'color': Colors.blue.shade800,
        'bgColor': Colors.blue.shade50,
        'range': celsius < 35.0 ? '< 35.0°C' : '< 95.0°F'
      };
    } else if (celsius < 36.0) {
      return {
        'status': 'Hipotermia Ringan', 
        'color': Colors.blue.shade500,
        'bgColor': Colors.blue.shade50,
        'range': '35.0°C - 36.0°C'
      };
    } else if (celsius <= 37.5) {
      return {
        'status': 'Normal', 
        'color': Colors.green.shade700,
        'bgColor': Colors.green.shade50,
        'range': '36.1°C - 37.5°C'
      };
    } else if (celsius <= 38.5) {
      return {
        'status': 'Demam Ringan', 
        'color': Colors.orange,
        'bgColor': Colors.orange.shade50,
        'range': '37.6°C - 38.5°C'
      };
    } else if (celsius <= 39.5) {
      return {
        'status': 'Demam', 
        'color': Colors.red.shade500,
        'bgColor': Colors.red.shade50,
        'range': '38.6°C - 39.5°C'
      };
    } else {
      return {
        'status': 'Demam Tinggi', 
        'color': Colors.red.shade800,
        'bgColor': Colors.red.shade50,
        'range': '> 39.5°C'
      };
    }
  }
  
  Future<void> _deleteItem(int id) async {
    setState(() {
      _isDeleting = true;
    });
    
    try {
      await SuhuDatabaseHelper.instance.deleteSuhu(id);
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
      MaterialPageRoute(builder: (context) => const InputSuhuScreen()),
    );
    
    if (result == true) {
      _loadData();
    }
  }
  
  Future<void> _navigateToEdit(int id) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UpdateSuhuScreen(suhuId: id)),
    );
    
    if (result == true) {
      _loadData();
    }
  }
  
  // Widget untuk menampilkan panel informasi nilai normal suhu tubuh
  Widget _buildInfoPanel() {
    final int? age = _userProfile != null && _userProfile!['tanggalLahir'] != null
        ? _calculateAge(_userProfile!['tanggalLahir'])
        : null;
    final bool isAdult = age == null || age >= 18;

    List<Widget> _buildNormalRange() {
      if (_showAsCelsius) {
        // Tampilkan dalam Celsius
        if (!isAdult) {
          // Untuk anak-anak
          return [
            _buildNormalRangeText('Normal', '36.6°C - 37.5°C', Colors.green.shade700),
            const SizedBox(height: 4),
            _buildNormalRangeText('Demam Ringan', '37.6°C - 38.3°C', Colors.orange),
            const SizedBox(height: 4),
            _buildNormalRangeText('Demam', '38.4°C - 39.5°C', Colors.red.shade500),
            const SizedBox(height: 4),
            _buildNormalRangeText('Demam Tinggi', '> 39.5°C', Colors.red.shade800),
          ];
        } else {
          // Untuk dewasa
          return [
            _buildNormalRangeText('Normal', '36.1°C - 37.2°C', Colors.green.shade700),
            const SizedBox(height: 4),
            _buildNormalRangeText('Demam Ringan', '37.3°C - 38.0°C', Colors.orange),
            const SizedBox(height: 4),
            _buildNormalRangeText('Demam', '38.1°C - 39.0°C', Colors.red.shade500),
            const SizedBox(height: 4),
            _buildNormalRangeText('Demam Tinggi', '> 39.0°C', Colors.red.shade800),
          ];
        }
      } else {
        // Tampilkan dalam Fahrenheit
        if (!isAdult) {
          // Untuk anak-anak
          return [
            _buildNormalRangeText('Normal', '98.0°F - 99.5°F', Colors.green.shade700),
            const SizedBox(height: 4),
            _buildNormalRangeText('Demam Ringan', '99.6°F - 100.9°F', Colors.orange),
            const SizedBox(height: 4),
            _buildNormalRangeText('Demam', '101.0°F - 103.1°F', Colors.red.shade500),
            const SizedBox(height: 4),
            _buildNormalRangeText('Demam Tinggi', '> 103.1°F', Colors.red.shade800),
          ];
        } else {
          // Untuk dewasa
          return [
            _buildNormalRangeText('Normal', '97.0°F - 99.0°F', Colors.green.shade700),
            const SizedBox(height: 4),
            _buildNormalRangeText('Demam Ringan', '99.1°F - 100.4°F', Colors.orange),
            const SizedBox(height: 4),
            _buildNormalRangeText('Demam', '100.5°F - 102.2°F', Colors.red.shade500),
            const SizedBox(height: 4),
            _buildNormalRangeText('Demam Tinggi', '> 102.2°F', Colors.red.shade800),
          ];
        }
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
                  'Nilai Normal Suhu Tubuh',
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
                    _showAsCelsius ? '°F' : '°C',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF64D1DE),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (age != null)
              Text(
                _userProfile!['gender'] == 'pria' || _userProfile!['gender'] == 'laki-laki' 
                    ? 'Pria, $age tahun'
                    : 'Wanita, $age tahun',
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
                    'Demam tinggi bisa menjadi tanda infeksi atau masalah kesehatan lainnya. Konsultasikan dengan dokter jika demam berlangsung lebih dari 3 hari.',
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
  
  // Convenience function to convert Celsius to Fahrenheit
  double convertCelsiusToFahrenheit(double celsius) {
    return (celsius * 9/5) + 32;
  }
  
  // Convenience function to convert Fahrenheit to Celsius
  double convertFahrenheitToCelsius(double fahrenheit) {
    return (fahrenheit - 32) * 5/9;
  }
  
  // Fungsi untuk mendapatkan nilai dalam satuan yang dipilih
  String _getValueInSelectedUnit(String valueStr, String originalUnit) {
    double? value = double.tryParse(valueStr);
    if (value == null) return '$valueStr $originalUnit';
    
    if (_showAsCelsius) {
      if (originalUnit == '°C') {
        return '${value.toStringAsFixed(1)} °C';
      } else {
        double celsius = convertFahrenheitToCelsius(value);
        return '${celsius.toStringAsFixed(1)} °C';
      }
    } else { // Tampilkan dalam Fahrenheit
      if (originalUnit == '°F') {
        return '${value.toStringAsFixed(1)} °F';
      } else {
        double fahrenheit = convertCelsiusToFahrenheit(value);
        return '${fahrenheit.toStringAsFixed(1)} °F';
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Riwayat Suhu Tubuh',
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
              _showAsCelsius ? '°C' : '°F',
              style: GoogleFonts.poppins(
                fontSize: 14,
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
                      _sortByDate ? CupertinoIcons.thermometer : CupertinoIcons.calendar,
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
          : _suhuData.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.thermometer,
                        size: 70,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada data suhu tubuh',
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
                                  _sortByDate ? CupertinoIcons.calendar : CupertinoIcons.thermometer,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _sortByDate 
                                      ? 'Diurutkan berdasarkan tanggal' 
                                      : 'Diurutkan berdasarkan suhu tubuh',
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
                          
                          // List data suhu tubuh
                          Expanded(
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: _suhuData.length,
                              itemBuilder: (context, index) {
                                final item = _suhuData[index];
                                // Parse tanggal to display formatted
                                final DateTime date = DateFormat('yyyy-MM-dd').parse(item.tanggal);
                                final String formattedDate = DateFormat('dd MMM yyyy').format(date);
                                
                                double? value = double.tryParse(item.hasil) ?? 0.0;
                                
                                // Determine background color and status based on suhu value
                                final status = _getSuhuStatus(value, item.satuan);
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
                                                        'Suhu Tubuh',
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 14,
                                                          color: Colors.grey.shade700,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        _getValueInSelectedUnit(item.hasil, item.satuan),
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