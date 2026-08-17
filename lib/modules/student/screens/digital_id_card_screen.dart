import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/idrak_logo.dart';
import '../../../providers/app_state.dart';

class DigitalIdCardScreen extends StatefulWidget {
  const DigitalIdCardScreen({super.key});

  @override
  State<DigitalIdCardScreen> createState() => _DigitalIdCardScreenState();
}

class _DigitalIdCardScreenState extends State<DigitalIdCardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  bool _showBack = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_showBack) {
      _animController.reverse();
    } else {
      _animController.forward();
    }
    setState(() {
      _showBack = !_showBack;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final student = appState.student;
    final medCard = appState.medicalCard;

    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      appBar: AppBar(
        title: const Text('Rəqəmsal Şagird Vəsiqəsi'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // Segmented Switcher (Ön / Arxa Tərəf) — frosted glass pill
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(20),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withAlpha(30)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (_showBack) _flipCard();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: !_showBack ? AppColors.primaryAccent : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Text(
                            'Ön Tərəf',
                            style: TextStyle(
                              color: !_showBack ? Colors.white : Colors.white70,
                              fontWeight: FontWeight.w900,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (!_showBack) _flipCard();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: _showBack ? AppColors.primaryAccent : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Text(
                            'Arxa Tərəf (Tibbi)',
                            style: TextStyle(
                              color: _showBack ? Colors.white : Colors.white70,
                              fontWeight: FontWeight.w900,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 3D Animated Flip Card
            GestureDetector(
              onTap: _flipCard,
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  final angle = _animController.value * pi;
                  final isUnder = angle > pi / 2;

                  return Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001) // Perspective
                      ..rotateY(angle),
                    alignment: Alignment.center,
                    child: isUnder
                        ? Transform(
                            transform: Matrix4.identity()..rotateY(pi),
                            alignment: Alignment.center,
                            child: _buildCardBack(context, student, medCard),
                          )
                        : _buildCardFront(context, student),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Tap hint
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.touch_app_rounded, color: Colors.white60, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Kartı çevirmək üçün üzərinə toxunun',
                  style: TextStyle(color: Colors.white.withAlpha(160), fontSize: 12),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Security Information Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(10),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withAlpha(20)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryAccent.withAlpha(30),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.security_rounded, color: AppColors.primaryAccent, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rəsmi İdrak Liseyi Kimliyi',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Bu vəsiqə məktəbə giriş, kitabxana və yeməkxanada etibarlıdır.',
                              style: TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ],
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
    );
  }

  Widget _buildCardFront(BuildContext context, dynamic student) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 380),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1B2E),
            Color(0xFF2E304F),
            Color(0xFF161827),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primaryAccent.withAlpha(120), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryAccent.withAlpha(40),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withAlpha(120),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Holographic sheen effect
          _buildHologramSheen(),

          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header: Logo + Contactless Wave Icon + School Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        IdrakLogo(size: 32),
                        SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'İDRAK LİSEYİ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                              ),
                            ),
                            Text(
                              'BEYNƏLXALQ TƏHSİL MƏKTƏBİ',
                              style: TextStyle(
                                color: AppColors.primaryAccent,
                                fontSize: 7.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Icon(Icons.contactless_rounded, color: Colors.white70, size: 24),
                  ],
                ),

                const SizedBox(height: 14),

                // EMV Chip + Gold Laser Pass Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildEmvChip(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: AppColors.accentGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'STUDENT PASS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Photo + Student Details
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Photo with gold border
                    Container(
                      width: 72,
                      height: 88,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primaryAccent, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(80),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.5),
                        child: Image.network(
                          student.photoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFF1E293B),
                            child: const Icon(Icons.person, color: Colors.white54, size: 36),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 14),

                    // Details Column
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.fullName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _buildCardField('TƏLƏBƏ NO', student.studentNumber),
                          const SizedBox(height: 3),
                          _buildCardField('SİNİF', student.className),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                Divider(color: Colors.white.withAlpha(25), height: 1),
                const SizedBox(height: 10),

                // Bottom QR Code Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TƏSDİQ EDİLMİŞ ŞAGİRD',
                          style: TextStyle(color: AppColors.primaryAccent, fontSize: 8.5, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Etibarlılıq: 2025/2026 Tədris İli',
                          style: TextStyle(color: Colors.white.withAlpha(160), fontSize: 9),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: QrImageView(
                        data: student.studentNumber,
                        version: QrVersions.auto,
                        size: 38,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack(BuildContext context, dynamic student, dynamic medCard) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 380),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF1A1B2E),
            Color(0xFF2E304F),
            Color(0xFF161827),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.primaryAccent.withAlpha(120), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryAccent.withAlpha(40),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withAlpha(120),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          _buildHologramSheen(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Magnetic Stripe
              Container(
                margin: const EdgeInsets.only(top: 18),
                height: 38,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF111111),
                      Color(0xFF222222),
                      Color(0xFF0A0A0A),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Official Header Back
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TƏHLÜKƏSİZLİK VƏ ƏLAQƏ',
                          style: TextStyle(color: AppColors.primaryAccent, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.2),
                        ),
                        Icon(Icons.verified_user_rounded, color: AppColors.primaryAccent, size: 18),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Emergency & Medical Info — dark frosted glass panel
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withAlpha(25)),
                      ),
                      child: Column(
                        children: [
                          _buildBackRow('🩸 Qan Qrupu', medCard.bloodGroup),
                          const SizedBox(height: 6),
                          _buildBackRow('👨‍👩‍👧 Valideyn', student.parentName),
                          const SizedBox(height: 6),
                          _buildBackRow('📞 Təcili Əlaqə', student.parentPhone),
                          const SizedBox(height: 6),
                          _buildBackRow('🏢 Ünvan', 'Bakı şəhəri, İdrak Liseyi'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Legal & Disclaimer text
                    const Text(
                      'Bu vəsiqə İdrak Liseyinin mülkiyyətidir. Tapıldığı təqdirdə liseyin mühafizə xidmətinə təhvil verilməsi xahiş olunur.',
                      style: TextStyle(color: Colors.white54, fontSize: 8.5, height: 1.3),
                    ),

                    const SizedBox(height: 10),

                    // Bottom Signature & Official Stamp
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.primaryAccent.withAlpha(40)),
                        color: Colors.white.withAlpha(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('RƏSMİ ELEKTRON İMZA', style: TextStyle(color: Colors.white38, fontSize: 7.5, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 2),
                              Text(student.id, style: const TextStyle(color: AppColors.primaryAccent, fontSize: 9.5, fontFamily: 'monospace')),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primaryAccent.withAlpha(40),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.primaryAccent),
                            ),
                            child: const Text('TƏSDİQ EDİLDİ', style: TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.w900)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHologramSheen() {
    return Positioned(
      top: -30,
      right: -30,
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppColors.primaryAccent.withAlpha(35),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmvChip() {
    return Container(
      width: 26,
      height: 20,
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
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF8A6A00), width: 0.8),
      ),
      child: Center(
        child: Container(
          width: 18,
          height: 12,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF8A6A00).withAlpha(160), width: 0.5),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildCardField(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w500),
        ),
        Flexible(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _buildBackRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10.5)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10.5)),
      ],
    );
  }
}
