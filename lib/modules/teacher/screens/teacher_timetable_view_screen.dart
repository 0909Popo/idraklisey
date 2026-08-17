import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
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
      appBar: AppBar(
        title: const Text('Mənim Dərs Cədvəlim'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Məlumat
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.primary.withAlpha(30),
                  backgroundImage: currentUser.photoUrl != null ? NetworkImage(currentUser.photoUrl!) : null,
                  child: currentUser.photoUrl == null
                      ? Icon(Icons.person_rounded, size: 28, color: AppColors.primary)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentUser.fullName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.goldDark.withAlpha(25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          currentUser.subject ?? 'Müəllim',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.goldDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.success),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.visibility_rounded, color: AppColors.success, size: 16),
                      const SizedBox(width: 4),
                      const Text(
                        'Baxış Rejimi',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Məlumat Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.info.withAlpha(20),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, color: AppColors.info, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Dərs cədvəlinizi yalnız görə bilərsiniz. Admin tərəfindən təyin edilib.',
                    style: TextStyle(fontSize: 11, color: AppColors.info, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          // Days Tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_daysList.length, (index) {
                  final isSelected = _selectedDayIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(_daysList[index]),
                      selected: isSelected,
                      onSelected: (val) {
                        if (val) setState(() => _selectedDayIndex = index);
                      },
                      selectedColor: AppColors.primaryAccent,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                      backgroundColor: AppColors.background,
                      side: BorderSide(color: isSelected ? AppColors.primaryAccent : AppColors.cardBorder),
                    ),
                  );
                }),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Lessons List
          Expanded(
            child: currentDayTimetable.lessons.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_note_rounded, size: 56, color: AppColors.textMuted),
                          const SizedBox(height: 12),
                          Text(
                            '${_daysList[_selectedDayIndex]} gününə dərsiniz yoxdur.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Admin sizə dərs təyin etdikdə avtomatik burada görünəcək.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 4, bottom: 80),
                    itemCount: currentDayTimetable.lessons.length,
                    itemBuilder: (context, index) {
                      final slot = currentDayTimetable.lessons[index];
                      return _buildLessonSlotCard(context, appState, slot, index);
                    },
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
      margin: const EdgeInsets.only(bottom: 12, left: 16, right: 16),
      decoration: BoxDecoration(
        color: isLocked ? AppColors.background : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLocked ? AppColors.cardBorder : color,
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(30),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
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
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left Accent Strip
                  Container(
                    width: 6,
                    color: isLocked ? AppColors.textMuted : color,
                  ),

                  // Card Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: color.withAlpha(20),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      slot.period,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: color,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.schedule_rounded, size: 13, color: AppColors.textSecondary),
                                      const SizedBox(width: 4),
                                      Text(
                                        slot.time,
                                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (isLocked)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.textMuted.withAlpha(40),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.textMuted),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.lock_rounded, color: AppColors.textPrimary, size: 11),
                                      SizedBox(width: 4),
                                      Text(
                                        'Kilidli',
                                        style: TextStyle(color: AppColors.textPrimary, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                )
                              else if (!canAccess)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.warning.withAlpha(40),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.warning),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.timer_rounded, color: AppColors.warning, size: 11),
                                      SizedBox(width: 4),
                                      Text(
                                        'Tezliklə',
                                        style: TextStyle(color: AppColors.warning, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Subject + Icon
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: color.withAlpha(20),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(icon, size: 20, color: color),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      slot.subject,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      'Otaq: ${slot.room}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          if (canAccess && !isLocked) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.success.withAlpha(20),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.success),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.touch_app_rounded, color: AppColors.success, size: 14),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Davamiyyət üçün tıklayın',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.success,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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

  void _showLockedDialog(BuildContext context, LessonSlot slot) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.lock_clock_rounded, color: AppColors.danger),
            SizedBox(width: 8),
            Text('Davamiyyət Kilidlənib', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Bu dərsin (${slot.subject}) davamiyyəti artıq təsdiqlənib və 5 dəqiqə keçdiyi üçün kilidlənib.\n\nDəyişiklik yalnız Admin tərəfindən edilə bilər.',
          style: TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.timer_rounded, color: AppColors.warning),
            SizedBox(width: 8),
            Text('Dərs Saatı Hələ Deyil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Davamiyyət qeydiyyatına dərs saatından 10 dəqiqə əvvəl ($timeStr) daxil ola bilərsiniz.\n\nDərs: ${slot.subject}\nSaat: ${slot.time}',
          style: TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Anladım', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
