import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Inter-based typography system
/// Clean, minimal, Apple/Nike-style aesthetics
/// Visual hierarchy through size and weight only
class AppTypography {
  AppTypography._();

  // FONT FAMILY - Inter
  static const String fontFamily = 'Inter';

  // Helper method to create TextStyle with Inter font
  static TextStyle _inter({
    required double fontSize,
    required FontWeight fontWeight,
    required double height,
    double letterSpacing = 0,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // HEADLINES / ONBOARDING TITLES
  // 24-28px, SemiBold/Bold, 1.4-1.5 line height, 0-0.5px letter spacing

  /// 28px, Bold - Large onboarding titles
  static TextStyle largeTitle = _inter(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.4,
    letterSpacing: 0,
  );

  /// 26px, SemiBold - Screen titles
  static TextStyle title1 = _inter(
    fontSize: 26,
    fontWeight: FontWeight.w600,
    height: 1.45,
    letterSpacing: 0,
  );

  /// 24px, SemiBold - Section headlines
  static TextStyle title2 = _inter(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.5,
    letterSpacing: 0,
  );

  // SECTION HEADINGS / CARD TITLES
  // 18-20px, Medium, 1.4-1.5 line height, 0-0.5px letter spacing

  /// 20px, Medium - Major section headers
  static TextStyle heading1 = _inter(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0,
  );

  /// 18px, Medium - Card titles, subsection headers
  static TextStyle heading2 = _inter(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.45,
    letterSpacing: 0,
  );

  // BODY TEXT / PARAGRAPHS
  // 14-16px, Regular, 1.4-1.6 line height, 0-0.5px letter spacing

  /// 16px, Regular - Primary body text
  static TextStyle body = _inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0,
  );

  /// 16px, Medium - Emphasized body text
  static TextStyle bodyEmphasized = _inter(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
    letterSpacing: 0,
  );

  /// 15px, Regular - Secondary body text
  static TextStyle bodySecondary = _inter(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0,
  );

  /// 14px, Regular - Tertiary body text
  static TextStyle bodySmall = _inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.6,
    letterSpacing: 0,
  );

  // CAPTION / SMALL TEXT
  // 12px, Regular/Medium, 1.3-1.5 line height, 0-0.5px letter spacing

  /// 12px, Medium - Emphasized captions
  static TextStyle captionEmphasized = _inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0,
  );

  /// 12px, Regular - Captions, footnotes, timestamps
  static TextStyle caption = _inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0,
  );

  // BUTTON TEXT

  /// 16px, Medium - Primary buttons
  static TextStyle button = _inter(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0,
  );

  /// 14px, Medium - Secondary buttons
  static TextStyle buttonSmall = _inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.2,
    letterSpacing: 0,
  );

  // LEGACY COMPATIBILITY (maintaining old names for backward compatibility)
  static TextStyle get title3 => heading1;
  static TextStyle get callout => bodySecondary;
  static TextStyle get subheadline => bodySmall;
  static TextStyle get footnote => caption;
}
