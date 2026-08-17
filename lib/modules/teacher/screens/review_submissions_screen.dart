import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../providers/app_state.dart';
import '../../../data/models/assignment_model.dart';
import '../../../data/models/student_model.dart';
import 'create_assignment_screen.dart';

class ReviewSubmissionsScreen extends StatefulWidget {
  const ReviewSubmissionsScreen({super.key});

  @override
  State<ReviewSubmissionsScreen> createState() => _ReviewSubmissionsScreenState();
}

class _ReviewSubmissionsScreenState extends State<ReviewSubmissionsScreen> {
  int _filterIndex = 0; // 0: Hamısı, 1: Təhvil Verilənlər, 2: Yoxlanılanlar, 3: Gözləmədə

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final allAssignments = appState.currentTeacherAssignments;
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

    final filtered = allAssignments.where((a) {
      if (_filterIndex == 1) return a.submittedCount > 0;
      if (_filterIndex == 2) return a.gradedCount > 0;
      if (_filterIndex == 3) return a.totalSubmissionsCount == 0;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Gradient Header ──
          SliverAppBar(
            expandedHeight: 140,
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
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add_task_rounded, size: 18, color: Colors.white),
                  ),
                  tooltip: 'Yeni Tapşırıq Əlavə Et',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CreateAssignmentScreen()),
                    );
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1A1B2E), Color(0xFF2D1B69), Color(0xFF6C5CE7)],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -15,
                      bottom: -15,
                      child: Icon(Icons.rate_review_rounded, size: 130, color: Colors.white.withAlpha(10)),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 44, 20, 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(20),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.fact_check_rounded, size: 22, color: Colors.white),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Tapşırıq Yoxlanışı',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${allAssignments.length} aktiv tapşırıq monitorinqi',
                                      style: TextStyle(
                                        color: Colors.white.withAlpha(180),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
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

          // ── Filter Chips ──
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildFilterChip(0, 'Hamısı (${allAssignments.length})'),
                    _buildFilterChip(1, '📥 Təhvil Var (${allAssignments.where((a) => a.submittedCount > 0).length})'),
                    _buildFilterChip(2, '✅ Yoxlanılanlar (${allAssignments.where((a) => a.gradedCount > 0).length})'),
                    _buildFilterChip(3, '⏳ Təhvil Yoxdur (${allAssignments.where((a) => a.totalSubmissionsCount == 0).length})'),
                  ],
                ),
              ),
            ),
          ),

          // ── Empty / List Content ──
          if (allAssignments.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(36),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.primaryAccent.withAlpha(10),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.assignment_add, size: 54, color: AppColors.primaryAccent),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Hələ heç bir dərs tapşırığı\nverilməyib',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Şagirdlərə fənniniz üzrə ev tapşırığı, məsələ və ya mövzu təyin etmək üçün düyməyə klikləyin.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.5),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CreateAssignmentScreen()),
                          );
                        },
                        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                        label: const Text('İlk Tapşırığı Təyin Et', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (filtered.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primaryAccent.withAlpha(8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.filter_alt_off_rounded, size: 44, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 14),
                    Text('Bu filtr üzrə tapşırıq tapılmadı.', style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final a = filtered[index];
                    return _buildAssignmentReviewCard(context, appState, a, dateFormat);
                  },
                  childCount: filtered.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateAssignmentScreen()),
          );
        },
        backgroundColor: AppColors.primaryAccent,
        icon: const Icon(Icons.add_task_rounded, color: Colors.white),
        label: const Text('Yeni Tapşırıq Ver', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildFilterChip(int index, String label) {
    final isSelected = _filterIndex == index;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _filterIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryAccent : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primaryAccent : AppColors.cardBorder,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? [BoxShadow(color: AppColors.primaryAccent.withAlpha(30), blurRadius: 6, offset: const Offset(0, 2))]
                : [],
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Color _getSubjectColor(String subject) {
    final s = subject.toLowerCase();
    if (s.contains('riyaziyyat') || s.contains('cəbr') || s.contains('həndəsə')) {
      return const Color(0xFF2563EB);
    } else if (s.contains('fizika')) {
      return const Color(0xFF0284C7);
    } else if (s.contains('kimya')) {
      return const Color(0xFF7C3AED);
    } else if (s.contains('biologiya') || s.contains('həyat bilgisi') || s.contains('təbiət')) {
      return const Color(0xFF059669);
    } else if (s.contains('ingilis') || s.contains('rus') || s.contains('alman') || s.contains('xarici dil')) {
      return const Color(0xFFD97706);
    } else if (s.contains('tarix') || s.contains('zəfər')) {
      return const Color(0xFFE11D48);
    } else if (s.contains('azərbaycan') || s.contains('ədəbiyyat')) {
      return const Color(0xFF1D4ED8);
    } else if (s.contains('informatika') || s.contains('rəqəmsal')) {
      return const Color(0xFF4F46E5);
    }
    return const Color(0xFF1E3A8A);
  }

  Widget _buildAssignmentReviewCard(BuildContext context, AppState appState, HomeworkAssignment a, DateFormat dateFormat) {
    final List<StudentProfile> targetStudents;
    if (a.assignedStudentIds.isNotEmpty) {
      targetStudents = appState.students.where((s) => a.assignedStudentIds.contains(s.id)).toList();
    } else if (a.assignedClass != null && a.assignedClass!.isNotEmpty && a.assignedClass!.toLowerCase() != 'hamısı') {
      targetStudents = appState.getStudentsForClass(a.assignedClass!);
    } else {
      targetStudents = appState.students;
    }

    final totalTarget = targetStudents.length;
    final totalSubmitted = a.totalSubmissionsCount;
    final gradedCount = a.gradedCount;
    final pendingReviewCount = a.submittedCount;
    final color = _getSubjectColor(a.subject);
    final progress = totalTarget > 0 ? (totalSubmitted / totalTarget) : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Color accent top strip ──
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color, color.withAlpha(100)]),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Subject, Class & Delete Action
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
                            a.subject,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color),
                          ),
                        ),
                        if (a.assignedClass != null && a.assignedClass!.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Text(
                              a.assignedClass!,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                            ),
                          ),
                        ],
                      ],
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert_rounded, size: 18, color: AppColors.textMuted),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      onSelected: (val) {
                        if (val == 'delete') {
                          _showDeleteConfirmDialog(context, appState, a);
                        }
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 18),
                              SizedBox(width: 8),
                              Text('Tapşırığı Sil', style: TextStyle(color: AppColors.danger, fontSize: 13, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  a.title,
                  style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.2),
                ),
                const SizedBox(height: 4),
                Text(
                  a.instructions,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 13, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      'Son təhvil: ${dateFormat.format(a.dueDate)}',
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Progress Bar & Stats
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Təhvil: $totalSubmitted / $totalTarget şagird (${(progress * 100).toInt()}%)',
                          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        Row(
                          children: [
                            if (pendingReviewCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                margin: const EdgeInsets.only(right: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withAlpha(15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.warning.withAlpha(40)),
                                ),
                                child: Text(
                                  '📥 $pendingReviewCount Gözləyir',
                                  style: const TextStyle(color: AppColors.warning, fontSize: 10, fontWeight: FontWeight.w700),
                                ),
                              ),
                            if (gradedCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withAlpha(15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.success.withAlpha(40)),
                                ),
                                child: Text(
                                  '✅ $gradedCount Yoxlandı',
                                  style: const TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.w700),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: AppColors.cardBorder.withAlpha(80),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progress >= 1.0 ? AppColors.success : (progress > 0.5 ? color : AppColors.warning),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: pendingReviewCount > 0 ? AppColors.primaryAccent : AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: () => _showStudentSubmissionsSheet(context, appState, a, targetStudents, dateFormat),
                    icon: Icon(pendingReviewCount > 0 ? Icons.rate_review_rounded : Icons.people_alt_rounded, size: 16, color: Colors.white),
                    label: Text(
                      pendingReviewCount > 0
                          ? 'Şagirdlərin İşlərini Yoxla və Qiymətləndir ($pendingReviewCount)'
                          : 'Bütün Şagirdlərin Təhvil Statusuna Bax ($totalTarget)',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showStudentSubmissionsSheet(
    BuildContext context,
    AppState appState,
    HomeworkAssignment a,
    List<StudentProfile> targetStudents,
    DateFormat dateFormat,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final assignment = appState.assignments.firstWhere((x) => x.id == a.id, orElse: () => a);

            return Container(
              height: MediaQuery.of(context).size.height * 0.88,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  // Handle
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    decoration: BoxDecoration(
                      color: AppColors.cardBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Sheet Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                assignment.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.3),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${assignment.subject} • ${assignment.assignedClass ?? "Bütün Siniflər"} (${targetStudents.length} Şagird)',
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
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
                  Divider(height: 1, color: AppColors.cardBorder),

                  // Students Submissions List
                  Expanded(
                    child: targetStudents.isEmpty
                        ? Center(
                            child: Text('Bu tapşırıq üçün heç bir şagird təyin olunmayıb.', style: TextStyle(color: AppColors.textSecondary)),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            physics: const BouncingScrollPhysics(),
                            itemCount: targetStudents.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final student = targetStudents[index];
                              final sub = assignment.getSubmissionForStudent(student.id);
                              final hasSubmitted = sub != null;
                              final isGraded = sub?.score != null;

                              return Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: isGraded
                                      ? const Color(0xFFF0FDF4)
                                      : (hasSubmitted ? const Color(0xFFFEF9C3).withAlpha(80) : AppColors.surface),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isGraded
                                        ? AppColors.success.withAlpha(60)
                                        : (hasSubmitted ? AppColors.warning.withAlpha(60) : AppColors.cardBorder),
                                    width: hasSubmitted ? 1.5 : 1.0,
                                  ),
                                  boxShadow: AppShadows.sm,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Student Profile Row
                                    Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(color: AppColors.primaryAccent.withAlpha(30)),
                                          ),
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(11),
                                            child: Container(
                                              width: 44,
                                              height: 44,
                                              color: AppColors.primaryAccent.withAlpha(12),
                                              child: Image.network(
                                                student.photoUrl,
                                                width: 44,
                                                height: 44,
                                                fit: BoxFit.cover,
                                                errorBuilder: (ctx, err, stack) => const Icon(Icons.person_rounded, color: AppColors.primaryAccent, size: 24),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                student.fullName,
                                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'ID: ${student.studentNumber} • ${student.className}',
                                                style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Status Pill
                                        if (isGraded)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppColors.success,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '${sub!.score!.toInt()} / 100 Bal',
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11),
                                            ),
                                          )
                                        else if (hasSubmitted)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppColors.warning,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: const Text(
                                              '📥 Təhvil Verilib',
                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11),
                                            ),
                                          )
                                        else
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: AppColors.background,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: AppColors.cardBorder),
                                            ),
                                            child: Text(
                                              '⏳ Gözləmədə',
                                              style: TextStyle(color: AppColors.textMuted, fontSize: 11, fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                      ],
                                    ),

                                    // Submission Content Details
                                    if (hasSubmitted) ...[
                                      const SizedBox(height: 10),
                                      Divider(height: 1, color: AppColors.cardBorder),
                                      const SizedBox(height: 8),

                                      if (sub.studentNote != null && sub.studentNote!.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(bottom: 6),
                                          child: Text(
                                            'Şagirdin qeydi: "${sub.studentNote}"',
                                            style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppColors.textPrimary),
                                          ),
                                        ),

                                      // Scanned Images Gallery
                                      if (sub.scannedImages.isNotEmpty) ...[
                                        Text('Yüklənmiş Dəftər Səhifələri:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                                        const SizedBox(height: 6),
                                        SizedBox(
                                          height: 70,
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: sub.scannedImages.length,
                                            itemBuilder: (c, imgIdx) {
                                              return Container(
                                                margin: const EdgeInsets.only(right: 8),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(10),
                                                  child: Image.network(
                                                    sub.scannedImages[imgIdx],
                                                    width: 70,
                                                    height: 70,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (ctx, err, stack) => Container(
                                                      width: 70,
                                                      height: 70,
                                                      color: AppColors.primaryAccent.withAlpha(15),
                                                      child: const Icon(Icons.photo_rounded, color: AppColors.primaryAccent),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                      ],

                                      if (isGraded && sub.teacherComment != null && sub.teacherComment!.isNotEmpty)
                                        Container(
                                          width: double.infinity,
                                          padding: const EdgeInsets.all(8),
                                          margin: const EdgeInsets.only(bottom: 8),
                                          decoration: BoxDecoration(
                                            color: AppColors.surface,
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: AppColors.cardBorder),
                                          ),
                                          child: Text(
                                            'Müəllim rəyi: "${sub.teacherComment}"',
                                            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                          ),
                                        ),

                                      // Grade / Re-grade Button
                                      SizedBox(
                                        width: double.infinity,
                                        child: ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isGraded ? AppColors.primaryAccent : AppColors.primary,
                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            elevation: 0,
                                          ),
                                          onPressed: () {
                                            _showGradeStudentDialog(context, appState, assignment, student, sub, () {
                                              setSheetState(() {});
                                            });
                                          },
                                          icon: Icon(isGraded ? Icons.edit_note_rounded : Icons.rate_review_rounded, size: 16, color: Colors.white),
                                          label: Text(
                                            isGraded ? 'Balı / Rəyi Yenilə' : 'Şagirdin İşini Qiymətləndir',
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showGradeStudentDialog(
    BuildContext context,
    AppState appState,
    HomeworkAssignment assignment,
    StudentProfile student,
    AssignmentSubmission submission,
    VoidCallback onGraded,
  ) {
    final scoreCtrl = TextEditingController(text: submission.score != null ? submission.score!.toInt().toString() : '95');
    final commentCtrl = TextEditingController(text: submission.teacherComment ?? 'Məsələlərin həlli dəqiq və aydın aparılıb, afərin!');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Text('${student.fullName} • Qiymətləndirmə', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tapşırıq: ${assignment.title}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: scoreCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Bal (0 - 100) *',
                    hintText: '95',
                    prefixIcon: const Icon(Icons.grade_rounded, color: AppColors.primaryAccent),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: commentCtrl,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Pedaqoji Rəy & Qeyd *',
                    hintText: 'Şagird üçün tövsiyə və qeydləriniz...',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Ləğv et')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                final score = double.tryParse(scoreCtrl.text.replaceAll(',', '.')) ?? 85.0;
                final cleanScore = score.clamp(0.0, 100.0);

                appState.gradeHomework(
                  assignmentId: assignment.id,
                  studentId: student.id,
                  score: cleanScore,
                  comment: commentCtrl.text.trim(),
                );

                onGraded();
                Navigator.pop(ctx);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${student.fullName} üçün $cleanScore bal qeydə alındı və valideyn panelində yeniləndi!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              child: const Text('Təsdiqlə və Göndər', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, AppState appState, HomeworkAssignment a) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Tapşırığı Sil', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text('"${a.title}" tapşırığını silmək istədiyinizə əminsiniz? Bütün şagirdlərin təhvilləri silinəcək.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Ləğv et')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              appState.deleteAssignment(a.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tapşırıq silindi'), backgroundColor: AppColors.danger),
              );
            },
            child: const Text('Sil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
