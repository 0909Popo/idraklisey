import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../providers/app_state.dart';
import '../../../data/models/timetable_model.dart';
import 'smart_attendance_screen.dart';

class TeacherTimetableViewScreen extends StatefulWidget {
  const TeacherTimetableViewScreen({super.key});

  @override
  State<TeacherTimetableViewScreen> createState() => _TeacherTimetableViewScreenState();
}

class _TeacherTimetableViewScreenState extends State<TeacherTimetableViewScreen> {
  int _selectedDayIndex = 0;

  final List<String> _daysList = [
    'Bazar ertəsi',
    'Çərşənbə axşamı',
    'Çərşənbə',
    'Cümə axşamı',
    'Cümə',
  ];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final currentUser = appState.currentUser!;
    final myTimetable = appState.getTeacherTimetable(currentUser.id);

    final currentDayTimetable = myTimetable.firstWhere(
      (d) => d.dayName == _daysList[_selectedDayIndex],
      orElse: () => DayTimetable(dayName: _daysList[_selectedDayIndex], shortDay: '', lessons: []),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Gradient Header ──
          SliverAppBar(
            expandedHeight: 170,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.primary,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1A1B2E), Color(0xFF2D1B69), Color(0xFF7C3AED)],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      bottom: -10,
                      child: Icon(Icons.calendar_month_rounded, size: 140, color: Colors.white.withAlpha(8)),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 44, 20, 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Avatar
                                Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white.withAlpha(40), width: 2),
                                  ),
                                  child: CircleAvatar(
                                    radius: 24,
                                    backgroundColor: Colors.white.withAlpha(20),
                                    backgroundImage: currentUser.photoUrl != null ? NetworkImage(currentUser.photoUrl!) : null,
                                    child: currentUser.photoUrl == null
                                        ? const Icon(Icons.person_rounded, size: 24, color: Colors.white)
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Dərs Cədvəlim',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Row(
                                        children: [
                                          Text(
                                            currentUser.fullName,
                                            style: TextStyle(
                                              color: Colors.white.withAlpha(200),
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.gold.withAlpha(25),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              currentUser.subject ?? 'Müəllim',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.goldLight,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // View-only badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(15),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.white.withAlpha(30)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.visibility_rounded, color: Colors.white.withAlpha(200), size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Baxış',
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white.withAlpha(200)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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

          // ── Info Banner ──
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryAccent.withAlpha(30)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppColors.primaryAccent.withAlpha(15),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: const Icon(Icons.info_outline_rounded, color: AppColors.primaryAccent, size: 14),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Dərs cədvəlinizi yalnız görə bilərsiniz. Admin tərəfindən təyin edilib.',
                      style: TextStyle(fontSize: 11.5, color: AppColors.primaryAccent, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Day Tabs ──
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: List.generate(_daysList.length, (index) {
                    final isSelected = _selectedDayIndex == index;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedDayIndex = index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryAccent : AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? AppColors.primaryAccent : AppColors.cardBorder,
                              width: isSelected ? 1.5 : 1,
                            ),
                            boxShadow: isSelected
                                ? [BoxShadow(color: AppColors.primaryAccent.withAlpha(35), blurRadius: 8, offset: const Offset(0, 2))]
                                : [],
                          ),
                          child: Text(
                            _daysList[index],
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),

          // ── Empty State ──
          if (currentDayTimetable.lessons.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.primaryAccent.withAlpha(8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.event_note_rounded, size: 52, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '${_daysList[_selectedDayIndex]} gününə\ndərsiniz yoxdur.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Admin sizə dərs təyin etdikdə\navtomatik burada görünəcək.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ── Lessons List ──
          if (currentDayTimetable.lessons.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 80),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final slot = currentDayTimetable.lessons[index];
                    return _buildLessonSlotCard(context, appState, slot, index);
                  },
                  childCount: currentDayTimetable.lessons.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLessonSlotCard(BuildContext context, AppState appState, LessonSlot slot, int index) {
    final isLocked = appState.isAttendanceLocked(
      appState.allDistinctClasses.firstWhere(
        (cls) => appState.getClassTimetable(cls).any((day) => day.lessons.any((l) => l == slot)),
        orElse: () => '9B',
      ),
      slot.subject,
    );

    final color = slot.subjectColor;
    final icon = slot.subjectIcon;

    // Dərs saatından 10 dəq əvvəl yoxla
    final now = DateTime.now();
    final startTimeParts = slot.time.split(' - ')[0].split(':');
    final lessonStartTime = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(startTimeParts[0]),
      int.parse(startTimeParts[1]),
    );
    final tenMinBefore = lessonStartTime.subtract(const Duration(minutes: 10));
    final canAccess = now.isAfter(tenMinBefore) || now.isAtSameMomentAs(tenMinBefore);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isLocked ? AppColors.background : AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isLocked ? AppColors.cardBorder : color.withAlpha(60)),
        boxShadow: isLocked ? [] : AppShadows.sm,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            if (isLocked) {
              _showLockedDialog(context, slot);
              return;
            }

            if (!canAccess) {
              _showEarlyAccessDialog(context, slot, tenMinBefore);
              return;
            }

            // Sinfin adını tap
            String targetClass = '9B';
            for (final cls in appState.allDistinctClasses) {
              final timetable = appState.getClassTimetable(cls);
              for (final day in timetable) {
                if (day.lessons.contains(slot)) {
                  targetClass = cls;
                  break;
                }
              }
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SmartAttendanceScreen(
                  targetClass: targetClass,
                  targetSubject: slot.subject,
                  targetTime: slot.time,
                ),
              ),
            );
          },
          child: Column(
            children: [
              // ── Color accent top bar ──
              Container(
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isLocked
                        ? [AppColors.textMuted.withAlpha(60), AppColors.textMuted.withAlpha(30)]
                        : [color, color.withAlpha(100)],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Top Row: Period + Time + Status ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: color.withAlpha(15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: color.withAlpha(40)),
                              ),
                              child: Text(
                                slot.period,
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.schedule_rounded, size: 13, color: AppColors.textMuted),
                            const SizedBox(width: 4),
                            Text(
                              slot.time,
                              style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        if (isLocked)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.textMuted.withAlpha(15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.textMuted.withAlpha(50)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.lock_rounded, color: AppColors.textSecondary, size: 11),
                                const SizedBox(width: 4),
                                Text('Kilidli', style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          )
                        else if (!canAccess)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withAlpha(12),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.warning.withAlpha(50)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.timer_rounded, color: AppColors.warning, size: 11),
                                const SizedBox(width: 4),
                                Text('Tezliklə', style: TextStyle(color: AppColors.warning, fontSize: 10, fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ── Subject Row ──
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isLocked ? AppColors.textMuted.withAlpha(10) : color.withAlpha(12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isLocked ? AppColors.cardBorder : color.withAlpha(30)),
                          ),
                          child: Icon(icon, size: 20, color: isLocked ? AppColors.textMuted : color),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                slot.subject,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: isLocked ? AppColors.textMuted : AppColors.textPrimary,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(Icons.door_back_door_outlined, size: 12, color: AppColors.textMuted),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Otaq: ${slot.room}',
                                    style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // ── Attendance CTA ──
                    if (canAccess && !isLocked) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppColors.success.withAlpha(10),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.success.withAlpha(40)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.touch_app_rounded, color: AppColors.success, size: 14),
                            const SizedBox(width: 6),
                            const Text(
                              'Davamiyyət üçün tıklayın',
                              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.success),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppColors.success),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLockedDialog(BuildContext context, LessonSlot slot) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.danger.withAlpha(12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.lock_clock_rounded, color: AppColors.danger, size: 18),
            ),
            const SizedBox(width: 10),
            const Text('Davamiyyət Kilidlənib', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ],
        ),
        content: Text(
          'Bu dərsin (${slot.subject}) davamiyyəti artıq təsdiqlənib və 5 dəqiqə keçdiyi üçün kilidlənib.\n\nDəyişiklik yalnız Admin tərəfindən edilə bilər.',
          style: TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.45),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Anladım', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEarlyAccessDialog(BuildContext context, LessonSlot slot, DateTime tenMinBefore) {
    final timeStr = '${tenMinBefore.hour.toString().padLeft(2, '0')}:${tenMinBefore.minute.toString().padLeft(2, '0')}';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.warning.withAlpha(12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.timer_rounded, color: AppColors.warning, size: 18),
            ),
            const SizedBox(width: 10),
            const Text('Dərs Saatı Hələ Deyil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ],
        ),
        content: Text(
          'Davamiyyət qeydiyyatına dərs saatından 10 dəqiqə əvvəl ($timeStr) daxil ola bilərsiniz.\n\nDərs: ${slot.subject}\nSaat: ${slot.time}',
          style: TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.45),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Anladım', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
