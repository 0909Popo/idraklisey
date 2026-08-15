import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/app_state.dart';
import '../../../data/models/student_model.dart';
import '../../../data/models/attendance_model.dart';

class SmartAttendanceScreen extends StatefulWidget {
  final String? targetClass;
  final String? targetSubject;
  final String? targetTime;

  const SmartAttendanceScreen({
    super.key,
    this.targetClass,
    this.targetSubject,
    this.targetTime,
  });

  @override
  State<SmartAttendanceScreen> createState() => _SmartAttendanceScreenState();
}

class _SmartAttendanceScreenState extends State<SmartAttendanceScreen> with SingleTickerProviderStateMixin {
  Offset _dragOffset = Offset.zero;
  double _dragRotation = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);
      final cls = widget.targetClass ?? (appState.currentTeacherClasses.isNotEmpty ? appState.currentTeacherClasses.first : '9B');
      final sub = widget.targetSubject ?? (appState.currentUser?.subject ?? 'Dərs');
      final tim = widget.targetTime ?? '08:30 - 09:15';
      appState.startAttendanceForLesson(className: cls, subject: sub, time: tim);
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final pendingStudents = appState.pendingAttendanceStudents;
    final sessionAttendance = appState.currentSessionAttendance;

    int presentCount = sessionAttendance.values.where((s) => s == AttendanceStatus.present).length;
    int lateCount = sessionAttendance.values.where((s) => s == AttendanceStatus.late).length;
    int absentCount = sessionAttendance.values.where((s) => s == AttendanceStatus.absent).length;

    final className = appState.currentSessionClass.isNotEmpty ? appState.currentSessionClass : (widget.targetClass ?? '9B Sinfi');
    final subject = appState.currentSessionSubject.isNotEmpty ? appState.currentSessionSubject : (widget.targetSubject ?? 'Dərs');
    final timeStr = widget.targetTime ?? 'Dərs Saatı';

    return Scaffold(
      backgroundColor: const Color(0xFF0C1322),
      appBar: AppBar(
        title: const Text('Smart Davamiyyət (Tinder-Style)'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Sessiyanı Sıfırla',
            onPressed: () {
              appState.resetAttendanceSession();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Class & Live Stats Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF131D33),
              border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$className • $subject',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$timeStr • Canlı Qeydiyyat',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.goldLight, fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildMiniBadge('İ: $presentCount', AppColors.success),
                    const SizedBox(width: 4),
                    _buildMiniBadge('G: $lateCount', AppColors.warning),
                    const SizedBox(width: 4),
                    _buildMiniBadge('Q: $absentCount', AppColors.danger),
                  ],
                ),
              ],
            ),
          ),

          // Gesture Hint Bar (Overflow-proof scrollable)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildGestureHint('⬅️ Sola', 'Qayıb', AppColors.danger),
                  const SizedBox(width: 8),
                  _buildGestureHint('⬆️ Yuxarı', 'Gecikmə', AppColors.warning),
                  const SizedBox(width: 8),
                  _buildGestureHint('➡️ Sağa', 'İştirak', AppColors.success),
                ],
              ),
            ),
          ),

          // Main Swipe Area
          Expanded(
            child: Center(
              child: pendingStudents.isEmpty
                  ? (sessionAttendance.isEmpty
                      ? _buildEmptyClassState(context, className)
                      : _buildCompletedState(context, appState, presentCount, lateCount, absentCount))
                  : Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background Card Placeholder
                        if (pendingStudents.length > 1)
                          _buildBackgroundCard(pendingStudents[1]),

                        // Top Active Swipable Card
                        _buildActiveSwipableCard(context, appState, pendingStudents.first),
                      ],
                    ),
            ),
          ),

          // Bottom Action Bar
          if (pendingStudents.isNotEmpty)
            _buildBottomControls(appState, pendingStudents.first),
        ],
      ),
    );
  }

  Widget _buildEmptyClassState(BuildContext context, String className) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(10),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.group_off_rounded, size: 54, color: AppColors.goldLight),
          ),
          const SizedBox(height: 18),
          Text(
            '$className sinfində hələ heç bir şagird qeydiyyatda deyil.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Məktəb İnzibatçısı (Admin) şagird yaratdıqda və ya sinfi bu qrupa təyin etdikdə avtomatik siyahıda görünəcək.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, fontSize: 12),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            label: const Text('Geri Qayıt', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 11),
      ),
    );
  }

  Widget _buildGestureHint(String action, String meaning, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(action, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
          const SizedBox(width: 4),
          Text('($meaning)', style: const TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildBackgroundCard(StudentProfile student) {
    return Transform.scale(
      scale: 0.94,
      child: Opacity(
        opacity: 0.6,
        child: Container(
          width: 320,
          height: 440,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  student.photoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(
                    color: const Color(0xFF1E293B),
                    child: const Icon(Icons.person_rounded, size: 80, color: Colors.white30),
                  ),
                ),
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black87],
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Text(
                    student.fullName,
                    style: const TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveSwipableCard(BuildContext context, AppState appState, StudentProfile student) {
    Color overlayColor = Colors.transparent;
    String overlayText = '';
    IconData overlayIcon = Icons.check;

    if (_dragOffset.dx > 60) {
      overlayColor = AppColors.success.withAlpha(200);
      overlayText = 'İŞTİRAK EDİR';
      overlayIcon = Icons.check_circle_rounded;
    } else if (_dragOffset.dx < -60) {
      overlayColor = AppColors.danger.withAlpha(200);
      overlayText = 'QAYIB (Yoxdur)';
      overlayIcon = Icons.cancel_rounded;
    } else if (_dragOffset.dy < -60) {
      overlayColor = AppColors.warning.withAlpha(200);
      overlayText = 'GECİKİB';
      overlayIcon = Icons.access_time_filled_rounded;
    }

    final currentMed = appState.getMedicalCardForStudent(student.id);

    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _dragOffset += details.delta;
          _dragRotation = _dragOffset.dx / 300 * 0.3;
        });
      },
      onPanEnd: (details) {
        if (_dragOffset.dx > 100) {
          _handleSwipe(appState, student.id, AttendanceStatus.present);
        } else if (_dragOffset.dx < -100) {
          _handleSwipe(appState, student.id, AttendanceStatus.absent);
        } else if (_dragOffset.dy < -80) {
          _handleSwipe(appState, student.id, AttendanceStatus.late);
        } else {
          setState(() {
            _dragOffset = Offset.zero;
            _dragRotation = 0.0;
          });
        }
      },
      child: Transform.translate(
        offset: _dragOffset,
        child: Transform.rotate(
          angle: _dragRotation,
          child: Container(
            width: 320,
            height: 440,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: overlayColor != Colors.transparent ? overlayColor : Colors.white24,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(120),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Full Card Background Image
                  Image.network(
                    student.photoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(
                      color: const Color(0xFF1E293B),
                      child: const Center(
                        child: Icon(Icons.person_rounded, size: 100, color: Colors.white24),
                      ),
                    ),
                  ),

                  // Bottom Gradient Overlay for text readability
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.35, 0.65, 1.0],
                        colors: [
                          Colors.transparent,
                          Colors.black54,
                          Colors.black87,
                        ],
                      ),
                    ),
                  ),

                  // Bottom Info Section
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (currentMed.allergies.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.danger.withAlpha(220),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.warning_amber_rounded, size: 14, color: Colors.white),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'Allergiya: ${currentMed.allergies.first.name}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        Text(
                          student.fullName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            shadows: [Shadow(color: Colors.black87, blurRadius: 6)],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.goldDark,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                student.className,
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'ID: ${student.studentNumber}',
                              style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Valideyn: ${student.parentName} (${student.parentPhone})',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white60, fontSize: 11),
                        ),
                      ],
                    ),
                  ),

                  // Live Swipe Feedback Overlay
                  if (overlayColor != Colors.transparent)
                    Container(
                      color: overlayColor,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(overlayIcon, size: 64, color: Colors.white),
                            const SizedBox(height: 8),
                            Text(
                              overlayText,
                              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleSwipe(AppState appState, String studentId, AttendanceStatus status) {
    appState.recordSwipeAttendance(studentId, status);
    setState(() {
      _dragOffset = Offset.zero;
      _dragRotation = 0.0;
    });
  }

  Widget _buildBottomControls(AppState appState, StudentProfile student) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(top: BorderSide(color: Color(0xFF1E293B))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Undo Button
          IconButton(
            onPressed: () => appState.undoLastSwipe(),
            icon: const Icon(Icons.undo_rounded, color: Colors.white54, size: 24),
            tooltip: 'Geri Qaytar',
          ),

          // Absent Button (Left Swipe)
          _buildActionButton(
            icon: Icons.close_rounded,
            color: AppColors.danger,
            label: 'Qayıb',
            onTap: () => _handleSwipe(appState, student.id, AttendanceStatus.absent),
          ),

          // Late Button (Up Swipe)
          _buildActionButton(
            icon: Icons.access_time_filled_rounded,
            color: AppColors.warning,
            label: 'Gecikmə',
            onTap: () => _handleSwipe(appState, student.id, AttendanceStatus.late),
          ),

          // Present Button (Right Swipe)
          _buildActionButton(
            icon: Icons.check_rounded,
            color: AppColors.success,
            label: 'İştirak',
            onTap: () => _handleSwipe(appState, student.id, AttendanceStatus.present),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withAlpha(25),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedState(
    BuildContext context,
    AppState appState,
    int present,
    int late,
    int absent,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.success.withAlpha(30),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.success, width: 2),
            ),
            child: const Icon(Icons.done_all_rounded, color: AppColors.success, size: 54),
          ),
          const SizedBox(height: 20),
          const Text(
            'Bütün Sinfin Davamiyyəti Tamamlandı!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'Məlumatlar həm Firestore bulud bazasına, həm də valideyn portallarına canlı sinxronizasiya edilir.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
          const SizedBox(height: 24),

          // Summary Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildResultCard('İştirak', '$present', AppColors.success),
              _buildResultCard('Gecikmə', '$late', AppColors.warning),
              _buildResultCard('Qayıb', '$absent', AppColors.danger),
            ],
          ),

          const SizedBox(height: 32),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
              appState.completeAttendanceSession();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Davamiyyət sessiyası uğurla təsdiqləndi və buluda yazıldı!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            icon: const Icon(Icons.cloud_upload_rounded, color: Colors.white),
            label: const Text('Davamiyyəti Təsdiqlə və Yadda Saxla', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}
