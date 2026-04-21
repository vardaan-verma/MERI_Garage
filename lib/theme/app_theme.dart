import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryRed = Color(0xFFE03C31);
  static const Color secondaryBlue = Color(0xFF0059A9);
  static const Color accentLight = Color(0xFFF5F5F7);
  static const Color textDark = Color(0xFF1D1B20);
  static const Color textLight = Color(0xFF757575);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryRed,
        primary: primaryRed,
        secondary: secondaryBlue,
        surface: Colors.white,
        onSurface: textDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryRed,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: secondaryBlue,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textDark,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: textDark,
        ),
      ),
    );
  }
}
