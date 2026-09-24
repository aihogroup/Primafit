import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:primafit/features/women_health/presentation/kehamilan/model_kehamilan.dart';
import 'package:primafit/features/women_health/data/database_kehamilan.dart';

class AddPregnancyPage extends StatefulWidget {
  const AddPregnancyPage({super.key});

  @override
  _AddPregnancyPageState createState() => _AddPregnancyPageState();
}

class _AddPregnancyPageState extends State<AddPregnancyPage> {
  late DateTime _lastPeriodDate;
  late DateTime _dueDate;
  bool _isSubmitting = false;
  
  final DateFormat _dateFormat = DateFormat('d MMMM yyyy');
  final _formKey = GlobalKey<FormState>();
  
  @override
  void initState() {
    super.initState();
    _lastPeriodDate = DateTime.now().subtract(const Duration(days: 14));
    _calculateDueDate();
  }
  
  void _calculateDueDate() {
    // Naegele's rule: add 1 year, subtract 3 months, add 7 days to LMP
    final year = _lastPeriodDate.year;
    final month = _lastPeriodDate.month;
    final day = _lastPeriodDate.day;
    
    DateTime calculatedDueDate;
    
    if (month <= 3) {
      // January, February, March
      calculatedDueDate = DateTime(year, month + 9, day + 7);
    } else {
      // April through December
      calculatedDueDate = DateTime(year + 1, month - 3, day + 7);
    }
    
    setState(() {
      _dueDate = calculatedDueDate;
    });
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _lastPeriodDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFE9458D),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedDate != null && pickedDate != _lastPeriodDate) {
      setState(() {
        _lastPeriodDate = pickedDate;
        _calculateDueDate();
      });
    }
  }
  
  Future<void> _savePregnancy() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      // Check if there's already an active pregnancy
      final activePregnancy = await DatabaseHelperPregnancy.instance.getActivePregnancy();
      
      if (activePregnancy != null) {
        if (!mounted) return;
        // Show confirmation dialog to end current pregnancy
        final shouldEndCurrent = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Kehamilan Aktif Ditemukan'),
            content: const Text(
              'Anda sudah memiliki data kehamilan aktif. Apakah Anda ingin mengakhiri kehamilan aktif dan memulai yang baru?'
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Akhiri & Buat Baru'),
              ),
            ],
          ),
        );
        
        if (shouldEndCurrent != true) {
          setState(() {
            _isSubmitting = false;
          });
          return;
        }
        
        // End current active pregnancy
        await DatabaseHelperPregnancy.instance.endPregnancy(
          activePregnancy.id, 
          DateTime.now()
        );
      }
      
      // Calculate current week based on last period date
      final today = DateTime.now();
      final difference = today.difference(_lastPeriodDate).inDays;
      final currentWeek = (difference / 7).floor() + 1;
      
      // Create new pregnancy
      final tempId = DateTime.now().millisecondsSinceEpoch;
      
      final pregnancy = Pregnancy(
        id: tempId,
        startDate: _lastPeriodDate,
        dueDate: _dueDate,
        currentWeek: currentWeek,
        isActive: true,
      );
      
      await DatabaseHelperPregnancy.instance.insertPregnancy(pregnancy);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Data kehamilan berhasil disimpan',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Error saving pregnancy: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal menyimpan data kehamilan: $e',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
        
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE9458D),
        elevation: 0,
        title: Text(
          'Tambah Data Kehamilan',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: _isSubmitting
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Color(0xFFE9458D)),
                    const SizedBox(height: 16),
                    Text(
                      'Menyimpan data kehamilan...',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9458D).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE9458D).withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE9458D).withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                CupertinoIcons.heart,
                                color: Color(0xFFE9458D),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Data Kehamilan Baru',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    'Masukkan tanggal HPHT untuk menghitung usia kehamilan',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // HPHT Date
                      Text(
                        'Tanggal Hari Pertama Haid Terakhir (HPHT)',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _dateFormat.format(_lastPeriodDate),
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  color: Colors.black87,
                                ),
                              ),
                              Icon(
                                CupertinoIcons.calendar,
                                color: Colors.grey.shade600,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      Text(
                        'Tanggal hari pertama menstruasi terakhir Anda',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Due Date (calculated)
                      Text(
                        'Perkiraan Tanggal Lahir (HPL)',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.teal.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _dateFormat.format(_dueDate),
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.teal.shade700,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.teal.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Otomatis',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.teal.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      Text(
                        'Dihitung secara otomatis menggunakan rumus Naegele berdasarkan HPHT',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Pregnancy Info Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Informasi Kehamilan',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Kehamilan normal berlangsung sekitar 40 minggu, atau 280 hari, dihitung dari hari pertama haid terakhir. Perkiraan tanggal lahir adalah perkiraan kasar, dan hanya 5% bayi yang lahir tepat pada hari tersebut.',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.grey.shade700,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Catatan: Jika siklus menstruasi Anda tidak teratur atau tidak pasti tentang tanggal HPHT, konsultasikan dengan dokter untuk pemeriksaan USG untuk perkiraan yang lebih akurat.',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontStyle: FontStyle.italic,
                                color: Colors.blue.shade700,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Save button
                      ElevatedButton(
                        onPressed: _savePregnancy,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFFE9458D),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: Text(
                          'Simpan Data Kehamilan',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}