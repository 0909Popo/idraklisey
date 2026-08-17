import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';

/// Modern primary button component (2026 style).
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget buttonChild = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: AppSpacing.iconMd),
                  SizedBox(width: AppSpacing.sm),
                  Text(label),
                ],
              )
            : Text(label);

    final button = FilledButton(
      onPressed: isLoading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: Size(fullWidth ? double.infinity : 120, 48),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.buttonPaddingH,
          vertical: AppSpacing.buttonPaddingV,
        ),
      ),
      child: buttonChild,
    );

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Modern secondary/outlined button.
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool fullWidth;

  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget buttonChild = icon != null
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: AppSpacing.iconMd),
              SizedBox(width: AppSpacing.sm),
              Text(label),
            ],
          )
        : Text(label);

    final button = OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: Size(fullWidth ? double.infinity : 120, 48),
      ),
      child: buttonChild,
    );

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Text-only button for subtle actions.
class TextOnlyButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  const TextOnlyButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: icon != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: AppSpacing.iconMd),
                SizedBox(width: AppSpacing.sm),
                Text(label),
              ],
            )
          : Text(label),
    );
  }
}

/// Icon button with modern styling.
class ModernIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;
  final Color? backgroundColor;
  final double size;

  const ModernIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.backgroundColor,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: AppSpacing.iconMd),
        color: color ?? AppColors.textPrimary,
        padding: EdgeInsets.zero,
      ),
    );
  }
}
