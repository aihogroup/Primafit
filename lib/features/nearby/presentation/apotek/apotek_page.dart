import 'dart:async';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ApotekPage extends StatefulWidget {
  const ApotekPage({super.key});

  @override
  _ApotekPageState createState() => _ApotekPageState();
}

class _ApotekPageState extends State<ApotekPage> with TickerProviderStateMixin {
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
  Position? _currentPosition;

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

    // Pulse animation for Apotek icon
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

    // Pulse animation for the Apotek icon
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

  // Comprehensive location permission handling
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      // Check if location services are enabled
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationServiceDisabledDialog();
        return false;
      }

      // Check and request location permissions
      permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showPermissionDeniedDialog();
          return false;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        _showPermanentlyDeniedDialog();
        return false;
      }

      return true;
    } catch (e) {
      _showErrorDialog('Kesalahan dalam memeriksa izin lokasi: ${e.toString()}');
      return false;
    }
  }

  // Method to open Google Maps with nearest Apoteks
  Future<void> _openNearestApoteks() async {
    // Prevent multiple simultaneous calls
    if (_isLoading) return;

    // Animate button press
    _buttonAnimationController.forward().then((_) => _buttonAnimationController.reverse());

    setState(() {
      _isLoading = true;
    });

    try {
      // Comprehensive permission check
      final hasPermission = await _handleLocationPermission();
      
      if (!hasPermission) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Get current position with timeout
      _currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw TimeoutException('Location retrieval timed out');
        },
      );

      // Construct Google Maps URL for nearby Apoteks
      final Uri mapsUrl = Uri.parse(
        'https://www.google.com/maps/search/Apotek+OR+Apotik/@${_currentPosition!.latitude},'
        '${_currentPosition!.longitude},15z'
      );

      // Launch the URL
      if (await canLaunchUrl(mapsUrl)) {
        await launchUrl(mapsUrl, mode: LaunchMode.externalApplication);
      } else {
        _showErrorDialog('Tidak dapat membuka Google Maps');
      }
    } on TimeoutException {
      _showErrorDialog('Pencarian lokasi memakan waktu terlalu lama');
    } catch (e) {
      _showErrorDialog('Gagal mencari lokasi rumah sakit: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Dialogs for various scenarios with improved design
  void _showLocationServiceDisabledDialog() {
    _showCustomDialog(
      title: 'Layanan Lokasi Dinonaktifkan',
      content: 'Silakan aktifkan layanan lokasi di pengaturan perangkat.',
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.of(context).pop();
            Geolocator.openLocationSettings();
          },
          child: const Text('Buka Pengaturan'),
        ),
        CupertinoDialogAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
      ],
    );
  }

  void _showPermissionDeniedDialog() {
    _showCustomDialog(
      title: 'Izin Lokasi Diperlukan',
      content: 'Aplikasi membutuhkan izin lokasi untuk menemukan rumah sakit terdekat.',
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.of(context).pop();
            Geolocator.openAppSettings();
          },
          child: const Text('Buka Pengaturan'),
        ),
        CupertinoDialogAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
      ],
    );
  }

  void _showPermanentlyDeniedDialog() {
    _showCustomDialog(
      title: 'Izin Lokasi Ditolak',
      content: 'Anda telah menolak izin lokasi secara permanen. Buka pengaturan aplikasi untuk mengaktifkan izin.',
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () {
            Navigator.of(context).pop();
            Geolocator.openAppSettings();
          },
          child: const Text('Buka Pengaturan'),
        ),
        CupertinoDialogAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Tutup'),
        ),
      ],
    );
  }

  void _showErrorDialog(String message) {
    _showCustomDialog(
      title: 'Kesalahan',
      content: message,
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }

  // Custom styled dialog
  void _showCustomDialog({
    required String title,
    required String content,
    required List<Widget> actions,
  }) {
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
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // Content
                  Text(
                    content,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  // Actions
                  Row(
                    mainAxisAlignment: actions.length > 1 
                        ? MainAxisAlignment.spaceEvenly 
                        : MainAxisAlignment.center,
                    children: actions.map((action) {
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: actions.length > 1 ? 5 : 30
                          ),
                          child: ElevatedButton(
                            onPressed: (action as CupertinoDialogAction).onPressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: action.isDefaultAction == true 
                                  ? primaryColor 
                                  : Colors.grey[200],
                              foregroundColor: action.isDefaultAction == true 
                                  ? Colors.white 
                                  : Colors.black87,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              (action.child as Text).data!,
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                                color: action.isDefaultAction == true 
                                    ? Colors.white 
                                    : Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // SVG string for Apotek icon

  // SVG string for location icon
  String get _locationIconSvg => '''
<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg">
  <path d="M12 2C8.13 2 5 5.13 5 9C5 14.25 12 22 12 22C12 22 19 14.25 19 9C19 5.13 15.87 2 12 2ZM12 11.5C10.62 11.5 9.5 10.38 9.5 9C9.5 7.62 10.62 6.5 12 6.5C13.38 6.5 14.5 7.62 14.5 9C14.5 10.38 13.38 11.5 12 11.5Z" fill="${primaryColor.toARGB32().toRadixString(16).substring(2)}" />
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
                      'Temukan Apotek',
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
                        // Apotek Icon using SVG with pulse animation
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
                                child: Image.asset(
                                  'assets/fitur/fitur15.png',
                                  width: isSmallScreen ? 60 : 80,
                                  height: isSmallScreen ? 60 : 80,
                                  color: Colors.black,
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
                                'Cari Apotek Terdekat',
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
                                'Temukan apotek terdekat dengan lokasi Anda saat ini',
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
                          onTap: _isLoading ? null : _openNearestApoteks,
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
                                    _locationIconSvg,
                                    width: 24,
                                    height: 24,
                                  ),
                                const SizedBox(width: 12),
                                Text(
                                  _isLoading ? 'Mencari...' : 'Cari Lokasi Terdekat',
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
              label: 'Halaman pencarian rumah sakit terdekat',
              hint: 'Tekan tombol di bagian bawah layar untuk mencari rumah sakit terdekat',
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