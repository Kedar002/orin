import 'package:flutter/material.dart';

/// iOS-aligned color palette
/// Clean design matching Apple's system colors
class SecurityColors {
  SecurityColors._();

  // Backgrounds - iOS System
  static const Color primaryBackground = Color(0xFFFFFFFF); // Clean white background
  static const Color secondarySurface = Color(0xFFF2F2F7); // iOS secondary background

  // Borders & Dividers - iOS Separator
  static const Color divider = Color(0xFFC6C6C8); // iOS separator

  // Text - iOS Labels
  static const Color primaryText = Color(0xFF000000); // iOS primary label
  static const Color secondaryText = Color(0xFF3C3C43); // iOS secondary label

  // Accents - iOS System Colors
  static const Color accent = Color(0xFF000000); // High contrast black
  static const Color secondaryAccent = Color(0xFF007AFF); // iOS Blue

  // Status Colors - iOS System
  static const Color statusOnline = Color(0xFF34C759); // iOS Green
  static const Color statusOffline = Color(0xFFFF3B30); // iOS Red
}
