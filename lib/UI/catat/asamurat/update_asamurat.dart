 import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primafit/database/catat/database_asamurat.dart';

class UpdateAsamUratScreen extends StatefulWidget {
  final int AsamUratId;
  
  const UpdateAsamUratScreen({
    Key? key,
    required this.AsamUratId,
  }) : super(key: key);

  @override
  State<UpdateAsamUratScreen> createState() => _UpdateAsamUratScreenState();
}

class _UpdateAsamUratScreenState extends State<UpdateAsamUratScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _hasilController = TextEditingController();
  final TextEditingController _catatanController = TextEditingController();
  
  bool _isLoading = false;
  bool _isLoadingData = true;
  // ignore: unused_field
  AsamUrat? _currentData;
  
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
    _loadAsamUratData();
  }
  
  Future<void> _loadAsamUratData() async {
    try {
      final data = await AsamUratDatabaseHelper.instance.getAsamUratById(widget.AsamUratId);
      if (data != null) {
        setState(() {
          _currentData = data;
          _hasilController.text = data.hasil;
          _catatanController.text = data.catatan;
          
          // Parse date
          final dateParts = data.tanggal.split('-');
          if (dateParts.length == 3) {
            _selectedDate = DateTime(
              int.parse(dateParts[0]),
              int.parse(dateParts[1]),
              int.parse(dateParts[2]),
            );
          }
          
          // Parse time
          final timeParts = data.waktu.split(':');
          if (timeParts.length == 2) {
            _selectedTime = TimeOfDay(
              hour: int.parse(timeParts[0]),
              minute: int.parse(timeParts[1]),
            );
          }
          
          _isLoadingData = false;
        });
        _animationController.forward();
      } else {
        // Handle case where data is not found
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data tidak ditemukan'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.pop(context);
      }
    }
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
      lastDate: DateTime(2100),
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
  
  void _updateData() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null || _selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Silakan pilih tanggal dan waktu'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
      
      setState(() {
        _isLoading = true;
      });
      
      final String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      final String formattedTime = '${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}';
      
      try {
        final updatedAsamUrat = AsamUrat(
          id: widget.AsamUratId,
          tanggal: formattedDate,
          waktu: formattedTime,
          hasil: _hasilController.text,
          catatan: _catatanController.text,
        );
        
        await AsamUratDatabaseHelper.instance.updateAsamUrat(updatedAsamUrat);
        
        // Add a small delay for smoother animation
        await Future.delayed(const Duration(milliseconds: 300));
        
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data berhasil diperbarui'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
          
          // Return to previous screen
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Terjadi kesalahan: ${e.toString()}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Catatan Asam Urat',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF64D1DE),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoadingData
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF64D1DE),
              ),
            )
          : FadeTransition(
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
                            'Perbarui data pemeriksaan AsamUrat Anda',
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
                            'Hasil Periksa Kadar Asam Urat Total',
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
                              hintText: 'Contoh: 3,7',
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
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 50,
                                  child: OutlinedButton(
                                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF64D1DE),
                                      side: const BorderSide(color: Color(0xFF64D1DE)),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      'Batal',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: SizedBox(
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _updateData,
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
}