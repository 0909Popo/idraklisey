import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
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
        elevation: 0,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.gold,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          tabs: const [
            Tab(icon: Icon(Icons.psychology_rounded, size: 18), text: 'Müəllim Bazlı'),
            Tab(icon: Icon(Icons.school_rounded, size: 18), text: 'Sinif Bazlı'),
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
        backgroundColor: AppColors.primaryAccent,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Dərs Əlavə Et',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
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
          padding: const EdgeInsets.all(36),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent.withAlpha(10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.psychology_rounded, size: 54, color: AppColors.primaryAccent),
              ),
              const SizedBox(height: 18),
              Text(
                'Hələ heç bir müəllim qeydiyyatda deyil.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Əvvəlcə "İstifadəçi İdarəsi" bölməsindən müəllim yaradın.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      itemCount: teachers.length,
      itemBuilder: (context, index) {
        final teacher = teachers[index];
        final timetable = appState.getTeacherTimetable(teacher.id);
        final totalLessons = timetable.fold<int>(0, (sum, day) => sum + day.lessons.length);

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: AppShadows.sm,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showTeacherTimetableDetails(context, appState, teacher),
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    // Profile Photo with border
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primaryAccent.withAlpha(30)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(13),
                        child: Container(
                          width: 54,
                          height: 54,
                          color: AppColors.primaryAccent.withAlpha(12),
                          child: teacher.photoUrl != null
                              ? Image.network(
                                  teacher.photoUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.person_rounded, size: 26, color: AppColors.primaryAccent),
                                )
                              : const Icon(Icons.person_rounded, size: 26, color: AppColors.primaryAccent),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Name and Subject
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
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.goldDark.withAlpha(15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.goldDark.withAlpha(40)),
                                ),
                                child: Text(
                                  teacher.subject ?? 'Fənn Yoxdur',
                                  style: const TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.goldDark,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${teacher.assignedClasses.length} Sinif',
                                style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Total lessons badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryAccent.withAlpha(12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.primaryAccent.withAlpha(30)),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$totalLessons',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryAccent,
                            ),
                          ),
                          Text(
                            'Dərs',
                            style: TextStyle(fontSize: 9.5, color: AppColors.primaryAccent.withAlpha(180), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
          padding: const EdgeInsets.all(36),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent.withAlpha(10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.meeting_room_rounded, size: 54, color: AppColors.primaryAccent),
              ),
              const SizedBox(height: 18),
              Text(
                'Hələ heç bir sinif yaradılmayıb.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                '"Sinif İdarəsi" bölməsindən sinif yaradın.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
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

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: AppShadows.sm,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showClassTimetableDetails(context, appState, className),
              borderRadius: BorderRadius.circular(18),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    // Class Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryAccent.withAlpha(12),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.primaryAccent.withAlpha(30)),
                      ),
                      child: Text(
                        className,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryAccent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Class info
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
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${uniqueTeachers.length} Müəllim • $totalLessons Dərs',
                            style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),

                    // Chevron
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.cardBorder.withAlpha(60),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
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
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Handle Bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: AppColors.primaryAccent.withAlpha(20),
                          backgroundImage: teacher.photoUrl != null ? NetworkImage(teacher.photoUrl!) : null,
                          child: teacher.photoUrl == null
                              ? const Icon(Icons.person_rounded, size: 22, color: AppColors.primaryAccent)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              teacher.fullName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.2,
                              ),
                            ),
                            Text(
                              teacher.subject ?? 'Fənn Yoxdur',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.cardBorder.withAlpha(80),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.close_rounded, size: 18),
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
                  physics: const BouncingScrollPhysics(),
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
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryAccent,
                            ),
                          ),
                        ),
                        ...day.lessons.map((lesson) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.cardBorder),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: lesson.subjectColor.withAlpha(15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(lesson.subjectIcon, size: 18, color: lesson.subjectColor),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${lesson.time} • ${lesson.period}',
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
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
                                      color: AppColors.primaryAccent.withAlpha(12),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      lesson.room,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primaryAccent,
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
        initialChildSize: 0.75,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, scrollController) => Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Handle Bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primaryAccent.withAlpha(15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            className,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryAccent,
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
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.cardBorder.withAlpha(80),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.close_rounded, size: 18),
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
                  physics: const BouncingScrollPhysics(),
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
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryAccent,
                            ),
                          ),
                        ),
                        ...day.lessons.map((lesson) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.cardBorder),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: lesson.subjectColor.withAlpha(20),
                                    backgroundImage: lesson.teacherPhotoUrl != null
                                        ? NetworkImage(lesson.teacherPhotoUrl!)
                                        : null,
                                    child: lesson.teacherPhotoUrl == null
                                        ? Icon(Icons.person_rounded, size: 16, color: lesson.subjectColor)
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
                                            fontWeight: FontWeight.w700,
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
                                      color: lesson.subjectColor.withAlpha(15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      lesson.room,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
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
