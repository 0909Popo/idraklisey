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
      backgroundColor: const Color(0xFF070D1B),
      appBar: AppBar(
        title: const Text('Rəqəmsal Şagird Vəsiqəsi'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
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
                            color: !_showBack ? AppColors.gold : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Text(
                            'Ön Tərəf',
                            style: TextStyle(
                              color: !_showBack ? const Color(0xFF0F2552) : Colors.white70,
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
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
                            color: _showBack ? AppColors.gold : Colors.transparent,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Text(
                            'Arxa Tərəf',
                            style: TextStyle(
                              color: _showBack ? const Color(0xFF0F2552) : Colors.white70,
                              fontWeight: FontWeight.w900,
                              fontSize: 13,
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

            // 3D Flippable Student ID Card
            GestureDetector(
              onTap: _flipCard,
              child: AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  final angle = _animController.value * pi;
                  final isUnder = angle > (pi / 2);

                  return Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.0015)
                      ..rotateY(angle),
                    alignment: Alignment.center,
                    child: isUnder
                        ? Transform(
                            transform: Matrix4.identity()..rotateY(pi),
                            alignment: Alignment.center,
                            child: _buildCardBack(student, medCard),
                          )
                        : _buildCardFront(student),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // NFC / Tap Hint — frosted glass pill
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(15),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withAlpha(25)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.touch_app_rounded, color: AppColors.goldLight, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Kartın digər üzünə baxmaq üçün üzərinə toxunun',
                        style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Quick Action Buttons — dark frosted glass
            Row(
              children: [
                Expanded(child: _buildGlassAction(
                  icon: Icons.nfc_rounded,
                  iconColor: AppColors.goldLight,
                  title: 'NFC Keçid',
                  subtitle: 'Turniket aktivdir',
                )),
                const SizedBox(width: 12),
                Expanded(child: _buildGlassAction(
                  icon: Icons.qr_code_scanner_rounded,
                  iconColor: AppColors.success,
                  title: 'Kitabxana Kodu',
                  subtitle: 'Skan üçün hazır',
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Dark frosted-glass quick action button (NFC / Library)
  Widget _buildGlassAction({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withAlpha(25)),
          ),
          child: Column(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(height: 6),
              Text(title, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }

  /// Diagonal light sheen overlay — gives the card a holographic glass feel.
  Widget _buildHologramSheen() {
    return Positioned.fill(
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.25, 0.5, 1.0],
              colors: [
                Colors.white.withAlpha(20),
                Colors.white.withAlpha(4),
                Colors.transparent,
                Colors.white.withAlpha(10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- FRONT OF THE CARD ---
  Widget _buildCardFront(dynamic student) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 380),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0A1628),
            Color(0xFF0F2552),
            Color(0xFF1E3E7B),
            Color(0xFF1D4ED8),
            Color(0xFF0A1935),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gold, width: 2),
        boxShadow: [
          // Gold glow + deep blue drop shadow
          BoxShadow(
            color: AppColors.gold.withAlpha(30),
            blurRadius: 30,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: AppColors.primaryAccent.withAlpha(90),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          _buildHologramSheen(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Header with Logo and School Info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const IdrakLogo(size: 42),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'İDRAK LİSEYİ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
                            ),
                          ),
                          Text(
                            'RƏQƏMSAL TƏLƏBƏ / ŞAGİRD VƏSİQƏSİ',
                            style: TextStyle(
                              color: AppColors.goldLight,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withAlpha(40),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.success),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.circle, color: AppColors.success, size: 8),
                          SizedBox(width: 4),
                          Text(
                            'AKTİV',
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 16),

                // Student Photo & Core Details
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.gold, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withAlpha(40),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          student.photoUrl,
                          width: 100,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student.fullName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Role badge — frosted gold pill
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              gradient: AppColors.goldGradient,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.gold.withAlpha(60),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Text(
                              'Ş A G İ R D',
                              style: TextStyle(
                                color: Color(0xFF0F2552),
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildCardField('Sinfi', student.className),
                          const SizedBox(height: 4),
                          _buildCardField('İdrak ID', student.studentNumber),
                          const SizedBox(height: 4),
                          _buildCardField('Tədris İli', student.academicYear),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // QR Code Section — frosted glass panel over the card gradient
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(235),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withAlpha(80)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          QrImageView(
                            data: student.qrData,
                            version: QrVersions.auto,
                            size: 85.0,
                            eyeStyle: const QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: Color(0xFF0F2552),
                            ),
                            dataModuleStyle: const QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.square,
                              color: Color(0xFF0F2552),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Turniket & Keçid QR',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  'Turniketə və ya kitabxana skanerinə yaxınlaşdırın.',
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 10, height: 1.3),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Barkod: ${student.barcodeData}',
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                    color: AppColors.primary,
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- BACK OF THE CARD ---
  Widget _buildCardBack(dynamic student, dynamic medCard) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 380),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E293B),
            Color(0xFF0A0F1D),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gold, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withAlpha(25),
            blurRadius: 30,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: Colors.black.withAlpha(120),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          _buildHologramSheen(),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Official Header Back
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'TƏHLÜKƏSİZLİK VƏ ƏLAQƏ',
                      style: TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.2),
                    ),
                    Icon(Icons.verified_user_rounded, color: AppColors.goldLight, size: 18),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 12),

                // Emergency & Medical Info — dark frosted glass panel
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(18),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withAlpha(30)),
                      ),
                      child: Column(
                        children: [
                          _buildBackRow('🩸 Qan Qrupu', medCard.bloodGroup),
                          const SizedBox(height: 8),
                          _buildBackRow('👨‍👩‍👧 Valideyn', student.parentName),
                          const SizedBox(height: 8),
                          _buildBackRow('📞 Təcili Əlaqə', student.parentPhone),
                          const SizedBox(height: 8),
                          _buildBackRow('🏢 Ünvan', 'Bakı şəhəri, İdrak Liseyi Baş Korpus'),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Legal & Disclaimer text
                const Text(
                  'Bu vəsiqə İdrak Liseyinin mülkiyyətidir. Tapıldığı təqdirdə liseyin mühafizə xidmətinə və ya rəhbərliyinə təhvil verilməsi xahiş olunur.',
                  style: TextStyle(color: Colors.white54, fontSize: 9, height: 1.4),
                ),

                const SizedBox(height: 14),

                // Bottom Barcode & Official Stamp — gold glow frame
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.goldLight.withAlpha(50)),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        AppColors.goldLight.withAlpha(10),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('RƏSMİ ELEKTRON İMZA', style: TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text(student.id, style: const TextStyle(color: AppColors.goldLight, fontSize: 10, fontFamily: 'monospace')),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryAccent.withAlpha(40),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.primaryAccent),
                        ),
                        child: const Text('TƏSDİQ EDİLDİ', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardField(String label, String value) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: const TextStyle(color: Colors.white60, fontSize: 12, fontWeight: FontWeight.w500),
        ),
        Flexible(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.goldLight, fontSize: 13, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  Widget _buildBackRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
      ],
    );
  }
}
