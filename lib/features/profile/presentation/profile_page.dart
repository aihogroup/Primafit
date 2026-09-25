import 'package:primafit/app/router/app_routes.dart';
import 'package:primafit/core/widgets/confirm_pop_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:primafit/features/health_record/presentation/asamurat/read_asamurat.dart';
import 'package:primafit/features/health_record/presentation/bmi/read_bmi.dart';
import 'package:primafit/features/health_record/presentation/guladarah/read_guladarah.dart';
import 'package:primafit/features/health_record/presentation/kolesterol/read_kolesterol.dart';
import 'package:primafit/features/health_record/presentation/tensi/read_tensi.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primafit/core/config/env.dart';
import 'package:primafit/features/auth/presentation/widgets/account_section.dart';
import 'package:primafit/features/health_record/presentation/widgets/sync_status_tile.dart';
import 'package:primafit/features/professional/presentation/widgets/professional_entry_tile.dart';
import 'package:primafit/features/profile/domain/entities/user_profile.dart';
import 'package:primafit/features/profile/presentation/providers/profile_providers.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class ProfilePage extends ConsumerStatefulWidget {
  final bool isEditingEnabled;
  
  const ProfilePage({
    super.key, 
    this.isEditingEnabled = false
  });

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> with SingleTickerProviderStateMixin {
  Map<String, dynamic> _profileData = {};
  bool _isLoading = true;
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for form fields
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _tanggalLahirController = TextEditingController();
  final TextEditingController _teleponController = TextEditingController();
  String? _selectedGender;
  String? _selectedGolonganDarah;
  String? _profileImagePath;
  
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    
    // Set editing mode based on widget parameter
    _isEditing = widget.isEditingEnabled;
    
    _loadProfileData();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _tanggalLahirController.dispose();
    _teleponController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final profile = await ref.read(profileControllerProvider.future);
      if (profile != null && mounted) {
        setState(() {
          _profileData = {...profile.toMap(), 'id': profile.id};
          _namaController.text = profile.name;
          _tanggalLahirController.text = profile.birthDate ?? '';
          _teleponController.text = profile.phone ?? '';
          _selectedGender = profile.gender;
          _selectedGolonganDarah = profile.bloodType;
          _profileImagePath = profile.photoPath;
        });
      }
    } catch (e) {
      debugPrint('Load profile failed: $e');
      _showErrorMessage('Gagal memuat data profil.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final error = await ref.read(profileControllerProvider.notifier).save(
          UserProfile(
            id: _profileData['id'] as int?,
            name: _namaController.text.trim(),
            birthDate: _tanggalLahirController.text,
            gender: _selectedGender,
            bloodType: _selectedGolonganDarah,
            phone: _teleponController.text,
            photoPath: _profileImagePath,
          ),
        );
    if (!mounted) return;

    if (error != null) {
      setState(() => _isLoading = false);
      _showErrorMessage(error);
      return;
    }

    setState(() => _isEditing = false);
    _showSuccessMessage('Profil berhasil disimpan');
    await _loadProfileData();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    
    if (image != null) {
      setState(() {
        _profileImagePath = image.path;
      });
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggalLahirController.text.isNotEmpty
          ? DateFormat('dd-MM-yyyy').parse(_tanggalLahirController.text)
          : DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF64D1DE),
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
        _tanggalLahirController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
Widget build(BuildContext context) {
  return ConfirmPopScope(
    onWillPop: _onWillPop,
    child: Scaffold(
      backgroundColor: Colors.white,
      
      appBar: AppBar(
        title: Text(
          'Profil Pengguna',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF64D1DE),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, color: Colors.white),
          tooltip: 'Kembali',
          onPressed: () {
            _onWillPop();
          },
        ),
        centerTitle: true,
      ),

      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF64D1DE)),
              ),
            )
          : FadeTransition(
              opacity: _animation,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildHeader(),
                    _isEditing ? _buildEditForm() : _buildProfileDetails(),
                    if (!_isEditing && Env.isSupabaseConfigured) ...[
                      const SyncStatusTile(),
                      const SizedBox(height: 8),
                      const ProfessionalEntryTile(),
                      const SizedBox(height: 8),
                      const AccountSection(),
                    ],
                  ],
                ),
              ),
            ),
    ),
  );
}

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(bottom: 20),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Hero(
              tag: 'profile-image',
              child: GestureDetector(
                onTap: _isEditing ? _pickImage : null,
                child: Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                    image: _profileImagePath != null && _profileImagePath!.isNotEmpty
                        ? DecorationImage(
                            image: FileImage(File(_profileImagePath!)),
                            fit: BoxFit.cover,
                          )
                        : const DecorationImage(
                            image: AssetImage('assets/avatar/avatar1.jpg'),
                            fit: BoxFit.cover,
                          ),
                  ),
                  child: _isEditing
                      ? Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black.withValues(alpha: 0.3),
                          ),
                          child: const Icon(
                            CupertinoIcons.camera,
                            color: Colors.white,
                            size: 40,
                          ),
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              _profileData['nama'] ?? 'Tambahkan Profil',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(255, 0, 0, 0),
              ),
              textAlign: TextAlign.center,
            ),
            if (!_isEditing && _profileData['telepon'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  _profileData['telepon'] ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: const Color.fromARGB(255, 0, 0, 0).withValues(alpha: 0.8),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetails() {
  return Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Baris berisi judul dan tombol "Ubah"
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('Informasi Pribadi'),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              label: Text(
                'Ubah',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  // fontWeight: FontWeight.w500,
                  color: const Color(0xFF64D1DE),
                ),
              ),
              icon: const Icon(
                CupertinoIcons.pencil,
                size: 25,
                color: Color(0xFF64D1DE),
              ),
            ),
          ],
        ),
        if (_isEditing)
          Align(
            alignment: Alignment.centerRight,
            child: FloatingActionButton(
              onPressed: _saveProfile,
              backgroundColor: const Color(0xFF64D1DE),
              tooltip: 'Simpan Profil',
              mini: true,
              child: const Icon(CupertinoIcons.check_mark, color: Colors.white),
            ),
          ),
        const SizedBox(height: 10),
        _buildInfoCard([
          _buildInfoItem(
            CupertinoIcons.calendar,
            'Tanggal Lahir',
            _profileData['tanggalLahir'] ?? 'Belum diisi',
          ),
          _buildInfoItem(
            CupertinoIcons.person,
            'Jenis Kelamin',
            _profileData['gender'] ?? 'Belum diisi',
          ),
          _buildInfoItem(
            CupertinoIcons.drop,
            'Golongan Darah',
            _profileData['golonganDarah'] ?? 'Belum diisi',
          ),
        ]),
        const SizedBox(height: 30),
        _buildSectionTitle('Catatan Kesehatan'),
        const SizedBox(height: 10),
        _buildHealthMetricsCard(),
      ],
    ),
  );
}

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
  return Card(
    color: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    child: Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        children: children,
      ),
    ),
  );
}


  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF64D1DE).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF64D1DE),
              size: 22,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthMetricsCard() {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildMetricTile(
              'Tekanan Darah',
              CupertinoIcons.heart,
              Colors.redAccent,
              'Lihat Riwayat',
              () {
                // Navigate to tekanan darah history page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReadTensiScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            _buildMetricTile(
              'Gula Darah',
              CupertinoIcons.drop_fill,
              Colors.orangeAccent,
              'Lihat Riwayat',
              () {
                // Navigate to gula darah history page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReadGulaDarahScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            _buildMetricTile(
              'Kolesterol',
              CupertinoIcons.chart_bar,
              Colors.purpleAccent,
              'Lihat Riwayat',
              () {
                // Navigate to kolesterol history page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReadKolesterolScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            _buildMetricTile(
              'Asam Urat',
              CupertinoIcons.arrow_up_right_square,
              Colors.blueAccent,
              'Lihat Riwayat',
              () {
                // Navigate to asam urat history page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReadAsamUratScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            _buildMetricTile(
              'BMI',
              CupertinoIcons.person_crop_rectangle,
              Colors.greenAccent.shade700,
              'Lihat Riwayat',
              () {
                // Navigate to BMI history page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReadBmiScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(
    String title,
    IconData icon,
    Color color,
    String buttonText,
    VoidCallback onPressed,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: onPressed,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF64D1DE),
              textStyle: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            child: Row(
              children: [
                Text(buttonText),
                const SizedBox(width: 5),
                const Icon(CupertinoIcons.chevron_right, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Edit Profil',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _namaController,
              label: 'Nama Lengkap',
              icon: CupertinoIcons.person_solid,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nama tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildDateField(
              controller: _tanggalLahirController,
              label: 'Tanggal Lahir',
              icon: CupertinoIcons.calendar,
              onTap: _selectDate,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Tanggal lahir tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildDropdownField(
              label: 'Jenis Kelamin',
              icon: CupertinoIcons.person_2,
              value: _selectedGender,
              items: const ['Laki-laki', 'Perempuan'],
              onChanged: (value) {
                setState(() {
                  _selectedGender = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Pilih jenis kelamin';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildDropdownField(
              label: 'Golongan Darah',
              icon: CupertinoIcons.drop,
              value: _selectedGolonganDarah,
              items: const ['A', 'B', 'AB', 'O', 'Tidak tahu'],
              onChanged: (value) {
                setState(() {
                  _selectedGolonganDarah = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Pilih golongan darah';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _teleponController,
              label: 'Nomor Telepon',
              icon: CupertinoIcons.phone,
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nomor telepon tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isEditing = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Batal',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF64D1DE),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Simpan',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          color: Colors.grey[700],
        ),
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF64D1DE),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.grey[300]!,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xFF64D1DE),
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.0,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 16.0,
        ),
      ),
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(),
      validator: validator,
    );
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          color: Colors.grey[700],
        ),
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF64D1DE),
        ),
        suffixIcon: Icon(
          CupertinoIcons.chevron_down,
          color: Colors.grey[600],
          size: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.grey[300]!,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xFF64D1DE),
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.0,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 16.0,
        ),
      ),
      readOnly: true,
      onTap: onTap,
      style: GoogleFonts.poppins(),
      validator: validator,
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          color: Colors.grey[700],
        ),
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF64D1DE),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.grey[300]!,
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Color(0xFF64D1DE),
            width: 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.0,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 16.0,
        ),
      ),
      icon: Icon(
        CupertinoIcons.chevron_down,
        color: Colors.grey[600],
        size: 18,
      ),
      style: GoogleFonts.poppins(
        color: Colors.black87,
      ),
      dropdownColor: Colors.white,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }

  Future<bool> _onWillPop() async {
  if (_isEditing) {
    // Show confirmation dialog when in editing mode
    bool shouldPop = false;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  spreadRadius: 5,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header dengan animasi
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 800),
                  builder: (context, double value, child) {
                    return Opacity(
                      opacity: value,
                      child: Transform.scale(
                        scale: value,
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            CupertinoIcons.exclamationmark_triangle,
                            color: Colors.red,
                            size: 50,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                // Judul dialog
                Text(
                  'Peringatan!',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                // Pesan dialog
                Text(
                  'Apakah anda yakin meninggalkan halaman ini? Data perubahan Anda tidak tersimpan',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 25),
                // Tombol aksi
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Tombol tidak
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Do not allow pop
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: Colors.red),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.xmark,
                              color: Colors.red,
                              size: 18,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Tidak',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Tombol ya
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Allow pop and navigate to profile
                          shouldPop = true;
                          Navigator.of(context).pop();
                          Navigator.pushReplacementNamed(context, AppRoutes.profile);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.check_mark,
                              size: 18,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Ya, Keluar',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
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
          ),
        );
      },
    );
    return shouldPop;
  } else {
    // If not editing, go to home directly
    Navigator.pushReplacementNamed(context, AppRoutes.home);
    return true;
  }
}
}