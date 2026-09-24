import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:primafit/features/women_health/presentation/menstruasi/model_menstruasi.dart';
import 'package:primafit/features/women_health/data/database_menstruasi.dart';

class AddSymptomPage extends StatefulWidget {
  final DateTime selectedDate;
  
  const AddSymptomPage({
    super.key, 
    required this.selectedDate,
  });

  @override
  _AddSymptomPageState createState() => _AddSymptomPageState();
}

class _AddSymptomPageState extends State<AddSymptomPage> {
  late DateTime _selectedDate;
  SymptomType _selectedSymptomType = SymptomType.cramps;
  int _intensity = 3;
  String _notes = '';
  bool _isSubmitting = false;
  int? _currentCycleId;
  
  final _formKey = GlobalKey<FormState>();
  final DateFormat _dateFormat = DateFormat('d MMMM yyyy');
  final _searchController = TextEditingController();
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    _loadCurrentCycle();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  // Load current cycle to associate symptom with
  Future<void> _loadCurrentCycle() async {
    try {
      final latestCycle = await DatabaseHelperMenstrual.instance.getLatestCycle();
      
      if (latestCycle != null) {
        setState(() {
          _currentCycleId = latestCycle.id;
        });
      }
    } catch (e) {
      debugPrint('Error loading current cycle: $e');
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
  
  Future<void> _saveSymptom() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Check if a cycle exists
    if (_currentCycleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Harap catat siklus menstruasi terlebih dahulu',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      // Calculate a temporary ID (will be replaced by database)
      final tempId = DateTime.now().millisecondsSinceEpoch;
      
      final symptom = MenstrualSymptom(
        id: tempId,
        cycleId: _currentCycleId!,
        date: _selectedDate,
        type: _selectedSymptomType,
        intensity: _intensity,
        notes: _notes,
      );
      
      await DatabaseHelperMenstrual.instance.insertSymptom(symptom);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gejala berhasil disimpan',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Error saving symptom: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal menyimpan gejala: $e',
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
  
  // Filter symptoms based on search query
  List<SymptomType> get _filteredSymptoms {
    if (_searchQuery.isEmpty) {
      return SymptomType.values;
    }
    
    return SymptomType.values.where((symptom) {
      return symptom.displayName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }
  
  Widget _buildSymptomSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search box
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari gejala...',
              prefixIcon: Icon(
                CupertinoIcons.search,
                color: Colors.grey.shade600,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black87,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        
        // Symptoms grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.9,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: _filteredSymptoms.length,
          itemBuilder: (context, index) {
            final symptom = _filteredSymptoms[index];
            final isSelected = symptom == _selectedSymptomType;
            
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSymptomType = symptom;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? Colors.purple.shade100 : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.purple.shade300 : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.purple.shade200.withValues(alpha: 0.5),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      symptom.icon,
                      color: isSelected ? Colors.purple.shade700 : Colors.grey.shade700,
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      symptom.displayName,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? Colors.purple.shade700 : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
  
  Widget _buildIntensitySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Intensitas',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ringan',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    'Sedang',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    'Berat',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Slider(
                value: _intensity.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                activeColor: Colors.purple.shade400,
                inactiveColor: Colors.grey.shade300,
                onChanged: (value) {
                  setState(() {
                    _intensity = value.round();
                  });
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(5, (index) {
                  final level = index + 1;
                  return Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: level <= _intensity
                          ? Colors.purple.shade400
                          : Colors.grey.shade200,
                    ),
                    child: Center(
                      child: Text(
                        '$level',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: level <= _intensity
                              ? Colors.white
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
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
          'Tambah Gejala',
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
                      'Menyimpan gejala...',
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
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.purple.shade200,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.purple.shade100,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                CupertinoIcons.bandage,
                                color: Colors.purple.shade700,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Catat Gejala',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    'Pilih gejala dan intensitasnya',
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
                        'Tanggal',
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
                      
                      // Symptom type
                      Text(
                        'Jenis Gejala',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildSymptomSelector(),
                      
                      const SizedBox(height: 24),
                      
                      // Intensity
                      _buildIntensitySelector(),
                      
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
                            hintText: 'Tambahkan detail tentang gejala ini...',
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
                            setState(() {
                              _notes = value;
                            });
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Save button
                      ElevatedButton(
                        onPressed: _saveSymptom,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.purple.shade500,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: Text(
                          'Simpan Gejala',
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