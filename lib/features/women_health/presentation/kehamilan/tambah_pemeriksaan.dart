import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:primafit/features/women_health/presentation/kehamilan/model_kehamilan.dart';
import 'package:primafit/features/women_health/data/database_kehamilan.dart';

class AddCheckupPage extends StatefulWidget {
  final int pregnancyId;
  final DateTime selectedDate;
  
  const AddCheckupPage({
    super.key, 
    required this.pregnancyId,
    required this.selectedDate,
  });

  @override
  _AddCheckupPageState createState() => _AddCheckupPageState();
}

class _AddCheckupPageState extends State<AddCheckupPage> {
  late DateTime _selectedDate;
  CheckupType _selectedCheckupType = CheckupType.regular;
  double _weight = 0.0;
  double _bpSystolic = 120.0;
  double _bpDiastolic = 80.0;
  double _fetalHeartRate = 0.0;
  double _fundusHeight = 0.0;
  String _doctorNotes = '';
  String _nextSteps = '';
  final List<String> _medications = [];
  String _medicationInput = '';
  bool _isSubmitting = false;
  
  final _formKey = GlobalKey<FormState>();
  final DateFormat _dateFormat = DateFormat('d MMMM yyyy');
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _bpSystolicController = TextEditingController();
  final TextEditingController _bpDiastolicController = TextEditingController();
  final TextEditingController _fetalHeartRateController = TextEditingController();
  final TextEditingController _fundusHeightController = TextEditingController();
  final TextEditingController _medicationController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    
    // Set default values
    _weightController.text = '0.0';
    _bpSystolicController.text = '120';
    _bpDiastolicController.text = '80';
    _fetalHeartRateController.text = '0';
    _fundusHeightController.text = '0';
    
    _loadLastCheckupData();
  }
  
  @override
  void dispose() {
    _weightController.dispose();
    _bpSystolicController.dispose();
    _bpDiastolicController.dispose();
    _fetalHeartRateController.dispose();
    _fundusHeightController.dispose();
    _medicationController.dispose();
    super.dispose();
  }
  
  Future<void> _loadLastCheckupData() async {
    try {
      // Get the latest checkup data to prefill some fields
      final latestCheckup = await DatabaseHelperPregnancy.instance.getLatestCheckup(widget.pregnancyId);
      
      if (latestCheckup != null) {
        setState(() {
          _weightController.text = latestCheckup.weight.toString();
          _weight = latestCheckup.weight;
        });
      }
      
      // Get latest weight record if available
      final weights = await DatabaseHelperPregnancy.instance.getWeightsForPregnancy(widget.pregnancyId);
      if (weights.isNotEmpty) {
        final latestWeight = weights.last;
        setState(() {
          _weightController.text = latestWeight.weight.toString();
          _weight = latestWeight.weight;
        });
      }
    } catch (e) {
      debugPrint('Error loading previous checkup data: $e');
    }
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
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
    
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }
  
  void _addMedication() {
    if (_medicationInput.isNotEmpty) {
      setState(() {
        _medications.add(_medicationInput);
        _medicationInput = '';
        _medicationController.clear();
      });
    }
  }
  
  void _removeMedication(int index) {
    setState(() {
      _medications.removeAt(index);
    });
  }
  
  Future<void> _saveCheckup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      // Get values from controllers
      _weight = double.parse(_weightController.text);
      _bpSystolic = double.parse(_bpSystolicController.text);
      _bpDiastolic = double.parse(_bpDiastolicController.text);
      _fetalHeartRate = _fetalHeartRateController.text.isNotEmpty 
          ? double.parse(_fetalHeartRateController.text) 
          : 0.0;
      _fundusHeight = _fundusHeightController.text.isNotEmpty
          ? double.parse(_fundusHeightController.text)
          : 0.0;
      
      // Calculate a temporary ID (will be replaced by database)
      final tempId = DateTime.now().millisecondsSinceEpoch;
      
      final checkup = PregnancyCheckup(
        id: tempId,
        pregnancyId: widget.pregnancyId,
        date: _selectedDate,
        type: _selectedCheckupType,
        weight: _weight,
        bpSystolic: _bpSystolic,
        bpDiastolic: _bpDiastolic,
        fetalHeartRate: _fetalHeartRate,
        fundusHeight: _fundusHeight,
        doctorNotes: _doctorNotes,
        nextSteps: _nextSteps,
        medications: _medications,
      );
      
      await DatabaseHelperPregnancy.instance.insertCheckup(checkup);
      
      // Also save the weight as a separate weight record if it's a regular checkup
      if (_selectedCheckupType == CheckupType.regular) {
        final weightRecord = PregnancyWeight(
          id: DateTime.now().millisecondsSinceEpoch + 1,
          pregnancyId: widget.pregnancyId,
          date: _selectedDate,
          weight: _weight,
          notes: 'Diukur saat pemeriksaan ${_selectedCheckupType.displayName}',
        );
        
        await DatabaseHelperPregnancy.instance.insertWeight(weightRecord);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Data pemeriksaan berhasil disimpan',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Error saving checkup data: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal menyimpan data pemeriksaan: $e',
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
  
  Widget _buildCheckupTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jenis Pemeriksaan',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        
        // Wrap the chips in a horizontal scrollable
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: CheckupType.values.map((type) {
              final isSelected = type == _selectedCheckupType;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCheckupType = type;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.green.shade100 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Colors.green.shade600 : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        type.icon,
                        size: 16,
                        color: isSelected ? Colors.green.shade800 : Colors.grey.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        type.displayName,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? Colors.green.shade800 : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
  
  Widget _buildNumberField({
    required String label,
    required String hint,
    required TextEditingController controller,
    String? unit,
    bool required = true,
    TextInputType keyboardType = TextInputType.number,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            if (!required)
              Text(
                ' (Opsional)',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.shade600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              suffixText: unit,
              suffixStyle: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black87,
            ),
            validator: validator ?? (value) {
              if (required && (value == null || value.isEmpty)) {
                return 'Harap masukkan $label';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE9458D),
        elevation: 0,
        title: Text(
          'Tambah Pemeriksaan',
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
                      'Menyimpan data pemeriksaan...',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              )
            : Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.green.shade200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              CupertinoIcons.doc_checkmark,
                              color: Colors.green.shade700,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Catat Pemeriksaan Kehamilan',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  'Rekam hasil pemeriksaan kesehatan ibu dan janin',
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
                    
                    // Date
                    Text(
                      'Tanggal Pemeriksaan',
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
                              _dateFormat.format(_selectedDate),
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
                    
                    const SizedBox(height: 24),
                    
                    // Checkup Type
                    _buildCheckupTypeSelector(),
                    
                    const SizedBox(height: 24),
                    
                    // Basic measurements
                    Text(
                      'Pengukuran Dasar',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Weight
                    _buildNumberField(
                      label: 'Berat Badan',
                      hint: 'Masukkan berat badan',
                      controller: _weightController,
                      unit: 'kg',
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Blood Pressure
                    Text(
                      'Tekanan Darah',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: TextFormField(
                              controller: _bpSystolicController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'Sistolik',
                                hintStyle: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                suffixText: 'mmHg',
                              ),
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Wajib diisi';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: TextFormField(
                              controller: _bpDiastolicController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'Diastolik',
                                hintStyle: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                suffixText: 'mmHg',
                              ),
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Wajib diisi';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Fetal measurements
                    Text(
                      'Pemeriksaan Janin',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Fetal Heart Rate
                    _buildNumberField(
                      label: 'Detak Jantung Janin',
                      hint: 'Masukkan detak jantung janin',
                      controller: _fetalHeartRateController,
                      unit: 'bpm',
                      required: false,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Fundus Height
                    _buildNumberField(
                      label: 'Tinggi Fundus',
                      hint: 'Masukkan tinggi fundus',
                      controller: _fundusHeightController,
                      unit: 'cm',
                      required: false,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Notes and Medications
                    Text(
                      'Catatan & Instruksi',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Doctor Notes
                    Text(
                      'Catatan Dokter (Opsional)',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextFormField(
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Catatan dari dokter atau tenaga medis...',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        onChanged: (value) {
                          _doctorNotes = value;
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Next Steps
                    Text(
                      'Langkah Selanjutnya (Opsional)',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextFormField(
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'Instruksi untuk tindakan berikutnya...',
                          hintStyle: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(16),
                        ),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        onChanged: (value) {
                          _nextSteps = value;
                        },
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Medications
                    Text(
                      'Obat-obatan (Opsional)',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: TextFormField(
                              controller: _medicationController,
                              decoration: InputDecoration(
                                hintText: 'Masukkan nama obat',
                                hintStyle: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              ),
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                              onChanged: (value) {
                                _medicationInput = value;
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _addMedication,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.green.shade600,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Icon(CupertinoIcons.add),
                        ),
                      ],
                    ),
                    
                    // Medication list
                    if (_medications.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Daftar Obat:',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...List.generate(_medications.length, (index) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      CupertinoIcons.capsule,
                                      size: 16,
                                      color: Colors.green.shade700,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _medications[index],
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () => _removeMedication(index),
                                      icon: Icon(
                                        CupertinoIcons.xmark_circle,
                                        size: 18,
                                        color: Colors.red.shade400,
                                      ),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: 40),
                    
                    // Save button
                    ElevatedButton(
                      onPressed: _saveCheckup,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green.shade600,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: Text(
                        'Simpan Pemeriksaan',
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
    );
  }
}