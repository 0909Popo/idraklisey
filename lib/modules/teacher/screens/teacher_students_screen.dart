import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_card.dart';
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
      appBar: AppBar(
        title: const Text('Şagirdlər Kataloqu & Profilləri'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task_rounded),
            tooltip: 'Tapşırıq Ver',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateAssignmentScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Şagird adı, İdrak kodu və ya sinif axtar...',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                ),
                if (classes.length > 1) ...[
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: classes.map((c) {
                        final isSelected = _selectedClass == c;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(c),
                            selected: isSelected,
                            onSelected: (val) {
                              if (val) setState(() => _selectedClass = c);
                            },
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            ),
                            backgroundColor: Colors.white,
                            side: BorderSide(color: isSelected ? AppColors.primary : AppColors.cardBorder),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Students List
          Expanded(
            child: students.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.person_search_rounded, size: 64, color: AppColors.textMuted),
                          SizedBox(height: 14),
                          Text(
                            'Sistemdə hələ heç bir şagird qeydiyyatdan keçməyib.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Yeni şagird və valideyn hesabları Məktəb İnzibatçısı (Admin) tərəfindən yaradılır.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  )
                : filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.search_off_rounded, size: 48, color: AppColors.textMuted),
                            SizedBox(height: 8),
                            Text('Axtarışa uyğun şagird tapılmadı.', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final student = filtered[index];
                          return _buildStudentListItem(context, appState, student);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentListItem(BuildContext context, AppState appState, StudentProfile student) {
    final gpaText = student.gpa > 0 ? 'GPA: ${student.gpa}' : 'Yeni Şagird';

    return CustomCard(
      onTap: () => _showStudentDetailsModal(context, appState, student),
      child: Row(
        children: [
          // Photo with fallback
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 56,
              height: 56,
              color: AppColors.primary.withAlpha(20),
              child: Image.network(
                student.photoUrl,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => const Icon(Icons.person_rounded, color: AppColors.primary, size: 28),
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
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    StatusBadge(
                      label: student.className,
                      color: AppColors.primaryAccent,
                      fontSize: 10,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${student.studentNumber} • $gpaText',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.family_restroom_rounded, size: 14, color: AppColors.goldDark),
                    const SizedBox(width: 4),
                    Text(
                      'Valideyn: ${student.parentName}',
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
        ],
      ),
    );
  }

  void _showStudentDetailsModal(BuildContext context, AppState appState, StudentProfile student) {
    final canEditMedical = appState.currentUser?.role == UserRole.admin ||
        (appState.currentUser?.teacherPermissions?.canManageMedical ?? false);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            final currentMed = appState.getMedicalCardForStudent(student.id);
            final gpaDisplay = student.gpa > 0 ? '${student.gpa}' : 'Yeni';
            final attDisplay = student.attendanceRate > 0 ? '${student.attendanceRate}%' : 'Yeni';

            return Container(
              height: MediaQuery.of(context).size.height * 0.90,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 50,
                              height: 50,
                              color: AppColors.primary.withAlpha(20),
                              child: Image.network(
                                student.photoUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (c, err, stack) => const Icon(Icons.person, color: AppColors.primary),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student.fullName,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                              ),
                              Text(
                                '${student.className} • ${student.studentNumber}',
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close_rounded)),
                    ],
                  ),

                  const SizedBox(height: 12),
                  const Divider(),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Quick Stats Row
                          Row(
                            children: [
                              _buildDetailStat('GPA (Ortalama)', gpaDisplay, AppColors.primary),
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

                          const SizedBox(height: 14),

                          // 📊 Academic Performance Box: Teacher's Subject vs Overall Average
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
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppColors.primary.withAlpha(80), width: 1.5),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withAlpha(15),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
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
                                            const Icon(Icons.school_rounded, color: AppColors.primary, size: 20),
                                            const SizedBox(width: 6),
                                            Text(
                                              teacherSub.isNotEmpty ? 'Sizin Fənniniz (${appState.currentUser?.subject})' : 'Akademik Göstəricilər',
                                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.primary),
                                            ),
                                          ],
                                        ),
                                        StatusBadge(
                                          label: mySubjectGrades.isNotEmpty ? '${myAvg.toStringAsFixed(1)} / 100 Bal' : 'Qiymət yoxdur',
                                          color: AppColors.primary,
                                          fontSize: 10,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Məktəb üzrə ümumi ortalama: ${student.gpa.toStringAsFixed(2)} GPA (${studentGrades.length} qiymət)',
                                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                                    ),
                                    if (mySubjectGrades.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      const Divider(height: 1),
                                      const SizedBox(height: 6),
                                      ...mySubjectGrades.take(3).map((g) => Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 2),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '• ${g.title}',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                                              ),
                                            ),
                                            Text(
                                              '${g.displayScore.toInt()} / ${g.maxScore.toInt()}',
                                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
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

                          // 📐 Physical Stats & Automatic BMI Box
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: currentMed.bmiColor.withAlpha(80), width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: currentMed.bmiColor.withAlpha(20),
                                  blurRadius: 10,
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
                                      children: const [
                                        Icon(Icons.accessibility_new_rounded, color: AppColors.primary, size: 20),
                                        SizedBox(width: 6),
                                        Text('Fiziki İnkişaf & BMI Göstəricisi', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.textPrimary)),
                                      ],
                                    ),
                                    if (canEditMedical)
                                      TextButton.icon(
                                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                                        onPressed: () {
                                          _showEditPhysicalStatsDialog(context, appState, student.id, currentMed, () {
                                            setSheetState(() {});
                                          });
                                        },
                                        icon: const Icon(Icons.edit_note_rounded, size: 16),
                                        label: const Text('Redaktə Et', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    _buildBmiStatSub('Boy', currentMed.heightCm > 0 ? '${currentMed.heightCm.toInt()} sm' : 'Qeyd yoxdur'),
                                    Container(height: 25, width: 1, color: AppColors.cardBorder),
                                    _buildBmiStatSub('Çəki', currentMed.weightKg > 0 ? '${currentMed.weightKg.toInt()} kq' : 'Qeyd yoxdur'),
                                    Container(height: 25, width: 1, color: AppColors.cardBorder),
                                    _buildBmiStatSub('BMI İndeksi', currentMed.bmiDisplay),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                StatusBadge(
                                  label: currentMed.bmiCategory,
                                  color: currentMed.bmiColor,
                                  fontSize: 11,
                                ),
                                if (currentMed.bmiWarning != null) ...[
                                  const SizedBox(height: 8),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: currentMed.bmiColor.withAlpha(20),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      currentMed.bmiWarning!,
                                      style: TextStyle(fontSize: 11, color: currentMed.bmiColor, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Parent Info Box with Direct Notification Action
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('👨‍👩‍👧 Valideyn Əlaqə Məlumatları', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.goldDark)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withAlpha(15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Text('Rəsmi Qəyyum', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text('Adı: ${student.parentName}', style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 2),
                                Text('Telefon: ${student.parentPhone}', style: const TextStyle(fontSize: 13, color: AppColors.primaryAccent, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 10),

                                // Direct Contact Button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0F172A),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      padding: const EdgeInsets.symmetric(vertical: 10),
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
                                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Health & Medical Card Section
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('🩺 Sağlamlıq & Allergiya Qeydləri', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.danger)),
                              TextButton.icon(
                                onPressed: () {
                                  _showAddAllergyQuickDialog(context, appState, student.id, () {
                                    setSheetState(() {});
                                  });
                                },
                                icon: const Icon(Icons.add_circle_outline_rounded, size: 16, color: AppColors.danger),
                                label: const Text('Qeyd Əlavə Et', style: TextStyle(fontSize: 12, color: AppColors.danger, fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          if (currentMed.allergies.isNotEmpty)
                            ...currentMed.allergies.map((allergy) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF2F2),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.danger.withAlpha(50)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.danger),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(allergy.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                          Text('Reaksiya: ${allergy.reaction}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
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
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text('Allergiya və ya xəstəlik qeydi yoxdur.', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                            ),

                          const SizedBox(height: 16),

                          // 💉 Vaccine / Immunization History
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('💉 Peyvənd & Vaksina Təqvimi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.primary)),
                              if (canEditMedical)
                                TextButton.icon(
                                  onPressed: () {
                                    _showAddVaccineQuickDialog(context, appState, student.id, () {
                                      setSheetState(() {});
                                    });
                                  },
                                  icon: const Icon(Icons.add_circle_outline_rounded, size: 16, color: AppColors.primary),
                                  label: const Text('Peyvənd Əlavə Et', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),

                          if (currentMed.vaccineHistory.isNotEmpty)
                            ...currentMed.vaccineHistory.map((v) {
                              final isDone = v.status == 'Tamamlandı';
                              return Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.cardBorder),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(v.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                                          Text('${v.doctor} • ${v.date.day}.${v.date.month}.${v.date.year}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
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
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text('Peyvənd qeydi daxil edilməyib.', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                            ),

                          // 👨‍👩‍👧 Parent Notes for this student (if any)
                          if (currentMed.parentNotes.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            const Text('👨‍👩‍👧 Valideynin Xüsusi Qeydləri', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.goldDark)),
                            const SizedBox(height: 6),
                            ...currentMed.parentNotes.map((note) => Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFBEB),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.goldLight),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(note.parentName, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.goldDark)),
                                      Text('${note.date.day}.${note.date.month}.${note.date.year}', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(note.note, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
                                ],
                              ),
                            )),
                          ],

                          const SizedBox(height: 20),

                          // Action Buttons: Assign Homework & Grade
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryAccent,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                                  icon: const Icon(Icons.add_task_rounded, size: 18),
                                  label: const Text('Tapşırıq Ver', style: TextStyle(fontSize: 13, color: Colors.white)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => const QuickGradingScreen()),
                                    );
                                  },
                                  icon: const Icon(Icons.grade_rounded, size: 18),
                                  label: const Text('Qiymətləndir', style: TextStyle(fontSize: 13, color: Colors.white)),
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
          Text(val, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.textPrimary)),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildDetailStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withAlpha(40)),
        ),
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: color),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Fiziki və Tibbi Göstəricilər'),
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
                  child: const Text('Yadda Saxla'),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Şagirdə Allergiya / Tibbi Qeyd Əlavə Et'),
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
                  child: const Text('Əlavə Et'),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Peyvənd / Vaksina Qeydi Əlavə Et'),
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
                  child: const Text('Yadda Saxla'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
