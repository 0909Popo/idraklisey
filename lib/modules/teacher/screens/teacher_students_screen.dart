import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../providers/app_state.dart';
import '../../../data/models/student_model.dart';
import '../../../data/models/medical_model.dart';
import 'quick_grading_screen.dart';
import 'create_assignment_screen.dart';
import '../../shared/dialogs/send_notification_dialog.dart';

class TeacherStudentsScreen extends StatefulWidget {
  const TeacherStudentsScreen({super.key});

  @override
  State<TeacherStudentsScreen> createState() => _TeacherStudentsScreenState();
}

class _TeacherStudentsScreenState extends State<TeacherStudentsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedClass = 'Hamısı';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final students = appState.students;

    final classes = ['Hamısı', ...appState.allDistinctClasses];

    final filtered = students.where((s) {
      final matchesClass = _selectedClass == 'Hamısı' || s.className == _selectedClass;
      final q = _searchCtrl.text.toLowerCase().trim();
      final matchesSearch = q.isEmpty ||
          s.fullName.toLowerCase().contains(q) ||
          s.studentNumber.toLowerCase().contains(q) ||
          s.className.toLowerCase().contains(q);
      return matchesClass && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Gradient Header ──
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.primary,
            surfaceTintColor: Colors.transparent,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add_task_rounded, size: 18, color: Colors.white),
                  ),
                  tooltip: 'Tapşırıq Ver',
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
                child: SafeArea(
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
                              child: const Icon(Icons.groups_rounded, size: 22, color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Şagirdlər Kataloqu',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${students.length} şagird qeydiyyatda',
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
              ),
            ),
          ),

          // ── Search & Filter ──
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                children: [
                  // Search Field
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                      boxShadow: AppShadows.sm,
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Şagird adı, İdrak kodu və ya sinif axtar...',
                        hintStyle: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                        filled: true,
                        fillColor: AppColors.surface,
                        prefixIcon: Icon(Icons.search_rounded, color: AppColors.primaryAccent, size: 20),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.primaryAccent, width: 1.5),
                        ),
                        suffixIcon: _searchCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                    ),
                  ),

                  // Class Filter Chips
                  if (classes.length > 1) ...[
                    const SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: classes.map((c) {
                          final isSelected = _selectedClass == c;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedClass = c),
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
                                      ? [BoxShadow(color: AppColors.primaryAccent.withAlpha(35), blurRadius: 8, offset: const Offset(0, 2))]
                                      : [],
                                ),
                                child: Text(
                                  c,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : AppColors.textPrimary,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ── Students List ──
          if (students.isEmpty)
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
                          color: AppColors.primaryAccent.withAlpha(10),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.person_search_rounded, size: 56, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Sistemdə hələ heç bir şagird\nqeydiyyatdan keçməyib.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Yeni şagird və valideyn hesabları\nMəktəb İnzibatçısı (Admin) tərəfindən yaradılır.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5),
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
                      child: Icon(Icons.search_off_rounded, size: 44, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Axtarışa uyğun şagird tapılmadı.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final student = filtered[index];
                    return _buildStudentListItem(context, appState, student);
                  },
                  childCount: filtered.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStudentListItem(BuildContext context, AppState appState, StudentProfile student) {
    final gpaText = student.gpa > 0 ? 'GPA: ${student.gpa}' : 'Yeni Şagird';

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
          onTap: () => _showStudentDetailsModal(context, appState, student),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Photo with rounded square
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primaryAccent.withAlpha(30), width: 1.5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Container(
                      width: 56,
                      height: 56,
                      color: AppColors.primaryAccent.withAlpha(12),
                      child: Image.network(
                        student.photoUrl,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => Icon(Icons.person_rounded, color: AppColors.primaryAccent, size: 28),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              student.fullName,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primaryAccent.withAlpha(15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.primaryAccent.withAlpha(40)),
                            ),
                            child: Text(
                              student.className,
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${student.studentNumber} • $gpaText',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(Icons.family_restroom_rounded, size: 13, color: AppColors.goldDark.withAlpha(180)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Valideyn: ${student.parentName}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
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
  }

  void _showStudentDetailsModal(BuildContext context, AppState appState, StudentProfile student) {
    final canEditMedical = appState.currentUser?.role == UserRole.admin ||
        (appState.currentUser?.teacherPermissions?.canManageMedical ?? false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final currentMed = appState.getMedicalCardForStudent(student.id);
            final gpaDisplay = student.gpa > 0 ? '${student.gpa}' : 'Yeni';
            final attDisplay = student.attendanceRate > 0 ? '${student.attendanceRate}%' : 'Yeni';

            return Container(
              height: MediaQuery.of(context).size.height * 0.90,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  // ── Sheet Handle ──
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 4),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.cardBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // ── Header ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 12, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.primaryAccent.withAlpha(40)),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(13),
                                  child: Container(
                                    width: 50,
                                    height: 50,
                                    color: AppColors.primaryAccent.withAlpha(12),
                                    child: Image.network(
                                      student.photoUrl,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, err, stack) => const Icon(Icons.person, color: AppColors.primaryAccent),
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
                                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.3),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${student.className} • ${student.studentNumber}',
                                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
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

                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(height: 1, color: AppColors.cardBorder),
                  ),

                  // ── Scrollable Content ──
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Quick Stats Row ──
                          Row(
                            children: [
                              _buildDetailStat('GPA (Ortalama)', gpaDisplay, AppColors.primaryAccent),
                              const SizedBox(width: 8),
                              _buildDetailStat('Davamiyyət', attDisplay, AppColors.success),
                              const SizedBox(width: 8),
                              _buildDetailStat(
                                'Qan Qrupu',
                                (currentMed.bloodGroup.isNotEmpty && !currentMed.bloodGroup.toLowerCase().contains('yoxdur') && !currentMed.bloodGroup.toLowerCase().contains('məlumat'))
                                    ? currentMed.bloodGroup
                                    : 'Qeyd yoxdur',
                                AppColors.danger,
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // ── Academic Performance Box ──
                          Builder(
                            builder: (context) {
                              final teacherSub = appState.currentUser?.subject?.toLowerCase().trim() ?? '';
                              final studentGrades = appState.grades.where((g) => g.studentId == student.id).toList();
                              final mySubjectGrades = teacherSub.isNotEmpty
                                  ? studentGrades.where((g) => g.subject.toLowerCase().contains(teacherSub)).toList()
                                  : studentGrades;

                              double myAvg = 0;
                              if (mySubjectGrades.isNotEmpty) {
                                myAvg = mySubjectGrades.map((g) => g.percentage).reduce((a, b) => a + b) / mySubjectGrades.length;
                              }

                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: AppColors.primaryAccent.withAlpha(60)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryAccent.withAlpha(10),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primaryAccent.withAlpha(15),
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: const Icon(Icons.school_rounded, color: AppColors.primaryAccent, size: 16),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  teacherSub.isNotEmpty ? 'Sizin Fənniniz (${appState.currentUser?.subject})' : 'Akademik Göstəricilər',
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.primaryAccent),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        StatusBadge(
                                          label: mySubjectGrades.isNotEmpty ? '${myAvg.toStringAsFixed(1)} / 100 Bal' : 'Qiymət yoxdur',
                                          color: AppColors.primaryAccent,
                                          fontSize: 10,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      'Məktəb üzrə ümumi ortalama: ${student.gpa.toStringAsFixed(2)} GPA (${studentGrades.length} qiymət)',
                                      style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                                    ),
                                    if (mySubjectGrades.isNotEmpty) ...[
                                      const SizedBox(height: 10),
                                      Container(height: 1, color: AppColors.cardBorder),
                                      const SizedBox(height: 8),
                                      ...mySubjectGrades.take(3).map((g) => Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 3),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '• ${g.title}',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryAccent.withAlpha(12),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                '${g.displayScore.toInt()} / ${g.maxScore.toInt()}',
                                                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.primaryAccent),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                    ],
                                  ],
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 16),

                          // ── Physical Stats & BMI ──
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: currentMed.bmiColor.withAlpha(60)),
                              boxShadow: [
                                BoxShadow(
                                  color: currentMed.bmiColor.withAlpha(12),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: currentMed.bmiColor.withAlpha(15),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(Icons.accessibility_new_rounded, color: currentMed.bmiColor, size: 16),
                                        ),
                                        const SizedBox(width: 8),
                                        Text('Fiziki İnkişaf & BMI', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textPrimary)),
                                      ],
                                    ),
                                    if (canEditMedical)
                                      TextButton.icon(
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                          minimumSize: const Size(0, 0),
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        onPressed: () {
                                          _showEditPhysicalStatsDialog(context, appState, student.id, currentMed, () {
                                            setSheetState(() {});
                                          });
                                        },
                                        icon: const Icon(Icons.edit_note_rounded, size: 14),
                                        label: const Text('Redaktə Et', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    color: AppColors.background,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      _buildBmiStatSub('Boy', currentMed.heightCm > 0 ? '${currentMed.heightCm.toInt()} sm' : 'Qeyd yoxdur'),
                                      Container(height: 28, width: 1, color: AppColors.cardBorder),
                                      _buildBmiStatSub('Çəki', currentMed.weightKg > 0 ? '${currentMed.weightKg.toInt()} kq' : 'Qeyd yoxdur'),
                                      Container(height: 28, width: 1, color: AppColors.cardBorder),
                                      _buildBmiStatSub('BMI İndeksi', currentMed.bmiDisplay),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                StatusBadge(
                                  label: currentMed.bmiCategory,
                                  color: currentMed.bmiColor,
                                  fontSize: 11,
                                ),
                                if (currentMed.bmiWarning != null) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: currentMed.bmiColor.withAlpha(12),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: currentMed.bmiColor.withAlpha(30)),
                                    ),
                                    child: Text(
                                      currentMed.bmiWarning!,
                                      style: TextStyle(fontSize: 11.5, color: currentMed.bmiColor, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ── Parent Info Box ──
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: AppColors.gold.withAlpha(40)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: AppColors.goldDark.withAlpha(15),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(Icons.family_restroom_rounded, color: AppColors.goldDark, size: 16),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text('Valideyn Əlaqə Məlumatları', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.goldDark)),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryAccent.withAlpha(12),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text('Rəsmi Qəyyum', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primaryAccent)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text('Adı: ${student.parentName}', style: TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 3),
                                Text('Telefon: ${student.parentPhone}', style: const TextStyle(fontSize: 13, color: AppColors.primaryAccent, fontWeight: FontWeight.w700)),
                                const SizedBox(height: 12),

                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      elevation: 0,
                                    ),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) => SendNotificationDialog(directStudent: student),
                                      );
                                    },
                                    icon: const Icon(Icons.send_rounded, color: AppColors.goldLight, size: 16),
                                    label: const Text(
                                      'Valideynə Bildiriş / Qeyd Göndər',
                                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ── Health & Allergies ──
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: AppColors.danger.withAlpha(12),
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    child: const Icon(Icons.medical_services_rounded, size: 14, color: AppColors.danger),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('Sağlamlıq & Allergiya', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.danger)),
                                ],
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  _showAddAllergyQuickDialog(context, appState, student.id, () {
                                    setSheetState(() {});
                                  });
                                },
                                icon: const Icon(Icons.add_circle_outline_rounded, size: 14, color: AppColors.danger),
                                label: const Text('Əlavə Et', style: TextStyle(fontSize: 11, color: AppColors.danger, fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          if (currentMed.allergies.isNotEmpty)
                            ...currentMed.allergies.map((allergy) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.danger.withAlpha(6),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.danger.withAlpha(35)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: AppColors.danger.withAlpha(15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.warning_amber_rounded, size: 16, color: AppColors.danger),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(allergy.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                          const SizedBox(height: 2),
                                          Text('Reaksiya: ${allergy.reaction}', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                        ],
                                      ),
                                    ),
                                    StatusBadge(label: allergy.severity, color: AppColors.danger, fontSize: 9),
                                  ],
                                ),
                              );
                            })
                          else
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text('Allergiya və ya xəstəlik qeydi yoxdur.', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                            ),

                          const SizedBox(height: 20),

                          // ── Vaccine History ──
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryAccent.withAlpha(12),
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    child: const Icon(Icons.vaccines_rounded, size: 14, color: AppColors.primaryAccent),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('Peyvənd & Vaksina', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primaryAccent)),
                                ],
                              ),
                              if (canEditMedical)
                                TextButton.icon(
                                  onPressed: () {
                                    _showAddVaccineQuickDialog(context, appState, student.id, () {
                                      setSheetState(() {});
                                    });
                                  },
                                  icon: const Icon(Icons.add_circle_outline_rounded, size: 14, color: AppColors.primaryAccent),
                                  label: const Text('Əlavə Et', style: TextStyle(fontSize: 11, color: AppColors.primaryAccent, fontWeight: FontWeight.w700)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          if (currentMed.vaccineHistory.isNotEmpty)
                            ...currentMed.vaccineHistory.map((v) {
                              final isDone = v.status == 'Tamamlandı';
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.cardBorder),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(v.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                          const SizedBox(height: 2),
                                          Text('${v.doctor} • ${v.date.day}.${v.date.month}.${v.date.year}', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                        ],
                                      ),
                                    ),
                                    StatusBadge(
                                      label: v.status,
                                      color: isDone ? AppColors.success : AppColors.warning,
                                      fontSize: 10,
                                    ),
                                  ],
                                ),
                              );
                            })
                          else
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text('Peyvənd qeydi daxil edilməyib.', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                            ),

                          // ── Parent Notes ──
                          if (currentMed.parentNotes.isNotEmpty) ...[
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: AppColors.goldDark.withAlpha(12),
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  child: const Icon(Icons.sticky_note_2_rounded, size: 14, color: AppColors.goldDark),
                                ),
                                const SizedBox(width: 8),
                                const Text('Valideynin Xüsusi Qeydləri', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.goldDark)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...currentMed.parentNotes.map((note) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFBEB),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.gold.withAlpha(50)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(note.parentName, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.goldDark)),
                                      Text('${note.date.day}.${note.date.month}.${note.date.year}', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(note.note, style: TextStyle(fontSize: 12.5, color: AppColors.textPrimary, height: 1.4)),
                                ],
                              ),
                            )),
                          ],

                          const SizedBox(height: 24),

                          // ── Action Buttons ──
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryAccent,
                                    padding: const EdgeInsets.symmetric(vertical: 13),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    elevation: 0,
                                  ),
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => CreateAssignmentScreen(preSelectedStudent: student),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.add_task_rounded, size: 18, color: Colors.white),
                                  label: const Text('Tapşırıq Ver', style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w700)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(vertical: 13),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    elevation: 0,
                                  ),
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const QuickGradingScreen()),
                                    );
                                  },
                                  icon: const Icon(Icons.grade_rounded, size: 18, color: Colors.white),
                                  label: const Text('Qiymətləndir', style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w700)),
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
            );
          },
        );
      },
    );
  }

  Widget _buildBmiStatSub(String label, String val) {
    return Expanded(
      child: Column(
        children: [
          Text(val, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.textPrimary)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildDetailStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: color.withAlpha(10),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withAlpha(30)),
        ),
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: color),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10.5, color: color.withAlpha(180), fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditPhysicalStatsDialog(BuildContext context, AppState appState, String studentId, StudentMedicalCard card, VoidCallback onUpdated) {
    final heightCtrl = TextEditingController(text: card.heightCm > 0 ? '${card.heightCm.toInt()}' : '');
    final weightCtrl = TextEditingController(text: card.weightKg > 0 ? '${card.weightKg.toInt()}' : '');
    String selectedBlood = card.bloodGroup.isNotEmpty && card.bloodGroup != 'Məlumat yoxdur' ? card.bloodGroup : 'A(II) Rh+';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              title: const Text('Fiziki və Tibbi Göstəricilər', style: TextStyle(fontWeight: FontWeight.w800)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: heightCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Boy (sm) *', hintText: 'Məs: 160'),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: weightCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Çəki (kq) *', hintText: 'Məs: 52'),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: selectedBlood,
                      decoration: const InputDecoration(labelText: 'Qan Qrupu *'),
                      items: [
                        'A(II) Rh+',
                        'A(II) Rh-',
                        'B(III) Rh+',
                        'B(III) Rh-',
                        'AB(IV) Rh+',
                        'AB(IV) Rh-',
                        'O(I) Rh+',
                        'O(I) Rh-',
                      ].map((bg) => DropdownMenuItem(value: bg, child: Text(bg))).toList(),
                      onChanged: (v) => setDialogState(() => selectedBlood = v!),
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
                    final h = double.tryParse(heightCtrl.text.trim()) ?? 0.0;
                    final w = double.tryParse(weightCtrl.text.trim()) ?? 0.0;
                    appState.updateStudentPhysicalStats(
                      studentId: studentId,
                      heightCm: h,
                      weightKg: w,
                      bloodGroup: selectedBlood,
                    );
                    Navigator.pop(ctx);
                    onUpdated();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Boy, çəki və qan qrupu yeniləndi!'), backgroundColor: AppColors.success),
                    );
                  },
                  child: const Text('Yadda Saxla', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddAllergyQuickDialog(BuildContext context, AppState appState, String studentId, VoidCallback onAdded) {
    final nameCtrl = TextEditingController();
    final reactionCtrl = TextEditingController();
    String severity = 'Yüksək dərəcə';

    showDialog(
      context: context,
      builder: (dCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              title: const Text('Allergiya / Tibbi Qeyd Əlavə Et', style: TextStyle(fontWeight: FontWeight.w800)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Qeyd / Allergiya (Məs: Fındıq)')),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: severity,
                    decoration: const InputDecoration(labelText: 'Təhlükə Dərəcəsi'),
                    items: ['Orta dərəcə', 'Yüksək dərəcə', 'Kritik'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                    onChanged: (v) => setDialogState(() => severity = v!),
                  ),
                  const SizedBox(height: 10),
                  TextField(controller: reactionCtrl, decoration: const InputDecoration(labelText: 'Reaksiya Təsiri')),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dCtx), child: const Text('Ləğv et')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (nameCtrl.text.isNotEmpty) {
                      appState.addAllergyToStudent(
                        studentId,
                        AllergyItem(
                          name: nameCtrl.text.trim(),
                          severity: severity,
                          reaction: reactionCtrl.text.trim().isEmpty ? 'Allergik reaksiya' : reactionCtrl.text.trim(),
                          firstAid: 'Tibb otağına məlumat verilsin',
                        ),
                      );
                      Navigator.pop(dCtx);
                      onAdded();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tibbi qeyd uğurla əlavə edildi!'), backgroundColor: AppColors.success),
                      );
                    }
                  },
                  child: const Text('Əlavə Et', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddVaccineQuickDialog(BuildContext context, AppState appState, String studentId, VoidCallback onAdded) {
    final nameCtrl = TextEditingController(text: 'QPM (Qızılca, Parotit, Məxmərək)');
    final doctorCtrl = TextEditingController(text: 'Dr. Əliyeva N. (Məktəb Tibb Otağı)');
    String status = 'Tamamlandı';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              title: const Text('Peyvənd / Vaksina Qeydi', style: TextStyle(fontWeight: FontWeight.w800)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Peyvəndin Adı *', hintText: 'Məs: Hepatit B, QPM'),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: status,
                      decoration: const InputDecoration(labelText: 'Vuruluş Statusu'),
                      items: ['Tamamlandı', 'Növbəti doza gözlənilir', 'Müddəti çatıb'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (v) => setDialogState(() => status = v!),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: doctorCtrl,
                      decoration: const InputDecoration(labelText: 'Həkim / Tibb Müəssisəsi'),
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
                    if (nameCtrl.text.trim().isNotEmpty) {
                      final newVaccine = VaccineRecord(
                        name: nameCtrl.text.trim(),
                        date: DateTime.now(),
                        status: status,
                        doctor: doctorCtrl.text.trim().isNotEmpty ? doctorCtrl.text.trim() : 'Məktəb Tibb Otağı',
                      );
                      appState.addVaccineRecordToStudent(studentId, newVaccine);
                      Navigator.pop(ctx);
                      onAdded();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Peyvənd qeydi əlavə edildi!'), backgroundColor: AppColors.success),
                      );
                    }
                  },
                  child: const Text('Yadda Saxla', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
