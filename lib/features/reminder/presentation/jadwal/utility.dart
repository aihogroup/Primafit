import 'package:primafit/core/widgets/confirm_pop_scope.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';

// Color utility class
class AppColors {
  static const Color primaryColor = Color(0xFF64D1DE);
  static const Color secondaryColor = Color(0xFF64D1DE);
  static const Color backgroundColor = Colors.white;
  static const Color errorColor = Colors.redAccent;
  static const Color successColor = Colors.green;
  static const Color warningColor = Colors.orangeAccent;
  
  // Dark theme colors
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkSurfaceColor = Color(0xFF1E1E1E);
  static const Color darkTextColor = Colors.white;
  
  // Get color from hex string
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
  
  // Convert Color to hex string
  static String toHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).substring(2)}';
  }
}

// Theme utility class
class AppTheme {
  // Light theme
  static ThemeData lightTheme = ThemeData(
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: AppColors.backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryColor,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    colorScheme: ColorScheme.light(
      primary: AppColors.primaryColor,
      secondary: AppColors.secondaryColor,
      error: AppColors.errorColor,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(),
    fontFamily: GoogleFonts.poppins().fontFamily,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.errorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );
  
  // Dark theme
  static ThemeData darkTheme = ThemeData.dark().copyWith(
    primaryColor: AppColors.primaryColor,
    scaffoldBackgroundColor: AppColors.darkBackgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.darkSurfaceColor,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryColor,
      secondary: AppColors.secondaryColor,
      error: AppColors.errorColor,
      surface: AppColors.darkSurfaceColor,
      onSurface: AppColors.darkTextColor,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
    // fontFamily: GoogleFonts.poppins().fontFamily,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[700]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[700]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.errorColor),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );
}

// Date and time formatter utility class
class DateTimeUtils {
  // Format date to string in format: yyyy-MM-dd
  static String formatDateToDb(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
  
  // Format time to string in format: HH:mm
  static String formatTimeToDb(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('HH:mm').format(dt);
  }
  
  // Format date for display: EEEE, MMMM d, yyyy
  static String formatDateForDisplay(DateTime date) {
    return DateFormat('EEEE, MMMM d, yyyy').format(date);
  }
  
  // Format date for short display: MMM d, yyyy
  static String formatDateShort(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }
  
  // Parse date from database format
  static DateTime parseDateFromDb(String dateStr) {
    try {
      return DateFormat('yyyy-MM-dd').parse(dateStr);
    } catch (e) {
      debugPrint('Error parsing date: $e');
      return DateTime.now();
    }
  }
  
  // Parse time from database format
  static TimeOfDay parseTimeFromDb(String timeStr) {
    try {
      final parts = timeStr.split(':');
      return TimeOfDay(
        hour: int.parse(parts[0]),
        minute: int.parse(parts[1]),
      );
    } catch (e) {
      debugPrint('Error parsing time: $e');
      return TimeOfDay.now();
    }
  }
  
  // Check if a date is today
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
  
  // Check if a date is yesterday
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year && date.month == yesterday.month && date.day == yesterday.day;
  }
  
  // Check if a date is tomorrow
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day;
  }
  
  // Get relative date string (Today, Tomorrow, Yesterday, or formatted date)
  static String getRelativeDateStr(DateTime date) {
    if (isToday(date)) {
      return 'Today';
    } else if (isTomorrow(date)) {
      return 'Tomorrow';
    } else if (isYesterday(date)) {
      return 'Yesterday';
    } else {
      return formatDateShort(date);
    }
  }
}

// UI utility components
class UiUtils {
  // Custom snackbar with consistent styling
  static void showSnackBar(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    Color backgroundColor;
    final Color textColor = Colors.white;
    IconData icon;
    
    switch (type) {
      case SnackBarType.success:
        backgroundColor = AppColors.successColor;
        icon = CupertinoIcons.check_mark_circled;
        break;
      case SnackBarType.error:
        backgroundColor = AppColors.errorColor;
        icon = CupertinoIcons.exclamationmark_circle;
        break;
      case SnackBarType.warning:
        backgroundColor = AppColors.warningColor;
        icon = CupertinoIcons.exclamationmark_triangle;
        break;
      case SnackBarType.info:
        backgroundColor = AppColors.primaryColor;
        icon = CupertinoIcons.info_circle;
        break;
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: textColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(color: textColor),
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(10),
        duration: duration,
      ),
    );
  }
  
  // Loading dialog
  static void showLoadingDialog(BuildContext context, {String text = 'Loading...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ConfirmPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
              ),
              const SizedBox(width: 20),
              Text(
                text,
                style: GoogleFonts.poppins(),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Custom confirmation dialog
  static Future<bool> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color confirmColor = AppColors.primaryColor,
    Color cancelColor = Colors.grey,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        content: Text(
          message,
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              cancelText,
              style: GoogleFonts.poppins(color: cancelColor),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              confirmText,
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
  
  // Input validation
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
  
  // Semantic label helper
  static String getSemanticLabel(String text) {
    return 'Button for $text';
  }
}

// Enum for SnackBar types
enum SnackBarType {
  info,
  success,
  error,
  warning,
}