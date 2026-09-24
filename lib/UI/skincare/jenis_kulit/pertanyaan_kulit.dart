import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'package:primafit/database/skincare/database_skintype.dart';
import 'package:primafit/UI/skincare/jenis_kulit/output_kulit.dart';
import 'package:primafit/UI/skincare/jenis_kulit/list_pertanyaan_kulit.dart';

class SkinTypeAnalysisPage extends StatefulWidget {
  const SkinTypeAnalysisPage({Key? key}) : super(key: key);

  @override
  _SkinTypeAnalysisPageState createState() => _SkinTypeAnalysisPageState();
}

class _SkinTypeAnalysisPageState extends State<SkinTypeAnalysisPage> with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  final Map<String, String> _answers = {};
  int _currentPage = 0;
  bool _isAnimating = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _loading = false;

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
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < SkinTypeQuestions.activeQuestions(_answers).length - 1) {
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
    _showLoadingDialog('Menganalisis jenis kulit...');

    try {
      // Konversi jawaban ke format untuk database
      Map<String, dynamic> userAnswers = Map<String, dynamic>.from(_answers);
      
      // Simpan jawaban ke database
      final userAnswerId = await DatabaseHelperSkinType.instance.saveUserAnswers(userAnswers);

      // Hitung analisis jenis kulit berdasarkan jawaban
      final skinTypeAnalysis = SkinTypeQuestions.calculateSkinType(_answers);
      
      // Simpan hasil analisis
      await DatabaseHelperSkinType.instance.saveAnalysisResult(userAnswerId, skinTypeAnalysis);

      // Navigasi ke halaman hasil
      if (!mounted) return;
      
      Navigator.pop(context); // Tutup dialog loading
      
      // Navigasi ke halaman hasil
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const OutputPageSkinType()),
      );
    } catch (e) {
      if (!mounted) return;
      
      Navigator.pop(context); // Close loading dialog
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Terjadi kesalahan: $e',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
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
                'Apakah Anda yakin ingin keluar? Jawaban Anda tidak akan disimpan.',
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

  Widget _buildOptionButton(String option, String questionId) {
    bool isSelected = _answers[questionId] == option;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 6),
      width: double.infinity,
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
              _answers[questionId] = option;
            });
            
            // Delay before moving to next question for better UX
            Future.delayed(const Duration(milliseconds: 300), () {
              _nextPage();
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    option,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? const Color(0xFF64D1DE) : Colors.black87,
                    ),
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
    final List<String> options = SkinTypeQuestions.getOptionsForQuestion(questionId);
    
    // Mengambil dimensi layar
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Get actual content height available (subtract app bar and safe area)
    final availableHeight = screenHeight - AppBar().preferredSize.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom;
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: availableHeight,
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenHeight * 0.02),
                
                // Progress indicator
                Row(
                  children: [
                    Text(
                      'Pertanyaan ${index + 1}/${SkinTypeQuestions.activeQuestions(_answers).length}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: screenWidth * 0.4,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey.shade200,
                      ),
                      child: Stack(
                        children: [
                          AnimatedFractionallySizedBox(
                            duration: const Duration(milliseconds: 300),
                            widthFactor: (index + 1) / SkinTypeQuestions.activeQuestions(_answers).length,
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
                
                SizedBox(height: screenHeight * 0.04),
                
                // Question container
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    vertical: screenHeight * 0.025,
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
                    mainAxisSize: MainAxisSize.min,
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
                          size: screenWidth * 0.08,
                          color: const Color(0xFF64D1DE),
                        ),
                      ),
                      
                      SizedBox(height: screenHeight * 0.02),
                      
                      // Question text
                      Text(
                        question['question'],
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: screenWidth * 0.042,
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                          color: Colors.black87,
                        ),
                      ),
                      
                      // Description
                      if (question.containsKey('description') && question['description'].isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(top: screenHeight * 0.015),
                          child: Text(
                            question['description'],
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: screenWidth * 0.033,
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                
                SizedBox(height: screenHeight * 0.035),
                
                // Answer options
                ...options.map((option) => _buildOptionButton(option, questionId)).toList(),
                
                SizedBox(height: screenHeight * 0.04),
                
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
                      const SizedBox(width: 110), // Fixed width to match button
                    
                    if (index < SkinTypeQuestions.activeQuestions(_answers).length - 1)
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
                          CupertinoIcons.person_fill,
                          size: 18,
                        ),
                        label: Text(
                          'Lihat Hasil Analisis',
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
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    // Get active questions with the skipping logic applied
    final activeQuestions = SkinTypeQuestions.activeQuestions(_answers);
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: const Color(0xFF64D1DE),
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Analisis Jenis Kulit',
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
          : activeQuestions.isEmpty 
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        CupertinoIcons.exclamationmark_triangle,
                        color: Color(0xFF64D1DE),
                        size: 48,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Tidak ada pertanyaan yang tersedia',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF64D1DE),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        child: Text(
                          'Kembali',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : SafeArea(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: activeQuestions.length,
                    itemBuilder: (context, index) {
                      // Ensure we don't try to access an index out of bounds
                      if (index >= activeQuestions.length) {
                        return Container(); // Return empty container for safety
                      }
                      return _buildQuestionPage(activeQuestions[index], index);
                    },
                  ),
                ),
    );
  }
}