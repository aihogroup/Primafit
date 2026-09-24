import 'package:flutter/material.dart';
import 'package:primafit/database/navigasi/database_profile.dart';
import 'package:primafit/UI/navigasi/profile/profile_page.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;
  final ProfileDatabaseHelper _databaseHelper = ProfileDatabaseHelper();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )

      ..addStatusListener((status) async {
        if (status == AnimationStatus.completed) {
          final hasProfile = await _checkUserProfile();
          
          if (!hasProfile) {
            // Navigate to profile page with editing mode on
            Navigator.pushReplacementNamed(context, '/intro');
          } else {
            // Navigate to home page as usual
            Navigator.pushReplacementNamed(context, '/home');
          }
        }
      });
    _fadeIn = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  Future<bool> _checkUserProfile() async {
    try {
      final profiles = await _databaseHelper.getProfiles();
      
      // Check if there are any profiles and if the first profile has a name
      return profiles.isNotEmpty && 
            profiles.first['nama'] != null && 
            profiles.first['nama'].toString().trim().isNotEmpty;
    } catch (e) {
      print('Error checking profile: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/Splash/background.png',
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: Alignment(0, -0.4),
            child: Image.asset(
              'assets/Splash/logo.png',
              width: 150,
            ),
          ),
          Align(
            alignment: Alignment(0, 0.7),
            child: FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideUp,
                child: Image.asset(
                  'assets/Splash/branding.png',
                  width: 250,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}