import 'package:flutter/material.dart';

/// Clean, professional color palette
/// Matt black accents with bright, readable design
class SecurityColors {
  SecurityColors._();

  // Backgrounds
  static const Color primaryBackground = Color(0xFFFFFFFF); // Clean white background
  static const Color secondarySurface = Color(0xFFF9FAFB); // Input fields & containers

  // Borders & Dividers
  static const Color divider = Color(0xFFE5E7EB); // Subtle separators

  // Text
  static const Color primaryText = Color(0xFF111827); // Strong readable text
  static const Color secondaryText = Color(0xFF6B7280); // Subtitles, placeholders

  // Accents
  static const Color accent = Color(0xFF18181B); // Primary button & focus (Matt black)
  static const Color secondaryAccent = Color(0xFF2563EB); // Links like "Forgot password"

  // Status Colors (LIMITED USE)
  static const Color statusOnline = Color(0xFF10B981); // Camera online (green)
  static const Color statusOffline = Color(0xFFDC2626); // Error state only (red)
}
