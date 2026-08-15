import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class IdrakLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool isLightText;

  const IdrakLogo({
    super.key,
    this.size = 60,
    this.showText = false,
    this.isLightText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(
          'assets/images/logo.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              'assets/logo.png',
              width: size,
              height: size,
              fit: BoxFit.contain,
              errorBuilder: (context2, error2, stackTrace2) {
                return CustomPaint(
                  size: Size(size, size),
                  painter: _IdrakLogoPainter(),
                );
              },
            );
          },
        ),
        if (showText) ...[
          const SizedBox(height: 8),
          Text(
            'İDRAK LİSEYİ',
            style: TextStyle(
              fontSize: size * 0.22,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
              color: isLightText ? Colors.white : AppColors.primary,
            ),
          ),
          Text(
            'BİLİK VƏ ŞƏXSİYYƏT MƏKTƏBİ',
            style: TextStyle(
              fontSize: size * 0.11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              color: isLightText ? AppColors.goldLight : AppColors.goldDark,
            ),
          ),
        ],
      ],
    );
  }
}

class _IdrakLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);

    final bgNavy = const Color(0xFF0F2552);
    final gold = const Color(0xFFF59E0B);
    final goldLight = const Color(0xFFFBBF24);

    // 1. Draw Shield
    final shieldPath = Path();
    final shieldTop = h * 0.16;
    final shieldLeft = w * 0.16;
    final shieldRight = w * 0.84;
    final shieldBottom = h * 0.82;

    shieldPath.moveTo(shieldLeft, shieldTop);
    shieldPath.lineTo(shieldRight, shieldTop);
    shieldPath.lineTo(shieldRight, shieldTop + (shieldBottom - shieldTop) * 0.55);
    shieldPath.cubicTo(
      shieldRight,
      shieldBottom * 0.95,
      center.dx + (shieldRight - center.dx) * 0.3,
      shieldBottom,
      center.dx,
      shieldBottom + h * 0.05,
    );
    shieldPath.cubicTo(
      center.dx - (shieldRight - center.dx) * 0.3,
      shieldBottom,
      shieldLeft,
      shieldBottom * 0.95,
      shieldLeft,
      shieldTop + (shieldBottom - shieldTop) * 0.55,
    );
    shieldPath.close();

    // Fill shield
    final shieldPaint = Paint()
      ..color = bgNavy
      ..style = PaintingStyle.fill;
    canvas.drawPath(shieldPath, shieldPaint);

    // Shield Gold Border
    final borderPaint = Paint()
      ..color = gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.055
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(shieldPath, borderPaint);

    // 2. Draw 4-Point Star Pinwheel (Compass / Sun Star)
    final starCenter = Offset(w / 2, h / 2);
    final starRadius = w * 0.48;
    final innerR = w * 0.15;

    // Top point
    final topGoldBlade = Path()
      ..moveTo(starCenter.dx, starCenter.dy)
      ..lineTo(starCenter.dx - innerR * 0.8, starCenter.dy - innerR * 0.5)
      ..lineTo(starCenter.dx, starCenter.dy - starRadius)
      ..close();
    canvas.drawPath(topGoldBlade, Paint()..color = goldLight..style = PaintingStyle.fill);

    final topNavyBlade = Path()
      ..moveTo(starCenter.dx, starCenter.dy)
      ..lineTo(starCenter.dx + innerR * 0.4, starCenter.dy - innerR * 0.9)
      ..lineTo(starCenter.dx, starCenter.dy - starRadius)
      ..close();
    canvas.drawPath(topNavyBlade, Paint()..color = const Color(0xFF071738)..style = PaintingStyle.fill);

    // Right point
    final rightGoldBlade = Path()
      ..moveTo(starCenter.dx, starCenter.dy)
      ..lineTo(starCenter.dx + innerR * 0.5, starCenter.dy - innerR * 0.8)
      ..lineTo(starCenter.dx + starRadius, starCenter.dy)
      ..close();
    canvas.drawPath(rightGoldBlade, Paint()..color = gold..style = PaintingStyle.fill);

    final rightNavyBlade = Path()
      ..moveTo(starCenter.dx, starCenter.dy)
      ..lineTo(starCenter.dx + innerR * 0.9, starCenter.dy + innerR * 0.4)
      ..lineTo(starCenter.dx + starRadius, starCenter.dy)
      ..close();
    canvas.drawPath(rightNavyBlade, Paint()..color = const Color(0xFF0A1E45)..style = PaintingStyle.fill);

    // Bottom point
    final bottomGoldBlade = Path()
      ..moveTo(starCenter.dx, starCenter.dy)
      ..lineTo(starCenter.dx + innerR * 0.8, starCenter.dy + innerR * 0.5)
      ..lineTo(starCenter.dx, starCenter.dy + starRadius * 0.95)
      ..close();
    canvas.drawPath(bottomGoldBlade, Paint()..color = goldLight..style = PaintingStyle.fill);

    final bottomNavyBlade = Path()
      ..moveTo(starCenter.dx, starCenter.dy)
      ..lineTo(starCenter.dx - innerR * 0.4, starCenter.dy + innerR * 0.9)
      ..lineTo(starCenter.dx, starCenter.dy + starRadius * 0.95)
      ..close();
    canvas.drawPath(bottomNavyBlade, Paint()..color = const Color(0xFF071738)..style = PaintingStyle.fill);

    // Left point
    final leftGoldBlade = Path()
      ..moveTo(starCenter.dx, starCenter.dy)
      ..lineTo(starCenter.dx - innerR * 0.5, starCenter.dy + innerR * 0.8)
      ..lineTo(starCenter.dx - starRadius, starCenter.dy)
      ..close();
    canvas.drawPath(leftGoldBlade, Paint()..color = gold..style = PaintingStyle.fill);

    final leftNavyBlade = Path()
      ..moveTo(starCenter.dx, starCenter.dy)
      ..lineTo(starCenter.dx - innerR * 0.9, starCenter.dy - innerR * 0.4)
      ..lineTo(starCenter.dx - starRadius, starCenter.dy)
      ..close();
    canvas.drawPath(leftNavyBlade, Paint()..color = const Color(0xFF0A1E45)..style = PaintingStyle.fill);

    // Center pin accent
    canvas.drawCircle(starCenter, w * 0.025, Paint()..color = goldLight);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
