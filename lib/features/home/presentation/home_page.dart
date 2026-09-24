import 'package:primafit/app/router/app_routes.dart';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:primafit/core/widgets/app_bottom_navigation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primafit/features/profile/presentation/providers/profile_providers.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  String getGreeting() {
    final int hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  Widget _buildProfileImage(String? photoPath) {
    const fallback = AssetImage('assets/avatar/avatar1.jpg');
    if (photoPath == null || photoPath.isEmpty) {
      return const Image(image: fallback, fit: BoxFit.cover);
    }
    return Image.file(
      File(photoPath),
      fit: BoxFit.cover,
      cacheWidth: 150,
      errorBuilder: (_, _, _) => const Image(image: fallback, fit: BoxFit.cover),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildFeatureCards(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const CustomBottomNavigationBar(currentIndex: 0),
    );
  }

  Widget _buildHeader() {
    final profile = ref.watch(profileControllerProvider).value;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              getGreeting(),
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF333333),
              ),
            ),
            Text(
              profile?.name ?? '',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: const Color(0xFF666666),
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.profile);
          },
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFD8C4FF),
              borderRadius: BorderRadius.circular(25),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: _buildProfileImage(profile?.photoPath),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildFeatureCards() {
  // List of feature data with icons, labels, and routes
  final List<Map<String, dynamic>> features = [
    {
      'icon': 'assets/fitur/fitur1.png',
      'label': 'Kolesterol',
      'route': '/kolesterol',
    },
    {
      'icon': 'assets/fitur/fitur2.png',
      'label': 'Asam Urat',
      'route': '/asamurat',
    },
    {
      'icon': 'assets/fitur/fitur3.png',
      'label': 'Tensi',
      'route': '/tensi',
    },
    {
      'icon': 'assets/fitur/fitur4.png',
      'label': 'BMI',
      'route': '/bmi',
    },
    {
      'icon': 'assets/fitur/fitur5.png',
      'label': 'Gula Darah',
      'route': '/guladarah',
    },
    {
      'icon': 'assets/fitur/suhu.png',
      'label': 'Suhu Tubuh',
      'route': '/suhu',
    },
    {
      'icon': 'assets/fitur/makan.png',
      'label': 'Makanan',
      'route': '/makanan',
    },
    {
      'icon': 'assets/fitur/fitur8.png',
      'label': 'Semua Fitur',
      'route': '/semua',
    },
  ];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Padding(
      //   padding: const EdgeInsets.only(left: 4.0, bottom: 16.0),
      //   child: Text(
      //     'Fitur',
      //     style: TextStyle(
      //       fontFamily: 'Poppins',
      //       fontSize: 18,
      //       fontWeight: FontWeight.w600,
      //       color: Colors.black87,
      //     ),
      //   ),
      // ),
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: MediaQuery.of(context).size.width > 600 ? 5 : 4,
                crossAxisSpacing: 16,
                mainAxisSpacing: 24,
                childAspectRatio: 0.9,
              ),
              itemCount: features.length,
              itemBuilder: (context, index) {
                return _buildFeatureItem(
                  context,
                  features[index]['icon'],
                  features[index]['label'],
                  features[index]['route'],
                );
              },
            );
          },
        ),
      ),
    ],
  );
}

Widget _buildFeatureItem(
    BuildContext context, String iconPath, String label, String route) {
  return InkWell(
    onTap: () {
      // Add haptic feedback for better user experience
      HapticFeedback.lightImpact();
      
      // Navigate with hero animation
      Navigator.of(context).pushReplacementNamed(route);
    },
    borderRadius: BorderRadius.circular(12),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Feature icon with background
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xFF64D1DE).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Hero(
            tag: route,
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Image.asset(
                iconPath,
                fit: BoxFit.contain,
                semanticLabel: label.replaceAll('\n', ' '),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Feature label
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          softWrap: true,
        ),
      ],
    ),
  );
}
}