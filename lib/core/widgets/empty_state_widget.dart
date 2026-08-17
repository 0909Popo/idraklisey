import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Modern empty state component with icon, message, and action.
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 56,
                color: AppColors.primary.withAlpha(128),
              ),
            ),
            
            SizedBox(height: AppSpacing.xxl),
            
            Text(
              title,
              style: AppTypography.h2(context),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: AppSpacing.sm),
            
            Text(
              message,
              style: AppTypography.body2(context),
              textAlign: TextAlign.center,
            ),
            
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: AppSpacing.xxl),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded),
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
