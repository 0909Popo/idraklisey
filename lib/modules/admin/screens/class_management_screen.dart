import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_card.dart';
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
      appBar: AppBar(
        title: const Text('Ağıllı Sinif İdarəsi & Statistikalar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            tooltip: 'Yeni Sinif Əlavə Et',
            onPressed: () => _showAddClassDialog(context, appState),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddClassDialog(context, appState),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Yeni Sinif Əlavə Et', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Stats Banner
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF1E3A8A)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(50),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
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

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Məktəbin Bütün Sinifləri',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                  ),
                  Text(
                    '${classes.length} Sinif Aktivdir',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryAccent),
                  ),
                ],
              ),
            ),

            if (classes.isEmpty)
              Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(Icons.meeting_room_rounded, size: 64, color: AppColors.textMuted),
                      SizedBox(height: 12),
                      Text('Hələ heç bir sinif yaradılmayıb.', style: TextStyle(color: AppColors.textSecondary, fontSize: 15)),
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

                return CustomCard(
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
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withAlpha(15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.primary.withAlpha(40)),
                                ),
                                child: Text(
                                  cls,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary),
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
                                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // 🚀 Promote Class Button
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryAccent,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () => _showPromoteClassDialog(context, appState, cls),
                            icon: const Icon(Icons.upgrade_rounded, size: 16, color: Colors.white),
                            label: const Text('Sinifi Yüksəlt', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Stats Row: GPA & Attendance
                      Row(
                        children: [
                          _buildClassStatBadge('Orta GPA', avgGpa > 0 ? '$avgGpa / 5.0' : 'Qiymət Yoxdur', AppColors.primary),
                          const SizedBox(width: 8),
                          _buildClassStatBadge('Orta Davamiyyət', avgAtt > 0 ? '$avgAtt%' : 'Yeni', AppColors.success),
                          const SizedBox(width: 8),
                          _buildClassStatBadge('Müəllim Sayı', '${teachers.length} Müəllim', AppColors.goldDark),
                        ],
                      ),

                      if (teachers.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          children: teachers.map((t) => Chip(
                            avatar: const Icon(Icons.person_rounded, size: 14, color: AppColors.primary),
                            label: Text('${t.fullName} (${t.subject ?? "Müəllim"})', style: const TextStyle(fontSize: 10)),
                            backgroundColor: AppColors.background,
                            side: BorderSide(color: AppColors.cardBorder),
                            padding: EdgeInsets.zero,
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
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                            children: classStudents.map((st) {
                              return ListTile(
                                dense: true,
                                contentPadding: EdgeInsets.zero,
                                leading: CircleAvatar(
                                  radius: 16,
                                  backgroundImage: NetworkImage(st.photoUrl),
                                  onBackgroundImageError: (_, _) {},
                                  child: null, // No overlay icon
                                ),
                                title: Text(st.fullName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                subtitle: Text('ID: ${st.studentNumber} • Valideyn: ${st.parentName} (${st.parentPhone})', style: const TextStyle(fontSize: 11)),
                                trailing: StatusBadge(
                                  label: st.gpa > 0 ? 'GPA ${st.gpa}' : 'Yeni',
                                  color: st.gpa > 0 ? AppColors.primary : AppColors.textMuted,
                                  fontSize: 10,
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
    );
  }

  Widget _buildHeaderStatItem(String title, String val, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.goldLight, size: 24),
        const SizedBox(height: 4),
        Text(val, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
        Text(title, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildClassStatBadge(String title, String val, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withAlpha(40)),
        ),
        child: Column(
          children: [
            Text(val, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
            Text(title, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Yeni Sinif Əlavə Et'),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(labelText: 'Sinif Adı', hintText: 'Məs: 10B, 11A, 8A'),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Ləğv et')),
            ElevatedButton(
              onPressed: () {
                if (ctrl.text.trim().isNotEmpty) {
                  appState.addNewClass(ctrl.text.trim());
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Yeni sinif uğurla əlavə edildi!'), backgroundColor: AppColors.success),
                  );
                }
              },
              child: const Text('Əlavə Et'),
            ),
          ],
        );
      },
    );
  }

  void _showPromoteClassDialog(BuildContext context, AppState appState, String fromClass) {
    // Determine suggested next class (e.g. 9B -> 10B)
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('🚀 $fromClass Sinifini Yüksəlt'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$fromClass sinfindəki bütün şagirdlərin sinfi bir kliklə növbəti tədris sinfinə keçiriləcək.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: targetCtrl,
                decoration: const InputDecoration(labelText: 'Yeni Sinif Adı *', hintText: 'Məs: 10B'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Ləğv et')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryAccent),
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
              child: const Text('Yüksəlişi Təsdiqlə'),
            ),
          ],
        );
      },
    );
  }
}
