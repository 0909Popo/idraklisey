import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
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
      appBar: AppBar(
        title: const Text('Tapşırıq Təhvili & Yoxlanış'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task_rounded),
            tooltip: 'Yeni Tapşırıq Əlavə Et',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateAssignmentScreen()),
              );
            },
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
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_task_rounded, color: Colors.white),
        label: const Text('Yeni Tapşırıq Ver', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(0, 'Bütün Tapşırıqlar (${allAssignments.length})'),
                  _buildFilterChip(1, '📥 Təhvil Var (${allAssignments.where((a) => a.submittedCount > 0).length})'),
                  _buildFilterChip(2, '✅ Yoxlanılanlar (${allAssignments.where((a) => a.gradedCount > 0).length})'),
                  _buildFilterChip(3, '⏳ Təhvil Yoxdur (${allAssignments.where((a) => a.totalSubmissionsCount == 0).length})'),
                ],
              ),
            ),
          ),

          // Main Content
          Expanded(
            child: allAssignments.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withAlpha(15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.assignment_add, size: 64, color: AppColors.primary),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Hələ heç bir dərs tapşırığı verilməyib',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Şagirdlərə fənniniz üzrə ev tapşırığı, məsələ və ya mövzu təyin etmək üçün aşağıdakı düyməyə klikləyin.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const CreateAssignmentScreen()),
                              );
                            },
                            icon: const Icon(Icons.add_rounded, color: Colors.white),
                            label: const Text('İlk Tapşırığı Təyin Et', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  )
                : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.filter_alt_off_rounded, size: 48, color: AppColors.textMuted),
                            SizedBox(height: 8),
                            Text('Bu filtr üzrə tapşırıq tapılmadı.', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(0, 12, 0, 80),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final a = filtered[index];
                          return _buildAssignmentReviewCard(context, appState, a, dateFormat);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(int index, String label) {
    final isSelected = _filterIndex == index;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _filterIndex = index),
        selectedColor: AppColors.primary,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: AppColors.background,
        side: BorderSide(color: isSelected ? AppColors.primary : AppColors.cardBorder),
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
    // Determine target students for this assignment
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(6),
            blurRadius: 10,
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
              // Left Accent Strip
              Container(
                width: 6,
                color: color,
              ),

              // Card Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
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
                                  color: color.withAlpha(20),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  a.subject,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: color,
                                  ),
                                ),
                              ),
                              if (a.assignedClass != null && a.assignedClass!.isNotEmpty) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.cardBorder),
                                  ),
                                  child: Text(
                                    a.assignedClass!,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          PopupMenuButton<String>(
                            icon: Icon(Icons.more_vert_rounded, size: 18, color: AppColors.textMuted),
                            padding: EdgeInsets.zero,
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
                                    Text('Tapşırığı Sil', style: TextStyle(color: AppColors.danger, fontSize: 13)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        a.title,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        a.instructions,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time_rounded, size: 12, color: AppColors.textMuted),
                          const SizedBox(width: 4),
                          Text(
                            'Son təhvil: ${dateFormat.format(a.dueDate)}',
                            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Progress Bar & Stats
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Təhvil: $totalSubmitted / $totalTarget şagird (${(progress * 100).toInt()}%)',
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                              ),
                              Row(
                                children: [
                                  if (pendingReviewCount > 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      margin: const EdgeInsets.only(right: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.warning.withAlpha(25),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '📥 $pendingReviewCount Gözləyir',
                                        style: const TextStyle(color: AppColors.warning, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  if (gradedCount > 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.success.withAlpha(25),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '✅ $gradedCount Yoxlandı',
                                        style: const TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 6,
                              backgroundColor: const Color(0xFFF1F5F9),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                progress >= 1.0 ? AppColors.success : (progress > 0.5 ? color : AppColors.warning),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Action Button: View & Grade individual students
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: pendingReviewCount > 0 ? AppColors.primary : const Color(0xFF334155),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => _showStudentSubmissionsSheet(context, appState, a, targetStudents, dateFormat),
                          icon: Icon(pendingReviewCount > 0 ? Icons.rate_review_rounded : Icons.people_alt_rounded, size: 16),
                          label: Text(
                            pendingReviewCount > 0
                                ? 'Şagirdlərin İşlərini Yoxla və Qiymətləndir ($pendingReviewCount)'
                                : 'Bütün Şagirdlərin Təhvil Statusuna Bax ($totalTarget)',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
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
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
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
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // Students Submissions List
                  Expanded(
                    child: targetStudents.isEmpty
                        ? Center(
                            child: Text('Bu tapşırıq üçün heç bir şagird təyin olunmayıb.', style: TextStyle(color: AppColors.textSecondary)),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
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
                                      : (hasSubmitted ? const Color(0xFFFEF9C3).withAlpha(100) : Colors.white),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isGraded
                                        ? AppColors.success.withAlpha(80)
                                        : (hasSubmitted ? AppColors.warning : AppColors.cardBorder),
                                    width: hasSubmitted ? 1.5 : 1.0,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Student Profile Row
                                    Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Container(
                                            width: 44,
                                            height: 44,
                                            color: AppColors.primary.withAlpha(20),
                                            child: Image.network(
                                              student.photoUrl,
                                              width: 44,
                                              height: 44,
                                              fit: BoxFit.cover,
                                              errorBuilder: (ctx, err, stack) => const Icon(Icons.person_rounded, color: AppColors.primary, size: 24),
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
                                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
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
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
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
                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
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

                                    // Submission Content Details (If submitted)
                                    if (hasSubmitted) ...[
                                      const SizedBox(height: 10),
                                      const Divider(height: 1),
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
                                        Text('Yüklənmiş Dəftər Səhifələri:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
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
                                                  borderRadius: BorderRadius.circular(8),
                                                  child: Image.network(
                                                    sub.scannedImages[imgIdx],
                                                    width: 70,
                                                    height: 70,
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (ctx, err, stack) => Container(
                                                      width: 70,
                                                      height: 70,
                                                      color: AppColors.primary.withAlpha(20),
                                                      child: const Icon(Icons.photo_rounded, color: AppColors.primary),
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
                                            borderRadius: BorderRadius.circular(8),
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
                                            padding: const EdgeInsets.symmetric(vertical: 9),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          ),
                                          onPressed: () {
                                            _showGradeStudentDialog(context, appState, assignment, student, sub, () {
                                              setSheetState(() {});
                                            });
                                          },
                                          icon: Icon(isGraded ? Icons.edit_note_rounded : Icons.rate_review_rounded, size: 16),
                                          label: Text(
                                            isGraded ? 'Balı / Rəyi Yenilə' : 'Şagirdin İşini Qiymətləndir',
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('${student.fullName} • Qiymətləndirmə'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tapşırıq: ${assignment.title}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: scoreCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Bal (0 - 100) *',
                    hintText: '95',
                    prefixIcon: Icon(Icons.grade_rounded, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: commentCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Pedaqoji Rəy & Qeyd *',
                    hintText: 'Şagird üçün tövsiyə və qeydləriniz...',
                    alignLabelWithHint: true,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Ləğv et')),
            ElevatedButton(
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
              child: const Text('Təsdiqlə və Göndər'),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Tapşırığı Sil'),
        content: Text('"${a.title}" tapşırığını silmək istədiyinizə əminsiniz? Bütün şagirdlərin təhvilləri silinəcək.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Ləğv et')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
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
