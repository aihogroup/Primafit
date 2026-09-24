import 'package:primafit/app/router/app_routes.dart';
import 'package:primafit/core/widgets/confirm_pop_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primafit/features/health_record/presentation/suhu/read_suhu.dart';
import 'package:primafit/features/health_record/data/database_suhu.dart';

class InputSuhuScreen extends StatefulWidget {
  const InputSuhuScreen({super.key});

  @override
  State<InputSuhuScreen> createState() => _InputSuhuScreenState();
}

class _InputSuhuScreenState extends State<InputSuhuScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _selectedUnit = '°C'; // Default satuan Celsius
  final TextEditingController _hasilController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();
  
  bool _isLoading = false;
  
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
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _hasilController.dispose();
    _catatanController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF64D1DE),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
  
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF64D1DE),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }
  
  // Metode untuk menampilkan dialog validasi input
  void _showValidationDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _buildInfoDialog(
          title: 'Perhatian',
          message: message,
          icon: CupertinoIcons.exclamationmark_circle,
          iconColor: Colors.orange,
          buttonText: 'Mengerti',
          onButtonPressed: () => Navigator.of(context).pop(),
        );
      },
    );
  }
  
  // Metode untuk menampilkan dialog error
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _buildInfoDialog(
          title: 'Gagal',
          message: message,
          icon: CupertinoIcons.xmark_circle,
          iconColor: Colors.red,
          buttonText: 'Tutup',
          onButtonPressed: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  // Metode untuk menampilkan dialog sukses
  void _showSuccessDialog() {
    showDialog(
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
                  color: Colors.black.withValues(alpha: 0.1),
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
                            color: const Color(0xFF64D1DE).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            CupertinoIcons.check_mark_circled,
                            color: const Color(0xFF64D1DE),
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
                  'Berhasil!',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                // Pesan dialog
                Text(
                  'Data suhu tubuh berhasil disimpan dalam database.',
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
                    // Tombol kembali ke home
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.pushReplacementNamed(context, AppRoutes.home);
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: const Color(0xFF64D1DE)),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.home,
                              color: const Color(0xFF64D1DE),
                              size: 18,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Kembali',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF64D1DE),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Tombol lihat riwayat
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ReadSuhuScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF64D1DE),
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
                            Icon(
                              CupertinoIcons.collections,
                              size: 18,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Lihat Riwayat',
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
              ],
            ),
          ),
        );
      },
    );
  }
  
  // Widget builder untuk dialog informatif (validasi & error)
  Widget _buildInfoDialog({
    required String title,
    required String message,
    required IconData icon,
    required Color iconColor,
    required String buttonText,
    required VoidCallback onButtonPressed,
  }) {
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
              color: Colors.black.withValues(alpha: 0.1),
              spreadRadius: 5,
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 50,
            ),
            const SizedBox(height: 15),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF64D1DE),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _saveData() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null || _selectedTime == null) {
        _showValidationDialog('Silakan pilih tanggal dan waktu pengukuran terlebih dahulu.');
        return;
      }
      
      setState(() {
        _isLoading = true;
      });
      
      final String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      final String formattedTime = '${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}';
      
      try {
        final suhu = SuhuTubuh(
          tanggal: formattedDate,
          waktu: formattedTime,
          hasil: _hasilController.text,
          catatan: _catatanController.text,
          satuan: _selectedUnit,
        );
        
        await SuhuDatabaseHelper.instance.insertSuhu(suhu);
        
        // Add a small delay for smoother animation
        await Future.delayed(const Duration(milliseconds: 300));
        
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          
          // Tampilkan dialog sukses
          _showSuccessDialog();
          
          // Reset form
          _formKey.currentState!.reset();
          _selectedDate = null;
          _selectedTime = null;
          _hasilController.clear();
          _catatanController.clear();
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          
          // Tampilkan dialog error
          _showErrorDialog('Terjadi kesalahan saat menyimpan data: ${e.toString()}');
        }
      }
    }
  }
  
  // Validasi nilai suhu yang masuk
  String? _validateSuhu(String? value) {
    if (value == null || value.isEmpty) {
      return 'Hasil pengukuran tidak boleh kosong';
    }
    
    final double? suhu = double.tryParse(value);
    if (suhu == null) {
      return 'Hasil harus berupa angka';
    }
    
    if (suhu < 0) {
      return 'Suhu tidak boleh bernilai negatif';
    }
    
    // Validasi rentang suhu tubuh manusia normal
    if (_selectedUnit == '°C') {
      if (suhu < 30 || suhu > 45) {
        return 'Suhu tubuh tidak valid (30°C - 45°C)';
      }
    } else { // Fahrenheit
      if (suhu < 86 || suhu > 113) {
        return 'Suhu tubuh tidak valid (86°F - 113°F)';
      }
    }
    
    return null;
  }
  
  @override
  Widget build(BuildContext context) {
    return ConfirmPopScope(
      onWillPop: () async {
        // Jika sedang loading, hindari pop
        if (_isLoading) {
          return false;
        }
        
        // Cek apakah form sudah diisi
        final bool formIsNotEmpty = _hasilController.text.isNotEmpty || 
          _catatanController.text.isNotEmpty || 
          _selectedDate != null || 
          _selectedTime != null;
        
        // Jika form masih kosong, langsung navigasi ke home
        if (!formIsNotEmpty) {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
          return false;
        }
        
        // Jika form sudah diisi, tampilkan dialog konfirmasi
        final bool shouldPop = await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Dialog(
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
                    color: Colors.black.withValues(alpha: 0.1),
                    spreadRadius: 5,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.exclamationmark_circle,
                    color: Colors.orange,
                    size: 50,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Perhatian',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Data yang Anda masukkan belum tersimpan. Yakin ingin keluar dari halaman ini?',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Tombol batalkan
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(false); // Tidak keluar
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(color: Colors.grey.shade400),
                            ),
                          ),
                          child: Text(
                            'Batal',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Tombol keluar
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(true); // Ya, keluar
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF64D1DE),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Keluar',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ) ?? false;
        
        if (shouldPop) {
          if (!context.mounted) return false;
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
        
        return false; // Kita menangani navigasi secara manual
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Catatan Suhu Tubuh',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: const Color(0xFF64D1DE),
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(CupertinoIcons.back),
            onPressed: () {
              // Gunakan Navigator.of(context).maybePop() untuk memicu WillPopScope
              Navigator.of(context).maybePop();
            },
          ),
        ),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Catat hasil pengukuran suhu tubuh Anda untuk memantau kesehatan secara teratur.',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Tanggal Pengukuran',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selectDate(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedDate == null
                                    ? 'Pilih Tanggal'
                                    : DateFormat('dd MMMM yyyy').format(_selectedDate!),
                                style: GoogleFonts.poppins(
                                  color: _selectedDate == null ? Colors.grey : Colors.black87,
                                ),
                              ),
                              const Icon(CupertinoIcons.calendar, color: Color(0xFF64D1DE)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Waktu Pengukuran',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selectTime(context),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _selectedTime == null
                                    ? 'Pilih waktu pengukuran'
                                    : _selectedTime!.format(context),
                                style: GoogleFonts.poppins(
                                  color: _selectedTime == null ? Colors.grey : Colors.black87,
                                ),
                              ),
                              const Icon(CupertinoIcons.clock, color: Color(0xFF64D1DE)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Hasil Pengukuran Suhu Tubuh',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Row untuk input suhu dengan dropdown satuan
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Input nilai suhu tubuh
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _hasilController,
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                              style: GoogleFonts.poppins(),
                              decoration: InputDecoration(
                                hintText: _selectedUnit == '°C' ? 'Contoh: 36.8' : 'Contoh: 98.6',
                                hintStyle: GoogleFonts.poppins(color: Colors.grey),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    bottomLeft: Radius.circular(12),
                                  ),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(12),
                                    bottomLeft: Radius.circular(12),
                                  ),
                                  borderSide: const BorderSide(color: Color(0xFF64D1DE)),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              validator: _validateSuhu,
                            ),
                          ),
                          // Dropdown untuk satuan
                          Expanded(
                            flex: 1,
                            child: Container(
                              height: 48, // Sesuaikan dengan tinggi TextFormField
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(12),
                                  bottomRight: Radius.circular(12),
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedUnit,
                                  icon: Icon(CupertinoIcons.chevron_down, size: 16),
                                  isExpanded: true,
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  borderRadius: BorderRadius.circular(12),
                                  items: [
                                    DropdownMenuItem(
                                      value: '°C',
                                      child: Text('°C', style: GoogleFonts.poppins()),
                                    ),
                                    DropdownMenuItem(
                                      value: '°F',
                                      child: Text('°F', style: GoogleFonts.poppins()),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedUnit = value!;
                                      // Clear the input when changing units to avoid confusion
                                      _hasilController.clear();
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Catatan',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _catatanController,
                        style: GoogleFonts.poppins(),
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Tambahkan catatan (misalnya: kondisi pasien, metode pengukuran, dll)',
                          hintStyle: GoogleFonts.poppins(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF64D1DE)),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF64D1DE),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Simpan',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}