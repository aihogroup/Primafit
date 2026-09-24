import 'package:primafit/core/widgets/confirm_pop_scope.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:primafit/features/health_wallet/data/database_dokumen.dart';

// Class untuk menyimpan data gambar (baik file baru atau bytes dari database)
class ImageItem {
  int? id;          // ID gambar dari database (jika sudah ada)
  File? file;       // File untuk gambar baru
  Uint8List? bytes; // Bytes untuk gambar dari database
  bool isNew;       // Penanda apakah ini gambar baru
  
  ImageItem({this.id, this.file, this.bytes, this.isNew = false});
}
class EditDokumenPage extends StatefulWidget {
  final int dokumenId;

  const EditDokumenPage({super.key, required this.dokumenId});

  @override
  State<EditDokumenPage> createState() => _EditDokumenPageState();
}

class _EditDokumenPageState extends State<EditDokumenPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _dokterController = TextEditingController();
  final _klinikController = TextEditingController();
  final _tanggalController = TextEditingController();
  final _hasilController = TextEditingController();
  final _catatanController = TextEditingController();
  final dbHelper = DatabaseDokumenHelper.instance;
  
  String _selectedJenisDokumen = 'Umum';
  final List<String> _jenisDokumenOptions = ['Umum', 'Laboratorium', 'Radiologi', 'Resep', 'Konsultasi'];
  
  DateTime? _selectedDate;
  List<ImageItem> _images = []; // Untuk menampung multiple images
  final List<int> _deletedImageIds = []; // Untuk tracking gambar yang dihapus
  // File? _images;
  // Uint8List? _deletedImageIds;
  Map<String, dynamic>? _initialData;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isFormDirty = false;
  String _originalTitle = '';
  
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
    _slideAnimation = Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    
    // Load dokumen data for editing
    _loadDokumenData();
    
    // Add listeners to track form changes
    _judulController.addListener(_onFormChanged);
    _dokterController.addListener(_onFormChanged);
    _klinikController.addListener(_onFormChanged);
    _tanggalController.addListener(_onFormChanged);
    _hasilController.addListener(_onFormChanged);
    _catatanController.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    // Clean up controllers
    _judulController.dispose();
    _dokterController.dispose();
    _klinikController.dispose();
    _tanggalController.dispose();
    _hasilController.dispose();
    _catatanController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  // Load dokumen data for editing
  Future<void> _loadDokumenData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final dokumen = await dbHelper.getDokumenById(widget.dokumenId);
      if (dokumen != null) {
        // Store original data for comparison
        _initialData = Map<String, dynamic>.from(dokumen);
        _originalTitle = dokumen['judul_dokumen'];
        
        // Set form data
        _judulController.text = dokumen['judul_dokumen'];
        _dokterController.text = dokumen['nama_dokter'] ?? '';
        _klinikController.text = dokumen['nama_klinik'] ?? '';
        _tanggalController.text = dokumen['tanggal_dokumen'];
        _hasilController.text = dokumen['hasil'] ?? '';
        _catatanController.text = dokumen['catatan'] ?? '';
        _selectedJenisDokumen = dokumen['jenis_dokumen'];
        
        // Parse date
        if (dokumen['tanggal_dokumen'].isNotEmpty) {
          final parts = dokumen['tanggal_dokumen'].split('-');
          if (parts.length == 3) {
            _selectedDate = DateTime(
              int.parse(parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );
          }
        }
        
        // Load images
        final gambarList = await dbHelper.getGambarByDokumenId(widget.dokumenId);
        if (gambarList.isNotEmpty) {
          setState(() {
            _images = gambarList.map((item) => 
              ImageItem(
                id: item['id'],
                bytes: item['gambar'],
                isNew: false
              )
            ).toList();
          });
        }
      }
    } catch (e) {
      _showErrorDialog('Error loading data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
      
      // Start animation after data is loaded
      _animationController.forward();
    }
  }

  // Track if form has changes for confirmation dialog
  void _onFormChanged() {
  if (!_isFormDirty && _initialData != null) {
    if (_judulController.text != _initialData!['judul_dokumen'] ||
        _dokterController.text != (_initialData!['nama_dokter'] ?? '') ||
        _klinikController.text != (_initialData!['nama_klinik'] ?? '') ||
        _tanggalController.text != _initialData!['tanggal_dokumen'] ||
        _hasilController.text != (_initialData!['hasil'] ?? '') ||
        _catatanController.text != (_initialData!['catatan'] ?? '') ||
        _selectedJenisDokumen != _initialData!['jenis_dokumen'] ||
        _images.any((img) => img.isNew) ||
        _deletedImageIds.isNotEmpty) {
      setState(() {
        _isFormDirty = true;
      });
    }
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
          _images.add(ImageItem(
            file: File(pickedFile.path),
            isNew: true
          ));
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
      firstDate: DateTime(2000),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF64D1DE),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF64D1DE),
              ),
            ),
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

  // Update Dokumen data
  Future<void> _updateDokumen() async {
    if (!_formKey.currentState!.validate()) {
      // Show animation for validation error
      _shakeAnimation();
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Prepare data for database update
      final dokumenData = {
        'judul_dokumen': _judulController.text.trim(),
        'jenis_dokumen': _selectedJenisDokumen,
        'nama_dokter': _dokterController.text.trim(),
        'nama_klinik': _klinikController.text.trim(),
        'tanggal_dokumen': _tanggalController.text,
        'hasil': _hasilController.text.trim(),
        'catatan': _catatanController.text.trim(),
      };

      // Update dokumen in database
      await dbHelper.updateDokumen(widget.dokumenId, dokumenData);
      
      // Hapus gambar yang ditandai untuk dihapus
      for (int id in _deletedImageIds) {
        await dbHelper.deleteGambar(id);
      }
      
      // Simpan gambar baru
      for (var image in _images.where((img) => img.isNew)) {
        if (image.file != null) {
          final imageBytes = await image.file!.readAsBytes();
          await dbHelper.addGambarToDokumen(widget.dokumenId, imageBytes);
        }
      }
      
      // Show success notification
      _showSuccessNotification();
      
      // Return to previous screen
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      _showErrorDialog('Error updating data: $e');
    }
  }

  void _removeImage(int index) {
  setState(() {
    // Jika gambar memiliki ID (dari database), tambahkan ke daftar yang akan dihapus
    if (_images[index].id != null) {
      _deletedImageIds.add(_images[index].id!);
    }
    _images.removeAt(index);
    _isFormDirty = true;
  });
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
              'Dokumen berhasil diperbarui',
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
              color: iconColor.withValues(alpha: 0.1),
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
          'Perubahan yang Anda buat belum tersimpan. Apakah Anda yakin ingin keluar?',
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
    return ConfirmPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            'Edit Dokumen Medis',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          leading: IconButton(
            icon: const Icon(CupertinoIcons.back),
            onPressed: () async {
              if (await _onWillPop()) {
                if (!context.mounted) return;
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
          actions: [
            if (!_isLoading && !_isSaving)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: TextButton.icon(
                  onPressed: _updateDokumen,
                  icon: const Icon(
                    CupertinoIcons.checkmark_circle,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Simpan',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
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
                    Text('Memuat data...'),
                  ],
                ),
              )
            : _isSaving
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: Color(0xFF64D1DE),
                        ),
                        SizedBox(height: 16),
                        Text('Menyimpan perubahan...'),
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
                                // Header info
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF64D1DE).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        CupertinoIcons.pencil_circle_fill,
                                        color: Color(0xFF64D1DE),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Anda sedang mengedit dokumen: $_originalTitle',
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
                                
                                // Image section
                                Text(
                                  'Foto Dokumen',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                
                                // Widget to display and pick photo
                                  Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Text(
                                        //   'Foto Dokumen',
                                        //   style: GoogleFonts.poppins(
                                        //     fontSize: 16,
                                        //     fontWeight: FontWeight.w600,
                                        //   ),
                                        // ),
                                        InkWell(
                                          onTap: _showImageSourceOptions,
                                          borderRadius: BorderRadius.circular(20),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF64D1DE),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(
                                                  CupertinoIcons.camera_fill,
                                                  color: Colors.white,
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  'Tambah Foto',
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    // Tampilan galeri foto
                                    _images.isEmpty
                                        ? GestureDetector(
                                            onTap: _showImageSourceOptions,
                                            child: Container(
                                              height: 150,
                                              width: double.infinity,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFEEF1FF),
                                                borderRadius: BorderRadius.circular(16),
                                                border: Border.all(
                                                  color: const Color(0xFF64D1DE).withValues(alpha: 0.2),
                                                  width: 2,
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                    CupertinoIcons.camera_circle_fill,
                                                    size: 48,
                                                    color: Color(0xFF64D1DE),
                                                  ),
                                                  const SizedBox(height: 12),
                                                  Text(
                                                    'Tap untuk ambil foto dokumen',
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
                                          )
                                        : SizedBox(
                                            height: 150,
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: _images.length,
                                              itemBuilder: (context, index) {
                                                final image = _images[index];
                                                return Container(
                                                  width: 150,
                                                  margin: const EdgeInsets.only(right: 12),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(12),
                                                    border: Border.all(
                                                      color: const Color(0xFF64D1DE).withValues(alpha: 0.2),
                                                      width: 2,
                                                    ),
                                                  ),
                                                  child: Stack(
                                                    fit: StackFit.expand,
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius: BorderRadius.circular(10),
                                                        child: image.file != null
                                                            ? Image.file(image.file!, fit: BoxFit.cover)
                                                            : Image.memory(image.bytes!, fit: BoxFit.cover),
                                                      ),
                                                      Positioned(
                                                        top: 8,
                                                        right: 8,
                                                        child: GestureDetector(
                                                          onTap: () => _removeImage(index),
                                                          child: Container(
                                                            padding: const EdgeInsets.all(6),
                                                            decoration: const BoxDecoration(
                                                              color: Colors.white,
                                                              shape: BoxShape.circle,
                                                            ),
                                                            child: const Icon(
                                                              CupertinoIcons.xmark,
                                                              color: Colors.red,
                                                              size: 16,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                
                                // Form section
                                Text(
                                  'Informasi Dokumen',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                // Jenis Dokumen dropdown
                                DropdownButtonFormField<String>(
                                  initialValue: _selectedJenisDokumen,
                                  decoration: InputDecoration(
                                    labelText: 'Jenis Dokumen',
                                    labelStyle: GoogleFonts.poppins(),
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
                                    prefixIcon: const Icon(CupertinoIcons.doc_text),
                                    prefixIconColor: const Color(0xFF64D1DE),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                  ),
                                  items: _jenisDokumenOptions.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(
                                      value,
                                      style: GoogleFonts.poppins(
                                        color: Colors.black,
                                        fontSize: 14, // opsional, mau atur ukuran juga
                                      ),
                                    ),
                                  );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    if (newValue != null && newValue != _selectedJenisDokumen) {
                                      setState(() {
                                        _selectedJenisDokumen = newValue;
                                        _isFormDirty = true;
                                      });
                                    }
                                  },
                                  style: GoogleFonts.poppins(),
                                ),
                                const SizedBox(height: 16),
                                
                                // Form field for judul
                                TextFormField(
                                  controller: _judulController,
                                  decoration: InputDecoration(
                                    labelText: 'Judul Dokumen',
                                    labelStyle: GoogleFonts.poppins(),
                                    hintText: 'Masukkan judul dokumen',
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
                                    prefixIcon: const Icon(CupertinoIcons.doc_append),
                                    prefixIconColor: const Color(0xFF64D1DE),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                  ),
                                  textCapitalization: TextCapitalization.sentences,
                                  textInputAction: TextInputAction.next,
                                  style: GoogleFonts.poppins(),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Judul dokumen tidak boleh kosong';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                
                                // Form field for dokter
                                TextFormField(
                                  controller: _dokterController,
                                  decoration: InputDecoration(
                                    labelText: 'Nama Dokter',
                                    labelStyle: GoogleFonts.poppins(),
                                    hintText: 'Masukkan nama dokter',
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
                                    prefixIcon: const Icon(CupertinoIcons.person_badge_plus),
                                    prefixIconColor: const Color(0xFF64D1DE),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                  ),
                                  textCapitalization: TextCapitalization.words,
                                  textInputAction: TextInputAction.next,
                                  style: GoogleFonts.poppins(),
                                ),
                                const SizedBox(height: 16),
                                
                                // Form field for klinik
                                TextFormField(
                                  controller: _klinikController,
                                  decoration: InputDecoration(
                                    labelText: 'Nama Klinik/Rumah Sakit',
                                    labelStyle: GoogleFonts.poppins(),
                                    hintText: 'Masukkan nama klinik/rumah sakit',
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
                                    prefixIcon: const Icon(CupertinoIcons.building_2_fill),
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
                                      return 'Nama klinik/rumah sakit tidak boleh kosong';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                
                                // Form field for date
                                TextFormField(
                                  controller: _tanggalController,
                                  decoration: InputDecoration(
                                    labelText: 'Tanggal Pemeriksaan',
                                    labelStyle: GoogleFonts.poppins(),
                                    hintText: 'Pilih tanggal pemeriksaan',
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
                                      return 'Tanggal pemeriksaan tidak boleh kosong';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                
                                // Form field for hasil
                                TextFormField(
                                  controller: _hasilController,
                                  decoration: InputDecoration(
                                    labelText: 'Hasil Pemeriksaan',
                                    labelStyle: GoogleFonts.poppins(),
                                    hintText: 'Contoh: Normal, Abnormal, Positif, dll',
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
                                    prefixIcon: const Icon(CupertinoIcons.checkmark_seal),
                                    prefixIconColor: const Color(0xFF64D1DE),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                  ),
                                  textCapitalization: TextCapitalization.sentences,
                                  textInputAction: TextInputAction.next,
                                  style: GoogleFonts.poppins(),
                                ),
                                const SizedBox(height: 16),
                                
                                // Form field for catatan
                                TextFormField(
                                  controller: _catatanController,
                                  decoration: InputDecoration(
                                    labelText: 'Catatan',
                                    labelStyle: GoogleFonts.poppins(),
                                    hintText: 'Masukkan catatan atau rekomendasi dokter',
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
                                    prefixIcon: const Icon(CupertinoIcons.text_quote),
                                    prefixIconColor: const Color(0xFF64D1DE),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                  ),
                                  textCapitalization: TextCapitalization.sentences,
                                  textInputAction: TextInputAction.done,
                                  style: GoogleFonts.poppins(),
                                  maxLines: 3,
                                ),
                                
                                // Comparison of changes
                                if (_isFormDirty && _initialData != null)
                                  Container(
                                    margin: const EdgeInsets.only(top: 24),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.amber.withValues(alpha: 0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(
                                              CupertinoIcons.exclamationmark_triangle,
                                              color: Colors.amber,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Perubahan Data',
                                              style: GoogleFonts.poppins(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        if (_judulController.text != _initialData!['judul_dokumen'])
                                          _buildChangeRow(
                                            'Judul Dokumen',
                                            _initialData!['judul_dokumen'],
                                            _judulController.text,
                                          ),
                                        if (_selectedJenisDokumen != _initialData!['jenis_dokumen'])
                                          _buildChangeRow(
                                            'Jenis Dokumen',
                                            _initialData!['jenis_dokumen'],
                                            _selectedJenisDokumen,
                                          ),
                                        if (_dokterController.text != (_initialData!['nama_dokter'] ?? ''))
                                          _buildChangeRow(
                                            'Nama Dokter',
                                            _initialData!['nama_dokter'] ?? 'Tidak Ada',
                                            _dokterController.text,
                                          ),
                                        if (_klinikController.text != (_initialData!['nama_klinik'] ?? ''))
                                          _buildChangeRow(
                                            'Nama Klinik',
                                            _initialData!['nama_klinik'] ?? 'Tidak Ada',
                                            _klinikController.text,
                                          ),
                                        if (_tanggalController.text != _initialData!['tanggal_dokumen'])
                                          _buildChangeRow(
                                            'Tanggal Pemeriksaan',
                                            _initialData!['tanggal_dokumen'],
                                            _tanggalController.text,
                                          ),
                                        if (_hasilController.text != (_initialData!['hasil'] ?? ''))
                                          _buildChangeRow(
                                            'Hasil Pemeriksaan',
                                            _initialData!['hasil'] ?? 'Tidak Ada',
                                            _hasilController.text,
                                          ),
                                        if (_catatanController.text != (_initialData!['catatan'] ?? ''))
                                          _buildChangeRow(
                                            'Catatan',
                                            _initialData!['catatan'] ?? 'Tidak Ada',
                                            _catatanController.text,
                                          ),
                                        if (_images.any((img) => img.isNew) || _deletedImageIds.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              'Foto dokumen diubah',
                                              style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                
                                // Additional information field section
                                const SizedBox(height: 32),
                                Text(
                                  'Informasi Tambahan',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            CupertinoIcons.info_circle,
                                            color: Color(0xFF64D1DE),
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Pastikan informasi yang Anda masukkan sesuai dengan dokumen asli untuk referensi medis yang akurat',
                                              style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          const Icon(
                                            CupertinoIcons.lock_shield,
                                            color: Color(0xFF64D1DE),
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Data ini disimpan secara lokal di perangkat Anda dan tidak dibagikan ke pihak lain',
                                              style: GoogleFonts.poppins(
                                                fontSize: 13,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Terms and conditions section
                                const SizedBox(height: 32),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: Checkbox(
                                        value: _isFormDirty,
                                        onChanged: (value) {
                                          // Checkbox is read-only, showing that user has made changes
                                        },
                                        activeColor: const Color(0xFF64D1DE),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Dengan menyimpan perubahan, saya menyatakan bahwa data yang diubah adalah benar dan sesuai',
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
        bottomNavigationBar: AnimatedOpacity(
          opacity: (_isLoading || _isSaving) ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 250),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: SafeArea(
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: (_isLoading || _isSaving) ? null : _updateDokumen,
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
                      const Icon(CupertinoIcons.arrow_up_doc_fill),
                      const SizedBox(width: 8),
                      Text(
                        'Perbarui Data',
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
  
  // Widget to show before and after changes
  Widget _buildChangeRow(String label, String oldValue, String newValue) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                CupertinoIcons.arrow_right_arrow_left,
                size: 14,
                color: Colors.grey,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                    children: [
                      TextSpan(
                        text: '$oldValue ',
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.red,
                        ),
                      ),
                      TextSpan(
                        text: '→ $newValue',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}