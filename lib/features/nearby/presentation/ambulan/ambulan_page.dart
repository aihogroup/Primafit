import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AmbulanPage extends StatefulWidget {
  const AmbulanPage({super.key});

  @override
  _AmbulanPageState createState() => _AmbulanPageState();
}

class _AmbulanPageState extends State<AmbulanPage> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _mainAnimationController;
  late AnimationController _pulseAnimationController;
  late AnimationController _buttonAnimationController;
  
  // Animations
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _buttonScaleAnimation;
  
  bool _isLoading = false;

  // Primary color
  final Color primaryColor = const Color(0xFF64D1DE);

  @override
  void initState() {
    super.initState();
    
    // Main animation controller for initial appearance
    _mainAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Pulse animation for Ambulance icon
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    // Button animation controller for interaction effect
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    // Scale and fade animations for initial appearance
    _scaleAnimation = CurvedAnimation(
      parent: _mainAnimationController,
      curve: Curves.easeOutBack,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainAnimationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    // Pulse animation for the Ambulance icon
    _pulseAnimation = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Button animation for interaction effect
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Start the initial animations
    _mainAnimationController.forward();
  }

  @override
  void dispose() {
    _mainAnimationController.dispose();
    _pulseAnimationController.dispose();
    _buttonAnimationController.dispose();
    super.dispose();
  }

  // Show emergency call options in bottom sheet
  void _showEmergencyCallOptions() {
    // Animate button press
    _buttonAnimationController.forward().then((_) => _buttonAnimationController.reverse());

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: 36,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(height: 24),
              
              // Header
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 400),
                tween: Tween(begin: 0, end: 1),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Column(
                  children: [
                    Text(
                      'Layanan Darurat',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pilih nomor layanan darurat yang ingin dihubungi',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Call options with staggered animation
              ..._buildCallOptions(),
              
              const SizedBox(height: 16),
              
              // Info text
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 400),
                tween: Tween(begin: 0, end: 1),
                // delay: const Duration(milliseconds: 300),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: child,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber[100]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        CupertinoIcons.info_circle_fill,
                        color: Colors.amber[700],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Gunakan layanan ini hanya dalam keadaan darurat',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Colors.amber[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Build call option items with staggered animation
  List<Widget> _buildCallOptions() {
    final callOptions = [
      {
        'title': 'Ambulan (118)',
        'subtitle': 'Layanan ambulan untuk kondisi kesehatan darurat',
        'icon': CupertinoIcons.plus_circle_fill,
        'number': 'tel:118',
        'color': Colors.red,
        'delay': 0,
      },
      {
        'title': 'Darurat Umum (112)',
        'subtitle': 'Layanan darurat umum untuk berbagai situasi',
        'icon': CupertinoIcons.exclamationmark_triangle,
        'number': 'tel:112',
        'color': Colors.orange,
        'delay': 100,
      },
    ];

    return callOptions.map((option) {
      return TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 400),
        tween: Tween(begin: 0, end: 1),
        // delay: Duration(milliseconds: 200 + (option['delay'] as int)),
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: child,
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildCallOptionItem(
            title: option['title'] as String,
            subtitle: option['subtitle'] as String,
            icon: option['icon'] as IconData,
            phoneNumber: option['number'] as String,
            color: option['color'] as Color,
          ),
        ),
      );
    }).toList();
  }

  // Build individual call option item
  Widget _buildCallOptionItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required String phoneNumber,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _callEmergencyNumber(phoneNumber),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.2),
                        blurRadius: 10,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Icon(
                    CupertinoIcons.phone_fill,
                    color: color,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Call emergency number
  Future<void> _callEmergencyNumber(String phoneNumber) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final Uri callUri = Uri.parse(phoneNumber);
      
      if (await canLaunchUrl(callUri)) {
        await launchUrl(callUri);
      } else {
        _showErrorDialog('Tidak dapat melakukan panggilan');
      }
    } catch (e) {
      _showErrorDialog('Gagal melakukan panggilan: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Error dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Alert icon
                  Icon(
                    CupertinoIcons.exclamationmark_circle,
                    color: primaryColor,
                    size: 50,
                  ),
                  const SizedBox(height: 16),
                  // Title
                  const Text(
                    'Kesalahan',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // Content
                  Text(
                    message,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  // Action button
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // SVG string for ambulance icon
  String get _ambulanceIconSvg => '''
<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <path d="M18.92 6.01C18.72 5.42 18.16 5 17.5 5H15V3H9v2H6.5c-.66 0-1.21.42-1.42 1.01L3 12v8c0 .55.45 1 1 1h1c.55 0 1-.45 1-1v-1h12v1c0 .55.45 1 1 1h1c.55 0 1-.45 1-1v-8l-2.08-5.99zM6.85 7h10.29l1.08 3.11H5.77L6.85 7zM19 17H5v-5h14v5z" fill="${primaryColor.toARGB32().toRadixString(16).substring(2)}"/>
  <circle cx="7.5" cy="14.5" r="1.5" fill="${primaryColor.toARGB32().toRadixString(16).substring(2)}"/>
  <circle cx="16.5" cy="14.5" r="1.5" fill="${primaryColor.toARGB32().toRadixString(16).substring(2)}"/>
  <path d="M15 11V6h-2v5H8l4 4 4-4h-1z" fill="${primaryColor.toARGB32().toRadixString(16).substring(2)}"/>
</svg>
  ''';

  // SVG string for phone icon
  String get _phoneIconSvg => '''
<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <path d="M20 15.5c-1.25 0-2.45-.2-3.57-.57-.35-.11-.74-.03-1.02.24l-2.2 2.2c-2.83-1.44-5.15-3.75-6.59-6.59l2.2-2.21c.28-.26.36-.65.25-1C8.7 6.45 8.5 5.25 8.5 4c0-.55-.45-1-1-1H4c-.55 0-1 .45-1 1 0 9.39 7.61 17 17 17 .55 0 1-.45 1-1v-3.5c0-.55-.45-1-1-1zM19 12h2c0-4.97-4.03-9-9-9v2c3.87 0 7 3.13 7 7zm-4 0h2c0-2.76-2.24-5-5-5v2c1.66 0 3 1.34 3 3z" fill="${primaryColor.toARGB32().toRadixString(16).substring(2)}"/>
</svg>
  ''';

  // Custom painter for drawing background decorations
  Widget _buildBackgroundDecoration() {
    return Positioned.fill(
      child: CustomPaint(
        painter: BackgroundPainter(primaryColor),
        child: Container(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));

    // Screen dimensions for responsive sizing
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.height < 700;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Background decorations
            _buildBackgroundDecoration(),

            // Back button with improved styling and feedback
            Positioned(
              top: 16,
              left: 16,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(30),
                  onTap: () => Navigator.of(context).pop(),
                  child: Ink(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    height: 40,
                    width: 40,
                    child: const Icon(
                      CupertinoIcons.back,
                      color: Colors.black87,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
            
            // Page Title with animated appearance
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'Panggilan Darurat',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Centered Content with animations
            Positioned.fill(
              top: 80,
              bottom: 100,
              child: Center(
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Ambulance Icon using SVG with pulse animation
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: child,
                            );
                          },
                          child: Container(
                            width: isSmallScreen ? 180 : 220,
                            height: isSmallScreen ? 180 : 220,
                            decoration: BoxDecoration(
                              color: primaryColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Container(
                                width: isSmallScreen ? 100 : 120,
                                height: isSmallScreen ? 100 : 120,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: primaryColor.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: SvgPicture.string(
                                  _ambulanceIconSvg,
                                  width: isSmallScreen ? 60 : 80,
                                  height: isSmallScreen ? 60 : 80,
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        SizedBox(height: isSmallScreen ? 20 : 30),
                        
                        // Description Text with improved style
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            children: [
                              Text(
                                'Layanan Darurat',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: isSmallScreen ? 22 : 26,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Hubungi layanan ambulan atau nomor darurat untuk mendapatkan bantuan segera',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: isSmallScreen ? 14 : 16,
                                  color: Colors.black54,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Search Location Button with improved design and animation
            Positioned(
              bottom: 32,
              left: 24,
              right: 24,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: AnimatedBuilder(
                  animation: _buttonScaleAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _buttonScaleAnimation.value,
                      child: child,
                    );
                  },
                  child: GestureDetector(
                    onTapDown: (_) => _buttonAnimationController.forward(),
                    onTapUp: (_) => _buttonAnimationController.reverse(),
                    onTapCancel: () => _buttonAnimationController.reverse(),
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            primaryColor,
                            primaryColor.withValues(alpha: 0.8),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: _isLoading ? null : _showEmergencyCallOptions,
                          splashColor: Colors.white.withValues(alpha: 0.1),
                          highlightColor: Colors.white.withValues(alpha: 0.1),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_isLoading)
                                  const CupertinoActivityIndicator(color: Colors.white)
                                else
                                  SvgPicture.string(
                                    _phoneIconSvg,
                                    width: 24,
                                    height: 24,
                                  ),
                                const SizedBox(width: 12),
                                Text(
                                  _isLoading ? 'Memproses...' : 'Lakukan Panggilan',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
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
              ),
            ),

            // Accessibility feature: Semantic node for screen readers
            Semantics(
              label: 'Halaman panggilan darurat',
              hint: 'Tekan tombol di bagian bawah layar untuk melakukan panggilan darurat',
              child: Container(),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for background decoration
class BackgroundPainter extends CustomPainter {
  final Color primaryColor;

  BackgroundPainter(this.primaryColor);

  @override
  void paint(Canvas canvas, Size size) {
    // Top right decoration
    final Paint circlePaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(size.width + 50, -20),
      size.width * 0.4,
      circlePaint,
    );
    
    canvas.drawCircle(
      Offset(size.width + 20, 40),
      size.width * 0.25,
      Paint()..color = primaryColor.withValues(alpha: 0.07),
    );

    // Bottom left decoration
    canvas.drawCircle(
      Offset(-40, size.height - 20),
      size.width * 0.3,
      Paint()..color = primaryColor.withValues(alpha: 0.05),
    );
    
    canvas.drawCircle(
      Offset(40, size.height + 40),
      size.width * 0.2,
      Paint()..color = primaryColor.withValues(alpha: 0.07),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}