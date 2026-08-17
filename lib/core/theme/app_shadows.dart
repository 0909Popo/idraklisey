import 'package:flutter/material.dart';

/// Centralized shadow system for subtle elevation and depth.
///
/// Provides consistent shadow definitions that work well in both
/// light and dark themes, following 2026 design principles of
/// subtle rather than aggressive depth cues.
class AppShadows {
  // Subtle elevation shadows (light theme optimized)
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x0A000000), // 4% black
      blurRadius: 4,
      offset: Offset(0, 1),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x0F000000), // 6% black
      blurRadius: 8,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x14000000), // 8% black
      blurRadius: 16,
      offset: Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> xl = [
    BoxShadow(
      color: Color(0x1F000000), // 12% black
      blurRadius: 24,
      offset: Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  // Card shadows
  static const List<BoxShadow> card = md;
  static const List<BoxShadow> cardHover = lg;

  // Button shadows
  static const List<BoxShadow> button = sm;

  // Dialog/modal shadows
  static const List<BoxShadow> modal = xl;

  // Dark theme shadows (more subtle)
  static const List<BoxShadow> darkSm = [
    BoxShadow(
      color: Color(0x1A000000), // 10% black (darker for dark mode)
      blurRadius: 4,
      offset: Offset(0, 1),
      spreadRadius: 0,
    ),
  ];

  static const List<BoxShadow> darkMd = [
    BoxShadow(
      color: Color(0x29000000), // 16% black
      blurRadius: 8,
      offset: Offset(0, 2),
      spreadRadius: 0,
    ),
  ];
}
