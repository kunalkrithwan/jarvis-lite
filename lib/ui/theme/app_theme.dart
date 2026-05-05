import 'package:flutter/material.dart';

/// Theme configuration for JARVIS Lite
class AppTheme {
  // Colors - Futuristic dark theme inspired by JARVIS
  static const Color primaryBlue = Color(0xFF0066CC);
  static const Color accentCyan = Color(0xFF00FFFF);
  static const Color darkBg = Color(0xFF0A0E27);
  static const Color darkCard = Color(0xFF1A1F3A);
  static const Color textPrimary = Color(0xFFEEEEEE);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color successGreen = Color(0xFF00DD00);
  static const Color errorRed = Color(0xFFDD0000);
  static const Color warningOrange = Color(0xFFFF9800);

  // Theme Data
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: darkBg,
    primaryColor: primaryBlue,
    colorScheme: ColorScheme.dark(
      primary: primaryBlue,
      secondary: accentCyan,
      surface: darkCard,
      error: errorRed,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: darkCard,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: accentCyan,
        letterSpacing: 1.5,
      ),
    ),
    cardTheme: CardTheme(
      color: darkCard,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: primaryBlue, width: 1),
      ),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: accentCyan,
        letterSpacing: 1.5,
      ),
      displayMedium: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: textPrimary,
        letterSpacing: 1.0,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: textPrimary,
        letterSpacing: 0.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: textPrimary,
        letterSpacing: 0.5,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        color: textSecondary,
        letterSpacing: 0.3,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkCard,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryBlue),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryBlue, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: accentCyan, width: 2),
      ),
      hintStyle: TextStyle(color: textSecondary),
      labelStyle: TextStyle(color: accentCyan),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accentCyan,
      foregroundColor: darkBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );

  // Custom gradients
  static final LinearGradient cyanGradient = LinearGradient(
    colors: [primaryBlue, accentCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final LinearGradient primaryGradient = LinearGradient(
    colors: [primaryBlue, Color(0xFF003366)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
