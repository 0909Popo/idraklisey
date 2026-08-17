import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';
import '../theme/app_shadows.dart';

/// Modern 2026-style card component with consistent styling.
///
/// Provides a clean, elevated surface with proper spacing and shadows.
/// Adapts automatically to light/dark themes.
class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final VoidCallback? onTap;
  final bool elevated;
  final BorderRadiusGeometry? borderRadius;

  const ModernCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.onTap,
    this.elevated = false,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final Widget cardContent = Container(
      padding: padding ?? EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: borderRadius ?? AppRadius.cardRadius,
        border: Border.all(
          color: AppColors.cardBorder,
          width: 1,
        ),
        boxShadow: elevated ? AppShadows.card : null,
      ),
      child: child,
    );

    if (onTap != null) {
      return Container(
        margin: margin ?? EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: (borderRadius ?? AppRadius.cardRadius) as BorderRadius?,
            child: cardContent,
          ),
        ),
      );
    }

    return Container(
      margin: margin ?? EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      child: cardContent,
    );
  }
}

/// Compact card variant for list items.
class CompactCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const CompactCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return ModernCard(
      padding: padding ?? EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
      margin: margin ?? EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
      onTap: onTap,
      child: child,
    );
  }
}
