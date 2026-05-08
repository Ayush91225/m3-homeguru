import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const Color _blueSeed = Color(0xFF1A73E8);

ColorScheme _pin(ColorScheme base) => base.copyWith(
      primary: _blueSeed,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFFD3E3FD),
      onPrimaryContainer: const Color(0xFF041E49),
      secondary: const Color(0xFF4A90D9),
      onSecondary: Colors.white,
      secondaryContainer: const Color(0xFFDCEEFB),
      onSecondaryContainer: const Color(0xFF0D2137),
      tertiary: const Color(0xFFBF5000),
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFFFDCC2),
      onTertiaryContainer: const Color(0xFF3A1500),
      surface: const Color(0xFFFFFBF7),
      surfaceContainerLow: const Color(0xFFFFF8F2),
      surfaceContainerHighest: const Color(0xFFF5EFE8),
    );

ColorScheme _pinDark(ColorScheme base) => base.copyWith(
      primary: const Color(0xFFADC6FF),
      onPrimary: const Color(0xFF002E6C),
      primaryContainer: const Color(0xFF1557B0),
      onPrimaryContainer: const Color(0xFFD3E3FD),
      secondary: const Color(0xFF8AB4F8),
      onSecondary: const Color(0xFF003063),
      secondaryContainer: const Color(0xFF1A3A6B),
      onSecondaryContainer: const Color(0xFFD3E3FD),
      tertiary: const Color(0xFFFFB77C),
      onTertiary: const Color(0xFF4A1800),
      tertiaryContainer: const Color(0xFF7A3800),
      onTertiaryContainer: const Color(0xFFFFDCC2),
      surface: const Color(0xFF111318),
      surfaceContainerLow: const Color(0xFF191C20),
      surfaceContainerHighest: const Color(0xFF33353A),
    );

ColorScheme harmonise(ColorScheme? dynamic, Brightness brightness) {
  if (dynamic != null) {
    return brightness == Brightness.light ? _pin(dynamic) : _pinDark(dynamic);
  }
  final base =
      ColorScheme.fromSeed(seedColor: _blueSeed, brightness: brightness);
  return brightness == Brightness.light ? _pin(base) : _pinDark(base);
}

// Cached text theme for performance
final _cachedTextTheme = _buildTextTheme();

TextTheme _buildTextTheme() {
  try {
    // Using Outfit for headings (Premium/Google Sans alternative)
    // and Inter for body text (Modern/Readable)
    return GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.outfit(
          fontSize: 57, fontWeight: FontWeight.w400, letterSpacing: -0.25),
      displayMedium:
          GoogleFonts.outfit(fontSize: 45, fontWeight: FontWeight.w400),
      displaySmall:
          GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.w400),
      headlineLarge:
          GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w700),
      headlineMedium:
          GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w700),
      headlineSmall:
          GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w700),
      titleLarge: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w600),
      titleMedium: GoogleFonts.outfit(
          fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.15),
      titleSmall: GoogleFonts.outfit(
          fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.1),
      bodyLarge: GoogleFonts.inter(
          fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5),
      bodyMedium: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25),
      bodySmall: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4),
      labelLarge: GoogleFonts.inter(
          fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1),
      labelMedium: GoogleFonts.inter(
          fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.5),
      labelSmall: GoogleFonts.inter(
          fontSize: 11, fontWeight: FontWeight.w500, letterSpacing: 0.5),
    );
  } catch (e) {
    // Fallback to default text theme if Google Fonts fails
    return const TextTheme();
  }
}

ThemeData buildTheme(ColorScheme cs) {
  return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      textTheme: _cachedTextTheme,
      scaffoldBackgroundColor: cs.surface,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: const StadiumBorder(),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          textStyle: _cachedTextTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
          side: BorderSide(color: cs.outlineVariant, width: 1.2),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: cs.primary,
          textStyle: _cachedTextTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: cs.surfaceContainerLow,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cs.surfaceContainerLow,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: cs.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      ),
  );
}
