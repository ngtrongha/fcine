import 'package:flutter/material.dart';

/// Design tokens and Material 3 theme configuration for F-Cine.
/// Aligns strictly with [DESIGN.md] and Stitch MCP design system.
class AppColors {
  static const Color background = Color(0xFF080B11);
  static const Color surface = Color(0xFF111622);
  static const Color surfaceVariant = Color(0xFF1A2130);
  static const Color primary = Color(0xFFE50914);
  static const Color primaryContainer = Color(0xFF380B0F);
  static const Color secondary = Color(0xFFFF5252);
  static const Color tertiary = Color(0xFFF59E0B);
  static const Color onBackground = Color(0xFFF1F5F9);
  static const Color onSurface = Color(0xFFF1F5F9);
  static const Color onSurfaceVariant = Color(0xFF94A3B8);
  static const Color outline = Color(0xFF2D3748);
  static const Color outlineVariant = Color(0xFF1E293B);
  static const Color error = Color(0xFFFF4D4F);
}

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.background,
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: Color(0xFFFFD9DC),
    secondary: AppColors.secondary,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFF4D1418),
    onSecondaryContainer: Colors.white,
    tertiary: AppColors.tertiary,
    onTertiary: Colors.black,
    tertiaryContainer: Color(0xFF452600),
    onTertiaryContainer: Color(0xFFFFDDB3),
    error: AppColors.error,
    onError: Colors.white,
    surface: AppColors.surface,
    onSurface: AppColors.onSurface,
    surfaceContainerHighest: AppColors.surfaceVariant,
    onSurfaceVariant: AppColors.onSurfaceVariant,
    outline: AppColors.outline,
    outlineVariant: AppColors.outlineVariant,
  ),
  useMaterial3: true,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.background,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
    iconTheme: IconThemeData(color: AppColors.onBackground),
    titleTextStyle: TextStyle(
      color: AppColors.onBackground,
      fontSize: 20,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.02,
    ),
  ),
  cardTheme: CardThemeData(
    color: AppColors.surface,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: const BorderSide(color: AppColors.outlineVariant, width: 1),
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: AppColors.surface,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.onSurfaceVariant,
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  ),
  chipTheme: ChipThemeData(
    backgroundColor: AppColors.surfaceVariant,
    selectedColor: AppColors.primary,
    disabledColor: AppColors.surface,
    labelStyle: const TextStyle(color: AppColors.onSurface, fontSize: 13),
    secondaryLabelStyle: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: Colors.transparent),
    ),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.onBackground,
      side: const BorderSide(color: AppColors.outline),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
    ),
  ),
);
