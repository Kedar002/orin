import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_typography.dart';

/// Clean, minimal app theme with Inter font
class AppTheme {
  AppTheme._();

  // LIGHT THEME - Pure Monochrome
  static ThemeData light = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: GoogleFonts.inter().fontFamily,

    // Colors
    scaffoldBackgroundColor: AppColors.backgroundLight,
    primaryColor: AppColors.primary,

    // Color Scheme
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.mono100,
      surface: AppColors.surfaceLight,
      onSurface: AppColors.textPrimaryLight,
      error: AppColors.error,
    ),

    // Card Theme - Subtle shadow for depth
    cardTheme: CardThemeData(
      color: AppColors.cardLight,
      elevation: 0,
      margin: EdgeInsets.zero,
      shadowColor: AppColors.mono0.withOpacity(0.04),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
    ),

    // App Bar Theme
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: AppColors.backgroundLight,
      foregroundColor: AppColors.textPrimaryLight,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: AppTypography.title1.copyWith(
        color: AppColors.textPrimaryLight,
      ),
    ),

    // Bottom Navigation Bar Theme - Monochrome with weight
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.backgroundLight,
      selectedItemColor: AppColors.mono0,
      unselectedItemColor: AppColors.mono70,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),

    // Text Theme
    textTheme: TextTheme(
      displayLarge: AppTypography.largeTitle,
      displayMedium: AppTypography.title1,
      displaySmall: AppTypography.title2,
      headlineMedium: AppTypography.title3,
      bodyLarge: AppTypography.body,
      bodyMedium: AppTypography.callout,
      bodySmall: AppTypography.subheadline,
      labelLarge: AppTypography.button,
      labelMedium: AppTypography.buttonSmall,
    ).apply(
      bodyColor: AppColors.textPrimaryLight,
      displayColor: AppColors.textPrimaryLight,
    ),

    // Input Decoration Theme - Monochrome focus state
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.mono0, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),

    // Elevated Button Theme - Pure monochrome
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.mono0,
        foregroundColor: AppColors.mono100,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: AppTypography.button,
        minimumSize: const Size(0, 44),
      ),
    ),

    // Text Button Theme - Pure monochrome
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.mono0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: AppTypography.button,
        minimumSize: const Size(0, 44),
      ),
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: AppColors.dividerLight,
      thickness: 0.33,
      space: 0.33,
    ),
  );

  // DARK THEME - Pure Monochrome
  static ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: GoogleFonts.inter().fontFamily,

    // Colors
    scaffoldBackgroundColor: AppColors.backgroundDark,
    primaryColor: AppColors.primaryDark,

    // Color Scheme
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryDark,
      onPrimary: AppColors.mono0Dark,
      surface: AppColors.surfaceDark,
      onSurface: AppColors.textPrimaryDark,
      error: AppColors.errorDark,
    ),

    // Card Theme - Subtle border instead of shadow
    cardTheme: const CardThemeData(
      color: AppColors.cardDark,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        side: BorderSide(color: AppColors.mono10Dark, width: 0.5),
      ),
    ),

    // App Bar Theme
    appBarTheme: AppBarTheme(
      elevation: 0,
      centerTitle: false,
      backgroundColor: AppColors.backgroundDark,
      foregroundColor: AppColors.textPrimaryDark,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: AppTypography.title1.copyWith(
        color: AppColors.textPrimaryDark,
      ),
    ),

    // Bottom Navigation Bar Theme - Monochrome with weight
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.backgroundDark,
      selectedItemColor: AppColors.mono100Dark,
      unselectedItemColor: AppColors.mono60Dark,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      showSelectedLabels: true,
      showUnselectedLabels: true,
    ),

    // Text Theme
    textTheme: TextTheme(
      displayLarge: AppTypography.largeTitle,
      displayMedium: AppTypography.title1,
      displaySmall: AppTypography.title2,
      headlineMedium: AppTypography.title3,
      bodyLarge: AppTypography.body,
      bodyMedium: AppTypography.callout,
      bodySmall: AppTypography.subheadline,
      labelLarge: AppTypography.button,
      labelMedium: AppTypography.buttonSmall,
    ).apply(
      bodyColor: AppColors.textPrimaryDark,
      displayColor: AppColors.textPrimaryDark,
    ),

    // Input Decoration Theme - Monochrome focus state
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.mono100Dark, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),

    // Elevated Button Theme - Pure monochrome
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.mono100Dark,
        foregroundColor: AppColors.mono0Dark,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: AppTypography.button,
        minimumSize: const Size(0, 44),
      ),
    ),

    // Text Button Theme - Pure monochrome
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.mono100Dark,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: AppTypography.button,
        minimumSize: const Size(0, 44),
      ),
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: AppColors.dividerDark,
      thickness: 0.5,
      space: 1,
    ),
  );
}
