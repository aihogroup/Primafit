import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:primafit/database/pengingat/database_obat.dart';

class InputObatScreen extends StatefulWidget {
  const InputObatScreen({Key? key}) : super(key: key);

  @override
  State<InputObatScreen> createState() => _InputObatScreenState();
}

class _InputObatScreenState extends State<InputObatScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Text controllers
  final TextEditingController _namaObatController = TextEditingController();
  final TextEditingController _dosisController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _stokController = TextEditingController();
  
  // Dropdown values
  String? _selectedJenisObat;
  String? _selectedFrekuensi;
  String? _selectedNada;
  
  // Time selection
  final List<TimeOfDay?> _selectedTimes = [null, null, null];
  
  // Medication instruction
  bool _setelahMakan = true;
  bool _sebelumMakan = false;

  // Lists for dropdown menus
  final List<String> _jenisObatList = ['Oral', 'Sirup', 'Injeksi', 'Topikal'];
  final List<String> _frekuensiList = ['1x sehari', '2x sehari', '3x sehari'];
  final List<String> _nadaList = ['Nada Default', 'Pilih dari perangkat'];

  bool _isLoading = false;

  // Get number of times based on frequency
  int get _numberOfTimes {
    if (_selectedFrekuensi == null) return 1;
    return int.parse(_selectedFrekuensi!.split('x')[0]);
  }

  @override
  void dispose() {
    _namaObatController.dispose();
    _dosisController.dispose();
    _deskripsiController.dispose();
    _stokController.dispose();
    super.dispose();
  }

  // Function to show time picker
  Future<void> _selectTime(BuildContext context, int index) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTimes[index] ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF64D1DE),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTimes[index] = pickedTime;
      });
    }
  }

  // Function to pick sound file
  Future<void> _pickSoundFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        _selectedNada = result.files.single.name;
      });
    }
  }

  // Save medication data to database
  Future<void> _saveObat() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Prepare data to insert
        final obatData = {
          'nama': _namaObatController.text.trim(),
          'dosis': _dosisController.text.trim(),
          'jenis': _selectedJenisObat ?? '',
          'deskripsi': _deskripsiController.text.trim(),
          'stok': _stokController.text.trim(),
          'frekuensi_harian': _selectedFrekuensi ?? '1x sehari',
          'instruksi': _setelahMakan ? 'Setelah makan' : 'Sebelum makan',
          'nada': _selectedNada ?? 'Nada Default',
        };

        // Insert obat record
        final obatId = await DatabaseObatHelper.instance.insertObat(obatData);

        // Insert alarm records
        for (int i = 0; i < _numberOfTimes; i++) {
          if (_selectedTimes[i] != null) {
            final now = DateTime.now();
            final alarmTime = DateTime(
              now.year,
              now.month,
              now.day,
              _selectedTimes[i]!.hour,
              _selectedTimes[i]!.minute,
            );
            
            await DatabaseObatHelper.instance.insertAlarmObat({
              'obat_id': obatId,
              'waktu_alarm': alarmTime.millisecondsSinceEpoch,
            });
          }
        }

        // Show success message
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/jadwal');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data obat berhasil disimpan!'),
              backgroundColor: Color(0xFF64D1DE),
            ),
          );
          
          // Reset form or navigate back
          _resetForm();
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menyimpan data: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  // Reset form fields
  void _resetForm() {
    _namaObatController.clear();
    _dosisController.clear();
    _deskripsiController.clear();
    _stokController.clear();
    setState(() {
      _selectedJenisObat = null;
      _selectedFrekuensi = null;
      _selectedNada = null;
      _selectedTimes.fillRange(0, _selectedTimes.length, null);
      _setelahMakan = true;
      _sebelumMakan = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primaryColor: const Color(0xFF64D1DE),
        fontFamily: GoogleFonts.poppins().fontFamily,
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF64D1DE),
        ),
      ),
      child: Scaffold(
        // appBar: AppBar(
        //   leading: IconButton(
        //     icon: const Icon(CupertinoIcons.back, color: Colors.black),
        //     onPressed: () {
        //     if (Navigator.canPop(context)) {
        //       Navigator.pop(context);
        //     } else {
        //       Navigator.pushReplacementNamed(context, '/home');
        //     }
        //   },
        //     tooltip: 'Kembali',
        //   ),
        //   title: Text(
        //     'Pengingat Obat',
        //     style: GoogleFonts.poppins(
        //       color: Colors.black,
        //       fontWeight: FontWeight.w600,
        //     ),
        //   ),
        //   backgroundColor: Colors.white,
        //   elevation: 0,
        //   centerTitle: true,
        // ),
        appBar: AppBar(
        title: Text(
          'Pengingat Obat',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF64D1DE),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
        body: SafeArea(
          child: Stack(
            children: [
              Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  children: [
                    // Description text
                    Text(
                      'Gunakan halaman ini untuk mengingatkan Anda meminum obat tepat waktu demi kesehatan yang optimal.',
                      style: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Nama Obat field
                    _buildFieldLabel('Nama Obat'),
                    _buildTextFormField(
                      controller: _namaObatController,
                      hintText: 'Masukkan nama obat',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama obat tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Dosis Obat field
                    _buildFieldLabel('Dosis Obat'),
                    _buildTextFormField(
                      controller: _dosisController,
                      hintText: 'Masukkan dosis obat (mis. 500mg)',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Dosis obat tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Jenis Obat dropdown
                    _buildFieldLabel('Jenis Obat'),
                    _buildDropdown(
                      value: _selectedJenisObat,
                      hint: 'Select Occupation',
                      items: _jenisObatList,
                      onChanged: (value) {
                        setState(() {
                          _selectedJenisObat = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Pilih jenis obat';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Deskripsi Obat field
                    _buildFieldLabel('Deskripsi Obat'),
                    _buildTextFormField(
                      controller: _deskripsiController,
                      hintText: 'Masukkan deskripsi obat (opsional)',
                      maxLines: 3,
                      validator: null,  // Optional field
                    ),
                    const SizedBox(height: 16),
                    
                    // Jumlah Sajian (Stok Obat) field
                    _buildFieldLabel('Jumlah Sajian (Stok Obat)'),
                    _buildTextFormField(
                      controller: _stokController,
                      hintText: 'Masukkan jumlah stok',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Stok obat tidak boleh kosong';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Masukkan angka yang valid';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Frekuensi Harian dropdown
                    _buildFieldLabel('Frekuensi Harian'),
                    _buildDropdown(
                      value: _selectedFrekuensi,
                      hint: 'Select Occupation',
                      items: _frekuensiList,
                      onChanged: (value) {
                        setState(() {
                          _selectedFrekuensi = value;
                          // Reset times when frequency changes
                          _selectedTimes.fillRange(0, _selectedTimes.length, null);
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Pilih frekuensi harian';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Time selection fields based on frequency
                    for (int i = 0; i < _numberOfTimes; i++)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('Waktu'),
                          GestureDetector(
                            onTap: () => _selectTime(context, i),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _selectedTimes[i] != null
                                        ? _formatTimeOfDay(_selectedTimes[i]!)
                                        : 'Pilih waktu',
                                    style: GoogleFonts.poppins(
                                      color: _selectedTimes[i] != null
                                          ? Colors.black
                                          : Colors.black54,
                                    ),
                                  ),
                                  const Icon(CupertinoIcons.clock, color: Colors.black54),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    
                    // Nada Dering dropdown
                    _buildFieldLabel('Nada Dering'),
                    _buildDropdown(
                      value: _selectedNada,
                      hint: 'Select Occupation',
                      items: _nadaList,
                      onChanged: (value) {
                        setState(() {
                          _selectedNada = value;
                          if (value == 'Pilih dari perangkat') {
                            _pickSoundFile();
                          }
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Pilih nada dering';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    
                    // Instruksi Minum Obat checkboxes
                    _buildFieldLabel('Intruksi Minum Obat'),
                    Row(
                      children: [
                        // Setelah makan checkbox
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              if (!_setelahMakan) {
                                setState(() {
                                  _setelahMakan = true;
                                  _sebelumMakan = false;
                                });
                              }
                            },
                            borderRadius: BorderRadius.circular(4),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Checkbox(
                                      value: _setelahMakan,
                                      onChanged: (value) {
                                        if (value == true) {
                                          setState(() {
                                            _setelahMakan = true;
                                            _sebelumMakan = false;
                                          });
                                        }
                                      },
                                      activeColor: const Color(0xFF64D1DE),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Setelah makan',
                                    style: GoogleFonts.poppins(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Sebelum makan checkbox
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              if (!_sebelumMakan) {
                                setState(() {
                                  _sebelumMakan = true;
                                  _setelahMakan = false;
                                });
                              }
                            },
                            borderRadius: BorderRadius.circular(4),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: Checkbox(
                                      value: _sebelumMakan,
                                      onChanged: (value) {
                                        if (value == true) {
                                          setState(() {
                                            _sebelumMakan = true;
                                            _setelahMakan = false;
                                          });
                                        }
                                      },
                                      activeColor: const Color(0xFF64D1DE),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Sesudah makan',
                                    style: GoogleFonts.poppins(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    // Submit button
                    ElevatedButton(
                      onPressed: _isLoading 
                      ? null 
                      : _saveObat,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF64D1DE),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Simpan',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              
              // Loading overlay
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const CircularProgressIndicator(
                        color: Color(0xFF64D1DE),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to format TimeOfDay
  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = DateFormat.jm();  // Format like 10:00 AM
    return format.format(dt);
  }

  // Helper widgets
  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF64D1DE), width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        hintStyle: GoogleFonts.poppins(color: Colors.black38),
        errorStyle: GoogleFonts.poppins(color: Colors.red, fontSize: 12),
        isDense: true,
        // Add shadow
        // filled: true,
        // fillColor: Colors.white,
      ),
      style: GoogleFonts.poppins(),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      cursorColor: const Color(0xFF64D1DE),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required Function(String?) onChanged,
    required String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF64D1DE), width: 1),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        hintStyle: GoogleFonts.poppins(color: Colors.black38),
        errorStyle: GoogleFonts.poppins(color: Colors.red, fontSize: 12),
        // Add shadow
        // filled: true,
        // fillColor: Colors.white,
        isDense: true,
      ),
      style: GoogleFonts.poppins(),
      dropdownColor: Colors.white,
      icon: const Icon(CupertinoIcons.chevron_down, size: 16),
      isExpanded: true,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item, style: TextStyle(color: Colors.black)),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }
}