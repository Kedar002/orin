import 'package:flutter/material.dart';

/// Pure Monochrome Color System
/// "Simplicity is the ultimate sophistication" - Steve Jobs
/// Uses ONLY black, white, and precisely chosen grays
class AppColors {
  AppColors._();

  // ═══════════════════════════════════════════════════════════
  // MONOCHROME PALETTE - LIGHT MODE
  // ═══════════════════════════════════════════════════════════

  /// Pure white - Background
  static const Color mono100 = Color(0xFFFFFFFF);

  /// Very subtle off-white - Surface
  static const Color mono95 = Color(0xFFF5F5F7);

  /// Borders, dividers - visible separation
  static const Color mono90 = Color(0xFFE5E5E7);

  /// Secondary text - readable but recessed
  static const Color mono70 = Color(0xFFAAAAAC);

  /// Tertiary text - de-emphasized
  static const Color mono40 = Color(0xFF666668);

  /// Emphasis text - between primary and black
  static const Color mono20 = Color(0xFF333335);

  /// Hover/pressed states
  static const Color mono10 = Color(0xFF1A1A1C);

  /// Pure black - Primary text, interactive elements
  static const Color mono0 = Color(0xFF000000);

  // ═══════════════════════════════════════════════════════════
  // MONOCHROME PALETTE - DARK MODE
  // ═══════════════════════════════════════════════════════════

  /// Pure black - Background
  static const Color mono0Dark = Color(0xFF000000);

  /// Surface - barely lifted
  static const Color mono5Dark = Color(0xFF0A0A0C);

  /// Secondary surface
  static const Color mono10Dark = Color(0xFF1A1A1C);

  /// Borders, dividers
  static const Color mono30Dark = Color(0xFF4C4C4E);

  /// Secondary text
  static const Color mono60Dark = Color(0xFF999999);

  /// Tertiary text
  static const Color mono80Dark = Color(0xFFCCCCCC);

  /// Near-white emphasis
  static const Color mono95Dark = Color(0xFFF2F2F2);

  /// Pure white - Primary text, interactive elements
  static const Color mono100Dark = Color(0xFFFFFFFF);

  // ═══════════════════════════════════════════════════════════
  // SEMANTIC MAPPINGS - Maintaining API compatibility
  // ═══════════════════════════════════════════════════════════

  // PRIMARY ACCENT (Black in light, White in dark)
  static const Color primary = mono0;
  static const Color primaryDark = mono100Dark;

  // LIGHT THEME STRUCTURE
  static const Color backgroundLight = mono100;
  static const Color surfaceLight = mono95;
  static const Color cardLight = mono100;

  // LIGHT THEME TEXT
  static const Color textPrimaryLight = mono0;
  static const Color textSecondaryLight = mono70;
  static const Color textTertiaryLight = mono40;

  // DARK THEME STRUCTURE
  static const Color backgroundDark = mono0Dark;
  static const Color surfaceDark = mono5Dark;
  static const Color cardDark = mono10Dark;

  // DARK THEME TEXT
  static const Color textPrimaryDark = mono100Dark;
  static const Color textSecondaryDark = mono60Dark;
  static const Color textTertiaryDark = mono30Dark;

  // STATUS COLORS (Monochrome representation)
  // Success/Active: Solid black/white circle with pulse animation
  static const Color success = mono0;
  static const Color successDark = mono100Dark;

  // Warning/Attention: Outlined circle with breathing animation
  static const Color warning = mono40;
  static const Color warningDark = mono60Dark;

  // Error/Offline: Empty outline, gray, no animation
  static const Color error = mono70;
  static const Color errorDark = mono30Dark;

  // DIVIDERS & BORDERS
  static const Color dividerLight = mono90;
  static const Color dividerDark = mono30Dark;

  // INTERACTIVE STATES

  /// Hover state (light mode)
  static const Color hoverLight = mono10;

  /// Hover state (dark mode)
  static const Color hoverDark = mono95Dark;

  /// Pressed state (light mode)
  static const Color pressedLight = mono20;

  /// Pressed state (dark mode)
  static const Color pressedDark = mono80Dark;

  /// Disabled state (light mode)
  static const Color disabledLight = mono90;

  /// Disabled state (dark mode)
  static const Color disabledDark = mono10Dark;
}
