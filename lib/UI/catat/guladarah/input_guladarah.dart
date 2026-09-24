import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primafit/UI/catat/guladarah/read_guladarah.dart';
import 'package:primafit/database/catat/database_guladarah.dart';

class InputGulaDarahScreen extends StatefulWidget {
  const InputGulaDarahScreen({Key? key}) : super(key: key);

  @override
  State<InputGulaDarahScreen> createState() => _InputGulaDarahScreenState();
}

class _InputGulaDarahScreenState extends State<InputGulaDarahScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
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
                            color: const Color(0xFF64D1DE).withOpacity(0.1),
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
                  'Data Gula Darah berhasil disimpan dalam database.',
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
                          Navigator.pushReplacementNamed(context, '/home');
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
                    // Tombol tambah data baru
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ReadGulaDarahScreen(),
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
        _showValidationDialog('Silakan pilih tanggal dan waktu pemeriksaan terlebih dahulu.');
        return;
      }
      
      setState(() {
        _isLoading = true;
      });
      
      final String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      final String formattedTime = '${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}';
      
      try {
        final guladarah = GulaDarah(
          tanggal: formattedDate,
          waktu: formattedTime,
          hasil: _hasilController.text,
          catatan: _catatanController.text,
        );
        
        await GulaDarahDatabaseHelper.instance.insertGulaDarah(guladarah);
        
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
  
  @override
Widget build(BuildContext context) {
  return WillPopScope(
    onWillPop: () async {
      // Jika sedang loading, hindari pop
      if (_isLoading) {
        return false;
      }
      
      // Cek apakah form sudah diisi
      bool formIsNotEmpty = _hasilController.text.isNotEmpty || 
        _catatanController.text.isNotEmpty || 
        _selectedDate != null || 
        _selectedTime != null;
      
      // Jika form masih kosong, langsung navigasi ke home
      if (!formIsNotEmpty) {
        Navigator.pushReplacementNamed(context, '/home');
        return false;
      }
      
      // Jika form sudah diisi, tampilkan dialog konfirmasi
      bool shouldPop = await showDialog(
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
        Navigator.pushReplacementNamed(context, '/home');
      }
      
      return false; // Kita menangani navigasi secara manual
    },
    child: Scaffold(
      appBar: AppBar(
        title: Text(
          'Catatan Gula Darah',
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
                      'Catat hasil pemeriksaan kesehatan terbaru Anda untuk mendapatkan gambaran kesehatan yang lebih baik.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Tanggal Pemeriksaan',
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
                      'Waktu Periksa',
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
                                  ? 'Pilih waktu periksa'
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
                      'Hasil Periksa Kadar Gula Darah Total',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _hasilController,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.poppins(),
                      decoration: InputDecoration(
                        hintText: 'Contoh: 120 mg/dL',
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Hasil pemeriksaan tidak boleh kosong';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Hasil harus berupa angka';
                        }
                        if (double.parse(value) < 1) {
                          return 'Hasil tidak boleh bernilai 0 atau negatif';
                        }
                        return null;
                      },
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
                        hintText: 'Tambahkan catatan',
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