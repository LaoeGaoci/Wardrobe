import 'package:flutter/material.dart';

class AppTheme {
  // ============================================================
  // Light Theme
  // ============================================================

  static ThemeData light = ThemeData(
    useMaterial3: true,

    // ------------------------------------------------------------
    // Color Scheme
    // ------------------------------------------------------------
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF2C2C2C),
      brightness: Brightness.light,
      surface: Colors.white,
    ),

    // ------------------------------------------------------------
    // 页面背景
    // ------------------------------------------------------------
    scaffoldBackgroundColor: const Color(0xFFF8F8F8),

    // ------------------------------------------------------------
    // AppBar
    // ------------------------------------------------------------
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF222222),
      elevation: 0,
      centerTitle: false,
    ),

    // ------------------------------------------------------------
    // Card
    // ------------------------------------------------------------
    cardTheme: const CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
    ),

    // ------------------------------------------------------------
    // Input
    // ------------------------------------------------------------
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF5F5F5),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFBDBDBD), width: 1),
      ),
    ),

    // ------------------------------------------------------------
    // Button
    // ------------------------------------------------------------
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF222222),
        foregroundColor: Colors.white,
        elevation: 0,

        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),

    // ------------------------------------------------------------
    // Divider
    // ------------------------------------------------------------
    dividerTheme: const DividerThemeData(
      color: Color(0xFFEAEAEA),
      thickness: 1,
      space: 1,
    ),
  );

  // ============================================================
  // Dark Theme
  // ============================================================

  static ThemeData dark = ThemeData(
    useMaterial3: true,

    // ------------------------------------------------------------
    // Color Scheme
    // ------------------------------------------------------------
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFE0E0E0),
      brightness: Brightness.dark,

      // 主背景
      surface: const Color(0xFF111111),
    ),

    // ------------------------------------------------------------
    // 页面背景
    // ------------------------------------------------------------
    scaffoldBackgroundColor: const Color(0xFF111111),

    // ------------------------------------------------------------
    // AppBar
    // ------------------------------------------------------------
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF111111),
      foregroundColor: Color(0xFFF2F2F2),
      elevation: 0,
      centerTitle: false,
    ),

    // ------------------------------------------------------------
    // Card
    // ------------------------------------------------------------
    cardTheme: const CardThemeData(
      color: Color(0xFF1A1A1A),
      elevation: 0,
      margin: EdgeInsets.zero,
    ),

    // ------------------------------------------------------------
    // Input
    // ------------------------------------------------------------
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1F1F1F),

      hintStyle: const TextStyle(color: Color(0xFF888888)),

      prefixIconColor: const Color(0xFFAAAAAA),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF555555), width: 1),
      ),
    ),

    // ------------------------------------------------------------
    // Button
    // ------------------------------------------------------------
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE5E5E5),
        foregroundColor: const Color(0xFF171717),
        elevation: 0,

        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),

    // ------------------------------------------------------------
    // Divider
    // ------------------------------------------------------------
    dividerTheme: const DividerThemeData(
      color: Color(0xFF2A2A2A),
      thickness: 1,
      space: 1,
    ),

    // ------------------------------------------------------------
    // Text
    // ------------------------------------------------------------
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFFF2F2F2)),
      bodyMedium: TextStyle(color: Color(0xFFD0D0D0)),
      bodySmall: TextStyle(color: Color(0xFFA0A0A0)),

      titleLarge: TextStyle(color: Color(0xFFF2F2F2)),
      titleMedium: TextStyle(color: Color(0xFFE8E8E8)),
      titleSmall: TextStyle(color: Color(0xFFD0D0D0)),
    ),
  );
}
