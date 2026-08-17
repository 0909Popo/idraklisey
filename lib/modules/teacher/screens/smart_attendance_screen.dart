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

  // Helper: Gün adından weekday tap
  int? _getDayOfWeekFromName(String dayName) {
    switch (dayName) {
      case 'Bazar ertəsi':
        return 1; // Monday
      case 'Çərşənbə axşamı':
        return 2; // Tuesday
      case 'Çərşənbə':
        return 3; // Wednesday
      case 'Cümə axşamı':
        return 4; // Thursday
      case 'Cümə':
        return 5; // Friday
      default:
        return null;
    }
  }

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

    // ✅ YENİ: 10 Dəqiqə Əvvəl Yoxlaması (GÜN DƏSTƏYİ)
    bool canAccessAttendance = true;
    String? blockMessage;
    
    // Dərsin hansı gündə olduğunu tap (cədvəldən)
    int? lessonDayOfWeek;
    
    // Cədvəldən dərsin hansı gündə olduğunu tapırıq
    final allClasses = appState.allDistinctClasses;
    for (final cls in allClasses) {
      final timetable = appState.getClassTimetable(cls);
      for (final day in timetable) {
        for (final lesson in day.lessons) {
          if (lesson.time == widget.targetTime && lesson.subject == subject) {
            // Günü tap
            lessonDayOfWeek = _getDayOfWeekFromName(day.dayName);
            break;
          }
        }
        if (lessonDayOfWeek != null) break;
      }
      if (lessonDayOfWeek != null) break;
    }
    
    if (widget.targetTime != null && widget.targetTime!.contains(' - ')) {
      final timeParts = widget.targetTime!.split(' - ');
      final startTimeParts = timeParts[0].trim().split(':');
      
      if (startTimeParts.length == 2) {
        final now = DateTime.now();
        final startHour = int.tryParse(startTimeParts[0]);
        final startMin = int.tryParse(startTimeParts[1]);
        
        if (startHour != null && startMin != null) {
          // Dərsin tam tarixini hesabla
          DateTime lessonStartTime;
          
          if (lessonDayOfWeek != null) {
            // Bu həftə və ya növbəti həftə
            final currentDayOfWeek = now.weekday; // 1=Bazar ertəsi, 7=Bazar
            int daysUntilLesson = lessonDayOfWeek - currentDayOfWeek;
            
            if (daysUntilLesson < 0) {
              daysUntilLesson += 7; // Növbəti həftə
            } else if (daysUntilLesson == 0) {
              // Bu gün - saata bax
              lessonStartTime = DateTime(now.year, now.month, now.day, startHour, startMin);
              if (now.isAfter(lessonStartTime)) {
                daysUntilLesson = 7; // Növbəti həftə eyni gün
              }
            }
            
            lessonStartTime = DateTime(
              now.year,
              now.month,
              now.day + daysUntilLesson,
              startHour,
              startMin,
            );
          } else {
            // Gün məlumatı yoxdursa, bu günə görə hesabla (köhnə metod)
            lessonStartTime = DateTime(now.year, now.month, now.day, startHour, startMin);
          }
          
          final tenMinBefore = lessonStartTime.subtract(const Duration(minutes: 10));
          
          if (now.isBefore(tenMinBefore)) {
            canAccessAttendance = false;
            final diffMinutes = tenMinBefore.difference(now).inMinutes;
            final diffHours = diffMinutes ~/ 60;
            final diffDays = diffHours ~/ 24;
            final remainingHours = diffHours % 24;
            final remainingMinutes = diffMinutes % 60;
            
            if (diffDays > 0) {
              blockMessage = 'Davamiyyət qeydiyyatına daha $diffDays gün $remainingHours saat var.\n\n'
                  'Dərs ${lessonStartTime.day}.${lessonStartTime.month} - ${lessonStartTime.hour.toString().padLeft(2, '0')}:${lessonStartTime.minute.toString().padLeft(2, '0')}-da başlayacaq.\n\n'
                  '10 dəqiqə əvvəl (${tenMinBefore.hour.toString().padLeft(2, '0')}:${tenMinBefore.minute.toString().padLeft(2, '0')}) giriş açılacaq.';
            } else if (remainingHours > 0) {
              blockMessage = 'Davamiyyət qeydiyyatına daha $remainingHours saat $remainingMinutes dəqiqə var.\n\n'
                  'Dərs saatından 10 dəqiqə əvvəl (${tenMinBefore.hour.toString().padLeft(2, '0')}:${tenMinBefore.minute.toString().padLeft(2, '0')}) '
                  'giriş açılacaq.';
            } else {
              blockMessage = 'Davamiyyət qeydiyyatına daha $diffMinutes dəqiqə var.\n\n'
                  'Dərs saatından 10 dəqiqə əvvəl (${tenMinBefore.hour.toString().padLeft(2, '0')}:${tenMinBefore.minute.toString().padLeft(2, '0')}) '
                  'giriş açılacaq.';
            }
          }
        }
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B0E1A),
      body: Column(
        children: [
          // ── Premium Dark Header ──
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              right: 16,
              bottom: 12,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F1023), Color(0xFF1A1B2E)],
              ),
              border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
            ),
            child: Column(
              children: [
                // Top bar with back & reset
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white),
                      ),
                    ),
                    const Text(
                      'Smart Davamiyyət',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: -0.3),
                    ),
                    GestureDetector(
                      onTap: () => appState.resetAttendanceSession(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(10),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.refresh_rounded, size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Class info & live stats
                Row(
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
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(Icons.schedule_rounded, size: 12, color: AppColors.goldLight.withAlpha(180)),
                              const SizedBox(width: 4),
                              Text(
                                '$timeStr • Canlı Qeydiyyat',
                                style: TextStyle(color: AppColors.goldLight.withAlpha(180), fontSize: 11, fontWeight: FontWeight.w500),
                              ),
                            ],
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
              ],
            ),
          ),

          // ── Gesture Hints ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: const Color(0xFF0B0E1A),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
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

          // ── Main Swipe Area ──
          Expanded(
            child: Center(
              child: !canAccessAttendance
                  ? _buildBlockedAccessState(context, blockMessage ?? 'Dərs saatına hələ vaxt var.')
                  : (pendingStudents.isEmpty
                      ? (sessionAttendance.isEmpty
                          ? _buildEmptyClassState(context, className)
                          : _buildCompletedState(context, appState, presentCount, lateCount, absentCount))
                      : Stack(
                          alignment: Alignment.center,
                          children: [
                            // Background Card
                            if (pendingStudents.length > 1)
                              _buildBackgroundCard(pendingStudents[1]),
                            // Active Swipable Card
                            _buildActiveSwipableCard(context, appState, pendingStudents.first),
                          ],
                        )),
            ),
          ),

          // ── Bottom Action Bar ──
          if (pendingStudents.isNotEmpty && canAccessAttendance)
            _buildBottomControls(appState, pendingStudents.first),
        ],
      ),
    );
  }

  Widget _buildEmptyClassState(BuildContext context, String className) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.goldLight.withAlpha(10),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.goldLight.withAlpha(30)),
            ),
            child: const Icon(Icons.group_off_rounded, size: 52, color: AppColors.goldLight),
          ),
          const SizedBox(height: 20),
          Text(
            '$className sinfində hələ heç bir\nşagird qeydiyyatda deyil.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          const Text(
            'Məktəb İnzibatçısı (Admin) şagird yaratdıqda və ya sinfi bu qrupa təyin etdikdə avtomatik siyahıda görünəcək.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.5),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryAccent,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 18),
            label: const Text('Geri Qayıt', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockedAccessState(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.warning.withAlpha(15),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.warning.withAlpha(40), width: 2),
            ),
            child: const Icon(Icons.timer_rounded, size: 60, color: AppColors.warning),
          ),
          const SizedBox(height: 24),
          const Text(
            'Dərs Saatı Hələ Başlamayıb',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.3),
          ),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A5F).withAlpha(60),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF3B82F6).withAlpha(40)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withAlpha(20),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: const Icon(Icons.info_outline_rounded, color: Color(0xFF60A5FA), size: 16),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Davamiyyət qeydiyyatı yalnız dərs saatından 10 dəqiqə əvvəl aktivləşir.',
                    style: TextStyle(color: Color(0xFF93C5FD), fontSize: 11.5, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryAccent,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 18),
            label: const Text('Geri Qayıt', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(50)),
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
        color: color.withAlpha(12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(action, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(width: 4),
          Text('($meaning)', style: TextStyle(color: Colors.white.withAlpha(140), fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildBackgroundCard(StudentProfile student) {
    return Transform.scale(
      scale: 0.94,
      child: Opacity(
        opacity: 0.5,
        child: Container(
          width: 320,
          height: 440,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withAlpha(8)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  student.photoUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(
                    color: const Color(0xFF1E293B),
                    child: const Icon(Icons.person_rounded, size: 80, color: Colors.white24),
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
                  left: 18,
                  right: 18,
                  bottom: 18,
                  child: Text(
                    student.fullName,
                    style: const TextStyle(color: Colors.white60, fontSize: 18, fontWeight: FontWeight.w700),
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
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: overlayColor != Colors.transparent ? overlayColor : Colors.white.withAlpha(15),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(100),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
                if (overlayColor != Colors.transparent)
                  BoxShadow(
                    color: overlayColor.withAlpha(40),
                    blurRadius: 30,
                    spreadRadius: 4,
                  ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
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

                  // Bottom Gradient Overlay
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.3, 0.6, 1.0],
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
                    left: 18,
                    right: 18,
                    bottom: 18,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (currentMed.allergies.isNotEmpty) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.danger.withAlpha(210),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.warning_amber_rounded, size: 13, color: Colors.white),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    'Allergiya: ${currentMed.allergies.first.name}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w700),
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
                            letterSpacing: -0.3,
                            shadows: [Shadow(color: Colors.black87, blurRadius: 8)],
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primaryAccent.withAlpha(180),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                student.className,
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'ID: ${student.studentNumber}',
                              style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Valideyn: ${student.parentName} (${student.parentPhone})',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white.withAlpha(140), fontSize: 11),
                        ),
                      ],
                    ),
                  ),

                  // Live Swipe Feedback Overlay
                  if (overlayColor != Colors.transparent)
                    Container(
                      decoration: BoxDecoration(
                        color: overlayColor,
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(overlayIcon, size: 64, color: Colors.white),
                            const SizedBox(height: 8),
                            Text(
                              overlayText,
                              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 0.5),
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0F1023), Color(0xFF1A1B2E)],
        ),
        border: Border(top: BorderSide(color: Colors.white.withAlpha(8))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Undo
            GestureDetector(
              onTap: () => appState.undoLastSwipe(),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withAlpha(15)),
                ),
                child: const Icon(Icons.undo_rounded, color: Colors.white54, size: 20),
              ),
            ),

            // Absent
            _buildActionButton(
              icon: Icons.close_rounded,
              color: AppColors.danger,
              label: 'Qayıb',
              onTap: () => _handleSwipe(appState, student.id, AttendanceStatus.absent),
            ),

            // Late
            _buildActionButton(
              icon: Icons.access_time_filled_rounded,
              color: AppColors.warning,
              label: 'Gecikmə',
              onTap: () => _handleSwipe(appState, student.id, AttendanceStatus.late),
            ),

            // Present
            _buildActionButton(
              icon: Icons.check_rounded,
              color: AppColors.success,
              label: 'İştirak',
              onTap: () => _handleSwipe(appState, student.id, AttendanceStatus.present),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(60), width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 12),
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
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.success.withAlpha(15),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.success.withAlpha(40), width: 2),
            ),
            child: const Icon(Icons.done_all_rounded, color: AppColors.success, size: 52),
          ),
          const SizedBox(height: 22),
          const Text(
            'Bütün Sinfin Davamiyyəti\nTamamlandı!',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: -0.3),
          ),
          const SizedBox(height: 8),
          const Text(
            'Məlumatlar həm Firestore bulud bazasına, həm də\nvalideyn portallarına canlı sinxronizasiya edilir.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.5),
          ),
          const SizedBox(height: 28),

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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
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
            icon: const Icon(Icons.cloud_upload_rounded, color: Colors.white, size: 18),
            label: const Text(
              'Davamiyyəti Təsdiqlə və Yadda Saxla',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: color.withAlpha(12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(40)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: color, fontSize: 26, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.white.withAlpha(160), fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
