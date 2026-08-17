import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../providers/app_state.dart';
import '../../../data/models/assignment_model.dart';
import 'homework_submission_screen.dart';

class AssignmentsTimelineScreen extends StatefulWidget {
  const AssignmentsTimelineScreen({super.key});

  @override
  State<AssignmentsTimelineScreen> createState() => _AssignmentsTimelineScreenState();
}

class _AssignmentsTimelineScreenState extends State<AssignmentsTimelineScreen> {
  AssignmentStatus? _selectedStatus;

  Color _getSubjectColor(String subject) {
    final s = subject.toLowerCase();
    if (s.contains('riyaziyyat') || s.contains('cəbr') || s.contains('həndəsə')) {
      return const Color(0xFF2563EB); // Royal Blue
    } else if (s.contains('fizika')) {
      return const Color(0xFF0284C7); // Ocean Sky
    } else if (s.contains('kimya')) {
      return const Color(0xFF7C3AED); // Vivid Purple
    } else if (s.contains('biologiya') || s.contains('həyat bilgisi') || s.contains('təbiət')) {
      return const Color(0xFF059669); // Emerald Green
    } else if (s.contains('ingilis') || s.contains('rus') || s.contains('alman') || s.contains('xarici dil')) {
      return const Color(0xFFD97706); // Amber Gold
    } else if (s.contains('tarix') || s.contains('zəfər')) {
      return const Color(0xFFE11D48); // Rose Crimson
    } else if (s.contains('azərbaycan') || s.contains('ədəbiyyat')) {
      return const Color(0xFF1D4ED8); // Deep Blue
    } else if (s.contains('informatika') || s.contains('rəqəmsal')) {
      return const Color(0xFF4F46E5); // Indigo
    }
    return const Color(0xFF1E3A8A); // Idrak Navy
  }

  IconData _getSubjectIcon(String subject) {
    final s = subject.toLowerCase();
    if (s.contains('riyaziyyat') || s.contains('cəbr') || s.contains('həndəsə')) {
      return Icons.calculate_rounded;
    } else if (s.contains('fizika')) {
      return Icons.wb_twilight_rounded;
    } else if (s.contains('kimya')) {
      return Icons.biotech_rounded;
    } else if (s.contains('biologiya') || s.contains('həyat bilgisi') || s.contains('təbiət')) {
      return Icons.eco_rounded;
    } else if (s.contains('ingilis') || s.contains('rus') || s.contains('alman') || s.contains('xarici dil')) {
      return Icons.translate_rounded;
    } else if (s.contains('tarix') || s.contains('zəfər')) {
      return Icons.history_edu_rounded;
    } else if (s.contains('azərbaycan') || s.contains('ədəbiyyat')) {
      return Icons.menu_book_rounded;
    } else if (s.contains('informatika') || s.contains('rəqəmsal')) {
      return Icons.computer_rounded;
    }
    return Icons.assignment_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final currentStudent = appState.student;
    final allAssignments = appState.assignments;

    // Filter by student target if student/parent is logged in
    final relevantAssignments = allAssignments.where((a) {
      if (appState.currentRole == UserRole.student || appState.currentRole == UserRole.parent) {
        final assignedCls = a.assignedClass?.trim();
        final matchesClass = assignedCls == null ||
            assignedCls.isEmpty ||
            assignedCls.toLowerCase() == 'hamısı' ||
            assignedCls.toLowerCase() == 'bütün siniflər' ||
            assignedCls.toLowerCase() == currentStudent.className.trim().toLowerCase();
        final matchesStudent = a.assignedStudentIds.isEmpty || a.assignedStudentIds.contains(currentStudent.id);
        return matchesClass && matchesStudent;
      }
      return true;
    }).toList();

    final pendingCount = relevantAssignments.where((a) => a.getStatusForStudent(currentStudent.id) == AssignmentStatus.pending).length;
    final submittedCount = relevantAssignments.where((a) => a.getStatusForStudent(currentStudent.id) == AssignmentStatus.submitted).length;
    final gradedCount = relevantAssignments.where((a) => a.getStatusForStudent(currentStudent.id) == AssignmentStatus.graded).length;

    final filtered = _selectedStatus == null
        ? relevantAssignments
        : relevantAssignments.where((a) => a.getStatusForStudent(currentStudent.id) == _selectedStatus).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Collapsing App Bar with gradient ──
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.primary,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(25),
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
                    colors: [
                      Color(0xFF1A1B2E),
                      Color(0xFF2D1B69),
                      Color(0xFF6C5CE7),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 44, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(20),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.assignment_outlined, size: 22, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tapşırıqlar',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${currentStudent.fullName} • ${relevantAssignments.length} tapşırıq',
                                    style: TextStyle(
                                      color: Colors.white.withAlpha(178),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
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
              ),
            ),
          ),

          // ── Stats Row ──
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  _buildStatCard(
                    'Gözləyir',
                    pendingCount,
                    Icons.hourglass_top_rounded,
                    const Color(0xFFF59E0B),
                    const Color(0xFFFFFBEB),
                  ),
                  const SizedBox(width: 10),
                  _buildStatCard(
                    'Təhvil',
                    submittedCount,
                    Icons.mark_email_read_rounded,
                    const Color(0xFF0D9488),
                    const Color(0xFFF0FDFA),
                  ),
                  const SizedBox(width: 10),
                  _buildStatCard(
                    'Yoxlanıldı',
                    gradedCount,
                    Icons.check_circle_rounded,
                    const Color(0xFF22C55E),
                    const Color(0xFFF0FDF4),
                  ),
                ],
              ),
            ),
          ),

          // ── Filter Chips ──
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildFilterChip('Hamısı', relevantAssignments.length, null),
                    const SizedBox(width: 6),
                    _buildFilterChip('Gözləyir', pendingCount, AssignmentStatus.pending),
                    const SizedBox(width: 6),
                    _buildFilterChip('Təhvil Verildi', submittedCount, AssignmentStatus.submitted),
                    const SizedBox(width: 6),
                    _buildFilterChip('Qiymətləndirilən', gradedCount, AssignmentStatus.graded),
                  ],
                ),
              ),
            ),
          ),

          // ── Empty State ──
          if (filtered.isEmpty)
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
                          color: AppColors.primaryAccent.withAlpha(12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.assignment_turned_in_outlined, size: 52, color: AppColors.primaryAccent.withAlpha(120)),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Tapşırıq tapılmadı',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Seçilmiş kateqoriya üzrə aktiv\nev tapşırığı mövcud deyil.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ── Timeline List ──
          if (filtered.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = filtered[index];
                    final isLast = index == filtered.length - 1;
                    return _buildTimelineCard(context, item, currentStudent.id, isLast);
                  },
                  childCount: filtered.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Stat Card ──
  Widget _buildStatCard(String label, int count, IconData icon, Color color, Color bgColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(30)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: color,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color.withAlpha(178),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Filter Chip ──
  Widget _buildFilterChip(String title, int count, AssignmentStatus? status) {
    final isSelected = _selectedStatus == status;
    return GestureDetector(
      onTap: () => setState(() => _selectedStatus = status),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryAccent : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryAccent : AppColors.cardBorder,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected ? [BoxShadow(color: AppColors.primaryAccent.withAlpha(40), blurRadius: 8, offset: const Offset(0, 2))] : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white.withAlpha(30) : AppColors.cardBorder.withAlpha(80),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Timeline Card with left connector ──
  Widget _buildTimelineCard(BuildContext context, HomeworkAssignment assignment, String studentId, bool isLast) {
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');
    final status = assignment.getStatusForStudent(studentId);
    final mySub = assignment.getSubmissionForStudent(studentId);
    final color = _getSubjectColor(assignment.subject);
    final icon = _getSubjectIcon(assignment.subject);

    final now = DateTime.now();
    final isOverdue = now.isAfter(assignment.dueDate) && status != AssignmentStatus.submitted && status != AssignmentStatus.graded;
    final diffHours = assignment.dueDate.difference(now).inHours;

    Color statusColor;
    String statusTitle;
    IconData statusIcon;

    switch (status) {
      case AssignmentStatus.pending:
        statusColor = isOverdue ? AppColors.danger : AppColors.warning;
        statusTitle = isOverdue ? 'Müddəti Bitib' : 'Gözləmədə';
        statusIcon = isOverdue ? Icons.error_outline_rounded : Icons.hourglass_top_rounded;
        break;
      case AssignmentStatus.inProgress:
        statusColor = AppColors.primaryAccent;
        statusTitle = 'İcrada';
        statusIcon = Icons.edit_note_rounded;
        break;
      case AssignmentStatus.submitted:
        statusColor = const Color(0xFF0D9488);
        statusTitle = 'Təhvil Verildi';
        statusIcon = Icons.mark_email_read_rounded;
        break;
      case AssignmentStatus.graded:
        statusColor = AppColors.success;
        statusTitle = 'Yoxlanıldı (${mySub?.score?.toInt()} Bal)';
        statusIcon = Icons.check_circle_rounded;
        break;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Left timeline connector ──
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: statusColor.withAlpha(30),
                    border: Border.all(color: statusColor, width: 2.5),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [statusColor.withAlpha(60), AppColors.cardBorder.withAlpha(40)],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Card Body ──
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.cardBorder),
                boxShadow: AppShadows.sm,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => HomeworkSubmissionScreen(assignment: assignment),
                      ),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Color accent top bar ──
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color, color.withAlpha(100)],
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(18),
                            topRight: Radius.circular(18),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Subject badge + Status ──
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(7),
                                        decoration: BoxDecoration(
                                          color: color.withAlpha(18),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(icon, size: 16, color: color),
                                      ),
                                      const SizedBox(width: 10),
                                      Flexible(
                                        child: Text(
                                          assignment.subject,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w800,
                                            color: color,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                StatusBadge(
                                  label: statusTitle,
                                  color: statusColor,
                                  icon: statusIcon,
                                  fontSize: 10,
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // ── Title ──
                            Text(
                              assignment.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.3,
                                height: 1.3,
                              ),
                            ),

                            const SizedBox(height: 6),

                            // ── Description preview ──
                            Text(
                              assignment.instructions,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.5,
                                color: AppColors.textSecondary,
                                height: 1.45,
                              ),
                            ),

                            const SizedBox(height: 14),

                            // ── Thin separator ──
                            Container(
                              height: 1,
                              color: AppColors.cardBorder.withAlpha(100),
                            ),

                            const SizedBox(height: 10),

                            // ── Bottom: Due date & CTA ──
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.schedule_rounded,
                                        size: 14,
                                        color: isOverdue ? AppColors.danger : AppColors.textMuted,
                                      ),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          'Son: ${dateFormat.format(assignment.dueDate)}',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: isOverdue ? AppColors.danger : AppColors.textSecondary,
                                            fontWeight: isOverdue ? FontWeight.w700 : FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      if (!isOverdue && diffHours >= 0 && diffHours <= 48 && status == AssignmentStatus.pending) ...[
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppColors.warning.withAlpha(20),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: AppColors.warning.withAlpha(50)),
                                          ),
                                          child: Text(
                                            diffHours < 24 ? 'Bu gün' : 'Sabah',
                                            style: const TextStyle(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.warning,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryAccent.withAlpha(12),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        status == AssignmentStatus.graded
                                            ? 'Qiymətə Bax'
                                            : (status == AssignmentStatus.submitted ? 'Təhvilə Bax' : 'Təhvil Ver'),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primaryAccent,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppColors.primaryAccent),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
