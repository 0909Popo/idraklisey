import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// A styled card container with a real frosted-glass effect.
///
/// Wraps content in a [ClipRRect] → [BackdropFilter] → [Container] stack so
/// that whatever sits behind the card is blurred and tinted — just like iOS 27's
/// native glass material.  Every existing call-site continues to work without
/// changes because the public API (child, padding, onTap, gradient, …) is kept
/// identical.
class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Border? border;
  final Gradient? gradient;
  final double borderRadius;
  final List<BoxShadow>? boxShadow;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.border,
    this.gradient,
    this.borderRadius = 16,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    // When a caller provides an explicit gradient or opaque background we
    // respect it verbatim — no blur in that case (gradient CTA banners etc.)
    final useGlass = gradient == null && backgroundColor == null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget content;

    if (useGlass) {
      content = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurface.withAlpha(215)
                  : Colors.white.withAlpha(220),
              borderRadius: BorderRadius.circular(borderRadius),
              border: border ??
                  Border.all(
                    color: isDark
                        ? Colors.white.withAlpha(28)
                        : Colors.white.withAlpha(50),
                    width: 1,
                  ),
              boxShadow: boxShadow ??
                  [
                    BoxShadow(
                      color: Colors.black.withAlpha(isDark ? 60 : 10),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
            ),
            child: Padding(
              padding: padding ?? const EdgeInsets.all(16),
              child: child,
            ),
          ),
        ),
      );
    } else {
      content = Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          gradient: gradient,
          borderRadius: BorderRadius.circular(borderRadius),
          border: border ?? Border.all(color: AppColors.cardBorder, width: 1),
          boxShadow: boxShadow ??
              [
                BoxShadow(
                  color: Colors.black.withAlpha(8),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
        ),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      );
    }

    content = Padding(
      padding: margin ?? const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: content,
    );

    if (onTap != null) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: content,
        ),
      );
    }

    return content;
  }
}
