import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primafit/UI/navigasi/navigation.dart';
import 'package:primafit/database/navigasi/database_gejala.dart';
import 'package:primafit/UI/navigasi/riwayat/input_gejala.dart';
import 'package:primafit/UI/navigasi/riwayat/update_gejala.dart';
import 'package:intl/intl.dart';
import 'dart:ui';

class GejalaPage extends StatefulWidget {
  const GejalaPage({Key? key}) : super(key: key);

  @override
  State<GejalaPage> createState() => _GejalaPageState();
}

class _GejalaPageState extends State<GejalaPage> with SingleTickerProviderStateMixin {
  final Color themeColor = const Color(0xFF64D1DE);
  late AnimationController _animationController;
  List<Map<String, dynamic>> _gejalaList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _refreshGejalaList();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Refresh list gejala dari database
  Future<void> _refreshGejalaList() async {
    setState(() {
      _isLoading = true;
    });
    
    final data = await DatabaseGejalaHelper.instance.getAllGejala();
    
    setState(() {
      _gejalaList = data;
      _isLoading = false;
    });
  }

  // Menghapus data gejala
  Future<void> _deleteGejala(int id) async {
    await DatabaseGejalaHelper.instance.deleteGejala(id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Data gejala berhasil dihapus'),
        backgroundColor: themeColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
    _refreshGejalaList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Catat Gejala',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        'Catat dan pantau gejala kesehatan Anda untuk membantu memantau kondisi kesehatan secara teratur.',
        style: GoogleFonts.poppins(
          fontSize: 14,
          color: Colors.black54,
          height: 1.5,
        ),
      ),
    ),
    const SizedBox(height: 16),
    // Floating Analysis Button
    Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/histori');
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: themeColor,
            foregroundColor: Colors.white,
            elevation: 4,
            shadowColor: themeColor.withOpacity(0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.graph_circle,
                size: 20,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                'Analisis Riwayat Diagnosa',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    const SizedBox(height: 16),
    Expanded(
      child: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _gejalaList.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        CupertinoIcons.doc_text_search,
                        size: 70,
                        color: themeColor.withOpacity(0.7),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum ada data gejala',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  itemCount: _gejalaList.length,
                  itemBuilder: (context, index) {
                    final gejala = _gejalaList[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: _buildTimelineItem(
                        gejala['id'],
                        gejala['gejala'],
                        gejala['catatan'] ?? '',
                        gejala['tanggal'],
                        index == _gejalaList.length - 1,
                      ),
                    );
                  },
                ),
    ),
  ],
),
      floatingActionButton: TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(milliseconds: 500),
        curve: Curves.elasticOut,
        builder: (context, double value, child) {
          return Transform.scale(
            scale: value,
            child: FloatingActionButton(
              backgroundColor: themeColor,
              elevation: 4,
              onPressed: () async {
                _animationController.forward();
                await Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => 
                      const InputGejala(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = Offset(0.0, 1.0);
                      const end = Offset.zero;
                      const curve = Curves.easeInOutCubic;
                      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                      var offsetAnimation = animation.drive(tween);
                      return SlideTransition(position: offsetAnimation, child: child);
                    },
                  ),
                );
                _animationController.reverse();
                _refreshGejalaList();
              },
              child: const Icon(
                Icons.add,
                size: 32,
                color: Colors.white,
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 4),
    );
  }

  Widget _buildTimelineItem(int id, String title, String description, String date, bool isLast) {
    return InkWell(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UpdateGejala(id: id),
          ),
        );
        _refreshGejalaList();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: themeColor,
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 120,
                    color: Colors.grey.withOpacity(0.3),
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: GoogleFonts.poppins(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text(
                                      'Hapus Data',
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    content: Text(
                                      'Apakah Anda yakin ingin menghapus data ini?',
                                      style: GoogleFonts.poppins(),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          'Batal',
                                          style: GoogleFonts.poppins(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          _deleteGejala(id);
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          'Hapus',
                                          style: GoogleFonts.poppins(
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  );
                                },
                              );
                            },
                            child: const Icon(
                              CupertinoIcons.delete,
                              size: 18,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (description.isNotEmpty)
                        Text(
                          description,
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: Colors.black54,
                          ),
                        ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFF7880B5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _formatDate(date),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final formattedDate = DateFormat('EEEE, d MMM yyyy', 'id_ID').format(date);
      return formattedDate;
    } catch (e) {
      return dateStr;
    }
  }
}