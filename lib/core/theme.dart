import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RutaPlacaTheme {
  RutaPlacaTheme._();

  // ── Paleta de colores de marca ──────────────────────────
  static const _primaryGreen = Color(0xFF1DB954); // verde vía libre
  static const _primaryGreenDark = Color(0xFF17A349);
  static const _errorRed = Color(0xFFE53935);
  static const _warningAmber = Color(0xFFFFA000);
  static const _surfaceLight = Color(0xFFF5F5F5);
  static const _surfaceDark = Color(0xFF1E1E1E);
  static const _cardLight = Color(0xFFFFFFFF);
  static const _cardDark = Color(0xFF2A2A2A);
  static const _bgDark = Color(0xFF121212);

  // ── Tipografía compartida ───────────────────────────────
  static const _textTheme = TextTheme(
    displayLarge: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w600,
      fontSize: 32,
    ),
    displayMedium: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w600,
      fontSize: 28,
    ),
    headlineLarge: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w600,
      fontSize: 24,
    ),
    headlineMedium: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w600,
      fontSize: 20,
    ),
    titleLarge: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w600,
      fontSize: 18,
    ),
    titleMedium: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w500,
      fontSize: 16,
    ),
    titleSmall: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w500,
      fontSize: 14,
    ),
    bodyLarge: TextStyle(fontFamily: 'Poppins', fontSize: 16, height: 1.5),
    bodyMedium: TextStyle(fontFamily: 'Poppins', fontSize: 14, height: 1.5),
    bodySmall: TextStyle(fontFamily: 'Poppins', fontSize: 12, height: 1.4),
    labelLarge: TextStyle(
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w600,
      fontSize: 14,
    ),
  );

  // ── TEMA CLARO ──────────────────────────────────────────
  static final ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryGreen,
      brightness: Brightness.light,
      primary: _primaryGreen,
      secondary: _primaryGreenDark,
      error: _errorRed,
      surface: _cardLight,
      surfaceContainerHighest: _surfaceLight,
    ),
    textTheme: _textTheme,
    appBarTheme: const AppBarTheme(
      backgroundColor: _cardLight,
      foregroundColor: Color(0xFF1A1A1A),
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
        fontSize: 20,
        color: Color(0xFF1A1A1A),
      ),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _cardLight,
      selectedItemColor: _primaryGreen,
      unselectedItemColor: Color(0xFF9E9E9E),
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    cardTheme: CardThemeData(
      color: _cardLight,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE0E0E0), width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: _surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primaryGreen, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryGreen,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: _surfaceLight,
      selectedColor: _primaryGreen.withValues(alpha: 0.15),
      labelStyle: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    scaffoldBackgroundColor: _surfaceLight,
    dividerColor: const Color(0xFFE0E0E0),
  );

  // ── TEMA OSCURO ─────────────────────────────────────────
  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _primaryGreen,
      brightness: Brightness.dark,
      primary: _primaryGreen,
      secondary: _primaryGreenDark,
      error: _errorRed,
      surface: _cardDark,
      surfaceContainerHighest: _surfaceDark,
    ),
    textTheme: _textTheme.apply(
      bodyColor: const Color(0xFFE0E0E0),
      displayColor: const Color(0xFFFFFFFF),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: _cardDark,
      foregroundColor: Color(0xFFFFFFFF),
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w600,
        fontSize: 20,
        color: Colors.white,
      ),
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _cardDark,
      selectedItemColor: _primaryGreen,
      unselectedItemColor: Color(0xFF757575),
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    cardTheme: CardThemeData(
      color: _cardDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF3A3A3A), width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2A2A2A),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _primaryGreen, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryGreen,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF2A2A2A),
      selectedColor: _primaryGreen.withValues(alpha: 0.2),
      labelStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 13,
        color: Color(0xFFE0E0E0),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
    scaffoldBackgroundColor: _bgDark,
    dividerColor: const Color(0xFF3A3A3A),
  );
}
