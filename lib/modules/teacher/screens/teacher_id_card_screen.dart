import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/idrak_logo.dart';
import '../../../providers/app_state.dart';

class TeacherIdCardScreen extends StatefulWidget {
  const TeacherIdCardScreen({super.key});

  @override
  State<TeacherIdCardScreen> createState() => _TeacherIdCardScreenState();
}

class _TeacherIdCardScreenState extends State<TeacherIdCardScreen> with SingleTickerProviderStateMixin {
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
    final user = appState.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF070B16),
      appBar: AppBar(
        title: const Text('Rəqəmsal Müəllim Vəsiqəsi'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // Segmented Switcher (Ön / Arxa Tərəf)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(12),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withAlpha(20)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (_showBack) _flipCard();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 9),
                      decoration: BoxDecoration(
                        color: !_showBack ? AppColors.goldDark : Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: !_showBack
                            ? [BoxShadow(color: AppColors.gold.withAlpha(40), blurRadius: 10, offset: const Offset(0, 2))]
                            : [],
                      ),
                      child: Text(
                        'Ön Tərəf',
                        style: TextStyle(
                          color: !_showBack ? Colors.white : Colors.white60,
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (!_showBack) _flipCard();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 9),
                      decoration: BoxDecoration(
                        color: _showBack ? AppColors.goldDark : Colors.transparent,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: _showBack
                            ? [BoxShadow(color: AppColors.gold.withAlpha(40), blurRadius: 10, offset: const Offset(0, 2))]
                            : [],
                      ),
                      child: Text(
                        'Arxa Tərəf',
                        style: TextStyle(
                          color: _showBack ? Colors.white : Colors.white60,
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 3D Flippable Teacher ID Card
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
                            child: _buildCardBack(user),
                          )
                        : _buildCardFront(user),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // NFC / Tap Hint
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(8),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withAlpha(15)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.touch_app_rounded, color: AppColors.goldLight, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Kartın digər üzünə baxmaq üçün üzərinə toxunun',
                    style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 11.5, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Quick Action Buttons
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131B2E),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withAlpha(12)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withAlpha(15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.nfc_rounded, color: AppColors.goldLight, size: 20),
                        ),
                        const SizedBox(height: 8),
                        const Text('NFC Keçid', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text('Turniket aktivdir', style: TextStyle(color: Colors.white.withAlpha(140), fontSize: 10)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131B2E),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withAlpha(12)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.success.withAlpha(15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.verified_rounded, color: AppColors.success, size: 20),
                        ),
                        const SizedBox(height: 8),
                        const Text('Təsdiqlənmiş', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text('Rəsmi vəsiqə', style: TextStyle(color: Colors.white.withAlpha(140), fontSize: 10)),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Additional Info Row
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131B2E),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withAlpha(12)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryAccent.withAlpha(15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.class_rounded, color: AppColors.primaryAccent, size: 20),
                        ),
                        const SizedBox(height: 8),
                        const Text('Siniflər', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(
                          user?.assignedClasses.isNotEmpty == true
                              ? user!.assignedClasses.join(', ')
                              : 'Təyin edilməyib',
                          style: TextStyle(color: Colors.white.withAlpha(140), fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131B2E),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withAlpha(12)),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.goldDark.withAlpha(15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.meeting_room_rounded, color: AppColors.goldDark, size: 20),
                        ),
                        const SizedBox(height: 8),
                        const Text('Kabinet', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(
                          user?.roomNumber ?? 'Qeyd yoxdur',
                          style: TextStyle(color: Colors.white.withAlpha(140), fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- FRONT OF THE CARD ---
  Widget _buildCardFront(dynamic user) {
    final name = user?.fullName ?? 'Müəllim';
    final subject = user?.subject ?? 'Fənn';
    final idrakCode = user?.idrakCode ?? 'IDR-TCH-000';
    final classes = user?.assignedClasses ?? [];
    final photoUrl = user?.photoUrl ?? 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400';
    final qrData = 'IDRAK-TEACHER-$idrakCode-${DateTime.now().year}';

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 380),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1B0B2E),
            Color(0xFF2C1650),
            Color(0xFF172B4D),
            Color(0xFF0A1220),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gold.withAlpha(180), width: 1.8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withAlpha(50),
            blurRadius: 28,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withAlpha(150),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header with Logo and School Info + EMV chip & NFC
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const IdrakLogo(size: 38),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'İDRAK LİSEYİ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        'RƏQƏMSAL MÜƏLLİM VƏSİQƏSİ',
                        style: TextStyle(
                          color: AppColors.goldLight,
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildEmvChip(),
                const SizedBox(width: 6),
                const Icon(Icons.contactless_rounded, color: Colors.white70, size: 18),
              ],
            ),

            const SizedBox(height: 16),
            Divider(color: Colors.white.withAlpha(20), height: 1),
            const SizedBox(height: 16),

            // Teacher Photo & Core Details
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.gold.withAlpha(160), width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withAlpha(30),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      photoUrl,
                      width: 95,
                      height: 115,
                      fit: BoxFit.cover,
                      errorBuilder: (_, e, s) => Container(
                        width: 95,
                        height: 115,
                        color: const Color(0xFF2D1B55),
                        child: const Icon(Icons.person, color: Colors.white54, size: 40),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Subject badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF7C3AED).withAlpha(50),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF7C3AED).withAlpha(100)),
                        ),
                        child: Text(
                          '📚 $subject',
                          style: const TextStyle(
                            color: AppColors.goldLight,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildCardField('İdrak ID', idrakCode),
                      const SizedBox(height: 4),
                      _buildCardField('Tədris İli', '2024-2025'),
                      if (classes.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        _buildCardField('Siniflər', (classes as List).join(', ')),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // QR Code Section for School Turnstile & Access
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(80),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 78.0,
                    padding: EdgeInsets.zero,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: Color(0xFF1A0A2E),
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Color(0xFF1A0A2E),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Turniket & Keçid QR',
                          style: TextStyle(
                            color: Color(0xFF1A0A2E),
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Turniketə və ya müəllimlər otağı skanerinə yaxınlaşdırın.',
                          style: TextStyle(color: Color(0xFF64748B), fontSize: 10, height: 1.3),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Barkod: $idrakCode',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            color: Color(0xFF7C3AED),
                          ),
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
    );
  }

  // --- BACK OF THE CARD ---
  Widget _buildCardBack(dynamic user) {
    final phone = user?.phone ?? '';
    final email = user?.email ?? 'info@idrakliseyi.edu.az';
    final roomNumber = user?.roomNumber ?? 'Qeyd yoxdur';
    final subject = user?.subject ?? 'Fənn';
    final userId = user?.id ?? 'TCH-000';

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 380),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color(0xFF1E293B),
            Color(0xFF0F172A),
            Color(0xFF1A0A2E),
            Color(0xFF0A0F1D),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gold.withAlpha(180), width: 1.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(120),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Magnetic Stripe
          Container(
            margin: const EdgeInsets.only(top: 20),
            height: 40,
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

                const SizedBox(height: 10),

                // Contact & Professional Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(12),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withAlpha(20)),
                  ),
                  child: Column(
                    children: [
                      _buildBackRow('📚 Fənn', subject),
                      const SizedBox(height: 6),
                      _buildBackRow('🏫 Kabinet', roomNumber),
                      const SizedBox(height: 6),
                      _buildBackRow('📞 Əlaqə Nömrəsi', phone.isNotEmpty ? phone : 'Qeyd yoxdur'),
                      const SizedBox(height: 6),
                      _buildBackRow('✉️ E-poçt', email),
                      const SizedBox(height: 6),
                      _buildBackRow('🏢 Ünvan', 'İdrak Liseyi Baş Korpus'),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // Legal & Disclaimer text
                const Text(
                  'Bu vəsiqə İdrak Liseyinin mülkiyyətidir. Yalnız müəllim heyəti tərəfindən istifadə olunmalıdır. Tapıldığı təqdirdə rəhbərliyə təhvil verilməsi xahiş olunur.',
                  style: TextStyle(color: Colors.white54, fontSize: 8.5, height: 1.3),
                ),

                const SizedBox(height: 10),

                // Bottom Official Stamp & Signature
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('RƏSMİ ELEKTRON İMZA', style: TextStyle(color: Colors.white38, fontSize: 7.5, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(userId, style: const TextStyle(color: AppColors.goldLight, fontSize: 9.5, fontFamily: 'monospace')),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.goldLight.withAlpha(60)),
                      ),
                      child: const Text('TƏSDİQ EDİLDİ', style: TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.w900)),
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
          style: const TextStyle(color: Colors.white60, fontSize: 11.5, fontWeight: FontWeight.w500),
        ),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(color: AppColors.goldLight, fontSize: 12.5, fontWeight: FontWeight.w700),
            overflow: TextOverflow.ellipsis,
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
        Flexible(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10.5),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
