import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../providers/app_state.dart';
import '../../../data/models/user_model.dart';
import 'create_timetable_entry_screen.dart';

class AdminTimetableManagementScreen extends StatefulWidget {
  const AdminTimetableManagementScreen({super.key});

  @override
  State<AdminTimetableManagementScreen> createState() => _AdminTimetableManagementScreenState();
}

class _AdminTimetableManagementScreenState extends State<AdminTimetableManagementScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final teachers = appState.users.where((u) => u.role == UserRole.teacher).toList();
    final classes = appState.allDistinctClasses;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dərs Cədvəli İdarəetməsi'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.gold,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(icon: Icon(Icons.person_rounded), text: 'Müəllim Bazlı'),
            Tab(icon: Icon(Icons.class_rounded), text: 'Sinif Bazlı'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateTimetableEntryScreen(),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Dərs Əlavə Et',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ============ Müəllim Bazlı ============
          _buildTeacherBasedView(appState, teachers),

          // ============ Sinif Bazlı ============
          _buildClassBasedView(appState, classes),
        ],
      ),
    );
  }

  // ============ Müəllim Bazlı Görünüş ============
  Widget _buildTeacherBasedView(AppState appState, List<AppUser> teachers) {
    if (teachers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.psychology_rounded, size: 64, color: AppColors.textMuted),
              const SizedBox(height: 16),
              Text(
                'Hələ heç bir müəllim qeydiyyatda deyil.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Əvvəlcə "İstifadəçi İdarəsi" bölməsindən müəllim yaradın.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 12, bottom: 80),
      itemCount: teachers.length,
      itemBuilder: (context, index) {
        final teacher = teachers[index];
        final timetable = appState.getTeacherTimetable(teacher.id);
        final totalLessons = timetable.fold<int>(0, (sum, day) => sum + day.lessons.length);

        return CustomCard(
          child: InkWell(
            onTap: () => _showTeacherTimetableDetails(context, appState, teacher),
            borderRadius: BorderRadius.circular(16),
            child: Row(
              children: [
                // Profil Fotosu
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primary.withAlpha(30),
                  backgroundImage: teacher.photoUrl != null ? NetworkImage(teacher.photoUrl!) : null,
                  child: teacher.photoUrl == null
                      ? Icon(Icons.person_rounded, size: 32, color: AppColors.primary)
                      : null,
                ),
                const SizedBox(width: 14),

                // Ad və Fənn
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        teacher.fullName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.goldDark.withAlpha(25),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.goldDark.withAlpha(60)),
                            ),
                            child: Text(
                              teacher.subject ?? 'Fənn Yoxdur',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.goldDark,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${teacher.assignedClasses.length} Sinif',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Dərs Sayı
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(20),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary.withAlpha(60)),
                      ),
                      child: Text(
                        '$totalLessons',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Dərs',
                      style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============ Sinif Bazlı Görünüş ============
  Widget _buildClassBasedView(AppState appState, List<String> classes) {
    if (classes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.meeting_room_rounded, size: 64, color: AppColors.textMuted),
              const SizedBox(height: 16),
              Text(
                'Hələ heç bir sinif yaradılmayıb.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '"Sinif İdarəsi" bölməsindən sinif yaradın.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 12, bottom: 80),
      itemCount: classes.length,
      itemBuilder: (context, index) {
        final className = classes[index];
        final timetable = appState.getClassTimetable(className);
        final totalLessons = timetable.fold<int>(0, (sum, day) => sum + day.lessons.length);
        final uniqueTeachers = <String>{};
        for (final day in timetable) {
          for (final lesson in day.lessons) {
            uniqueTeachers.add(lesson.teacher);
          }
        }

        return CustomCard(
          child: InkWell(
            onTap: () => _showClassTimetableDetails(context, appState, className),
            borderRadius: BorderRadius.circular(16),
            child: Row(
              children: [
                // Sinif İkonu
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withAlpha(60)),
                  ),
                  child: Text(
                    className,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Sinif Məlumatı
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$className Sinfi',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${uniqueTeachers.length} Müəllim • $totalLessons Dərs',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),

                // Chevron
                Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============ Müəllim Cədvəl Detayları ============
  void _showTeacherTimetableDetails(BuildContext context, AppState appState, AppUser teacher) {
    final timetable = appState.getTeacherTimetable(teacher.id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle Bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withAlpha(80),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primary.withAlpha(30),
                      backgroundImage: teacher.photoUrl != null ? NetworkImage(teacher.photoUrl!) : null,
                      child: teacher.photoUrl == null
                          ? Icon(Icons.person_rounded, size: 28, color: AppColors.primary)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            teacher.fullName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            teacher.subject ?? 'Fənn Yoxdur',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Divider(color: AppColors.cardBorder, height: 1),

              // Lessons List
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: timetable.length,
                  itemBuilder: (_, dayIndex) {
                    final day = timetable[dayIndex];
                    if (day.lessons.isEmpty) return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8, top: 12),
                          child: Text(
                            day.dayName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        ...day.lessons.map((lesson) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.cardBorder),
                              ),
                              child: Row(
                                children: [
                                  Icon(lesson.subjectIcon, size: 20, color: lesson.subjectColor),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${lesson.time} • ${lesson.period}',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        Text(
                                          lesson.subject,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withAlpha(15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      lesson.room,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============ Sinif Cədvəl Detayları ============
  void _showClassTimetableDetails(BuildContext context, AppState appState, String className) {
    final timetable = appState.getClassTimetable(className);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle Bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted.withAlpha(80),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        className,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$className Sinfi Cədvəli',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),

              Divider(color: AppColors.cardBorder, height: 1),

              // Lessons List
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: timetable.length,
                  itemBuilder: (_, dayIndex) {
                    final day = timetable[dayIndex];
                    if (day.lessons.isEmpty) return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8, top: 12),
                          child: Text(
                            day.dayName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        ...day.lessons.map((lesson) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.cardBorder),
                              ),
                              child: Row(
                                children: [
                                  // Müəllim Fotosu
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: lesson.subjectColor.withAlpha(30),
                                    backgroundImage: lesson.teacherPhotoUrl != null
                                        ? NetworkImage(lesson.teacherPhotoUrl!)
                                        : null,
                                    child: lesson.teacherPhotoUrl == null
                                        ? Icon(Icons.person_rounded, size: 18, color: lesson.subjectColor)
                                        : null,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${lesson.time} • ${lesson.period}',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        Text(
                                          lesson.subject,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          lesson.teacher,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: lesson.subjectColor.withAlpha(20),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      lesson.room,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: lesson.subjectColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
