import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/widgets/idrak_logo.dart';
import '../../../providers/app_state.dart';
import 'create_employee_screen.dart';
import 'admin_users_screen.dart';
import 'class_management_screen.dart';
import 'admin_timetable_management_screen.dart';
import 'qr_inventory_management_screen.dart';
import 'role_management_screen.dart';
import 'student_management_screen.dart';
import '../../parent/screens/parent_tickets_screen.dart';
import '../../parent/screens/grades_analytics_screen.dart';
import '../../student/screens/cafeteria_menu_screen.dart';
import '../../shared/screens/notifications_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final users = appState.users;
    final teacherCount = users.where((u) => u.role == UserRole.teacher).length;
    final studentCount = users.where((u) => u.role == UserRole.student).length;
    final parentCount = users.where((u) => u.role == UserRole.parent).length;
    final activeTickets = appState.tickets.length;

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
                    child: const Icon(Icons.cloud_sync_rounded, color: Colors.white, size: 18),
                  ),
                  tooltip: 'Firebase Bulud Sinxronizasiyası',
                  onPressed: () async {
                    await appState.initFirebaseData();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Firebase Firestore ilə məlumatlar sinxronizasiya edildi!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
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
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF1E3A8A)],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      bottom: -20,
                      child: Icon(Icons.admin_panel_settings_rounded, size: 140, color: Colors.white.withAlpha(8)),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 44, 20, 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.red.withAlpha(25),
                                    border: Border.all(color: Colors.red.withAlpha(60), width: 1.5),
                                  ),
                                  child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 26),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const IdrakLogo(size: 16),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AppColors.gold.withAlpha(30),
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: const Text(
                                              'MƏKTƏB İDARƏETMƏSİ',
                                              style: TextStyle(
                                                color: AppColors.goldLight,
                                                fontSize: 9.5,
                                                fontWeight: FontWeight.w800,
                                                letterSpacing: 0.8,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Baş İnzibatçı Paneli',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: -0.4,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'İdrak Liseyi • Sistem Nəzarəti',
                                        style: TextStyle(
                                          color: Colors.white.withAlpha(180),
                                          fontSize: 11.5,
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
                  // Fast Account Creator Banner
                  if (appState.hasPermission('add_users'))
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: AppShadows.md,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const CreateEmployeeScreen()),
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(25),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.person_add_rounded, color: Colors.white, size: 24),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Yeni İşçi Hesabı Yarat',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Bütün HR məlumatları, rol və avtomatik @idrak.edu.az mail ilə',
                                        style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(20),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // Stats 4-Grid Matrix
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 2.3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildAdminStatTile('Müəllimlər', '$teacherCount Nəfər', Icons.psychology_rounded, const Color(0xFF0D9488)),
                      _buildAdminStatTile('Şagirdlər', '$studentCount Nəfər', Icons.school_rounded, AppColors.primaryAccent),
                      _buildAdminStatTile('Valideynlər', '$parentCount Nəfər', Icons.family_restroom_rounded, AppColors.goldDark),
                      _buildAdminStatTile('Helpdesk', '$activeTickets Ticket', Icons.support_agent_rounded, Colors.purple),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Yaxınlaşan doğum günləri ( Firestore-dakı doğum tarixlərindən)
                  _buildBirthdaysCard(appState),

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'İnzibati Modullar',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.3),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'İcazələr, cədvəl və məktəb idarəetməsi',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      // Aktiv rol göstəricisi — səlahiyyət qapısının vəziyyətini dərhal göstərir
                      Builder(builder: (context) {
                        final role = appState.getRoleById(appState.currentUser?.assignedRoleId);
                        if (role == null) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.red.withAlpha(12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.red.withAlpha(40)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.admin_panel_settings_rounded, size: 12, color: Colors.red),
                                const SizedBox(width: 4),
                                Text('Tam Səlahiyyət', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Colors.red)),
                              ],
                            ),
                          );
                        }
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withAlpha(15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.gold.withAlpha(45)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.workspace_premium_rounded, size: 12, color: AppColors.goldDark),
                              const SizedBox(width: 4),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 90),
                                child: Text(
                                  role.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.goldDark),
                                ),
                              ),
                              const SizedBox(width: 3),
                              Text('(${role.permissionIds.length})', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: AppColors.goldDark)),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // 2-Column Admin Tools Grid (səlahiyyətə görə filtrlənir)
                  GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      if (appState.hasPermission('view_students'))
                        _buildAdminGridTile(
                          context: context,
                          title: 'Şagird İdarəsi',
                          subtitle: '${studentCount} qeydiyyatda şagird',
                          icon: Icons.school_rounded,
                          accentColor: AppColors.primaryAccent,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const StudentManagementScreen()),
                          ),
                        ),
                      if (appState.hasPermission('view_classes'))
                        _buildAdminGridTile(
                          context: context,
                          title: 'Sinif İdarəsi',
                          subtitle: '${appState.allDistinctClasses.length} Sinif yüksəlişi',
                          icon: Icons.class_rounded,
                          accentColor: const Color(0xFF0284C7),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ClassManagementScreen()),
                          ),
                        ),
                      if (appState.hasPermission('view_timetable'))
                        _buildAdminGridTile(
                          context: context,
                          title: 'Dərs Cədvəli',
                          subtitle: 'Cədvəl təyini',
                          icon: Icons.calendar_month_rounded,
                          accentColor: const Color(0xFF7C3AED),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AdminTimetableManagementScreen()),
                          ),
                        ),
                      if (appState.hasPermission('view_users'))
                        _buildAdminGridTile(
                          context: context,
                          title: 'İstifadəçilər',
                          subtitle: '${users.where((u) => u.role == UserRole.teacher || u.role == UserRole.admin).length} İşçi hesabı',
                          icon: Icons.manage_accounts_rounded,
                          accentColor: const Color(0xFF0D9488),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AdminUsersScreen()),
                          ),
                        ),
                      if (appState.hasPermission('view_roles'))
                        _buildAdminGridTile(
                          context: context,
                          title: 'Rol İdarəetməsi',
                          subtitle: 'Səlahiyyət təyini',
                          icon: Icons.admin_panel_settings_rounded,
                          accentColor: const Color(0xFFD97706),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RoleManagementScreen()),
                          ),
                        ),
                      if (appState.hasPermission('view_tickets'))
                        _buildAdminGridTile(
                          context: context,
                          title: 'Helpdesk',
                          subtitle: '$activeTickets Müraciət',
                          icon: Icons.support_agent_rounded,
                          accentColor: Colors.purple,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ParentTicketsScreen()),
                          ),
                        ),
                      if (appState.hasPermission('view_reports'))
                        _buildAdminGridTile(
                          context: context,
                          title: 'Statistika',
                          subtitle: 'KSQ / BSQ / IB',
                          icon: Icons.analytics_rounded,
                          accentColor: AppColors.primary,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const GradesAnalyticsScreen()),
                          ),
                        ),
                      if (appState.hasPermission('view_cafeteria'))
                        _buildAdminGridTile(
                          context: context,
                          title: 'Yeməkxana',
                          subtitle: 'Menyu təyini',
                          icon: Icons.restaurant_menu_rounded,
                          accentColor: AppColors.goldDark,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CafeteriaMenuScreen()),
                          ),
                        ),
                      if (appState.hasPermission('view_settings'))
                        _buildAdminGridTile(
                          context: context,
                          title: 'Toplu Elan',
                          subtitle: 'Rəsmi bildirişlər',
                          icon: Icons.campaign_rounded,
                          accentColor: const Color(0xFFEF4444),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                          ),
                        ),
                      if (appState.hasPermission('view_inventory'))
                        _buildAdminGridTile(
                          context: context,
                          title: 'QR İnventar',
                          subtitle: 'Texniki xidmət',
                          icon: Icons.qr_code_rounded,
                          accentColor: const Color(0xFF0D9488),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const QrInventoryManagementScreen()),
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
  }

  /// Yaxınlaşan doğum günləri — bütün istifadəçilərin (işçi/şagird/valideyn)
  /// doğum tarixlərindən növbəti 30 gün hesablanır.
  Widget _buildBirthdaysCard(AppState appState) {
    const monthNames = ['Yan', 'Fev', 'Mar', 'Apr', 'May', 'İyn', 'İyl', 'Avq', 'Sen', 'Okt', 'Noy', 'Dek'];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final entries = <({String name, String role, DateTime date, int days})>[];
    for (final u in appState.users) {
      final b = u.birthDate;
      if (b == null) continue;
      var next = DateTime(now.year, b.month, b.day);
      if (next.isBefore(today)) next = DateTime(now.year + 1, b.month, b.day);
      final days = next.difference(today).inDays;
      if (days > 30) continue;
      final roleLabel = switch (u.role) {
        UserRole.student => 'Şagird',
        UserRole.parent => 'Valideyn',
        UserRole.teacher => 'Müəllim',
        UserRole.admin => 'İşçi',
      };
      entries.add((name: u.fullName, role: roleLabel, date: next, days: days));
    }
    entries.sort((a, b) => a.days.compareTo(b.days));
    final upcoming = entries.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(color: AppColors.gold.withAlpha(15), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.cake_rounded, size: 17, color: AppColors.goldDark),
              ),
              const SizedBox(width: 10),
              Text('Yaxınlaşan Doğum Günləri', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.3)),
              const Spacer(),
              if (entries.length > 5)
                Text('+${entries.length - 5}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textMuted)),
            ],
          ),
          const SizedBox(height: 12),
          if (upcoming.isEmpty)
            Text('Növbəti 30 gündə doğum günü yoxdur.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary))
          else
            for (var i = 0; i < upcoming.length; i++) ...[
              if (i > 0) Divider(color: AppColors.cardBorder.withAlpha(60), height: 14),
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: upcoming[i].days == 0 ? AppColors.danger.withAlpha(12) : AppColors.primaryAccent.withAlpha(8),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: upcoming[i].days == 0 ? AppColors.danger.withAlpha(40) : AppColors.primaryAccent.withAlpha(25)),
                    ),
                    child: Text(
                      '${upcoming[i].date.day}',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        color: upcoming[i].days == 0 ? AppColors.danger : AppColors.primaryAccent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          upcoming[i].name,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                        Text(upcoming[i].role, style: TextStyle(fontSize: 10.5, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${upcoming[i].date.day} ${monthNames[upcoming[i].date.month - 1]}', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
                      Text(
                        upcoming[i].days == 0 ? 'Bugün! 🎉' : '${upcoming[i].days} gün sonra',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: upcoming[i].days == 0 ? AppColors.danger : AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ],
        ],
      ),
    );
  }

  Widget _buildAdminStatTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withAlpha(15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
                Text(
                  label,
                  style: TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminGridTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppShadows.sm,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: accentColor.withAlpha(15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: accentColor.withAlpha(30)),
                      ),
                      child: Icon(icon, color: accentColor, size: 20),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.cardBorder.withAlpha(60),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(Icons.arrow_outward_rounded, size: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
