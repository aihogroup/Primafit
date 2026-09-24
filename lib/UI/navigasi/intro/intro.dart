import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<IntroContent> _introContents = [
    IntroContent(
      title: 'Mulai hidup sehat',
      description: 'Ciptakan pola hidup sehat bersama\nPrimafit',
      imagePath: 'assets/Intro/intro1.png',
      backgroundImage: 'assets/Splash/background.png',
    ),
    IntroContent(
      title: 'Pantau kesehatan',
      description: 'Pantau kesehatan secara teratur\nuntuk menjaga tubuh Anda tetap\nsehat dan prima',
      imagePath: 'assets/Intro/intro2.png',
      backgroundImage: 'assets/Splash/background.png',
    ),
    IntroContent(
      title: 'Reminder obat',
      description: 'Pengingat rutin minum obat sesuai\njadwal untuk pemulihan yang optimal',
      imagePath: 'assets/Intro/intro3.png',
      backgroundImage: 'assets/Splash/background.png',
    ),
    IntroContent(
      title: 'Simpan hasil check-up medis',
      description: 'Simpan hasil check-up untuk\npencatatan kesehatan lebih tepat\nselanjutnya',
      imagePath: 'assets/Intro/intro4.png',
      backgroundImage: 'assets/Splash/background.png',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextPage() {
    if (_currentPage < _introContents.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _skipIntro() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _introContents.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              return _buildIntroPage(_introContents[index]);
            },
          ),

          // Skip button
          Positioned(
            top: 50,
            right: 20,
            child: TextButton(
              onPressed: _skipIntro,
              child: Text(
                'Skip',
                style: GoogleFonts.poppins(
                  color: Colors.black54,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Bottom navigation controls
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Previous Button (jika bukan halaman pertama)
                    _currentPage > 0
                        ? Padding(
                            padding: const EdgeInsets.only(left: 20),
                            child: _buildCircularButton(
                              Icons.arrow_back_ios,
                              () {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                            ),
                          )
                        : const SizedBox(width: 60),

                    // Dots Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _introContents.length,
                        (index) => _buildDotIndicator(index),
                      ),
                    ),

                    // Next/Get Started Button
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: _buildCircularButton(
                        Icons.arrow_forward_ios,
                        _onNextPage,
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

  Widget _buildCircularButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.black54),
      ),
    );
  }

  Widget _buildIntroPage(IntroContent content) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          content.backgroundImage,
          fit: BoxFit.cover,
        ),

        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image
            Image.asset(
              content.imagePath,
              height: 350,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 40),

            // Judul
            Text(
              content.title,
              style: GoogleFonts.poppins(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF64D1DE),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Deskripsi
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                content.description,
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  color: const Color(0xFF424242),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDotIndicator(int index) {
    bool isActive = index == _currentPage;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 16 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF64D1DE) : const Color(0xFFADADAD),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class IntroContent {
  final String title;
  final String description;
  final String imagePath;
  final String backgroundImage;

  IntroContent({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.backgroundImage,
  });
}