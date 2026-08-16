import 'dart:ui';
import 'package:flutter/material.dart';

/// A frosted-glass container inspired by iOS 27's real glassmorphism.
///
/// Uses [BackdropFilter] to blur whatever sits behind it, layered with a
/// semi-tinted fill and a luminous border edge so the colour of the background
/// still shows through — the hallmark of real glass, not a flat translucent box.
///
/// Set [isDark] to true when the card sits on a dark / navy surface (e.g. the
/// student ID card screen) so the tint shifts from white to black.
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double borderRadius;
  final double blurSigma;
  final double opacity;
  final bool isDark;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.borderRadius = 20,
    this.blurSigma = 20,
    this.opacity = 0.72,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final fillColor = isDark
        ? Colors.black.withAlpha((255 * opacity * 0.45).round())
        : Colors.white.withAlpha((255 * opacity).round());

    final borderColor = isDark
        ? Colors.white.withAlpha(25)
        : Colors.white.withAlpha(55);

    Widget card = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          decoration: BoxDecoration(
            color: fillColor,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withAlpha(50)
                    : Colors.black.withAlpha(8),
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

    if (onTap != null) {
      card = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: card,
        ),
      );
    }

    return Padding(
      padding: margin ?? const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: card,
    );
  }
}
