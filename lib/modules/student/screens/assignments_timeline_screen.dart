import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
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
      appBar: AppBar(
        title: Text('${currentStudent.fullName} • Tapşırıqlar'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Top Summary Banner
          Container(
            padding: const EdgeInsets.all(16),
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
              children: [
                _buildSummaryPill('Gözləyir', '$pendingCount', AppColors.warning, Icons.hourglass_top_rounded),
                const SizedBox(width: 8),
                _buildSummaryPill('Təhvil Verildi', '$submittedCount', Colors.teal, Icons.mark_email_read_rounded),
                const SizedBox(width: 8),
                _buildSummaryPill('Qiymətləndirildi', '$gradedCount', AppColors.success, Icons.check_circle_rounded),
              ],
            ),
          ),

          // Filter Chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilter('Hamısı (${relevantAssignments.length})', null),
                  _buildFilter('⏳ Yeni ($pendingCount)', AssignmentStatus.pending),
                  _buildFilter('📤 Təhvil Verilənlər ($submittedCount)', AssignmentStatus.submitted),
                  _buildFilter('⭐ Yoxlanılanlar ($gradedCount)', AssignmentStatus.graded),
                ],
              ),
            ),
          ),

          // Assignment Timeline List
          Expanded(
            child: filtered.isEmpty
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
                            child: const Icon(Icons.assignment_turned_in_rounded, size: 56, color: AppColors.primary),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Tapşırıq tapılmadı',
                            style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Seçilmiş kateqoriya üzrə aktiv ev tapşırığı mövcud deyil.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return _buildTimelineCard(context, item, currentStudent.id);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryPill(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(40)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: color),
                  ),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilter(String title, AssignmentStatus? status) {
    final isSelected = _selectedStatus == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(title),
        selected: isSelected,
        onSelected: (_) => setState(() => _selectedStatus = status),
        selectedColor: AppColors.primary,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: const Color(0xFFF1F5F9),
        side: BorderSide(color: isSelected ? AppColors.primary : AppColors.cardBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildTimelineCard(BuildContext context, HomeworkAssignment assignment, String studentId) {
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
        statusColor = Colors.teal;
        statusTitle = 'Təhvil Verildi';
        statusIcon = Icons.mark_email_read_rounded;
        break;
      case AssignmentStatus.graded:
        statusColor = AppColors.success;
        statusTitle = 'Yoxlanıldı (${mySub?.score?.toInt()} Bal)';
        statusIcon = Icons.check_circle_rounded;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HomeworkSubmissionScreen(assignment: assignment),
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
                    color: color,
                  ),

                  // Assignment Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Header: Subject Badge + Status Badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: color.withAlpha(20),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(icon, size: 16, color: color),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    assignment.subject,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      color: color,
                                    ),
                                  ),
                                ],
                              ),
                              StatusBadge(
                                label: statusTitle,
                                color: statusColor,
                                icon: statusIcon,
                                fontSize: 11,
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Assignment Title
                          Text(
                            assignment.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimary,
                            ),
                          ),

                          const SizedBox(height: 4),

                          // Instructions / Description preview
                          Text(
                            assignment.instructions,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
                          ),

                          const SizedBox(height: 12),
                          Divider(color: AppColors.cardBorder, height: 1),
                          const SizedBox(height: 8),

                          // Bottom Row: Due Date & Action CTA
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 13,
                                    color: isOverdue ? AppColors.danger : AppColors.textMuted,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Son: ${dateFormat.format(assignment.dueDate)}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isOverdue ? AppColors.danger : AppColors.textSecondary,
                                      fontWeight: isOverdue ? FontWeight.bold : FontWeight.w500,
                                    ),
                                  ),
                                  if (!isOverdue && diffHours >= 0 && diffHours <= 48 && status == AssignmentStatus.pending) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.warning.withAlpha(25),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        diffHours < 24 ? 'Bu gün' : 'Sabah',
                                        style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.warning),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    status == AssignmentStatus.graded
                                        ? 'Qiymətə Bax'
                                        : (status == AssignmentStatus.submitted ? 'Təhvilə Bax' : 'Kamera ilə Təhvil'),
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryAccent),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.arrow_forward_ios_rounded, size: 11, color: AppColors.primaryAccent),
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
      ),
    );
  }
}
