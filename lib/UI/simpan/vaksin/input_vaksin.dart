import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:primafit/database/simpan/database_vaksin.dart';

class InputVaksinPage extends StatefulWidget {
  const InputVaksinPage({Key? key}) : super(key: key);

  @override
  State<InputVaksinPage> createState() => _InputVaksinPageState();
}

class _InputVaksinPageState extends State<InputVaksinPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nomorController = TextEditingController();
  final _namaController = TextEditingController();
  final _tanggalController = TextEditingController();
  final dbHelper = DatabaseVaksinHelper.instance;
  
  DateTime? _selectedDate;
  File? _imageFile;
  Uint8List? _imageBytes;
  bool _isLoading = false;
  bool _isFormDirty = false;
  
  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    // Setup fade animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    
    // Setup slide animation for form elements
    _slideAnimation = Tween<Offset>(begin: const Offset(0.0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    
    // Add listeners to track form changes
    _nomorController.addListener(_onFormChanged);
    _namaController.addListener(_onFormChanged);
    _tanggalController.addListener(_onFormChanged);
    
    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    // Clean up controllers
    _nomorController.dispose();
    _namaController.dispose();
    _tanggalController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Track if form has changes for confirmation dialog
  void _onFormChanged() {
    if (!_isFormDirty && (_nomorController.text.isNotEmpty || 
        _namaController.text.isNotEmpty || 
        _tanggalController.text.isNotEmpty)) {
      setState(() {
        _isFormDirty = true;
      });
    }
  }

  // Function to pick image from gallery or camera
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 70, // Compress image for storage efficiency
        maxWidth: 1000,   // Limit width for better performance
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _imageBytes = null;
          _isFormDirty = true;
        });
      }
    } catch (e) {
      _showErrorDialog('Error picking image: $e');
    }
  }

  // Function to select date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = _selectedDate ?? now;
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2019), // COVID-19 vaccines started in 2020
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF64D1DE),
              // primary: Color(0xFF5271FF),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF64D1DE),
              ),
            ),
            dialogBackgroundColor: Colors.white,
            dialogTheme: DialogThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
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
        _tanggalController.text = DateFormat('dd-MM-yyyy').format(picked);
        _isFormDirty = true;
      });
    }
  }

  // Save Vaksin data to database
  Future<void> _saveVaksin() async {
    if (!_formKey.currentState!.validate()) {
      // Show animation for validation error
      _shakeAnimation();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      Uint8List? imageData;
      
      // Get image data if available
      if (_imageFile != null) {
        imageData = await _imageFile!.readAsBytes();
      } else if (_imageBytes != null) {
        imageData = _imageBytes;
      }

      // Prepare data for database
      final vaksinData = {
        'nomor_vaksin': _nomorController.text.trim(),
        'nama_vaksin': _namaController.text.trim(),
        'tanggal_vaksin': _tanggalController.text,
        'foto': imageData,
      };

      // Save to database
      await dbHelper.insertVaksin(vaksinData);
      
      // Show success notification
      _showSuccessNotification();
      
      // Return to previous screen
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error saving data: $e');
    }
  }

  // Show success alert
  void _showSuccessNotification() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(CupertinoIcons.check_mark_circled, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              'Data vaksin berhasil disimpan',
              style: GoogleFonts.poppins(),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  // Show error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Error',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          message,
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: GoogleFonts.poppins(color: const Color(0xFF64D1DE)),
            ),
          ),
        ],
      ),
    );
  }

  // Show image source options (camera/gallery)
  void _showImageSourceOptions() {
    HapticFeedback.lightImpact(); // Provide haptic feedback
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Pilih Sumber Foto',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Camera option
                  _buildImageSourceOption(
                    icon: CupertinoIcons.camera_fill,
                    label: 'Kamera',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                  
                  // Gallery option
                  _buildImageSourceOption(
                    icon: CupertinoIcons.photo_fill,
                    label: 'Galeri',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                  
                  // Delete option (only shown if image exists)
                  if (_imageFile != null || _imageBytes != null)
                    _buildImageSourceOption(
                      icon: CupertinoIcons.delete,
                      label: 'Hapus',
                      iconColor: Colors.red,
                      onTap: () {
                        Navigator.pop(context);
                        setState(() {
                          _imageFile = null;
                          _imageBytes = null;
                          _isFormDirty = true;
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
  
  // Build image source option widget
  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color iconColor = const Color(0xFF64D1DE),
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Show confirmation dialog before exit if form is dirty
  Future<bool> _onWillPop() async {
    if (!_isFormDirty) {
      return true;
    }
    
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Konfirmasi',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Data yang Anda masukkan belum tersimpan. Apakah Anda yakin ingin keluar?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Keluar',
              style: GoogleFonts.poppins(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
  
  // Shake animation for validation errors
  void _shakeAnimation() {
    // Create a controller for the shake animation
    final shakeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Create a shake animation
    // ignore: unused_local_variable
    final offsetAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -10.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: -10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -10.0, end: 10.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 10.0, end: 0.0), weight: 1),
    ]).animate(shakeController);
    
    // Play the animation
    shakeController.forward().then((_) => shakeController.dispose());
    
    // Provide haptic feedback
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            'Tambah Kartu Vaksin',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          leading: IconButton(
            icon: const Icon(CupertinoIcons.back),
            onPressed: () async {
              if (await _onWillPop()) {
                Navigator.pop(context);
              }
            },
          ),
          backgroundColor: const Color(0xFF64D1DE),
          elevation: 0,
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF64D1DE),
                  Color(0xFF59BECA),
                ],
              ),
            ),
          ),
        ),
        body: _isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Color(0xFF64D1DE),
                    ),
                    SizedBox(height: 16),
                    Text('Menyimpan data...'),
                  ],
                ),
              )
            : FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: GestureDetector(
                    onTap: () => FocusScope.of(context).unfocus(),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Section title
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF64D1DE).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    CupertinoIcons.info_circle_fill,
                                    color: Color(0xFF64D1DE),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Silakan isi data Kartu Vaksin Anda dengan lengkap',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // Image picker section
                            Text(
                              'Foto Kartu Vaksin',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            
                            // Widget to display and pick photo
                            GestureDetector(
                              onTap: _showImageSourceOptions,
                              child: Container(
                                height: 200,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEF1FF),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFF64D1DE).withOpacity(0.2),
                                    width: 2,
                                  ),
                                ),
                                child: _imageFile != null
                                    ? Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(14),
                                            child: Image.file(
                                              _imageFile!,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          // Edit overlay button
                                          Positioned(
                                            bottom: 8,
                                            right: 8,
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.8),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Icon(
                                                CupertinoIcons.camera,
                                                color: Color(0xFF64D1DE),
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    : _imageBytes != null
                                        ? Stack(
                                            fit: StackFit.expand,
                                            children: [
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(14),
                                                child: Image.memory(
                                                  _imageBytes!,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              // Edit overlay button
                                              Positioned(
                                                bottom: 8,
                                                right: 8,
                                                child: Container(
                                                  padding: const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white.withOpacity(0.8),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: const Icon(
                                                    CupertinoIcons.camera,
                                                    color: Color(0xFF64D1DE),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        : Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                CupertinoIcons.camera_circle_fill,
                                                size: 64,
                                                color: Color(0xFF64D1DE),
                                              ),
                                              const SizedBox(height: 16),
                                              Text(
                                                'Tap untuk ambil foto kartu vaksin',
                                                style: GoogleFonts.poppins(
                                                  color: Colors.grey[700],
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Opsional',
                                                style: GoogleFonts.poppins(
                                                  color: Colors.grey[500],
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            
                            // Form section
                            Text(
                              'Informasi Kartu Vaksin',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Form field for Vaksin number
                            TextFormField(
                              controller: _nomorController,
                              decoration: InputDecoration(
                                labelText: 'Nomor Kartu Vaksin',
                                labelStyle: GoogleFonts.poppins(),
                                hintText: 'Masukkan nomor kartu vaksin',
                                hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF64D1DE),
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 1,
                                  ),
                                ),
                                prefixIcon: const Icon(CupertinoIcons.number),
                                prefixIconColor: const Color(0xFF64D1DE),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              style: GoogleFonts.poppins(),
                              onChanged: (value) {
                                // Format nomor Vaksin
                                if (value.length > 4) {
                                  // Implement formatting logic if needed
                                }
                              },
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(16),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Nomor Vaksin tidak boleh kosong';
                                }
                                if (value.length < 8) {
                                  return 'Nomor Vaksin terlalu pendek';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            
                            // Form field for name
                            TextFormField(
                              controller: _namaController,
                              decoration: InputDecoration(
                                labelText: 'Nama Vaksin',
                                labelStyle: GoogleFonts.poppins(),
                                hintText: 'Masukkan nama vaksin',
                                hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF64D1DE),
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 1,
                                  ),
                                ),
                                prefixIcon: const Icon(CupertinoIcons.bandage),
                                prefixIconColor: const Color(0xFF64D1DE),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.next,
                              style: GoogleFonts.poppins(),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Nama vaksin tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            
                            // Form field for date
                            TextFormField(
                              controller: _tanggalController,
                              decoration: InputDecoration(
                                labelText: 'Tanggal Vaksin',
                                labelStyle: GoogleFonts.poppins(),
                                hintText: 'Pilih tanggal vaksin',
                                hintStyle: GoogleFonts.poppins(color: Colors.grey[400]),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Color(0xFF64D1DE),
                                    width: 2,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 1,
                                  ),
                                ),
                                prefixIcon: const Icon(CupertinoIcons.calendar),
                                prefixIconColor: const Color(0xFF64D1DE),
                                suffixIcon: IconButton(
                                  icon: const Icon(
                                    CupertinoIcons.chevron_down_circle,
                                    color: Color(0xFF64D1DE),
                                  ),
                                  onPressed: () => _selectDate(context),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                              readOnly: true,
                              onTap: () => _selectDate(context),
                              style: GoogleFonts.poppins(),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Tanggal vaksin tidak boleh kosong';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
        bottomNavigationBar: AnimatedOpacity(
          opacity: _isLoading ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 250),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: SafeArea(
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveVaksin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF64D1DE),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(CupertinoIcons.check_mark),
                      const SizedBox(width: 8),
                      Text(
                        'Simpan Data',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}