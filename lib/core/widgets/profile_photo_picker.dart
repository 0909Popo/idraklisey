import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/cloudinary_service.dart';

/// Yenidən istifadə olunan profil foto seçimi widget-i.
/// Kamera və ya qalereyadan foto seçir, Cloudinary-yə yükləyir.
class ProfilePhotoPicker extends StatefulWidget {
  final String? initialPhotoUrl;
  final ValueChanged<String> onPhotoUploaded;
  final double size;
  final String folder;

  const ProfilePhotoPicker({
    super.key,
    this.initialPhotoUrl,
    required this.onPhotoUploaded,
    this.size = 100,
    this.folder = 'idrak/profiles',
  });

  @override
  State<ProfilePhotoPicker> createState() => _ProfilePhotoPickerState();
}

class _ProfilePhotoPickerState extends State<ProfilePhotoPicker>
    with SingleTickerProviderStateMixin {
  String? _photoUrl;
  bool _isUploading = false;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _photoUrl = widget.initialPhotoUrl;
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _showPickerDialog() async {
    final source = await showModalBottomSheet<ImageSourceOption>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Profil Fotosu Seçin',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Fotosu kamera ilə çəkin və ya qalereyadan seçin',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const SizedBox(width: 20),
                Expanded(
                  child: _buildOptionCard(
                    icon: Icons.camera_alt_rounded,
                    label: 'Kamera',
                    color: AppColors.primary,
                    onTap: () => Navigator.pop(ctx, ImageSourceOption.camera),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildOptionCard(
                    icon: Icons.photo_library_rounded,
                    label: 'Qaleriya',
                    color: AppColors.goldDark,
                    onTap: () => Navigator.pop(ctx, ImageSourceOption.gallery),
                  ),
                ),
                const SizedBox(width: 20),
              ],
            ),
            if (_photoUrl != null) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => Navigator.pop(ctx, ImageSourceOption.remove),
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 18),
                label: const Text(
                  'Fotonu Sil',
                  style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w600),
                ),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );

    if (source == null) return;

    if (source == ImageSourceOption.remove) {
      setState(() => _photoUrl = null);
      return;
    }

    setState(() => _isUploading = true);

    String? uploadedUrl;
    if (source == ImageSourceOption.camera) {
      uploadedUrl = await CloudinaryService.pickAndUploadFromCamera(
        folder: widget.folder,
      );
    } else {
      uploadedUrl = await CloudinaryService.pickAndUploadFromGallery(
        folder: widget.folder,
      );
    }

    if (mounted) {
      setState(() {
        _isUploading = false;
        if (uploadedUrl != null) {
          _photoUrl = uploadedUrl;
          widget.onPhotoUploaded(uploadedUrl);
        }
      });

      if (uploadedUrl != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil fotosu uğurla yükləndi!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withAlpha(18),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(40)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isUploading ? null : _showPickerDialog,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Photo Circle
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _photoUrl != null
                      ? AppColors.primary.withAlpha(120)
                      : AppColors.cardBorder,
                  width: 3,
                ),
                boxShadow: _photoUrl != null
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(40),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: ClipOval(
                child: _isUploading
                    ? Container(
                        color: AppColors.background,
                        child: Center(
                          child: AnimatedBuilder(
                            animation: _pulseCtrl,
                            builder: (context, child) {
                              return Opacity(
                                opacity: 0.4 + (_pulseCtrl.value * 0.6),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: widget.size * 0.3,
                                      height: widget.size * 0.3,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Yüklənir...',
                                      style: TextStyle(
                                        fontSize: widget.size * 0.1,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      )
                    : _photoUrl != null
                        ? Image.network(
                            _photoUrl!,
                            fit: BoxFit.cover,
                            width: widget.size,
                            height: widget.size,
                            errorBuilder: (_, _, _) => _buildPlaceholder(),
                          )
                        : _buildPlaceholder(),
              ),
            ),

            // Camera Badge
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: widget.size * 0.32,
                height: widget.size * 0.32,
                decoration: BoxDecoration(
                  color: _photoUrl != null ? AppColors.primary : AppColors.gold,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(40),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  _photoUrl != null
                      ? Icons.edit_rounded
                      : Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: widget.size * 0.16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.background,
      child: Icon(
        Icons.person_rounded,
        size: widget.size * 0.45,
        color: AppColors.textSecondary.withAlpha(80),
      ),
    );
  }
}

enum ImageSourceOption { camera, gallery, remove }
