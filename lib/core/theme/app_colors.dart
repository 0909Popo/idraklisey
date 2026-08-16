import 'package:flutter/material.dart';

/// App color palette.
///
/// Brand colors (navy, gold, status) are constant and shared by both themes.
/// The neutral subset (background, surfaces, borders, text) is adaptive:
/// [applyDark] swaps these mutable statics in place so every screen that
/// reads `AppColors.background` etc. instantly follows the active theme
/// without any per-screen logic.
class AppColors {
  // Primary Navy Brand Colors
  static const Color primary = Color(0xFF0F2552); // Deep Idrak Navy
  static const Color primaryDark = Color(0xFF0A1935);
  static const Color primaryLight = Color(0xFF1E3E7B);
  static const Color primaryAccent = Color(0xFF2563EB);

  // Gold / Amber Accent Colors (From Logo)
  static const Color gold = Color(0xFFF59E0B);
  static const Color goldLight = Color(0xFFFBBF24);
  static const Color goldDark = Color(0xFFD97706);

  // Status Colors
  static const Color success = Color(0xFF10B981); // Emerald (Attended)
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B); // Amber (Late)
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color danger = Color(0xFFEF4444);  // Red (Absent)
  static const Color dangerLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);    // Blue (Info)
  static const Color infoLight = Color(0xFFDBEAFE);

  // Dark palette (constant source for the adaptive values below)
  static const Color darkBackground = Color(0xFF090D16);
  static const Color darkSurface = Color(0xFF131B2E);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF334155);

  // --- Adaptive neutral palette (swapped by applyDark) ---
  static const Color _lightBackground = Color(0xFFF8FAFC);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightCardBorder = Color(0xFFE2E8F0);
  static const Color _lightTextPrimary = Color(0xFF0F172A);
  static const Color _lightTextSecondary = Color(0xFF64748B);
  static const Color _lightTextMuted = Color(0xFF94A3B8);

  static const Color _darkTextPrimary = Color(0xFFF1F5F9);
  static const Color _darkTextSecondary = Color(0xFF94A3B8);
  static const Color _darkTextMuted = Color(0xFF64748B);

  static Color background = _lightBackground;
  static Color surface = _lightSurface;
  static Color surfaceElevated = _lightSurface;
  static Color cardBorder = _lightCardBorder;

  // Text
  static Color textPrimary = _lightTextPrimary;
  static Color textSecondary = _lightTextSecondary;
  static Color textMuted = _lightTextMuted;
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  /// Swaps every adaptive neutral to the requested palette.
  static void applyDark(bool dark) {
    if (dark) {
      background = darkBackground;
      surface = darkSurface;
      surfaceElevated = darkCard;
      cardBorder = darkBorder;
      textPrimary = _darkTextPrimary;
      textSecondary = _darkTextSecondary;
      textMuted = _darkTextMuted;
    } else {
      background = _lightBackground;
      surface = _lightSurface;
      surfaceElevated = _lightSurface;
      cardBorder = _lightCardBorder;
      textPrimary = _lightTextPrimary;
      textSecondary = _lightTextSecondary;
      textMuted = _lightTextMuted;
    }
  }

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F2552), Color(0xFF1E3E7B), Color(0xFF1D4ED8)],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF59E0B), Color(0xFFFBBF24), Color(0xFFFDE68A)],
  );

  /// Card gradient built from the current adaptive surfaces.
  static LinearGradient get cardGradient => LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [surface, background],
      );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0F2552), Color(0xFF0A1935)],
  );
}
