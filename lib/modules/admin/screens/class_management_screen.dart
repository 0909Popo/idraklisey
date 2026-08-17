import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/widgets/status_badge.dart';
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

                            if (teachers.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: teachers.map((t) => Container(
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
                                )).toList(),
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

  void _showAddClassDialog(BuildContext context, AppState appState) {
    final ctrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: const Text('Yeni Sinif Əlavə Et', style: TextStyle(fontWeight: FontWeight.w800)),
          content: TextField(
            controller: ctrl,
            decoration: InputDecoration(
              labelText: 'Sinif Adı',
              hintText: 'Məs: 10B, 11A, 8A',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
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
                  appState.addNewClass(ctrl.text.trim());
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Yeni sinif uğurla əlavə edildi!'), backgroundColor: AppColors.success),
                  );
                }
              },
              child: const Text('Əlavə Et', style: TextStyle(color: Colors.white)),
            ),
          ],
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
