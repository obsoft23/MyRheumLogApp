// app_theme.dart
import 'package:flutter/material.dart';

Color primaryBlue = Color(0xFF4A90E2); //echo '#4A90E2'
Color secondaryGreen = Color(0xFF7ED321);
Color warningAmber = Color(0xFFF5A623);
Color alertRed = Color(0xFFD0021B);
Color backgroundLight = Color(0xFFF8F9FA);
Color surfaceWhite = Colors.white;
Color textDark = Color(0xFF222222);
Color textMuted = Color(0xFF6C757D);

class AppTheme {
  static ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primaryBlue,
    fontFamily: 'Satoshi',
    scaffoldBackgroundColor: backgroundLight,
    colorScheme: ColorScheme.light(
      primary: primaryBlue,
      secondary: secondaryGreen,
      tertiary: warningAmber,
      error: alertRed,
      surface: surfaceWhite,
      onSurface: textDark,
    ),
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: surfaceWhite,
      foregroundColor: textDark,
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 20,
        color: textDark,
      ),
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(fontSize: 16, color: textDark),
      bodyMedium: TextStyle(fontSize: 15, color: textDark),
      bodySmall: TextStyle(fontSize: 14, color: textMuted),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        // ignore: deprecated_member_use
        borderSide: BorderSide(color: primaryBlue.withOpacity(0.4)),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: primaryBlue, width: 1.5),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
    cardTheme: const CardThemeData(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
  );

  //dark theme can be added here in the future
  ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF121212),
    colorScheme: ColorScheme.dark(
      primary: primaryBlue,
      secondary: secondaryGreen,
      tertiary: warningAmber,
      error: alertRed,
      surface: Color(0xFF1E1E1E),
      onSurface: Colors.white,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 16, color: Colors.white),
      bodyMedium: TextStyle(fontSize: 15, color: Color(0xFFE0E0E0)),
      bodySmall: TextStyle(fontSize: 14, color: Color(0xFFBDBDBD)),
      titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      elevation: 0,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        fontSize: 20,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
      ),
    ),
  );
}
