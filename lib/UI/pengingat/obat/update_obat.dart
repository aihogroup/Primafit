import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:primafit/database/pengingat/database_obat.dart';

class UpdateObatScreen extends StatefulWidget {
  final int obatId;
  
  const UpdateObatScreen({Key? key, required this.obatId}) : super(key: key);

  @override
  State<UpdateObatScreen> createState() => _UpdateObatScreenState();
}

class _UpdateObatScreenState extends State<UpdateObatScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
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
  List<Map<String, dynamic>> _alarmList = [];
  
  // Medication instruction
  bool _setelahMakan = true;
  bool _sebelumMakan = false;

  // Lists for dropdown menus
  final List<String> _jenisObatList = ['Oral', 'Sirup', 'Injeksi', 'Topikal', 'Tablet', 'Kapsul', 'Tetes', 'Salep', 'Krim'];
  final List<String> _frekuensiList = ['1x sehari', '2x sehari', '3x sehari'];
  final List<String> _nadaList = ['Nada Default', 'Pilih dari perangkat'];

  bool _isLoading = true;
  bool _isSaving = false;
  bool _dataLoaded = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _loadObatData();
  }

  @override
  void dispose() {
    _namaObatController.dispose();
    _dosisController.dispose();
    _deskripsiController.dispose();
    _stokController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Load medication data from database
  Future<void> _loadObatData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Get medication data
      final obatData = await DatabaseObatHelper.instance.getObatById(widget.obatId);
      
      if (obatData != null) {
        // Set text controllers
        _namaObatController.text = obatData['nama'] ?? '';
        _dosisController.text = obatData['dosis'] ?? '';
        _deskripsiController.text = obatData['deskripsi'] ?? '';
        _stokController.text = obatData['stok'] ?? '';
        
        // Set dropdown values
        setState(() {
          _selectedJenisObat = obatData['jenis'];
          _selectedFrekuensi = obatData['frekuensi_harian'];
          _selectedNada = obatData['nada'];
          
          // Set medication instruction
          _setelahMakan = obatData['instruksi'] == 'Setelah makan';
          _sebelumMakan = !_setelahMakan;
        });
        
        // Get alarm data
        _alarmList = await DatabaseObatHelper.instance.getAlarmsByObatId(widget.obatId);
        
        // Set alarm times
        for (int i = 0; i < _alarmList.length && i < 3; i++) {
          final timestamp = _alarmList[i]['waktu_alarm'] as int;
          final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
          _selectedTimes[i] = TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
        }
        
        _dataLoaded = true;
        _animationController.forward();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
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

  // Function to get number of times based on frequency
  int get _numberOfTimes {
    if (_selectedFrekuensi == null) return 1;
    return int.parse(_selectedFrekuensi!.split('x')[0]);
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
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null && mounted) {
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

    if (result != null && mounted) {
      setState(() {
        _selectedNada = result.files.single.name;
      });
    }
  }

  // Helper method to format TimeOfDay
  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final format = DateFormat.jm();  // Format like 10:00 AM
    return format.format(dt);
  }

  // Save updated medication data to database
  Future<void> _updateObat() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      try {
        // Prepare data to update
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

        // Update obat record
        await DatabaseObatHelper.instance.updateObat(widget.obatId, obatData);

        // Delete existing alarm records
        for (var alarm in _alarmList) {
          await DatabaseObatHelper.instance.deleteAlarmObat(alarm['id']);
        }

        // Insert new alarm records
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
              'obat_id': widget.obatId,
              'waktu_alarm': alarmTime.millisecondsSinceEpoch,
            });
          }
        }

        // Animation before closing
        await _animationController.reverse();

        // Show success message and navigate back
        if (mounted) {
          Navigator.pop(context, true); // true indicates success
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data obat berhasil diperbarui!'),
              backgroundColor: Color(0xFF64D1DE),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal memperbarui data: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
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
        appBar: AppBar(
          title: Text(
            'Perbarui Data Obat',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: const Color(0xFF64D1DE),
          foregroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(CupertinoIcons.back),
            onPressed: () async {
              await _animationController.reverse();
              if (mounted) {
                Navigator.pop(context);
              }
            },
          ),
        ),
        body: SafeArea(
          child: _isLoading 
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF64D1DE),
                ),
              )
            : Stack(
                children: [
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        children: [
                          // Description text
                          Text(
                            'Perbarui data obat dan pengaturan alarm untuk kesehatan yang optimal.',
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
                            hint: 'Pilih jenis obat',
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
                          
                          // Stok Obat field
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
                            hint: 'Pilih frekuensi',
                            items: _frekuensiList,
                            onChanged: (value) {
                              setState(() {
                                _selectedFrekuensi = value;
                                // Adjust times when frequency changes
                                if (_selectedFrekuensi != null) {
                                  int newFreq = int.parse(_selectedFrekuensi!.split('x')[0]);
                                  // Keep existing times if possible
                                  for (int i = newFreq; i < _selectedTimes.length; i++) {
                                    _selectedTimes[i] = null;
                                  }
                                }
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
                                _buildFieldLabel('Waktu Ke-${i+1}'),
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
                            hint: 'Pilih nada',
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
                                          'Sebelum makan',
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
                          
                          // Update and Cancel buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: _isSaving 
                                    ? null 
                                    : () async {
                                        await _animationController.reverse();
                                        if (mounted) {
                                          Navigator.pop(context);
                                        }
                                      },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF64D1DE),
                                    side: const BorderSide(color: Color(0xFF64D1DE)),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'Batal',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton(
                                  onPressed: _isSaving 
                                    ? null 
                                    : _updateObat,
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
                                    'Simpan Perubahan',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  
                  // Loading overlay
                  if (_isSaving)
                    Container(
                      color: Colors.black.withOpacity(0.3),
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(
                                color: Color(0xFF64D1DE),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Menyimpan perubahan...',
                                style: GoogleFonts.poppins(),
                              ),
                            ],
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
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: TextFormField(
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
      ),
      style: GoogleFonts.poppins(),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      cursorColor: const Color(0xFF64D1DE),
    ),
  );
}

  Widget _buildDropdown({
  required String? value,
  required String hint,
  required List<String> items,
  required Function(String?) onChanged,
  required String? Function(String?)? validator,
}) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: DropdownButtonFormField<String>(
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
        isDense: true,
      ),
      style: GoogleFonts.poppins(),
      dropdownColor: Colors.white,
      icon: const Icon(CupertinoIcons.chevron_down, size: 16),
      isExpanded: true,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item, style: GoogleFonts.poppins(color: Colors.black)),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
    ),
  );
}

}