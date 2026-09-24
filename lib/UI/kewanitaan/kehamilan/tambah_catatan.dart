import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:primafit/UI/kewanitaan/kehamilan/model_kehamilan.dart';
import 'package:primafit/database/kewanitaan/database_kehamilan.dart';

class AddNotePage extends StatefulWidget {
  final int pregnancyId;
  final DateTime selectedDate;
  
  const AddNotePage({
    Key? key, 
    required this.pregnancyId,
    required this.selectedDate,
  }) : super(key: key);

  @override
  _AddNotePageState createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  late DateTime _selectedDate;
  String _title = '';
  String _content = '';
  NoteType _selectedNoteType = NoteType.general;
  bool _isSubmitting = false;
  
  final _formKey = GlobalKey<FormState>();
  final DateFormat _dateFormat = DateFormat('d MMMM yyyy');
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 30)), // Allow future dates for appointments
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
  
  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });
    
    try {
      // Calculate a temporary ID (will be replaced by database)
      final tempId = DateTime.now().millisecondsSinceEpoch;
      
      final note = PregnancyNote(
        id: tempId,
        pregnancyId: widget.pregnancyId,
        date: _selectedDate,
        title: _title,
        content: _content,
        type: _selectedNoteType,
      );
      
      await DatabaseHelperPregnancy.instance.insertNote(note);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Catatan berhasil disimpan',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('Error saving note: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal menyimpan catatan: $e',
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
  
  Widget _buildNoteTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jenis Catatan',
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
            children: NoteType.values.map((type) {
              final isSelected = type == _selectedNoteType;
              
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedNoteType = type;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? type.color.withOpacity(0.2) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? type.color : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        type.icon,
                        size: 16,
                        color: isSelected ? type.color : Colors.grey.shade700,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        type.displayName,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? type.color : Colors.grey.shade700,
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
    // Get the appropriate color based on note type
    final Color noteColor = _selectedNoteType.color;
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE9458D),
        elevation: 0,
        title: Text(
          'Tambah Catatan',
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
                      'Menyimpan catatan...',
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
                          color: noteColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: noteColor.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: noteColor.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _selectedNoteType.icon,
                                color: noteColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Catatan ${_selectedNoteType.displayName}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    'Catat hal penting selama kehamilan Anda',
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
                      
                      // Note Type
                      _buildNoteTypeSelector(),
                      
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
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            hintText: 'Masukkan judul catatan',
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Harap masukkan judul catatan';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            _title = value;
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Content
                      Text(
                        'Isi Catatan',
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
                          controller: _contentController,
                          maxLines: 8,
                          decoration: InputDecoration(
                            hintText: 'Tulis catatan Anda di sini...',
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Harap masukkan isi catatan';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            _content = value;
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Tips for different note types
                      _buildNoteTips(),
                      
                      const SizedBox(height: 40),
                      
                      // Save button
                      ElevatedButton(
                        onPressed: _saveNote,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: noteColor,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: Text(
                          'Simpan Catatan',
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
  
  Widget _buildNoteTips() {
    // Different tips based on note type
    String tipText = '';
    
    switch (_selectedNoteType) {
      case NoteType.general:
        tipText = 'Catat perasaan, pengalaman, dan momen penting kehamilan Anda.';
        break;
      case NoteType.appointment:
        tipText = 'Catat detail janji temu, seperti tanggal, waktu, tempat, dan persiapan yang diperlukan.';
        break;
      case NoteType.diary:
        tipText = 'Tulis tentang perasaan dan pengalaman harian selama kehamilan Anda.';
        break;
      case NoteType.question:
        tipText = 'Catat pertanyaan yang ingin Anda tanyakan pada dokter atau bidan pada kunjungan berikutnya.';
        break;
      case NoteType.milestone:
        tipText = 'Catat momen penting kehamilan, seperti merasakan tendangan pertama atau mengetahui jenis kelamin bayi.';
        break;
      case NoteType.babyNames:
        tipText = 'Daftar nama-nama bayi yang Anda suka dan artinya.';
        break;
      case NoteType.other:
        tipText = 'Gunakan untuk jenis catatan lain yang tidak termasuk dalam kategori di atas.';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _selectedNoteType.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.lightbulb_fill,
            size: 16,
            color: _selectedNoteType.color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tipText,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}