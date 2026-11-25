import 'package:flutter/material.dart';

/// Minimal terrarium palette: moss, sage and sand, with amber reserved for alerts.
abstract final class AppColors {
  static const moss = Color(0xFF2F4A3A);
  static const sage = Color(0xFFDCE4D3);
  static const sand = Color(0xFFF4F1EA);
  static const ink = Color(0xFF1D241F);
  static const muted = Color(0xFF6B756D);
  static const amber = Color(0xFFC9822B);
  static const amberSoft = Color(0xFFF6E7D2);
}

ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.moss,
    primary: AppColors.moss,
    surface: AppColors.sand,
    onSurface: AppColors.ink,
  );
  final radius = BorderRadius.circular(16);

  return ThemeData(
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.sand,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.sand,
      foregroundColor: AppColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: radius, borderSide: BorderSide.none),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white,
      selectedColor: AppColors.moss,
      side: BorderSide.none,
      shape: const StadiumBorder(),
      showCheckmark: false,
      labelStyle: const TextStyle(fontWeight: FontWeight.w500),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(160, 48),
        shape: RoundedRectangleBorder(borderRadius: radius),
      ),
    ),
  );
}
