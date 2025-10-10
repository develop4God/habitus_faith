import 'package:flutter/material.dart';

class ThemeConstants {
  // Primary gradient colors for app bar
  static const Color gradientStart = Color(0xff6366f1);
  static const Color gradientEnd = Color(0xff8b5cf6);

  // Text colors
  static const Color onPrimaryColor = Colors.white;
  static const Color primaryTextColor = Color(0xff1a202c);
  static const Color secondaryTextColor = Color(0xff718096);

  // Background colors
  static const Color backgroundColor = Color(0xfff8fafc);
  static const Color cardBackgroundColor = Colors.white;

  // Accent colors
  static const Color accentColor = Color(0xff6366f1);
  static const Color successColor = Colors.green;
  static const Color errorColor = Colors.red;

  // App bar gradient
  static LinearGradient get appBarGradient => const LinearGradient(
        colors: [gradientStart, gradientEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      );

  // SnackBar theme colors
  static Color getSnackBarBackground(BuildContext context) {
    return Theme.of(context).colorScheme.inverseSurface;
  }

  static Color getSnackBarForeground(BuildContext context) {
    return Theme.of(context).colorScheme.onInverseSurface;
  }

  // Typography
  static const TextStyle appBarTitleStyle = TextStyle(
    color: onPrimaryColor,
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle appBarSubtitleStyle = TextStyle(
    color: onPrimaryColor,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  // Theme data
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: gradientStart,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: onPrimaryColor),
          titleTextStyle: appBarTitleStyle,
        ),
      );
}
