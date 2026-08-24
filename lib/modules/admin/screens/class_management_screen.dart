import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/models/user_model.dart';
import '../../../providers/app_state.dart';

class ClassManagementScreen extends StatefulWidget {
  const ClassManagementScreen({super.key});

  @override
  State<ClassManagementScreen> createState() => _ClassManagementScreenState();
}

class _ClassManagementScreenState extends State<ClassManagementScreen> {
  final _newClassCtrl = TextEditingController();

  @override
  void dispose() {
    _newClassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final classes = appState.allDistinctClasses;
    final totalStudents = appState.students.length;

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
                    child: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
                  ),
                  tooltip: 'Yeni Sinif Əlavə Et',
                  onPressed: () => _showAddClassDialog(context, appState),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0284C7)],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -15,
                      bottom: -15,
                      child: Icon(Icons.school_rounded, size: 130, color: Colors.white.withAlpha(10)),
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
                                  child: const Icon(Icons.class_rounded, size: 22, color: Colors.white),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Ağıllı Sinif İdarəsi',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${classes.length} aktiv sinif • Statistikalar',
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

          // ── Content Body ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Stats Banner
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF1E3A8A)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppShadows.md,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildHeaderStatItem('Cəmi Siniflər', '${classes.length}', Icons.class_rounded),
                        Container(height: 36, width: 1, color: Colors.white24),
                        _buildHeaderStatItem('Cəmi Şagird', '$totalStudents', Icons.school_rounded),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Məktəbin Bütün Sinifləri',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.3),
                      ),
                      Text(
                        '${classes.length} Sinif Aktivdir',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryAccent),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  if (classes.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Icon(Icons.meeting_room_rounded, size: 54, color: AppColors.textMuted),
                            const SizedBox(height: 12),
                            Text('Hələ heç bir sinif yaradılmayıb.', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                          ],
                        ),
                      ),
                    )
                  else
                    ...classes.map((cls) {
                      final classStudents = appState.getStudentsForClass(cls);
                      final avgGpa = appState.getClassAverageGpa(cls);
                      final avgAtt = appState.getClassAverageAttendance(cls);

                      // Find teachers assigned to this class
                      final teachers = appState.users.where((u) => u.role == UserRole.teacher && u.assignedClasses.contains(cls)).toList();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.cardBorder),
                          boxShadow: AppShadows.sm,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header Row: Class name & Promote Button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryAccent.withAlpha(15),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppColors.primaryAccent.withAlpha(35)),
                                      ),
                                      child: Text(
                                        cls,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primaryAccent),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '$cls Sinfi',
                                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                                        ),
                                        Text(
                                          '${classStudents.length} Şagird Qeydiyyatda',
                                          style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                // Promote Class Button
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryAccent,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    elevation: 0,
                                  ),
                                  onPressed: () => _showPromoteClassDialog(context, appState, cls),
                                  icon: const Icon(Icons.upgrade_rounded, size: 16, color: Colors.white),
                                  label: const Text('Sinifi Yüksəlt', style: TextStyle(fontSize: 11.5, color: Colors.white, fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),

                            const SizedBox(height: 14),

                            // Stats Row: GPA & Attendance
                            Row(
                              children: [
                                _buildClassStatBadge('Orta GPA', avgGpa > 0 ? '$avgGpa / 5.0' : 'Yoxdur', AppColors.primaryAccent),
                                const SizedBox(width: 8),
                                _buildClassStatBadge('Davamiyyət', avgAtt > 0 ? '$avgAtt%' : 'Yeni', AppColors.success),
                                const SizedBox(width: 8),
                                _buildClassStatBadge('Müəllimlər', '${teachers.length} Müəllim', AppColors.goldDark),
                              ],
                            ),

                            // Sinif detalları (otaq, rəhbər, il, qeyd)
                            Builder(builder: (context) {
                              final details = appState.classDetails(cls);
                              final curator = details?.curatorTeacherId == null
                                  ? null
                                  : appState.users.where((u) => u.id == details!.curatorTeacherId).isEmpty
                                      ? null
                                      : appState.users.firstWhere((u) => u.id == details!.curatorTeacherId);
                              final hasDetails = (details?.room ?? '').isNotEmpty ||
                                  curator != null ||
                                  (details?.note ?? '').isNotEmpty ||
                                  (details?.academicYear ?? '').isNotEmpty;
                              if (!hasDetails) return const SizedBox.shrink();
                              return Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(top: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: AppColors.cardBorder),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.primaryAccent),
                                        const SizedBox(width: 6),
                                        Text('Sinif Detalları', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    if ((details?.room ?? '').isNotEmpty)
                                      _classDetailRow(Icons.meeting_room_rounded, 'Otaq: ${details!.room}'),
                                    if (curator != null)
                                      _classDetailRow(Icons.person_rounded, 'Sinif rəhbəri: ${curator.fullName}'),
                                    if ((details?.academicYear ?? '').isNotEmpty)
                                      _classDetailRow(Icons.calendar_today_rounded, 'Təhsil ili: ${details!.academicYear}'),
                                    if ((details?.note ?? '').isNotEmpty)
                                      _classDetailRow(Icons.notes_rounded, details!.note!),
                                  ],
                                ),
                              );
                            }),

                            if (teachers.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: teachers.map((t) => GestureDetector(
                                  onTap: () => _showTeacherDetailSheet(context, appState, t),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppColors.cardBorder),
                                    ),
                                    child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.person_rounded, size: 13, color: AppColors.primaryAccent),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${t.fullName} (${t.subject ?? "Müəllim"})',
                                        style: TextStyle(fontSize: 10.5, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                  ),
                                )).toList(),
                              ),

                              // Müəllim təyin et düyməsi
                              const SizedBox(height: 8),
                              GestureDetector(
                                onTap: () => _showAssignTeacherDialog(context, appState, cls),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.gold.withAlpha(12),
                                    borderRadius: BorderRadius.circular(9),
                                    border: Border.all(color: AppColors.gold.withAlpha(40)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.person_add_alt_rounded, size: 13, color: AppColors.goldDark),
                                      const SizedBox(width: 5),
                                      Text('Sinfə Müəllim Təyin Et', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.goldDark)),
                                    ],
                                  ),
                                ),
                              ),
                            ],

                            // Expandable Students List
                            if (classStudents.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Theme(
                                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                                child: ExpansionTile(
                                  tilePadding: EdgeInsets.zero,
                                  title: Text(
                                    '👥 $cls Şagirdlərinin Siyahısı (${classStudents.length})',
                                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.primaryAccent),
                                  ),
                                  children: classStudents.map((st) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 4),
                                      child: Row(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(color: AppColors.primaryAccent.withAlpha(30)),
                                            ),
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(9),
                                              child: Container(
                                                width: 36,
                                                height: 36,
                                                color: AppColors.primaryAccent.withAlpha(12),
                                                child: Image.network(
                                                  st.photoUrl,
                                                  width: 36,
                                                  height: 36,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) => const Icon(Icons.person_rounded, size: 20, color: AppColors.primaryAccent),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(st.fullName, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                                                Text('ID: ${st.studentNumber} • Valideyn: ${st.parentName}', style: TextStyle(fontSize: 10.5, color: AppColors.textSecondary)),
                                              ],
                                            ),
                                          ),
                                          StatusBadge(
                                            label: st.gpa > 0 ? 'GPA ${st.gpa}' : 'Yeni',
                                            color: st.gpa > 0 ? AppColors.primaryAccent : AppColors.textMuted,
                                            fontSize: 9.5,
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddClassDialog(context, appState),
        backgroundColor: AppColors.primaryAccent,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Yeni Sinif Əlavə Et', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildHeaderStatItem(String title, String val, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.goldLight, size: 22),
        const SizedBox(height: 4),
        Text(val, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
        Text(title, style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildClassStatBadge(String title, String val, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withAlpha(10),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withAlpha(30)),
        ),
        child: Column(
          children: [
            Text(val, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 2),
            Text(title, style: TextStyle(fontSize: 9.5, color: color.withAlpha(200), fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _classDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 13, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  /// Müəllim chipinə basılanda: bütün detalları — fənn, otaq, təyin olunan
  /// siniflər, əlaqə məlumatları
  void _showTeacherDetailSheet(BuildContext context, AppState appState, AppUser teacher) {
    final dateFormat = DateFormat('dd.MM.yyyy');
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 30),
            children: [
              Center(child: Container(width: 42, height: 4.5, decoration: BoxDecoration(color: AppColors.cardBorder, borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                      image: teacher.photoUrl != null
                          ? DecorationImage(image: NetworkImage(teacher.photoUrl!), fit: BoxFit.cover, onError: (_, __) {})
                          : null,
                      color: AppColors.background,
                    ),
                    child: teacher.photoUrl == null ? const Icon(Icons.psychology_rounded, color: Color(0xFF0D9488)) : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(teacher.fullName, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.3)),
                        const SizedBox(height: 3),
                        Text('Fənn: ${teacher.subject ?? "Təyin edilməyib"}', style: TextStyle(fontSize: 12, color: AppColors.primaryAccent, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _teacherDetailBox(
                icon: Icons.school_rounded,
                title: 'Təyin Olunan Siniflər (${teacher.assignedClasses.length})',
                color: const Color(0xFF0D9488),
                children: teacher.assignedClasses.isEmpty
                    ? [Text('Hələ sinif təyin edilməyib', style: TextStyle(fontSize: 12, color: AppColors.textMuted))]
                    : [
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final cls in teacher.assignedClasses)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0D9488).withAlpha(12),
                                  borderRadius: BorderRadius.circular(9),
                                  border: Border.all(color: const Color(0xFF0D9488).withAlpha(40)),
                                ),
                                child: Text(cls, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Color(0xFF0D9488))),
                              ),
                          ],
                        ),
                      ],
              ),
              const SizedBox(height: 12),
              _teacherDetailBox(
                icon: Icons.badge_rounded,
                title: 'Şəxsi Məlumatlar',
                color: AppColors.primaryAccent,
                children: [
                  if (teacher.fatherName != null) _classDetailRow(Icons.person_rounded, 'Ata adı: ${teacher.fatherName}'),
                  if (teacher.gender != null) _classDetailRow(Icons.wc_rounded, 'Cins: ${teacher.gender}'),
                  if (teacher.birthDate != null) _classDetailRow(Icons.cake_rounded, 'Doğum: ${dateFormat.format(teacher.birthDate!)}'),
                  if (teacher.finCode != null) _classDetailRow(Icons.pin_rounded, 'FIN: ${teacher.finCode}'),
                  if (teacher.phone.isNotEmpty) _classDetailRow(Icons.phone_rounded, 'Telefon: ${teacher.phone}'),
                  if (teacher.email != null) _classDetailRow(Icons.alternate_email_rounded, teacher.email!),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _teacherDetailBox({required IconData icon, required String title, required Color color, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 7),
              Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 9),
          ...children,
        ],
      ),
    );
  }

  /// Sinfə müəllim təyin etmə dialoqu
  void _showAssignTeacherDialog(BuildContext context, AppState appState, String className) {
    String? teacherId;
    final subjectCtrl = TextEditingController();
    bool isCurator = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              title: Text('$className — Müəllim Təyin Et', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    value: teacherId,
                    decoration: InputDecoration(
                      labelText: 'Müəllim *',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    items: [
                      for (final t in appState.users.where((u) => u.role == UserRole.teacher))
                        DropdownMenuItem(
                          value: t.id,
                          child: Text(
                            '${t.fullName} (${t.subject ?? "Müəllim"})${t.assignedClasses.contains(className) ? " ✓" : ""}',
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                    ],
                    onChanged: (v) {
                      setDialog(() => teacherId = v);
                      final t = appState.users.where((u) => u.id == v).isEmpty ? null : appState.users.firstWhere((u) => u.id == v);
                      if (t != null && (t.subject ?? '').isNotEmpty) {
                        subjectCtrl.text = t.subject!;
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: subjectCtrl,
                    decoration: InputDecoration(
                      labelText: 'Bu sinifdə oxudulan fənn',
                      hintText: 'Məs: Riyaziyyat',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Sinif rəhbəri kimi təyin et', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    value: isCurator,
                    activeThumbColor: AppColors.gold,
                    onChanged: (v) => setDialog(() => isCurator = v),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Ləğv et')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (teacherId != null) {
                      appState.assignTeacherToClass(
                        teacherId: teacherId!,
                        className: className,
                        subject: subjectCtrl.text.trim().isEmpty ? null : subjectCtrl.text.trim(),
                        isClassTeacher: isCurator,
                      );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Müəllim sinifə təyin edildi!'), backgroundColor: AppColors.success),
                      );
                    }
                  },
                  child: const Text('Təyin Et', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddClassDialog(BuildContext context, AppState appState) {
    final ctrl = TextEditingController();
    final roomCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    String academicYear = '2025 - 2026';
    String? curatorId;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              title: const Text('Yeni Sinif Yarat', style: TextStyle(fontWeight: FontWeight.w800)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: ctrl,
                      decoration: InputDecoration(
                        labelText: 'Sinif Adı *',
                        hintText: 'Məs: 10B, 11A, 8A',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: roomCtrl,
                      decoration: InputDecoration(
                        labelText: 'Sinif Otağı',
                        hintText: 'Məs: Otaq 305',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: curatorId,
                      decoration: InputDecoration(
                        labelText: 'Sinif Rəhbəri (Kurator)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Seçilməyib', style: TextStyle(fontSize: 13))),
                        for (final t in appState.users.where((u) => u.role == UserRole.teacher))
                          DropdownMenuItem(value: t.id, child: Text(t.fullName, style: const TextStyle(fontSize: 13))),
                      ],
                      onChanged: (v) => setDialog(() => curatorId = v),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: academicYear,
                      decoration: InputDecoration(
                        labelText: 'Təhsil İli',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      items: const [
                        DropdownMenuItem(value: '2025 - 2026', child: Text('2025 - 2026', style: TextStyle(fontSize: 13))),
                        DropdownMenuItem(value: '2024 - 2025', child: Text('2024 - 2025', style: TextStyle(fontSize: 13))),
                        DropdownMenuItem(value: '2026 - 2027', child: Text('2026 - 2027', style: TextStyle(fontSize: 13))),
                      ],
                      onChanged: (v) => setDialog(() => academicYear = v!),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Qeyd',
                        hintText: 'Sinif haqqında əlavə məlumat...',
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
                    if (ctrl.text.trim().isNotEmpty) {
                      appState.addNewClass(
                        ctrl.text.trim(),
                        room: roomCtrl.text.trim().isEmpty ? null : roomCtrl.text.trim(),
                        curatorTeacherId: curatorId,
                        academicYear: academicYear,
                        note: noteCtrl.text.trim().isEmpty ? null : noteCtrl.text.trim(),
                      );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Yeni sinif uğurla yaradıldı!'), backgroundColor: AppColors.success),
                      );
                    }
                  },
              child: const Text('Yarat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        );
        },
      );
      },
    );
  }

  void _showPromoteClassDialog(BuildContext context, AppState appState, String fromClass) {
    final match = RegExp(r'^(\d+)(.*)$').firstMatch(fromClass);
    String suggested = '';
    if (match != null) {
      final gradeNum = int.tryParse(match.group(1)!) ?? 9;
      final suffix = match.group(2) ?? '';
      if (gradeNum >= 11) {
        suggested = 'Məzun-$fromClass';
      } else {
        suggested = '${gradeNum + 1}$suffix';
      }
    } else {
      suggested = '$fromClass-Yüksəldilmiş';
    }

    final targetCtrl = TextEditingController(text: suggested);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: Text('🚀 $fromClass Sinifini Yüksəlt', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$fromClass sinfindəki bütün şagirdlərin sinfi bir kliklə növbəti tədris sinfinə keçiriləcək.',
                style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: targetCtrl,
                decoration: InputDecoration(
                  labelText: 'Yeni Sinif Adı *',
                  hintText: 'Məs: 10B',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Ləğv et')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                if (targetCtrl.text.trim().isNotEmpty) {
                  final toClass = targetCtrl.text.trim();
                  appState.promoteClass(fromClass, toClass);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$fromClass sinfi uğurla $toClass sinfinə yüksəldildi!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              child: const Text('Yüksəlişi Təsdiqlə', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
