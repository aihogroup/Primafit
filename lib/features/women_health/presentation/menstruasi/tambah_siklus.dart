import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:primafit/features/women_health/presentation/menstruasi/model_menstruasi.dart';
import 'package:primafit/features/women_health/data/database_menstruasi.dart';

class AddCyclePage extends StatefulWidget {
  const AddCyclePage({super.key});

  @override
  _AddCyclePageState createState() => _AddCyclePageState();
}

class _AddCyclePageState extends State<AddCyclePage> {
  late DateTime _startDate;
  DateTime? _endDate;
  int _cycleLength = 28;
  int _periodLength = 5;
  String _notes = '';
  MoodType _mood = MoodType.normal;
  bool _isSubmitting = false;
  
  final DateFormat _dateFormat = DateFormat('d MMMM yyyy');
  final _formKey = GlobalKey<FormState>();
  
  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now();
    
    // Load settings to get default values
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    try {
      final settings = await DatabaseHelperMenstrual.instance.getSettings();
      setState(() {
        _cycleLength = settings['average_cycle_length'] as int;
        _periodLength = settings['average_period_length'] as int;
      });
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }
  
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate ? _startDate : (_endDate ?? DateTime.now());
    
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: isStartDate ? DateTime(2020) : _startDate,
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
    
    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
          // Reset end date if it's before the new start date
          if (_endDate != null && _endDate!.isBefore(_startDate)) {
            _endDate = null;
          }
        } else {
          _endDate = pickedDate;
          // Calculate period length
          if (_endDate != null) {
            _periodLength = _endDate!.difference(_startDate).inDays + 1;
          }
        }
      });
    }
  }
  
  Future<void> _saveCycle() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      // Calculate a temporary ID (will be replaced by database)
      final tempId = DateTime.now().millisecondsSinceEpoch;
      
      final cycle = MenstrualCycle(
        id: tempId,
        startDate: _startDate,
        endDate: _endDate,
        cycleLength: _cycleLength,
        periodLength: _periodLength,
        notes: _notes,
        mood: _mood,
      );
      
      await DatabaseHelperMenstrual.instance.insertCycle(cycle);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Siklus berhasil disimpan',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Error saving cycle: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal menyimpan siklus: $e',
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
  
  Widget _buildMoodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mood',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            children: MoodType.values.map((mood) {
              final isSelected = mood == _mood;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _mood = mood;
                  });
                },
                child: Container(
                  width: 60,
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? mood.color.withValues(alpha: 0.2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: isSelected 
                        ? Border.all(color: mood.color) 
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        mood.icon,
                        color: mood.color,
                        size: 28,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        mood.displayName,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                          color: mood.color,
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
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE9458D),
        elevation: 0,
        title: Text(
          'Catat Siklus Baru',
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
                      'Menyimpan siklus...',
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
                                CupertinoIcons.calendar_badge_plus,
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
                                    'Catat Siklus Menstruasi',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    'Masukkan informasi periode saat ini',
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
                      
                      // Start Date
                      Text(
                        'Tanggal Mulai',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selectDate(context, true),
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
                                _dateFormat.format(_startDate),
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
                      
                      const SizedBox(height: 16),
                      
                      // End Date (Optional)
                      Row(
                        children: [
                          Text(
                            'Tanggal Selesai',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(Opsional)',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () => _selectDate(context, false),
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
                                _endDate != null
                                    ? _dateFormat.format(_endDate!)
                                    : 'Pilih tanggal selesai (jika sudah berakhir)',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  color: _endDate != null
                                      ? Colors.black87
                                      : Colors.grey.shade500,
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
                      
                      const SizedBox(height: 16),
                      
                      // Cycle Length
                      Text(
                        'Panjang Siklus (hari)',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (_cycleLength > 15) {
                                  setState(() {
                                    _cycleLength--;
                                  });
                                }
                              },
                              icon: Icon(
                                CupertinoIcons.minus_circle,
                                color: Colors.grey.shade600,
                              ),
                              splashRadius: 24,
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  '$_cycleLength',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                if (_cycleLength < 50) {
                                  setState(() {
                                    _cycleLength++;
                                  });
                                }
                              },
                              icon: Icon(
                                CupertinoIcons.plus_circle,
                                color: Colors.grey.shade600,
                              ),
                              splashRadius: 24,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      Text(
                        'Rata-rata 21-35 hari dari awal satu periode ke awal periode berikutnya',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Period Length
                      Text(
                        'Panjang Periode (hari)',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (_periodLength > 1) {
                                  setState(() {
                                    _periodLength--;
                                  });
                                }
                              },
                              icon: Icon(
                                CupertinoIcons.minus_circle,
                                color: Colors.grey.shade600,
                              ),
                              splashRadius: 24,
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  '$_periodLength',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                if (_periodLength < 15) {
                                  setState(() {
                                    _periodLength++;
                                  });
                                }
                              },
                              icon: Icon(
                                CupertinoIcons.plus_circle,
                                color: Colors.grey.shade600,
                              ),
                              splashRadius: 24,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      Text(
                        'Rata-rata 3-7 hari lamanya menstruasi',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Mood selector
                      _buildMoodSelector(),
                      
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
                            hintText: 'Tambahkan catatan atau pengingat...',
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
                        onPressed: _saveCycle,
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
                          'Simpan',
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