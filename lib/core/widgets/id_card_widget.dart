import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../theme/app_colors.dart';
import 'modern_avatar.dart';

/// Ultra-Premium 2026-style Titanium/Gold Smart Digital ID Card.
///
/// Features:
/// - Brushed titanium/deep obsidian gradient
/// - Realistic Gold EMV Smart Chip graphic
/// - Contactless NFC Wave indicator
/// - Embossed luxury typography with letter spacing
/// - High-precision QR code container with subtle glow
/// - Authentic barcode strip
class ModernIDCard extends StatelessWidget {
  final String fullName;
  final String idNumber;
  final String className;
  final String? photoUrl;
  final String qrData;
  final String barcodeData;
  final Color? accentColor;

  const ModernIDCard({
    super.key,
    required this.fullName,
    required this.idNumber,
    required this.className,
    this.photoUrl,
    required this.qrData,
    required this.barcodeData,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveAccentColor = accentColor ?? AppColors.gold;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 420),
      child: AspectRatio(
        aspectRatio: 1.586, // Standard ISO/IEC 7810 ID-1 card ratio
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0F1B2D),
                Color(0xFF0A1220),
                Color(0xFF14243B),
                Color(0xFF070C15),
              ],
              stops: [0.0, 0.4, 0.75, 1.0],
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: effectiveAccentColor.withAlpha(120),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: effectiveAccentColor.withAlpha(35),
                blurRadius: 28,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withAlpha(150),
                blurRadius: 20,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(21),
            child: Stack(
              children: [
                // Metallic brushed light reflection
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withAlpha(22),
                          Colors.white.withAlpha(4),
                          Colors.transparent,
                          effectiveAccentColor.withAlpha(15),
                        ],
                      ),
                    ),
                  ),
                ),

                // Subtle circuit security watermark pattern
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.04,
                    child: CustomPaint(
                      painter: _CircuitPainter(),
                    ),
                  ),
                ),

                // Main card content
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: School name + EMV Chip + NFC Wave
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(18),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white.withAlpha(30)),
                            ),
                            child: const Icon(
                              Icons.school_rounded,
                              color: AppColors.goldLight,
                              size: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'İDRAK LİSEYİ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.8,
                                  ),
                                ),
                                Text(
                                  'BEYNƏLXALQ TƏHSİL KOMPLEKSİ',
                                  style: TextStyle(
                                    color: AppColors.goldLight,
                                    fontSize: 7.5,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Realistic Gold EMV Smart Chip
                          _buildEmvChip(),
                          const SizedBox(width: 8),
                          // Contactless NFC Wave
                          const Icon(
                            Icons.contactless_rounded,
                            color: Colors.white70,
                            size: 20,
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Center Row: Avatar, Student info, and Sharp QR
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Photo with luxury gold rim
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: effectiveAccentColor, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: effectiveAccentColor.withAlpha(40),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: ModernAvatar(
                              imageUrl: photoUrl,
                              name: fullName,
                              size: 58,
                              backgroundColor: Colors.white.withAlpha(20),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Name and Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  fullName.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.6,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: effectiveAccentColor.withAlpha(30),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: effectiveAccentColor.withAlpha(90), width: 0.8),
                                      ),
                                      child: Text(
                                        className,
                                        style: TextStyle(
                                          color: effectiveAccentColor,
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      idNumber,
                                      style: TextStyle(
                                        color: Colors.white.withAlpha(210),
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.0,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // High-precision QR container
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(80),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: QrImageView(
                              data: qrData,
                              version: QrVersions.auto,
                              size: 58,
                              padding: EdgeInsets.zero,
                              eyeStyle: const QrEyeStyle(
                                eyeShape: QrEyeShape.square,
                                color: Color(0xFF0F1B2D),
                              ),
                              dataModuleStyle: const QrDataModuleStyle(
                                dataModuleShape: QrDataModuleShape.square,
                                color: Color(0xFF0F1B2D),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Footer Barcode + Authenticity stamp
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white.withAlpha(20)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              barcodeData,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.5,
                                fontFamily: 'monospace',
                                color: Colors.white.withAlpha(200),
                              ),
                            ),
                            Row(
                              children: const [
                                Icon(Icons.verified_rounded, size: 10, color: AppColors.goldLight),
                                SizedBox(width: 3),
                                Text(
                                  'OFFICIAL PASS',
                                  style: TextStyle(
                                    fontSize: 7.5,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.0,
                                    color: AppColors.goldLight,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Realistic gold EMV smart chip representation
  Widget _buildEmvChip() {
    return Container(
      width: 28,
      height: 22,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFDF7A),
            Color(0xFFD4AF37),
            Color(0xFFAA820A),
            Color(0xFFE5C158),
          ],
        ),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: const Color(0xFF8A6A00), width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55000000),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 20,
          height: 14,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF8A6A00).withAlpha(160), width: 0.6),
            borderRadius: BorderRadius.circular(3),
          ),
        ),
      ),
    );
  }
}

/// Circuit background pattern painter
class _CircuitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    const step = 24.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x + 10, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
