// import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:primafit/database/simpan/database_bpjs.dart';
// import 'package:path_provider/path_provider.dart';

// Halaman utama untuk menampilkan daftar kartu BPJS
class BpjsListPage extends StatefulWidget {
  const BpjsListPage({Key? key}) : super(key: key);

  @override
  State<BpjsListPage> createState() => _BpjsListPageState();
}

class _BpjsListPageState extends State<BpjsListPage> with SingleTickerProviderStateMixin {
  final dbHelper = DatabaseBpjsHelper.instance;
  List<Map<String, dynamic>> bpjsList = [];
  bool isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _loadBpjsData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Fungsi untuk memuat data BPJS dari database
  Future<void> _loadBpjsData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = await dbHelper.getAllBpjs();
      setState(() {
        bpjsList = data;
        isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorDialog('Error loading data: $e');
    }
  }

  // Fungsi untuk menampilkan dialog error
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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

  // Fungsi untuk konfirmasi penghapusan data
  Future<void> _confirmDelete(int id, String nama) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Konfirmasi Hapus',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus data BPJS untuk $nama?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Batal',
              style: GoogleFonts.poppins(color: Colors.grey),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteBpjs(id);
            },
            child: Text(
              'Hapus',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi untuk menghapus data BPJS
  Future<void> _deleteBpjs(int id) async {
    try {
      await dbHelper.deleteBpjs(id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Data BPJS berhasil dihapus',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(10),
        ),
      );
      _loadBpjsData();
    } catch (e) {
      _showErrorDialog('Error deleting data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Simpan data',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF64D1DE),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/semua'),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF64D1DE),
              ),
            )
          : bpjsList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.doc_text_search,
                        size: 70,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada kartu BPJS tersimpan',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    itemCount: bpjsList.length,
                    itemBuilder: (context, index) {
                      final bpjs = bpjsList[index];
                      Uint8List? fotoBytes;
                      if (bpjs['foto'] != null) {
                        fotoBytes = bpjs['foto'];
                      }

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: BpjsCard(
                          bpjs: bpjs,
                          fotoBytes: fotoBytes,
                          onDelete: () => _confirmDelete(bpjs['id'], bpjs['nama']),
                          onEdit: () => _navigateToEditBpjs(bpjs['id']),
                        ),
                      );
                    },
                  ),
                ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            height: 56,
            child: ElevatedButton(
              onPressed: () => _navigateToAddBpjs(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF64D1DE),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Tambahkan',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Navigasi ke halaman input BPJS baru
  void _navigateToAddBpjs() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const InputBpjsPage(),
      ),
    );

    if (result == true) {
      _loadBpjsData();
    }
  }

  // Navigasi ke halaman edit BPJS
  void _navigateToEditBpjs(int id) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InputBpjsPage(bpjsId: id),
      ),
    );

    if (result == true) {
      _loadBpjsData();
    }
  }
}

// Widget untuk menampilkan kartu BPJS
class BpjsCard extends StatelessWidget {
  final Map<String, dynamic> bpjs;
  final Uint8List? fotoBytes;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const BpjsCard({
    Key? key,
    required this.bpjs,
    this.fotoBytes,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          if (fotoBytes != null)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Stack(
                children: [
                  Image.memory(
                    fotoBytes!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  // Positioned(
                  //   bottom: 0,
                  //   right: 0,
                  //   child: Container(
                  //     decoration: BoxDecoration(
                  //       color: Colors.red.withOpacity(0.8),
                  //       borderRadius: const BorderRadius.only(
                  //         topLeft: Radius.circular(12),
                  //       ),
                  //     ),
                  //     child: IconButton(
                  //       icon: const Icon(
                  //         CupertinoIcons.pause_fill,
                  //         color: Colors.white,
                  //       ),
                  //       onPressed: onDelete,
                  //     ),
                  //   ),
                  // ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                        ),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          CupertinoIcons.eye,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.memory(
                                  fotoBytes!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              height: 200,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFEAF7F9),
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Icon(
                CupertinoIcons.creditcard,
                size: 100,
                color: Colors.grey[400],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Nomor Kartu', bpjs['nomor_bpjs']),
                const SizedBox(height: 8),
                _buildInfoRow('Nama', bpjs['nama']),
                const SizedBox(height: 8),
                _buildInfoRow('Tanggal Lahir', bpjs['tanggal_lahir']),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: onEdit,
                      icon: const Icon(CupertinoIcons.pencil),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF64D1DE),
                        side: const BorderSide(color: Color(0xFF64D1DE)),
                        textStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: onDelete,
                      icon: const Icon(CupertinoIcons.delete),
                      label: const Text('Hapus'),
                      // style: ElevatedButton.styleFrom(
                      //   backgroundColor: Colors.red,
                      //   textStyle: GoogleFonts.poppins(
                      //     fontWeight: FontWeight.w500,
                      //   ),
                      // ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color.fromARGB(255, 255, 0, 0),
                        side: const BorderSide(color: Color.fromARGB(255, 255, 0, 0)),
                        textStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk menampilkan baris informasi (label dan nilai)
  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
        const Text(': '),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

// Halaman untuk input atau edit data BPJS
class InputBpjsPage extends StatefulWidget {
  final int? bpjsId;

  const InputBpjsPage({Key? key, this.bpjsId}) : super(key: key);

  @override
  State<InputBpjsPage> createState() => _InputBpjsPageState();
}

class _InputBpjsPageState extends State<InputBpjsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomorController = TextEditingController();
  final _namaController = TextEditingController();
  final _tanggalLahirController = TextEditingController();
  final dbHelper = DatabaseBpjsHelper.instance;
  
  DateTime? _selectedDate;
  File? _imageFile;
  Uint8List? _imageBytes;
  bool _isLoading = false;
  bool _isEdit = false;

  @override
  void initState() {
    super.initState();
    if (widget.bpjsId != null) {
      _isEdit = true;
      _loadBpjsData();
    }
  }

  // Fungsi untuk memuat data BPJS untuk diedit
  Future<void> _loadBpjsData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final bpjs = await dbHelper.getBpjsById(widget.bpjsId!);
      if (bpjs != null) {
        _nomorController.text = bpjs['nomor_bpjs'];
        _namaController.text = bpjs['nama'];
        _tanggalLahirController.text = bpjs['tanggal_lahir'];
        
        if (bpjs['tanggal_lahir'].isNotEmpty) {
          final parts = bpjs['tanggal_lahir'].split('-');
          if (parts.length == 3) {
            _selectedDate = DateTime(
              int.parse(parts[2]),
              int.parse(parts[1]),
              int.parse(parts[0]),
            );
          }
        }
        
        if (bpjs['foto'] != null) {
          setState(() {
            _imageBytes = bpjs['foto'];
          });
        }
      }
    } catch (e) {
      _showErrorDialog('Error loading data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fungsi untuk mengambil gambar dari galeri atau kamera
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
          _imageBytes = null;
        });
      }
    } catch (e) {
      _showErrorDialog('Error picking image: $e');
    }
  }

  // Fungsi untuk memilih tanggal lahir
  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = _selectedDate ?? DateTime(now.year - 20, 1, 1);
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF64D1DE),
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

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _tanggalLahirController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  // Fungsi untuk menyimpan data BPJS
  Future<void> _saveBpjs() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      Uint8List? imageData;
      
      // Jika ada file gambar baru
      if (_imageFile != null) {
        imageData = await _imageFile!.readAsBytes();
      } 
      // Jika tidak ada file baru tapi ada data gambar dari database
      else if (_imageBytes != null) {
        imageData = _imageBytes;
      }

      final bpjsData = {
        'nomor_bpjs': _nomorController.text,
        'nama': _namaController.text,
        'tanggal_lahir': _tanggalLahirController.text,
        'foto': imageData,
      };

      if (_isEdit) {
        await dbHelper.updateBpjs(widget.bpjsId!, bpjsData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Data BPJS berhasil diperbarui',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        await dbHelper.insertBpjs(bpjsData);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Data BPJS berhasil disimpan',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }

      Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error saving data: $e');
    }
  }

  // Fungsi untuk menampilkan dialog error
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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

  // Fungsi untuk menampilkan opsi pengambilan foto
  void _showImageSourceOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pilih Sumber Foto',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFEAF7F9),
                child: Icon(
                  CupertinoIcons.camera,
                  color: Color(0xFF64D1DE),
                ),
              ),
              title: Text(
                'Kamera',
                style: GoogleFonts.poppins(),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFEAF7F9),
                child: Icon(
                  CupertinoIcons.photo,
                  color: Color(0xFF64D1DE),
                ),
              ),
              title: Text(
                'Galeri',
                style: GoogleFonts.poppins(),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            if (_imageFile != null || _imageBytes != null)
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFFFEEEE),
                  child: Icon(
                    CupertinoIcons.delete,
                    color: Colors.red,
                  ),
                ),
                title: Text(
                  'Hapus Foto',
                  style: GoogleFonts.poppins(),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _imageFile = null;
                    _imageBytes = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Kartu BPJS' : 'Tambah Kartu BPJS'),
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF64D1DE),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Widget untuk menampilkan dan mengambil foto
                    GestureDetector(
                      onTap: _showImageSourceOptions,
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF7F9),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 1,
                          ),
                        ),
                        child: _imageFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _imageFile!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : _imageBytes != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.memory(
                                      _imageBytes!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        CupertinoIcons.camera,
                                        size: 50,
                                        color: Colors.grey[400],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Tap untuk ambil foto kartu BPJS',
                                        style: GoogleFonts.poppins(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Informasi Kartu BPJS',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Form field untuk nomor BPJS
                    TextFormField(
                      controller: _nomorController,
                      decoration: InputDecoration(
                        labelText: 'Nomor Kartu BPJS',
                        labelStyle: GoogleFonts.poppins(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(CupertinoIcons.creditcard),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF64D1DE),
                            width: 2,
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nomor BPJS tidak boleh kosong';
                        }
                        if (value.length < 8) {
                          return 'Nomor BPJS terlalu pendek';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Form field untuk nama
                    TextFormField(
                      controller: _namaController,
                      decoration: InputDecoration(
                        labelText: 'Nama Lengkap',
                        labelStyle: GoogleFonts.poppins(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(CupertinoIcons.person),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF64D1DE),
                            width: 2,
                          ),
                        ),
                      ),
                      textCapitalization: TextCapitalization.words,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Form field untuk tanggal lahir
                    TextFormField(
                      controller: _tanggalLahirController,
                      decoration: InputDecoration(
                        labelText: 'Tanggal Lahir',
                        labelStyle: GoogleFonts.poppins(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(CupertinoIcons.calendar),
                        suffixIcon: IconButton(
                          icon: const Icon(CupertinoIcons.arrow_down_circle),
                          onPressed: () => _selectDate(context),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF64D1DE),
                            width: 2,
                          ),
                        ),
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Tanggal lahir tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    // Tombol simpan data BPJS
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _saveBpjs,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF64D1DE),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          _isEdit ? 'Perbarui Data' : 'Simpan Data',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

@override
  void dispose() {
    _nomorController.dispose();
    _namaController.dispose();
    _tanggalLahirController.dispose();
    super.dispose();
  }
}