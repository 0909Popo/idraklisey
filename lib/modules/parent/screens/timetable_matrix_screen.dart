import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
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
          indicatorColor: AppColors.primaryAccent,
          indicatorWeight: 3,
          labelColor: AppColors.primaryAccent,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
          tabs: days.map((d) => Tab(text: d.shortDay.isNotEmpty ? d.shortDay : d.dayName.substring(0, 3))).toList(),
        ),
      ),
      body: Column(
        children: [
          // Current Selected Day Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryAccent.withAlpha(20),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.calendar_month_outlined, color: AppColors.primaryAccent, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          days[_selectedDayIndex].dayName,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${days[_selectedDayIndex].lessons.length} Dərs Saatı Planlaşdırılıb',
                          style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryAccent.withAlpha(15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primaryAccent.withAlpha(40)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.school_outlined, size: 13, color: AppColors.primaryAccent),
                      const SizedBox(width: 4),
                      Text(
                        className,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: AppColors.primaryAccent),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Timetable Matrix List
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
              Icon(Icons.event_busy_outlined, size: 48, color: AppColors.textMuted),
              const SizedBox(height: 12),
              Text(
                '${day.dayName} üçün dərs cədvəli boşdur',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                'Dərslər əlavə olunduqda burada əks olunacaq.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: day.lessons.length,
      itemBuilder: (context, index) {
        final lesson = day.lessons[index];
        final isCurrent = lesson.isCurrent;
        final color = lesson.subjectColor;
        final icon = lesson.subjectIcon;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isCurrent ? AppColors.primaryAccent : AppColors.cardBorder,
              width: isCurrent ? 1.5 : 1.0,
            ),
            boxShadow: AppShadows.sm,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left Accent Strip
                  Container(
                    width: 5,
                    color: color,
                  ),

                  // Lesson Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                    decoration: BoxDecoration(
                                      color: color.withAlpha(20),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      lesson.period,
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                        color: color,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Row(
                                    children: [
                                      Icon(Icons.schedule_outlined, size: 12, color: AppColors.textSecondary),
                                      const SizedBox(width: 3),
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
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                  decoration: BoxDecoration(
                                    color: AppColors.danger,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.play_circle_filled_rounded, color: Colors.white, size: 11),
                                      SizedBox(width: 3),
                                      Text(
                                        'İNDİ KEÇİRİLİR',
                                        style: TextStyle(color: Colors.white, fontSize: 8.5, fontWeight: FontWeight.w900),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.cardBorder),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.meeting_room_outlined, size: 11, color: AppColors.textSecondary),
                                      const SizedBox(width: 3),
                                      Text(
                                        lesson.room,
                                        style: TextStyle(fontSize: 10.5, color: AppColors.textPrimary, fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: color.withAlpha(20),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(icon, color: color, size: 18),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      lesson.subject,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Icon(Icons.person_outline_rounded, size: 12, color: AppColors.textSecondary),
                                        const SizedBox(width: 3),
                                        Expanded(
                                          child: Text(
                                            lesson.teacher,
                                            style: TextStyle(
                                              fontSize: 11.5,
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
