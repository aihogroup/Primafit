import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:primafit/UI/kewanitaan/kehamilan/model_kehamilan.dart';
import 'package:primafit/database/kewanitaan/database_kehamilan.dart';

class AddWeightPage extends StatefulWidget {
  final int pregnancyId;
  final DateTime selectedDate;
  
  const AddWeightPage({
    Key? key, 
    required this.pregnancyId,
    required this.selectedDate,
  }) : super(key: key);

  @override
  _AddWeightPageState createState() => _AddWeightPageState();
}

class _AddWeightPageState extends State<AddWeightPage> {
  late DateTime _selectedDate;
  double _weight = 0.0;
  String _notes = '';
  bool _isSubmitting = false;
  double? _previousWeight;
  double? _initialWeight;
  
  final _formKey = GlobalKey<FormState>();
  final DateFormat _dateFormat = DateFormat('d MMMM yyyy');
  final TextEditingController _weightController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    _loadPreviousWeightData();
  }
  
  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }
  
  Future<void> _loadPreviousWeightData() async {
    try {
      // Get all weight records
      final weightRecords = await DatabaseHelperPregnancy.instance.getWeightsForPregnancy(widget.pregnancyId);
      
      if (weightRecords.isNotEmpty) {
        // Set initial weight (first recorded)
        _initialWeight = weightRecords.first.weight;
        
        // Set latest weight as previous
        _previousWeight = weightRecords.last.weight;
        
        // Set controller with the latest weight
        setState(() {
          _weightController.text = _previousWeight!.toString();
          _weight = _previousWeight!;
        });
      }
    } catch (e) {
      debugPrint('Error loading previous weight data: $e');
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
  
  Future<void> _saveWeight() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      // Get value from controller
      _weight = double.parse(_weightController.text);
      
      // Calculate a temporary ID (will be replaced by database)
      final tempId = DateTime.now().millisecondsSinceEpoch;
      
      final weightRecord = PregnancyWeight(
        id: tempId,
        pregnancyId: widget.pregnancyId,
        date: _selectedDate,
        weight: _weight,
        notes: _notes,
      );
      
      await DatabaseHelperPregnancy.instance.insertWeight(weightRecord);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Data berat badan berhasil disimpan',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Error saving weight data: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal menyimpan data berat badan: $e',
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
    // Calculate weight changes
    String weightChangeText = '';
    if (_initialWeight != null && _weight > 0) {
      final totalChange = _weight - _initialWeight!;
      weightChangeText = '${totalChange > 0 ? '+' : ''}${totalChange.toStringAsFixed(1)} kg dari awal kehamilan';
    }
    
    String previousWeightChangeText = '';
    if (_previousWeight != null && _weight > 0 && _previousWeight != _weight) {
      final change = _weight - _previousWeight!;
      previousWeightChangeText = '${change > 0 ? '+' : ''}${change.toStringAsFixed(1)} kg dari pengukuran terakhir';
    }
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE9458D),
        elevation: 0,
        title: Text(
          'Catat Berat Badan',
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
                      'Menyimpan data berat badan...',
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
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blue.shade200,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                CupertinoIcons.arrow_up_right_square,
                                color: Colors.blue.shade700,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Catat Berat Badan',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    'Pantau perkembangan berat badan selama kehamilan',
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
                        'Tanggal Pengukuran',
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
                      
                      // Weight
                      Text(
                        'Berat Badan',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
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
                          controller: _weightController,
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            hintText: 'Masukkan berat badan',
                            hintStyle: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            suffixText: 'kg',
                            suffixStyle: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Harap masukkan berat badan';
                            }
                            
                            if (double.tryParse(value) == null) {
                              return 'Masukkan angka yang valid';
                            }
                            
                            return null;
                          },
                          onChanged: (value) {
                            if (value.isNotEmpty && double.tryParse(value) != null) {
                              _weight = double.parse(value);
                              setState(() {}); // Refresh to update weight change text
                            }
                          },
                        ),
                      ),
                      
                      // Weight change indicators
                      if (weightChangeText.isNotEmpty || previousWeightChangeText.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (weightChangeText.isNotEmpty)
                                Text(
                                  weightChangeText,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              if (previousWeightChangeText.isNotEmpty) ...[
                                if (weightChangeText.isNotEmpty)
                                  const SizedBox(height: 4),
                                Text(
                                  previousWeightChangeText,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: previousWeightChangeText.contains('+') 
                                        ? Colors.green.shade700 
                                        : Colors.red.shade700,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 24),
                      
                      // Notes
                      Text(
                        'Catatan (Opsional)',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
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
                            hintText: 'Tambahkan catatan tentang berat badan Anda...',
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
                            _notes = value;
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Weight gain guidance
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  CupertinoIcons.info_circle_fill,
                                  color: Colors.amber.shade700,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Panduan Kenaikan Berat Badan',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Kenaikan berat badan yang disarankan selama kehamilan:',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.grey.shade800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildGuidanceRow('BMI < 18.5 (Kurus)', '12.5-18 kg'),
                            _buildGuidanceRow('BMI 18.5-24.9 (Normal)', '11.5-16 kg'),
                            _buildGuidanceRow('BMI 25-29.9 (Gemuk)', '7-11.5 kg'),
                            _buildGuidanceRow('BMI ≥ 30 (Obesitas)', '5-9 kg'),
                            const SizedBox(height: 8),
                            Text(
                              'Catatan: Ini hanya panduan umum. Konsultasikan dengan dokter untuk rekomendasi yang lebih spesifik untuk kondisi Anda.',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Save button
                      ElevatedButton(
                        onPressed: _saveWeight,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue.shade600,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: Text(
                          'Simpan Berat Badan',
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
  
  Widget _buildGuidanceRow(String category, String range) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.amber.shade800,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              category,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          Text(
            range,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}