import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavigationBar({
    Key? key,
    required this.currentIndex,
  }) : super(key: key);

  static const _routes = <String>[
    '/home',
    '/jadwal',
    '/analisis',
    '/artikel',
    '/riwayat',
  ];

  static const _iconNames = <String>[
    'home',
    'jadwal',
    'analytics',
    'artikel',
    'riwayat',
  ];

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF64D1DE),
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      unselectedLabelStyle: GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      onTap: (index) {
        if (index == currentIndex) return;
        Navigator.pushReplacementNamed(context, _routes[index]);
      },
      items: List.generate(_routes.length, (index) {
        final iconName = _iconNames[index];
        final iconAsset = index == currentIndex
            ? 'assets/Navigation/${iconName}1.png'
            : 'assets/Navigation/$iconName.png';

        return BottomNavigationBarItem(
          icon: ImageAssetIcon(iconAsset),
          label: iconName[0].toUpperCase() + iconName.substring(1),
        );
      }),
    );
  }
}

class ImageAssetIcon extends StatelessWidget {
  final String assetPath;
  const ImageAssetIcon(this.assetPath);

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: 24,
      height: 24,
    );
  }
}