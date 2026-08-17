/// Centralized spacing system for consistent layout rhythm.
///
/// Uses a predictable 4px-based scale to maintain visual consistency
/// across the entire application.
class AppSpacing {
  // Base spacing scale (4px-based)
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 40.0;
  static const double massive = 48.0;

  // Common paddings
  static const double screenPadding = lg; // 16px
  static const double cardPadding = lg; // 16px
  static const double buttonPaddingV = md; // 12px
  static const double buttonPaddingH = xxl; // 24px
  static const double sectionSpacing = xxl; // 24px
  static const double itemSpacing = md; // 12px

  // Icon sizes
  static const double iconSm = 16.0;
  static const double iconMd = 20.0;
  static const double iconLg = 24.0;
  static const double iconXl = 32.0;
  static const double iconXxl = 48.0;
}
