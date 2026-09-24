import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:primafit/database/diagnosa/database_umum.dart';
import 'package:primafit/UI/diagnosa/umum/output_umum.dart';
import 'package:primafit/UI/diagnosa/umum/list_pertanyaan.dart';

class UmumPage extends StatefulWidget {
  const UmumPage({Key? key}) : super(key: key);

  @override
  _UmumPageState createState() => _UmumPageState();
}

class _UmumPageState extends State<UmumPage> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  final Map<String, String> _answers = {};
  int _currentPage = 0;
  bool _isAnimating = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    
    _animationController.forward();
    
    // Inisialisasi database dan import data CSV
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await DatabaseHelper.instance.importCSV();
      setState(() {
        _loading = false;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < UmumQuestions.activeQuestions(_answers).length - 1) {
      _animateToNextPage();
    } else {
      _submitAnswers();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _animateToPreviousPage();
    }
  }

  Future<void> _animateToNextPage() async {
    if (_isAnimating) return;
    
    setState(() => _isAnimating = true);
    
    await _animationController.reverse();
    
    if (!mounted) return;
    
    await _pageController.nextPage(
      duration: const Duration(milliseconds: 300), 
      curve: Curves.easeInOut,
    );
    
    if (!mounted) return;
    
    setState(() {
      _currentPage++;
      _isAnimating = false;
    });
    
    await _animationController.forward();
  }

  Future<void> _animateToPreviousPage() async {
    if (_isAnimating) return;
    
    setState(() => _isAnimating = true);
    
    await _animationController.reverse();
    
    if (!mounted) return;
    
    await _pageController.previousPage(
      duration: const Duration(milliseconds: 300), 
      curve: Curves.easeInOut,
    );
    
    if (!mounted) return;
    
    setState(() {
      _currentPage--;
      _isAnimating = false;
    });
    
    await _animationController.forward();
  }

  Future<void> _submitAnswers() async {
    _showLoadingDialog('Memproses diagnosa...');

    // Konversi jawaban ke format untuk database
    Map<String, dynamic> userAnswers = {};
    for (var question in UmumQuestions.questions) {
      String id = question['id'];
      userAnswers[id] = _answers.containsKey(id) ? _answers[id] : 'Tidak';
    }

    // Simpan jawaban ke database
    await DatabaseHelper.instance.saveUserAnswers(userAnswers);

    // Navigasi ke halaman hasil
    if (!mounted) return;
    
    Navigator.pop(context); // Tutup dialog loading
    
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => OutputPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          
          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );
          
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 500),
      ),
    );
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 5,
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF64D1DE).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const CupertinoActivityIndicator(
                  radius: 15,
                  color: Color(0xFF64D1DE),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExitConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF64D1DE).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.exclamationmark_triangle_fill,
                  color: Color(0xFF64D1DE),
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Konfirmasi',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Apakah Anda yakin ingin keluar? Data jawaban tidak akan disimpan.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: Text(
                      'Tidak',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);  // Tutup dialog
                      Navigator.pop(context);  // Kembali ke halaman sebelumnya
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF64D1DE),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Ya, Keluar',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerButton(String answer, String questionId) {
    bool isSelected = _answers[questionId] == answer;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 8),
      width: double.infinity, // Membuat tombol selebar layar
      decoration: BoxDecoration(
        color: isSelected 
            ? const Color(0xFF64D1DE).withOpacity(0.1)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFF64D1DE) : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected 
            ? [
                BoxShadow(
                  color: const Color(0xFF64D1DE).withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 1,
                )
              ] 
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 5,
                  spreadRadius: 1,
                )
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          splashColor: const Color(0xFF64D1DE).withOpacity(0.1),
          highlightColor: const Color(0xFF64D1DE).withOpacity(0.05),
          onTap: () {
            setState(() {
              _answers[questionId] = answer;
            });
            
            // Hapus jawaban kondisional jika diperlukan
            if (questionId == 'batuk' && answer == 'Tidak') {
              _answers.remove('batuk_berdahak');
              _answers.remove('batuk_berdarah');
            }
            
            // Delay before moving to next question
            Future.delayed(const Duration(milliseconds: 300), () {
              _nextPage();
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  answer,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? const Color(0xFF64D1DE) : Colors.black87,
                  ),
                ),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: isSelected ? 1.0 : 0.0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Color(0xFF64D1DE),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      CupertinoIcons.checkmark,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionPage(Map<String, dynamic> question, int index) {
    String questionId = question['id'];
    // Mengambil dimensi layar
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24),
          height: screenHeight - AppBar().preferredSize.height - MediaQuery.of(context).padding.top,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.02),
              
              // Progress indicator
              Row(
                children: [
                  Text(
                    'Pertanyaan ${index + 1}/${UmumQuestions.activeQuestions(_answers).length}',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: screenWidth * 0.4, // Membuat progress bar responsif
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey.shade200,
                    ),
                    child: Stack(
                      children: [
                        AnimatedFractionallySizedBox(
                          duration: const Duration(milliseconds: 300),
                          widthFactor: (index + 1) / UmumQuestions.activeQuestions(_answers).length,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: const Color(0xFF64D1DE),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF64D1DE).withOpacity(0.4),
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: screenHeight * 0.05),
              
              // Question container - Dibuat responsif dengan lebar layar
              Container(
                width: double.infinity, // Mengisi lebar layar
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.03,
                  horizontal: screenWidth * 0.05,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      spreadRadius: 1,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Menyesuaikan dengan konten
                  children: [
                    // Question icon
                    Container(
                      padding: EdgeInsets.all(screenWidth * 0.03),
                      decoration: BoxDecoration(
                        color: const Color(0xFF64D1DE).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        question['icon'],
                        size: screenWidth * 0.09, // Ikon responsif
                        color: const Color(0xFF64D1DE),
                      ),
                    ),
                    
                    SizedBox(height: screenHeight * 0.025),
                    
                    // Question text
                    Text(
                      question['question'],
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.045, // Teks responsif
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                        color: Colors.black87,
                      ),
                    ),
                    
                    // Description (if available)
                    if (question.containsKey('description') && question['description'].isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: screenHeight * 0.015),
                        child: Text(
                          question['description'],
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: screenWidth * 0.035, // Teks responsif
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              SizedBox(height: screenHeight * 0.04),
              
              // Answer options
              _buildAnswerButton('Ya', questionId),
              _buildAnswerButton('Tidak', questionId),
              _buildAnswerButton('Kadang', questionId),
              
              const Spacer(),
              
              // Navigation buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (index > 0)
                    TextButton.icon(
                      onPressed: _previousPage,
                      icon: const Icon(
                        CupertinoIcons.arrow_left,
                        size: 18,
                      ),
                      label: Text(
                        'Sebelumnya',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF64D1DE),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    )
                  else
                    SizedBox(width: screenWidth * 0.25),
                  
                  if (index < UmumQuestions.activeQuestions(_answers).length - 1)
                    ElevatedButton.icon(
                      onPressed: !_answers.containsKey(questionId) 
                          ? null 
                          : _nextPage,
                      icon: const Icon(
                        CupertinoIcons.arrow_right,
                        size: 18,
                      ),
                      label: Text(
                        'Selanjutnya',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF64D1DE),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        shadowColor: const Color(0xFF64D1DE).withOpacity(0.3),
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.grey.shade600,
                      ),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: !_answers.containsKey(questionId) 
                          ? null 
                          : _submitAnswers,
                      icon: const Icon(
                        CupertinoIcons.doc_text,
                        size: 18,
                      ),
                      label: Text(
                        'Lihat Hasil',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF64D1DE),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        shadowColor: const Color(0xFF64D1DE).withOpacity(0.3),
                        disabledBackgroundColor: Colors.grey.shade300,
                        disabledForegroundColor: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFF64D1DE),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Diagnosa Penyakit Umum',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.chevron_back, color: Colors.white),
          onPressed: _showExitConfirmationDialog,
        ),
      ),
      body: _loading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CupertinoActivityIndicator(
                    radius: 15,
                    color: Color(0xFF64D1DE),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Memuat data...',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            )
          : SafeArea(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: UmumQuestions.activeQuestions(_answers).length,
                itemBuilder: (context, index) {
                  return _buildQuestionPage(UmumQuestions.activeQuestions(_answers)[index], index);
                },
              ),
            ),
    );
  }
}