import 'package:flutter/material.dart';

/// iOS SF Colors palette
/// Official Apple system colors for authentic iOS design
class AppColors {
  AppColors._();

  // PRIMARY ACCENT COLOR
  /// iOS Blue - System primary color
  static const Color primary = Color(0xFF007AFF);
  static const Color primaryDark = Color(0xFF0A84FF);

  // iOS SYSTEM COLORS
  static const Color systemRed = Color(0xFFFF3B30);
  static const Color systemRedDark = Color(0xFFFF453A);

  static const Color systemGreen = Color(0xFF34C759);
  static const Color systemGreenDark = Color(0xFF30D158);

  static const Color systemOrange = Color(0xFFFF9500);
  static const Color systemOrangeDark = Color(0xFFFF9F0A);

  static const Color systemYellow = Color(0xFFFFCC00);
  static const Color systemYellowDark = Color(0xFFFFD60A);

  static const Color systemTeal = Color(0xFF5AC8FA);
  static const Color systemTealDark = Color(0xFF64D2FF);

  static const Color systemIndigo = Color(0xFF5856D6);
  static const Color systemIndigoDark = Color(0xFF5E5CE6);

  static const Color systemPurple = Color(0xFFAF52DE);
  static const Color systemPurpleDark = Color(0xFFBF5AF2);

  static const Color systemPink = Color(0xFFFF2D55);
  static const Color systemPinkDark = Color(0xFFFF375F);

  // NEUTRAL LIGHT THEME (iOS System Backgrounds)
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF2F2F7);
  static const Color cardLight = Color(0xFFFFFFFF);

  // TEXT LIGHT THEME (iOS Label Colors)
  static const Color textPrimaryLight = Color(0xFF000000);
  static const Color textSecondaryLight = Color(0xFF3C3C43);
  static const Color textTertiaryLight = Color(0xFF3C3C43);

  // NEUTRAL DARK THEME (iOS System Backgrounds)
  static const Color backgroundDark = Color(0xFF000000);
  static const Color surfaceDark = Color(0xFF1C1C1E);
  static const Color cardDark = Color(0xFF2C2C2E);

  // TEXT DARK THEME (iOS Label Colors)
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFEBEBF5);
  static const Color textTertiaryDark = Color(0xFFEBEBF5);

  // STATUS COLORS (map to iOS system colors)
  static const Color success = systemGreen;
  static const Color warning = systemOrange;
  static const Color error = systemRed;

  // DIVIDERS & BORDERS (iOS Separator Colors)
  static const Color dividerLight = Color(0xFF3C3C43);
  static const Color dividerDark = Color(0xFF545458);
}
