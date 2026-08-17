import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Centralized typography system with clear visual hierarchy.
///
/// Provides semantic text styles that adapt to both light and dark themes
/// while maintaining consistent sizing, weight, and spacing.
class AppTypography {
  static final TextTheme _baseTheme = GoogleFonts.plusJakartaSansTextTheme();

  // Display styles (Page titles, hero sections)
  static TextStyle display1(BuildContext context) => _baseTheme.displayLarge!.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w900,
        letterSpacing: -0.5,
        height: 1.2,
        color: AppColors.textPrimary,
      );

  static TextStyle display2(BuildContext context) => _baseTheme.displayMedium!.copyWith(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
        height: 1.25,
        color: AppColors.textPrimary,
      );

  // Headline styles (Section titles, card headers)
  static TextStyle h1(BuildContext context) => _baseTheme.headlineLarge!.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        height: 1.3,
        color: AppColors.textPrimary,
      );

  static TextStyle h2(BuildContext context) => _baseTheme.headlineMedium!.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
        height: 1.3,
        color: AppColors.textPrimary,
      );

  static TextStyle h3(BuildContext context) => _baseTheme.headlineSmall!.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.4,
        color: AppColors.textPrimary,
      );

  // Title styles (List items, component headers)
  static TextStyle title1(BuildContext context) => _baseTheme.titleLarge!.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.4,
        color: AppColors.textPrimary,
      );

  static TextStyle title2(BuildContext context) => _baseTheme.titleMedium!.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        height: 1.4,
        color: AppColors.textPrimary,
      );

  // Body styles (Main content text)
  static TextStyle body1(BuildContext context) => _baseTheme.bodyLarge!.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.5,
        color: AppColors.textPrimary,
      );

  static TextStyle body2(BuildContext context) => _baseTheme.bodyMedium!.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.5,
        color: AppColors.textSecondary,
      );

  static TextStyle body3(BuildContext context) => _baseTheme.bodySmall!.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.5,
        color: AppColors.textSecondary,
      );

  // Label styles (Form labels, buttons, metadata)
  static TextStyle label1(BuildContext context) => _baseTheme.labelLarge!.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        height: 1.4,
        color: AppColors.textPrimary,
      );

  static TextStyle label2(BuildContext context) => _baseTheme.labelMedium!.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        height: 1.4,
        color: AppColors.textSecondary,
      );

  // Caption styles (Supporting text, timestamps, hints)
  static TextStyle caption1(BuildContext context) => _baseTheme.labelSmall!.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.4,
        color: AppColors.textMuted,
      );

  static TextStyle caption2(BuildContext context) => _baseTheme.labelSmall!.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        height: 1.3,
        color: AppColors.textMuted,
      );

  // Button styles
  static TextStyle button(BuildContext context) => _baseTheme.labelLarge!.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        height: 1.2,
      );

  static TextStyle buttonSmall(BuildContext context) => _baseTheme.labelMedium!.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        height: 1.2,
      );

  // Utility styles
  static TextStyle overline(BuildContext context) => _baseTheme.labelSmall!.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        height: 1.3,
        color: AppColors.textMuted,
      );

  static TextStyle mono(BuildContext context) => const TextStyle(
        fontFamily: 'monospace',
        fontSize: 13,
        fontWeight: FontWeight.w400,
        letterSpacing: 0,
        height: 1.5,
      );
}
