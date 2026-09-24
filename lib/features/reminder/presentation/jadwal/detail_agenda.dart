import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart';
import 'package:primafit/features/reminder/presentation/jadwal/utility.dart';
import 'package:primafit/features/reminder/data/database_agenda.dart';
// import 'package:primafit/UI/jadwal/notification_service.dart';
// import 'package:primafit/UI/jadwal/utility.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class DetailAgendaPage extends StatefulWidget {
  final Agenda? agenda;
  final DateTime? selectedDate;

  const DetailAgendaPage({
    super.key,
    this.agenda,
    this.selectedDate,
  });

  @override
  State<DetailAgendaPage> createState() => _DetailAgendaPageState();
}

class _DetailAgendaPageState extends State<DetailAgendaPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _dateController;
  late TextEditingController _timeController;
  late bool _isCompleted;
  late bool _isEditing;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final Color _themeColor = AppColors.primaryColor;
  bool _isLoading = false;
  bool _isDeleting = false;
  String? _reminderTime;
  String? _repeatType;
  int? _repeatInterval = 1;
  late Color _selectedColor;
  final List<String> _reminderOptions = ['5min', '15min', '30min', '1hour', '2hours', '1day'];
  final List<String> _repeatOptions = ['daily', 'weekly', 'monthly', 'yearly'];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.agenda == null;
    
    // Initialize controllers
    _titleController = TextEditingController(text: widget.agenda?.title ?? '');
    _descriptionController = TextEditingController(text: widget.agenda?.description ?? '');
    
    // Initialize date
    if (widget.agenda != null) {
      _selectedDate = DateTimeUtils.parseDateFromDb(widget.agenda!.date);
    } else {
      _selectedDate = widget.selectedDate ?? DateTime.now();
    }
    _dateController = TextEditingController(
      text: DateTimeUtils.formatDateToDb(_selectedDate),
    );
    
    // Initialize time
    if (widget.agenda != null) {
      _selectedTime = DateTimeUtils.parseTimeFromDb(widget.agenda!.time);
    } else {
      _selectedTime = TimeOfDay.now();
    }
    _timeController = TextEditingController(
      text: widget.agenda?.time ?? DateTimeUtils.formatTimeToDb(_selectedTime),
    );
    
    // Initialize reminder time
    _reminderTime = widget.agenda?.reminderTime;
    
    // Initialize repeat settings
    _repeatType = widget.agenda?.repeatType;
    _repeatInterval = widget.agenda?.repeatInterval ?? 1;
    
    // Initialize color
    _selectedColor = widget.agenda?.color != null 
        ? AppColors.fromHex(widget.agenda!.color) 
        : _themeColor;
    
    // Initialize completion status
    _isCompleted = widget.agenda?.isCompleted == 1;
    
    // Animation setup
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _animationController.forward();
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
    // Allow editing past dates but not creating new agendas with past dates
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

  Future<void> _saveAgenda() async {
    if (_formKey.currentState!.validate() && _isValidDateTime()) {
      setState(() {
        _isLoading = true;
      });
      
      try {
        if (widget.agenda == null) {
          // Create new agenda
          final newAgenda = Agenda(
            title: _titleController.text,
            description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
            date: _dateController.text,
            time: _timeController.text,
            isCompleted: _isCompleted ? 1 : 0,
            reminderTime: _reminderTime,
            repeatType: _repeatType,
            repeatInterval: _repeatType != null ? _repeatInterval : null,
            color: AppColors.toHex(_selectedColor),
          );
          
          await DatabaseAgenda.instance.insertAgenda(newAgenda);
          if (!mounted) return;
          
          UiUtils.showSnackBar(
            context, 
            message: 'Agenda created successfully', 
            type: SnackBarType.success
          );
          
          Navigator.pop(context, 'refresh');
        } else {
          // Update existing agenda
          final updatedAgenda = Agenda(
            id: widget.agenda!.id,
            title: _titleController.text,
            description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
            date: _dateController.text,
            time: _timeController.text,
            isCompleted: _isCompleted ? 1 : 0,
            reminderTime: _reminderTime,
            repeatType: _repeatType,
            repeatInterval: _repeatType != null ? _repeatInterval : null,
            color: AppColors.toHex(_selectedColor),
          );
          
          await DatabaseAgenda.instance.updateAgenda(updatedAgenda);
          if (!mounted) return;
          
          UiUtils.showSnackBar(
            context, 
            message: 'Agenda updated successfully', 
            type: SnackBarType.success
          );
          
          Navigator.pop(context, 'refresh');
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

  void _toggleEditMode() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _toggleCompletionStatus() {
    setState(() {
      _isCompleted = !_isCompleted;
    });
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
          // semanticLabel: 'Back button',
        ),
        title: Text(
          widget.agenda == null ? 'New Agenda' : (_isEditing ? 'Edit Agenda' : 'Agenda Detail'),
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: widget.agenda != null
            ? [
                IconButton(
                  icon: Icon(
                    _isEditing ? CupertinoIcons.eye : CupertinoIcons.pencil,
                    color: _themeColor,
                  ),
                  onPressed: _toggleEditMode,
                  tooltip: _isEditing ? 'View mode' : 'Edit mode',
                  // semanticLabel: _isEditing ? 'Switch to view mode' : 'Switch to edit mode',
                ),
                if (!_isEditing) 
                  IconButton(
                    icon: const Icon(
                      CupertinoIcons.delete,
                      color: Colors.red,
                    ),
                    onPressed: _showDeleteConfirmation,
                    tooltip: 'Delete agenda',
                    // semanticLabel: 'Delete this agenda',
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
                      // Header with date/time icons
                      if (!_isEditing && widget.agenda != null)
                        _buildDetailHeader(),
                      
                      // Title Field
                      _buildTextField(
                        controller: _titleController,
                        labelText: 'Title',
                        icon: CupertinoIcons.doc_text,
                        validator: (value) => UiUtils.validateRequired(value, 'Title'),
                      ),
                      
                      // Description Field
                      _buildTextField(
                        controller: _descriptionController,
                        labelText: 'Description',
                        icon: CupertinoIcons.doc_plaintext,
                        maxLines: 5,
                        optional: true,
                      ),
                      
                      // Date Field
                      _buildDateTimeField(
                        controller: _dateController,
                        labelText: 'Date',
                        icon: CupertinoIcons.calendar,
                        onTap: () => _selectDate(context),
                      ),
                      
                      // Time Field
                      _buildDateTimeField(
                        controller: _timeController,
                        labelText: 'Time',
                        icon: CupertinoIcons.clock,
                        onTap: () => _selectTime(context),
                      ),
                      
                      // Reminder Field
                      if (_isEditing)
                        _buildReminderSelector(),
                      
                      // Repeat Field
                      if (_isEditing)
                        _buildRepeatSelector(),
                      
                      // Color Selector
                      if (_isEditing)
                        _buildColorSelector(),
                      
                      // Completion Status
                      _buildCompletionToggle(),
                      
                      // Save Button
                      if (_isEditing)
                        _buildSaveButton(),
                        
                      // Delete Button
                      if (_isEditing && widget.agenda != null)
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
        color: _isEditing ? Colors.white : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isEditing ? _themeColor : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: _isEditing
            ? [
                BoxShadow(
                  color: _themeColor.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: TextFormField(
        controller: controller,
        enabled: _isEditing,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: labelText,
          alignLabelWithHint: maxLines > 1,
          labelStyle: GoogleFonts.poppins(
            color: _isEditing ? _themeColor : Colors.grey,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 16, right: 8),
            child: Icon(
              icon,
              color: _isEditing ? _themeColor : Colors.grey,
            ),
          ),
          prefixIconConstraints: const BoxConstraints(
            minWidth: 0,
            minHeight: 0,
          ),
          suffixIcon: optional && _isEditing
              ? const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Text(
                    '(Optional)',
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
        color: _isEditing ? Colors.white : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isEditing ? _themeColor : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: _isEditing
            ? [
                BoxShadow(
                  color: _themeColor.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: GoogleFonts.poppins(
            color: _isEditing ? _themeColor : Colors.grey,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          prefixIcon: Icon(
            icon,
            color: _isEditing ? _themeColor : Colors.grey,
          ),
          suffixIcon: _isEditing
              ? IconButton(
                  icon: Icon(
                    CupertinoIcons.arrow_down_circle,
                    color: _themeColor,
                  ),
                  onPressed: onTap,
                )
              : null,
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
        onTap: _isEditing ? onTap : null,
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
            color: _themeColor.withValues(alpha: 0.1),
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
                  'Reminder',
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
                    'None',
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
                      displayText = '1 hour';
                      break;
                    case '2hours':
                      displayText = '2 hours';
                      break;
                    case '1day':
                      displayText = '1 day';
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
                }),
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
            color: _themeColor.withValues(alpha: 0.1),
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
                    'None',
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
                      displayText = 'Daily';
                      break;
                    case 'weekly':
                      displayText = 'Weekly';
                      break;
                    case 'monthly':
                      displayText = 'Monthly';
                      break;
                    case 'yearly':
                      displayText = 'Yearly';
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
                          _repeatInterval ??= 1;
                        });
                      }
                    },
                  );
                }),
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
            color: _themeColor.withValues(alpha: 0.1),
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
                'Agenda Color',
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
            ? Colors.green.withValues(alpha: 0.1)
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
              'Mark as completed',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: _isCompleted ? Colors.green : Colors.grey.shade700,
              ),
            ),
          ),
          if (_isEditing)
            CupertinoSwitch(
              value: _isCompleted,
              onChanged: (_) => _toggleCompletionStatus(),
              activeTrackColor: Colors.green,
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
            _themeColor.withValues(alpha: 0.9),
            _themeColor,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: _themeColor.withValues(alpha: 0.3),
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
          splashColor: Colors.white.withValues(alpha: 0.2),
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
                  widget.agenda == null ? 'Create Agenda' : 'Save Changes',
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

  Widget _buildDetailHeader() {
    // Format the date for readable display
    final displayDate = DateTimeUtils.formatDateForDisplay(_selectedDate);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _selectedColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _selectedColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                CupertinoIcons.calendar,
                color: Colors.black54,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  displayDate,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                CupertinoIcons.clock,
                color: Colors.black54,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                _timeController.text,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _isCompleted
                      ? Colors.green.withValues(alpha: 0.1)
                      : _selectedColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isCompleted ? Colors.green : _selectedColor,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isCompleted
                          ? CupertinoIcons.check_mark_circled_solid
                          : CupertinoIcons.time,
                      color: _isCompleted ? Colors.green : _selectedColor,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isCompleted ? 'Completed' : 'Pending',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: _isCompleted ? Colors.green : _selectedColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Show reminder info if set
          if (widget.agenda?.reminderTime != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  const Icon(
                    CupertinoIcons.bell,
                    color: Colors.black54,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getReminderTimeText(widget.agenda!.reminderTime!),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          
          // Show repeat info if set
          if (widget.agenda?.repeatType != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  const Icon(
                    CupertinoIcons.repeat,
                    color: Colors.black54,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getRepeatTypeText(widget.agenda!),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  String _getReminderTimeText(String reminderTime) {
    switch (reminderTime) {
      case '5min':
        return 'Reminder 5 minutes before';
      case '15min':
        return 'Reminder 15 minutes before';
      case '30min':
        return 'Reminder 30 minutes before';
      case '1hour':
        return 'Reminder 1 hour before';
      case '2hours':
        return 'Reminder 2 hours before';
      case '1day':
        return 'Reminder 1 day before';
      default:
        return 'Reminder set';
    }
  }
  
  String _getRepeatTypeText(Agenda agenda) {
    final interval = agenda.repeatInterval ?? 1;
    
    switch (agenda.repeatType) {
      case 'daily':
        return interval == 1 
            ? 'Repeats daily' 
            : 'Repeats every $interval days';
      case 'weekly':
        return interval == 1 
            ? 'Repeats weekly' 
            : 'Repeats every $interval weeks';
      case 'monthly':
        return interval == 1 
            ? 'Repeats monthly' 
            : 'Repeats every $interval months';
      case 'yearly':
        return interval == 1 
            ? 'Repeats yearly' 
            : 'Repeats every $interval years';
      default:
        return 'Repeats regularly';
    }
  }
}