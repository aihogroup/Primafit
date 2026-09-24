import 'package:primafit/app/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primafit/features/profile/domain/entities/user_profile.dart';
import 'package:primafit/features/profile/presentation/providers/profile_providers.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> 
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  
  // Controllers
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _tanggalLahirController = TextEditingController();
  final TextEditingController _teleponController = TextEditingController();
  
  // Variables
  String? _selectedGender;
  String? _selectedGolonganDarah;
  String? _profileImagePath;
  int _currentPage = 0;
  bool _isLoading = false;
  DateTime? _selectedDate;
  
  // Animation controllers
  late AnimationController _fadeAnimationController;
  late AnimationController _slideAnimationController;
  late AnimationController _scaleAnimationController;
  
  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _checkExistingProfile();
    _initAnimations();
  }

  void _initAnimations() {
    _fadeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _slideAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _scaleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeAnimationController, curve: Curves.easeInOut),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideAnimationController, curve: Curves.easeOutBack));
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleAnimationController, curve: Curves.elasticOut),
    );

    // Start animations
    _fadeAnimationController.forward();
    _slideAnimationController.forward();
    _scaleAnimationController.forward();
  }

  Future<void> _checkExistingProfile() async {
    try {
      final profile = await ref.read(profileControllerProvider.future);
      if ((profile?.isComplete ?? false) && mounted) {
        // Profile already exists, navigate to main app
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } catch (e) {
      debugPrint('Error checking profile: $e');
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _tanggalLahirController.dispose();
    _teleponController.dispose();
    _fadeAnimationController.dispose();
    _slideAnimationController.dispose();
    _scaleAnimationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // Modern popup notification
  void _showModernNotification({
    required String message,
    required bool isSuccess,
    int durationSeconds = 3,
  }) {
    HapticFeedback.lightImpact();
    
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => _ModernNotificationWidget(
        message: message,
        isSuccess: isSuccess,
        onDismiss: () => overlayEntry.remove(),
      ),
    );
    
    overlay.insert(overlayEntry);
    
    // Auto dismiss after specified duration
    Future.delayed(Duration(seconds: durationSeconds), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  void _showSuccessMessage(String message) {
    _showModernNotification(message: message, isSuccess: true);
  }

  void _showErrorMessage(String message) {
    HapticFeedback.vibrate();
    _showModernNotification(message: message, isSuccess: false);
  }

  // Phone number validator
  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nomor telepon harus diisi';
    }
    
    // Remove all non-digit characters
    final String cleanedPhone = value.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cleanedPhone.length < 10) {
      return 'Nomor telepon minimal 10 digit';
    }
    
    if (cleanedPhone.length > 15) {
      return 'Nomor telepon maksimal 15 digit';
    }
    
    return null;
  }

  // Form validation
  bool _validateCurrentPage() {
    switch (_currentPage) {
      case 0:
        if (_namaController.text.trim().isEmpty) {
          _showErrorMessage('Nama lengkap harus diisi');
          return false;
        }
        if (_tanggalLahirController.text.isEmpty) {
          _showErrorMessage('Tanggal lahir harus dipilih');
          return false;
        }
        if (_selectedGender == null) {
          _showErrorMessage('Jenis kelamin harus dipilih');
          return false;
        }
        break;
      case 1:
        if (_selectedGolonganDarah == null) {
          _showErrorMessage('Golongan darah harus dipilih');
          return false;
        }
        final String? phoneError = _validatePhoneNumber(_teleponController.text);
        if (phoneError != null) {
          _showErrorMessage(phoneError);
          return false;
        }
        break;
    }
    return true;
  }

  Future<void> _pickImage() async {
    await _showImageSourceDialog();
  }

  Future<void> _showImageSourceDialog() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25),
              topRight: Radius.circular(25),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Pilih Sumber Foto',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageSourceOption(
                    icon: CupertinoIcons.camera,
                    label: 'Kamera',
                    onTap: () => _pickImageFromSource(ImageSource.camera),
                  ),
                  _buildImageSourceOption(
                    icon: CupertinoIcons.photo,
                    label: 'Galeri',
                    onTap: () => _pickImageFromSource(ImageSource.gallery),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF64D1DE).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: const Color(0xFF64D1DE).withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 40,
              color: const Color(0xFF64D1DE),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64D1DE),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _profileImagePath = image.path;
        });
        _showSuccessMessage('Foto berhasil dipilih');
      }
    } catch (e) {
      _showErrorMessage('Gagal mengambil foto: $e');
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF64D1DE),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF64D1DE),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _tanggalLahirController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  void _nextPage() {
    if (_currentPage < 2) {
      if (_validateCurrentPage()) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _saveProfile() async {
    if (!_validateCurrentPage()) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Clean phone number
      final String cleanedPhone = _teleponController.text.replaceAll(RegExp(r'[^0-9]'), '');
      
      final error = await ref.read(profileControllerProvider.notifier).save(
        UserProfile(
          name: _namaController.text.trim(),
          birthDate: _tanggalLahirController.text,
          gender: _selectedGender,
          bloodType: _selectedGolonganDarah,
          phone: cleanedPhone,
          photoPath: _profileImagePath,
        ),
      );
      if (error != null) {
        _showErrorMessage(error);
        return;
      }

      _showSuccessMessage('Profil berhasil dibuat!');
      
      // Navigate to main app after short delay
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    } catch (e) {
      debugPrint('Save profile failed: $e');
      _showErrorMessage('Gagal menyimpan profil. Silakan coba lagi.');
    } finally {
      // The page may already be replaced by /home at this point.
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                _buildHeader(),
                _buildProgressIndicator(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    children: [
                      _buildPersonalInfoPage(),
                      _buildMedicalInfoPage(),
                      _buildConfirmationPage(),
                    ],
                  ),
                ),
                _buildNavigationButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF64D1DE),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF64D1DE).withValues(alpha: 0.3),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                CupertinoIcons.person_add_solid,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _getPageTitle(),
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _getPageSubtitle(),
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getPageTitle() {
    switch (_currentPage) {
      case 0:
        return 'Informasi Pribadi';
      case 1:
        return 'Informasi Kesehatan';
      case 2:
        return 'Konfirmasi Data';
      default:
        return 'Setup Profil';
    }
  }

  String _getPageSubtitle() {
    switch (_currentPage) {
      case 0:
        return 'Masukkan data personal Anda';
      case 1:
        return 'Lengkapi informasi kesehatan';
      case 2:
        return 'Periksa kembali data Anda';
      default:
        return 'Buat profil Anda';
    }
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        children: List.generate(3, (index) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < 2 ? 10 : 0),
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: index <= _currentPage
                    ? const Color(0xFF64D1DE)
                    : Colors.grey[300],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPersonalInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildProfileImagePicker(),
            const SizedBox(height: 30),
            _buildTextField(
              controller: _namaController,
              label: 'Nama Lengkap',
              icon: CupertinoIcons.person_solid,
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 20),
            _buildDateField(
              controller: _tanggalLahirController,
              label: 'Tanggal Lahir',
              icon: CupertinoIcons.calendar,
              onTap: _selectDate,
            ),
            const SizedBox(height: 20),
            _buildDropdownField(
              label: 'Jenis Kelamin',
              icon: CupertinoIcons.person_2,
              value: _selectedGender,
              items: const ['Laki-laki', 'Perempuan'],
              onChanged: (value) => setState(() => _selectedGender = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalInfoPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildDropdownField(
            label: 'Golongan Darah',
            icon: CupertinoIcons.drop,
            value: _selectedGolonganDarah,
            items: const ['A', 'B', 'AB', 'O', 'Tidak tahu'],
            onChanged: (value) => setState(() => _selectedGolonganDarah = value),
          ),
          const SizedBox(height: 20),
          _buildTextField(
            controller: _teleponController,
            label: 'Nomor Telepon',
            icon: CupertinoIcons.phone,
            keyboardType: TextInputType.phone,
            validator: _validatePhoneNumber,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(15),
            ],
          ),
          const SizedBox(height: 30),
          _buildInfoCard(),
        ],
      ),
    );
  }

  Widget _buildConfirmationPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildConfirmationCard(),
          const SizedBox(height: 30),
          _buildTermsAndConditions(),
        ],
      ),
    );
  }

  Widget _buildProfileImagePicker() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF64D1DE).withValues(alpha: 0.1),
          border: Border.all(
            color: const Color(0xFF64D1DE),
            width: 3,
            style: BorderStyle.solid,
          ),
          image: _profileImagePath != null
              ? DecorationImage(
                  image: FileImage(File(_profileImagePath!)),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: _profileImagePath == null
            ? const Icon(
                CupertinoIcons.camera_fill,
                color: Color(0xFF64D1DE),
                size: 40,
              )
            : Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.3),
                ),
                child: const Icon(
                  CupertinoIcons.camera,
                  color: Colors.white,
                  size: 30,
                ),
              ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.grey[700]),
        prefixIcon: Icon(icon, color: const Color(0xFF64D1DE)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF64D1DE), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      style: GoogleFonts.poppins(),
      inputFormatters: inputFormatters,
      validator: validator,
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.grey[700]),
        prefixIcon: Icon(icon, color: const Color(0xFF64D1DE)),
        suffixIcon: Icon(CupertinoIcons.chevron_down, color: Colors.grey[600], size: 18),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF64D1DE), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      readOnly: true,
      onTap: onTap,
      style: GoogleFonts.poppins(),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.grey[700]),
        prefixIcon: Icon(icon, color: const Color(0xFF64D1DE)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey[300]!, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Color(0xFF64D1DE), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      icon: Icon(CupertinoIcons.chevron_down, color: Colors.grey[600], size: 18),
      style: GoogleFonts.poppins(color: Colors.black87),
      dropdownColor: Colors.white,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF64D1DE).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFF64D1DE).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.info_circle,
            color: const Color(0xFF64D1DE),
            size: 24,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              'Data ini akan digunakan untuk fitur kesehatan dan tidak akan dibagikan kepada pihak ketiga.',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF64D1DE),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Data Profil Anda',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          if (_profileImagePath != null) ...[
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: FileImage(File(_profileImagePath!)),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
          _buildConfirmationItem('Nama', _namaController.text),
          _buildConfirmationItem('Tanggal Lahir', _tanggalLahirController.text),
          _buildConfirmationItem('Jenis Kelamin', _selectedGender ?? ''),
          _buildConfirmationItem('Golongan Darah', _selectedGolonganDarah ?? ''),
          _buildConfirmationItem('Nomor Telepon', _teleponController.text),
        ],
      ),
    );
  }

  Widget _buildConfirmationItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : 'Belum diisi',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: value.isNotEmpty ? Colors.black87 : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsAndConditions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Icon(
            CupertinoIcons.checkmark_shield,
            color: const Color(0xFF64D1DE),
            size: 40,
          ),
          const SizedBox(height: 15),
          Text(
            'Privasi & Keamanan',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Data Anda akan disimpan dengan aman di perangkat dan hanya digunakan untuk fitur aplikasi kesehatan. Kami tidak akan membagikan informasi pribadi Anda kepada pihak ketiga.',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.black54,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          if (_currentPage > 0)
            Expanded(
              child: ElevatedButton(
                onPressed: _previousPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.black54,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Kembali',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_currentPage > 0) const SizedBox(width: 15),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : (_currentPage == 2 ? _saveProfile : _nextPage),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF64D1DE),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 3,
                shadowColor: const Color(0xFF64D1DE).withValues(alpha: 0.3),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _currentPage == 2 ? 'Selesai' : 'Lanjut',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

// Modern Notification Widget
class _ModernNotificationWidget extends StatefulWidget {
  final String message;
  final bool isSuccess;
  final VoidCallback onDismiss;

  const _ModernNotificationWidget({
    required this.message,
    required this.isSuccess,
    required this.onDismiss,
  });

  @override
  State<_ModernNotificationWidget> createState() => _ModernNotificationWidgetState();
}

class _ModernNotificationWidgetState extends State<_ModernNotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: -100.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 20,
      right: 20,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: widget.isSuccess 
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFE53E3E),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: (widget.isSuccess 
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFFE53E3E)).withValues(alpha: 0.3),
                          blurRadius: 15,
                          spreadRadius: 0,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            widget.isSuccess 
                                ? CupertinoIcons.check_mark 
                                : CupertinoIcons.exclamationmark,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            widget.message,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            _animationController.reverse().then((_) {
                              widget.onDismiss();
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              CupertinoIcons.xmark,
                              color: Colors.white.withValues(alpha: 0.8),
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}