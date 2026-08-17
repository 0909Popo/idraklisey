import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

/// Modern avatar component with network image support and fallback.
class ModernAvatar extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double size;
  final IconData? fallbackIcon;
  final Color? backgroundColor;
  final VoidCallback? onTap;

  const ModernAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = 48,
    this.fallbackIcon,
    this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primary.withAlpha(30),
        borderRadius: BorderRadius.circular(AppRadius.avatar),
        border: Border.all(
          color: AppColors.cardBorder.withAlpha(50),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.avatar),
        child: imageUrl != null && imageUrl!.isNotEmpty
            ? Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _buildFallback(),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return _buildFallback();
                },
              )
            : _buildFallback(),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.avatar),
        child: avatar,
      );
    }

    return avatar;
  }

  Widget _buildFallback() {
    if (fallbackIcon != null) {
      return Icon(
        fallbackIcon,
        size: size * 0.5,
        color: AppColors.primary,
      );
    }

    if (name != null && name!.isNotEmpty) {
      final initials = _getInitials(name!);
      return Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: size * 0.35,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      );
    }

    return Icon(
      Icons.person_rounded,
      size: size * 0.5,
      color: AppColors.primary,
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }
}

/// Avatar with online status indicator.
class AvatarWithStatus extends StatelessWidget {
  final String? imageUrl;
  final String? name;
  final double size;
  final bool isOnline;

  const AvatarWithStatus({
    super.key,
    this.imageUrl,
    this.name,
    this.size = 48,
    this.isOnline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ModernAvatar(
          imageUrl: imageUrl,
          name: name,
          size: size,
        ),
        if (isOnline)
          Positioned(
            right: 2,
            bottom: 2,
            child: Container(
              width: size * 0.25,
              height: size * 0.25,
              decoration: BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.surface,
                  width: 2,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
