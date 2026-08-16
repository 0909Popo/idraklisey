import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/app_state.dart';
import '../../../data/models/timetable_model.dart';

class TimetableMatrixScreen extends StatefulWidget {
  const TimetableMatrixScreen({super.key});

  @override
  State<TimetableMatrixScreen> createState() => _TimetableMatrixScreenState();
}

class _TimetableMatrixScreenState extends State<TimetableMatrixScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedDayIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {
          _selectedDayIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final days = appState.weeklyTimetable;
    final currentStudent = appState.student;
    final className = currentStudent.className.isNotEmpty ? currentStudent.className : '9B';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Dərs Cədvəli ($className)'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          indicatorColor: AppColors.gold,
          indicatorWeight: 3.5,
          labelColor: AppColors.goldLight,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
          tabs: days.map((d) => Tab(text: d.shortDay.isNotEmpty ? d.shortDay : d.dayName.substring(0, 3))).toList(),
        ),
      ),
      body: Column(
        children: [
          // Current Selected Day Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(8),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(50),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          days[_selectedDayIndex].dayName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${days[_selectedDayIndex].lessons.length} Dərs Saatı Planlaşdırılıb',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primaryAccent.withAlpha(60)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.school_rounded, size: 14, color: AppColors.primaryAccent),
                      const SizedBox(width: 4),
                      Text(
                        className,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryAccent),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Timetable Matrix List / Grid
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: days.map((day) => _buildDaySchedule(day, className)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaySchedule(DayTimetable day, String className) {
    if (day.lessons.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.event_busy_rounded, size: 48, color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              Text(
                '${day.dayName} üçün dərs cədvəli boşdur',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              Text(
                'Müəllimlər və məktəb rəhbərliyi tərəfindən dərslər əlavə olunduqda burada əks olunacaq.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 12, bottom: 24, left: 16, right: 16),
      itemCount: day.lessons.length,
      itemBuilder: (context, index) {
        final lesson = day.lessons[index];
        final isCurrent = lesson.isCurrent;
        final color = lesson.subjectColor;
        final icon = lesson.subjectIcon;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCurrent ? color : AppColors.cardBorder,
              width: isCurrent ? 2.0 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isCurrent ? color.withAlpha(35) : Colors.black.withAlpha(8),
                blurRadius: isCurrent ? 12 : 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left Accent Strip with Subject Color
                  Container(
                    width: 6,
                    color: color,
                  ),

                  // Lesson Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Row: Period badge + Live indicator + Room
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
                                      lesson.period,
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
                                        lesson.time,
                                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (isCurrent)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.play_circle_filled_rounded, color: Colors.white, size: 12),
                                      SizedBox(width: 4),
                                      Text(
                                        'İNDİ KEÇİRİLİR',
                                        style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.cardBorder),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.meeting_room_outlined, size: 12, color: AppColors.textSecondary),
                                      const SizedBox(width: 4),
                                      Text(
                                        lesson.room,
                                        style: TextStyle(fontSize: 11, color: AppColors.textPrimary, fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Subject Title with Subject Icon
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: color.withAlpha(25),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(icon, color: color, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      lesson.subject,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Row(
                                      children: [
                                        Icon(Icons.person_outline_rounded, size: 13, color: AppColors.textSecondary),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            lesson.teacher,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textSecondary,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
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
        );
      },
    );
  }
}
