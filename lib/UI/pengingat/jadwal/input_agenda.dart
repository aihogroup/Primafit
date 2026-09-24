import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:primafit/database/pengingat/database_agenda.dart';
import 'package:primafit/UI/pengingat/jadwal/utility.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class InputAgendaScreen extends StatefulWidget {
  final Agenda? agenda; // Optional agenda for editing
  final DateTime? selectedDate;

  const InputAgendaScreen({Key? key, this.agenda, this.selectedDate}) : super(key: key);

  @override
  State<InputAgendaScreen> createState() => _InputAgendaScreenState();
}

class _InputAgendaScreenState extends State<InputAgendaScreen> with SingleTickerProviderStateMixin {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();
  
  // Text controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();
  final _timeController = TextEditingController();
  
  // Date and time variables
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  
  // Loading state
  bool _isLoading = false;
  bool _isDeleting = false;
  
  // Animation controller
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Colors
  final Color _themeColor = const Color(0xFF64D1DE);
  final Color _errorColor = Colors.redAccent;
  
  // Agenda properties
  late bool _isCompleted;
  String? _reminderTime;
  String? _repeatType;
  int? _repeatInterval = 1;
  late Color _selectedColor;
  
  final List<String> _reminderOptions = ['5min', '15min', '30min', '1hour', '2hours', '1day'];
  final List<String> _repeatOptions = ['daily', 'weekly', 'monthly', 'yearly'];
  
  @override
  void initState() {
    super.initState();
    
    // Set up animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _animationController.forward();
    
    // Initialize properties
    if (widget.agenda != null) {
      // Editing mode
      _titleController.text = widget.agenda!.title;
      if (widget.agenda!.description != null) {
        _descriptionController.text = widget.agenda!.description!;
      }
      
      _selectedDate = DateTimeUtils.parseDateFromDb(widget.agenda!.date);
      _selectedTime = DateTimeUtils.parseTimeFromDb(widget.agenda!.time);
      
      _dateController.text = widget.agenda!.date;
      _timeController.text = widget.agenda!.time;
      
      _isCompleted = widget.agenda!.isCompleted == 1;
      _reminderTime = widget.agenda!.reminderTime;
      _repeatType = widget.agenda!.repeatType;
      _repeatInterval = widget.agenda!.repeatInterval ?? 1;
      
      _selectedColor = widget.agenda!.color != null 
          ? AppColors.fromHex(widget.agenda!.color) 
          : _themeColor;
    } else {
      // Tambahkan Agenda mode
      _selectedDate = widget.selectedDate ?? DateTime.now();
      _selectedTime = TimeOfDay.now();
      
      _dateController.text = DateTimeUtils.formatDateToDb(_selectedDate);
      _timeController.text = DateTimeUtils.formatTimeToDb(_selectedTime);
      
      _isCompleted = false;
      _reminderTime = null;
      _repeatType = null;
      _repeatInterval = 1;
      _selectedColor = _themeColor;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _themeColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: _themeColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateTimeUtils.formatDateToDb(_selectedDate);
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _themeColor,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: _themeColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _timeController.text = DateTimeUtils.formatTimeToDb(_selectedTime);
      });
    }
  }

  void _selectColor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Select Agenda Color',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _selectedColor,
            onColorChanged: (color) {
              setState(() {
                _selectedColor = color;
              });
            },
            pickerAreaHeightPercent: 0.8,
            enableAlpha: false,
            displayThumbColor: true,
            paletteType: PaletteType.hsv,
            pickerAreaBorderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Select',
              style: GoogleFonts.poppins(
                color: _themeColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isValidDateTime() {
    // Allow editing past dates but not creating Tambahkan Agendas with past dates
    if (widget.agenda == null) {
      final now = DateTime.now();
      final selectedDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );
      
      if (selectedDateTime.isBefore(now)) {
        _showErrorDialog('Cannot create an agenda with a past date and time.');
        return false;
      }
    }
    return true;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Error',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: GoogleFonts.poppins(
                color: _themeColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation() {
    UiUtils.showConfirmDialog(
      context: context,
      title: 'Delete Agenda',
      message: 'Are you sure you want to delete this agenda?',
      confirmText: 'Delete',
      confirmColor: Colors.red,
    ).then((confirmed) {
      if (confirmed) {
        _deleteAgenda();
      }
    });
  }

  Future<void> _saveAgenda() async {
    if (_formKey.currentState!.validate() && _isValidDateTime()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        // Prepare agenda object
        final agenda = Agenda(
          id: widget.agenda?.id,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim().isEmpty 
            ? null 
            : _descriptionController.text.trim(),
          date: _dateController.text,
          time: _timeController.text,
          isCompleted: _isCompleted ? 1 : 0,
          reminderTime: _reminderTime,
          repeatType: _repeatType,
          repeatInterval: _repeatType != null ? _repeatInterval : null,
          color: AppColors.toHex(_selectedColor),
        );
        
        // Save to database
        if (widget.agenda == null) {
          // Create Tambahkan Agenda
          await DatabaseAgenda.instance.insertAgenda(agenda);
          if (!mounted) return;
          
          UiUtils.showSnackBar(
            context, 
            message: 'Agenda created successfully', 
            type: SnackBarType.success
          );
        } else {
          // Update existing agenda
          await DatabaseAgenda.instance.updateAgenda(agenda);
          if (!mounted) return;
          
          UiUtils.showSnackBar(
            context, 
            message: 'Agenda updated successfully', 
            type: SnackBarType.success
          );
        }
        
        // Return to previous screen
        if (mounted) {
          Navigator.of(context).pop('refresh');
        }
      } catch (e) {
        _showErrorDialog('Failed to save agenda: $e');
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _deleteAgenda() async {
    if (widget.agenda?.id == null) return;
    
    setState(() {
      _isDeleting = true;
    });
    
    try {
      await DatabaseAgenda.instance.deleteAgenda(widget.agenda!.id!);
      if (!mounted) return;
      
      UiUtils.showSnackBar(
        context, 
        message: 'Agenda deleted successfully', 
        type: SnackBarType.success
      );
      
      Navigator.pop(context, 'deleted');
    } catch (e) {
      _showErrorDialog('Failed to delete agenda: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

  void _toggleCompletionStatus() {
    setState(() {
      _isCompleted = !_isCompleted;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: isDarkMode ? AppColors.darkSurfaceColor : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
          tooltip: 'Back',
        ),
        title: Text(
          widget.agenda == null ? 'Tambahkan Agenda' : 'Edit Agenda',
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: widget.agenda != null
            ? [
                IconButton(
                  icon: const Icon(
                    CupertinoIcons.delete,
                    color: Colors.red,
                  ),
                  onPressed: _showDeleteConfirmation,
                  tooltip: 'Delete agenda',
                ),
              ]
            : null,
      ),
      body: _isLoading || _isDeleting
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(_themeColor),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isDeleting ? 'Deleting...' : 'Saving...',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
          : SafeArea(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Title Field
                      _buildTextField(
                        controller: _titleController,
                        labelText: 'Nama Agenda',
                        icon: CupertinoIcons.doc_text,
                        validator: (value) => UiUtils.validateRequired(value, 'Title'),
                      ),
                      
                      // Description Field
                      _buildTextField(
                        controller: _descriptionController,
                        labelText: 'Deskripsi Agenda',
                        icon: CupertinoIcons.doc_plaintext,
                        maxLines: 5,
                        optional: true,
                      ),
                      
                      // Date Field
                      _buildDateTimeField(
                        controller: _dateController,
                        labelText: 'Tanggal',
                        icon: CupertinoIcons.calendar,
                        onTap: () => _selectDate(context),
                      ),
                      
                      // Time Field
                      _buildDateTimeField(
                        controller: _timeController,
                        labelText: 'Pukul',
                        icon: CupertinoIcons.clock,
                        onTap: () => _selectTime(context),
                      ),
                      
                      // Reminder Field
                      _buildReminderSelector(),
                      
                      // Repeat Field
                      _buildRepeatSelector(),
                      
                      // Color Selector
                      _buildColorSelector(),
                      
                      // Completion Status
                      _buildCompletionToggle(),
                      
                      // Save Button
                      _buildSaveButton(),
                      
                      // Delete Button
                      if (widget.agenda != null)
                        _buildDeleteButton(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    int maxLines = 1,
    bool optional = false,
    String? Function(String?)? validator,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _themeColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _themeColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: labelText,
          alignLabelWithHint: maxLines > 1,
          labelStyle: GoogleFonts.poppins(
            color: _themeColor,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 8),
            child: Icon(
              icon,
              color: _themeColor,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
          suffixIcon: optional
              ? const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Text(
                    '(Opsional)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                )
              : null,
          suffixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
        ),
        style: GoogleFonts.poppins(
          fontSize: 16,
        ),
        textCapitalization: maxLines > 1 
            ? TextCapitalization.sentences 
            : TextCapitalization.words,
        validator: validator,
      ),
    );
  }
  
  Widget _buildDateTimeField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _themeColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _themeColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: GoogleFonts.poppins(
            color: _themeColor,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          prefixIcon: Icon(
            icon,
            color: _themeColor,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              CupertinoIcons.arrow_down_circle,
              color: _themeColor,
            ),
            onPressed: onTap,
          ),
        ),
        style: GoogleFonts.poppins(
          fontSize: 16,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please select a $labelText';
          }
          return null;
        },
        onTap: onTap,
      ),
    );
  }

  Widget _buildReminderSelector() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _themeColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _themeColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 12, bottom: 8),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.bell,
                  color: _themeColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Ingatkan Sebelum',
                  style: GoogleFonts.poppins(
                    color: _themeColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // No reminder option
                ChoiceChip(
                  label: Text(
                    'Tidak',
                    style: GoogleFonts.poppins(
                      color: _reminderTime == null ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  selected: _reminderTime == null,
                  selectedColor: _themeColor,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _reminderTime = null;
                      });
                    }
                  },
                ),
                
                // Reminder options
                ..._reminderOptions.map((option) {
                  String displayText;
                  switch (option) {
                    case '5min':
                      displayText = '5 min';
                      break;
                    case '15min':
                      displayText = '15 min';
                      break;
                    case '30min':
                      displayText = '30 min';
                      break;
                    case '1hour':
                      displayText = '1 jam';
                      break;
                    case '2hours':
                      displayText = '2 jam';
                      break;
                    case '1day':
                      displayText = '1 Hari';
                      break;
                    default:
                      displayText = option;
                  }
                  
                  return ChoiceChip(
                    label: Text(
                      displayText,
                      style: GoogleFonts.poppins(
                        color: _reminderTime == option ? Colors.white : Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                    selected: _reminderTime == option,
                    selectedColor: _themeColor,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _reminderTime = option;
                        });
                      }
                    },
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRepeatSelector() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _themeColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _themeColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 12, bottom: 8),
            child: Row(
              children: [
                Icon(
                  CupertinoIcons.repeat,
                  color: _themeColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Repeat',
                  style: GoogleFonts.poppins(
                    color: _themeColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // No repeat option
                ChoiceChip(
                  label: Text(
                    'Tidak',
                    style: GoogleFonts.poppins(
                      color: _repeatType == null ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  selected: _repeatType == null,
                  selectedColor: _themeColor,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _repeatType = null;
                      });
                    }
                  },
                ),
                
                // Repeat type options
                ..._repeatOptions.map((option) {
                  String displayText;
                  switch (option) {
                    case 'daily':
                      displayText = 'Harian';
                      break;
                    case 'weekly':
                      displayText = 'Mingguan';
                      break;
                    case 'monthly':
                      displayText = 'Bulanan';
                      break;
                    case 'yearly':
                      displayText = 'Tahunan';
                      break;
                    default:
                      displayText = option;
                  }
                  
                  return ChoiceChip(
                    label: Text(
                      displayText,
                      style: GoogleFonts.poppins(
                        color: _repeatType == option ? Colors.white : Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                    selected: _repeatType == option,
                    selectedColor: _themeColor,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _repeatType = option;
                          if (_repeatInterval == null) {
                            _repeatInterval = 1;
                          }
                        });
                      }
                    },
                  );
                }).toList(),
              ],
            ),
          ),
          
          // Repeat interval
          if (_repeatType != null)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
              child: Row(
                children: [
                  Text(
                    'Every',
                    style: GoogleFonts.poppins(
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 60,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () {
                            if (_repeatInterval! > 1) {
                              setState(() {
                                _repeatInterval = _repeatInterval! - 1;
                              });
                            }
                          },
                          child: const Icon(
                            CupertinoIcons.minus,
                            size: 16,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          '$_repeatInterval',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _repeatInterval = _repeatInterval! + 1;
                            });
                          },
                          child: const Icon(
                            CupertinoIcons.plus,
                            size: 16,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _repeatType == 'daily' ? 'day(s)' :
                    _repeatType == 'weekly' ? 'week(s)' :
                    _repeatType == 'monthly' ? 'month(s)' : 'year(s)',
                    style: GoogleFonts.poppins(
                      color: Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildColorSelector() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _themeColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _themeColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: _selectColor,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                CupertinoIcons.color_filter,
                color: _themeColor,
              ),
              const SizedBox(width: 12),
              Text(
                'Warna Agenda',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: _selectedColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                CupertinoIcons.arrow_right,
                color: Colors.grey.shade400,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionToggle() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _isCompleted
            ? Colors.green.withOpacity(0.1)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isCompleted
              ? Colors.green
              : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isCompleted
                ? CupertinoIcons.check_mark_circled_solid
                : CupertinoIcons.circle,
            color: _isCompleted ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tandai telah selesai',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: _isCompleted ? Colors.green : Colors.grey.shade700,
              ),
            ),
          ),
          CupertinoSwitch(
            value: _isCompleted,
            onChanged: (_) => _toggleCompletionStatus(),
            activeColor: Colors.green,
          ),
        ],
      ),
    );
  }
  
  Widget _buildSaveButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _themeColor.withOpacity(0.9),
            _themeColor,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: _themeColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _saveAgenda,
          borderRadius: BorderRadius.circular(25),
          splashColor: Colors.white.withOpacity(0.2),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  CupertinoIcons.check_mark,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.agenda == null ? 'Buat Agenda' : 'Simpan Perubahan',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildDeleteButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: TextButton(
        onPressed: _showDeleteConfirmation,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.delete,
              color: Colors.red,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              'Delete Agenda',
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}