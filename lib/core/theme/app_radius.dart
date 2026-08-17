import 'package:flutter/material.dart';

/// Centralized border radius system for consistent component shapes.
///
/// Provides a unified radius scale to ensure all cards, buttons, dialogs
/// and containers maintain visual consistency throughout the application.
class AppRadius {
  // Radius scale
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double full = 9999.0; // Pill shape

  // Common radius presets
  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius buttonRadius = BorderRadius.all(Radius.circular(md));
  static const BorderRadius dialogRadius = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius bottomSheetRadius = BorderRadius.vertical(top: Radius.circular(xxl));
  static const BorderRadius chipRadius = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius pillRadius = BorderRadius.all(Radius.circular(full));

  // Component-specific
  static const double avatar = full; // Always circular
  static const double badge = sm;
  static const double inputField = md;
}
