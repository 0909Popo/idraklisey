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
      backgroundColor: const Color(0xFF070D1B),
      appBar: AppBar(
        title: const Text('Rəqəmsal Müəllim Vəsiqəsi'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // Segmented Switcher (Ön / Arxa Tərəf)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(20),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white24),
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

            const SizedBox(height: 24),

            // NFC / Tap Hint
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(12),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white12),
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

            const SizedBox(height: 24),

            // Quick Action Buttons
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.nfc_rounded, color: AppColors.goldLight, size: 24),
                        SizedBox(height: 6),
                        Text('NFC Keçid', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        Text('Turniket aktivdir', style: TextStyle(color: Colors.white54, fontSize: 10)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.verified_rounded, color: AppColors.success, size: 24),
                        SizedBox(height: 6),
                        Text('Təsdiqlənmiş', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        Text('Rəsmi vəsiqə', style: TextStyle(color: Colors.white54, fontSize: 10)),
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
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.class_rounded, color: AppColors.primaryAccent, size: 24),
                        const SizedBox(height: 6),
                        const Text('Siniflər', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        Text(
                          user?.assignedClasses.isNotEmpty == true
                              ? user!.assignedClasses.join(', ')
                              : 'Təyin edilməyib',
                          style: const TextStyle(color: Colors.white54, fontSize: 10),
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
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.meeting_room_rounded, color: AppColors.goldDark, size: 24),
                        const SizedBox(height: 6),
                        const Text('Kabinet', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        Text(
                          user?.roomNumber ?? 'Qeyd yoxdur',
                          style: const TextStyle(color: Colors.white54, fontSize: 10),
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
            Color(0xFF1A0A2E),
            Color(0xFF2D1B55),
            Color(0xFF1E3A5F),
            Color(0xFF0A1628),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gold, width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D1B55).withAlpha(90),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
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
                        'RƏQƏMSAL MÜƏLLİM VƏSİQƏSİ',
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
                // Teacher Verified Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.goldLight.withAlpha(100)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.school_rounded, color: Colors.white, size: 10),
                      SizedBox(width: 3),
                      Text(
                        'MÜƏLLİM',
                        style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(color: Colors.white24, height: 1),
            const SizedBox(height: 16),

            // Teacher Photo & Core Details
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.gold, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withAlpha(40),
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
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
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
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 85.0,
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
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Turniketə və ya müəllimlər otağı skanerinə yaxınlaşdırın.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 10, height: 1.3),
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
        border: Border.all(color: AppColors.gold, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(120),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
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

            // Contact & Professional Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Column(
                children: [
                  _buildBackRow('📚 Fənn', subject),
                  const SizedBox(height: 8),
                  _buildBackRow('🏫 Kabinet', roomNumber),
                  const SizedBox(height: 8),
                  _buildBackRow('📞 Əlaqə Nömrəsi', phone.isNotEmpty ? phone : 'Qeyd yoxdur'),
                  const SizedBox(height: 8),
                  _buildBackRow('✉️ E-poçt', email),
                  const SizedBox(height: 8),
                  _buildBackRow('🏢 Ünvan', 'İdrak Liseyi Baş Korpus'),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Academic Degree / Permissions info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF7C3AED).withAlpha(20),
                    const Color(0xFF4F46E5).withAlpha(10),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF7C3AED).withAlpha(50)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED).withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.workspace_premium_rounded, color: AppColors.goldLight, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Peşəkar Müəllim Statusu',
                          style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'İdrak Liseyi Tədris Heyəti',
                          style: TextStyle(color: Colors.white54, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Legal & Disclaimer text
            const Text(
              'Bu vəsiqə İdrak Liseyinin mülkiyyətidir. Yalnız müəllim heyəti tərəfindən istifadə olunmalıdır. Tapıldığı təqdirdə liseyin inzibati rəhbərliyinə təhvil verilməsi xahiş olunur.',
              style: TextStyle(color: Colors.white54, fontSize: 9, height: 1.4),
            ),

            const SizedBox(height: 14),

            // Bottom Official Stamp & Signature
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('RƏSMİ ELEKTRON İMZA', style: TextStyle(color: Colors.white38, fontSize: 8, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(userId, style: const TextStyle(color: AppColors.goldLight, fontSize: 10, fontFamily: 'monospace')),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
                    ),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.goldLight.withAlpha(60)),
                  ),
                  child: const Text('TƏSDİQ EDİLDİ', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
                ),
              ],
            ),
          ],
        ),
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
            style: const TextStyle(color: AppColors.goldLight, fontSize: 12, fontWeight: FontWeight.w700),
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
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        Flexible(
          child: Text(
            value,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}
