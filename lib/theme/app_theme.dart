import 'package:flutter/material.dart';

abstract final class AppTheme {
  static ThemeData build() {
    const seed = Color(0xFF1B2A4A);
    const accent = Color(0xFFE8A838);
    final scheme = ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.light,
      primary: const Color(0xFF1B2A4A),
      secondary: accent,
      tertiary: const Color(0xFF3D8B7E),
      surface: const Color(0xFFF4F1EA),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.primary,
        indicatorColor: accent.withValues(alpha: 0.35),
        selectedIconTheme: IconThemeData(color: accent),
        selectedLabelTextStyle: TextStyle(color: accent, fontWeight: FontWeight.w600),
        unselectedIconTheme: IconThemeData(color: scheme.onPrimary.withValues(alpha: 0.7)),
        unselectedLabelTextStyle:
            TextStyle(color: scheme.onPrimary.withValues(alpha: 0.7)),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.white,
        shadowColor: scheme.primary.withValues(alpha: 0.08),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: scheme.primary,
        titleTextStyle: TextStyle(
          color: scheme.primary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}