import 'package:flutter/material.dart';

/// Apple-inspired color palette
/// Neutral base with one primary accent color
class AppColors {
  AppColors._();

  // PRIMARY ACCENT COLOR
  /// Deep blue accent - calm and confident
  static const Color primary = Color(0xFF0A84FF);
  static const Color primaryDark = Color(0xFF0066CC);

  // NEUTRAL LIGHT THEME
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF5F5F7);
  static const Color cardLight = Color(0xFFFFFFFF);

  // TEXT LIGHT THEME
  static const Color textPrimaryLight = Color(0xFF000000);
  static const Color textSecondaryLight = Color(0xFF6E6E73);
  static const Color textTertiaryLight = Color(0xFFAEAEB2);

  // NEUTRAL DARK THEME
  static const Color backgroundDark = Color(0xFF000000);
  static const Color surfaceDark = Color(0xFF1C1C1E);
  static const Color cardDark = Color(0xFF2C2C2E);

  // TEXT DARK THEME
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFF98989D);
  static const Color textTertiaryDark = Color(0xFF636366);

  // STATUS COLORS (subtle, not alarming)
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9500);
  static const Color error = Color(0xFFFF3B30);

  // DIVIDERS & BORDERS
  static const Color dividerLight = Color(0xFFE5E5EA);
  static const Color dividerDark = Color(0xFF38383A);
}
