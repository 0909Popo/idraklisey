import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/idrak_logo.dart';
import '../../../providers/app_state.dart';
import 'create_account_dialog.dart';
import 'admin_users_screen.dart';
import 'class_management_screen.dart';
import 'qr_inventory_management_screen.dart';
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
        slivers: [
          // Admin Hero Header
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            backgroundColor: const Color(0xFF0F172A),
            actions: [
              IconButton(
                icon: const Icon(Icons.cloud_sync_rounded, color: Colors.white),
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
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0F2552)],
                  ),
                ),
                padding: const EdgeInsets.only(left: 20, right: 20, top: 45, bottom: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red.withAlpha(40),
                        border: Border.all(color: Colors.red, width: 2),
                      ),
                      child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 36),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              IdrakLogo(size: 18),
                              SizedBox(width: 6),
                              Text(
                                'MƏKTƏB İDARƏETMƏSİ',
                                style: TextStyle(
                                  color: AppColors.goldLight,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.0,
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
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'İdrak Liseyi • Bütün Sistemə Tam Nəzarət',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Main Admin Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fast Account Creator Banner
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFF3B82F6)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryAccent.withAlpha(70),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => const CreateAccountDialog(),
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Row(
                            children: [
                              ClipOval(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withAlpha(35),
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white.withAlpha(50)),
                                    ),
                                    child: const Icon(Icons.person_add_rounded, color: Colors.white, size: 28),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Yeni Müəllim / Şagird Hesabı Yarat',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'İdrak kodu təyini, şifrə verilməsi və əlaqəli valideyn yaratmaq',
                                      style: TextStyle(color: Colors.white70, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // School Stats Cards (Grid 2x2)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _buildStatBox('Müəllimlər', '$teacherCount Nəfər', Icons.psychology_rounded, const Color(0xFF0D9488), isDark: appState.isDarkMode),
                        const SizedBox(width: 8),
                        _buildStatBox('Şagirdlər', '$studentCount Nəfər', Icons.school_rounded, AppColors.primaryAccent, isDark: appState.isDarkMode),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _buildStatBox('Valideynlər', '$parentCount Nəfər', Icons.family_restroom_rounded, AppColors.goldDark, isDark: appState.isDarkMode),
                        const SizedBox(width: 8),
                        _buildStatBox('Müraciətlər', '$activeTickets Ticket', Icons.support_agent_rounded, Colors.purple, isDark: appState.isDarkMode),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  const SectionHeader(
                    title: 'İnzibati İdarəetmə Modulları',
                    subtitle: 'Hesablar, icazələr və məktəb monitorinqi',
                  ),

                  // 0. Smart Class Management
                  _buildAdminToolCard(
                    context: context,
                    title: 'Ağıllı Sinif İdarəsi & Yüksəliş',
                    subtitle: 'Bütün siniflər, şagird təyini, sinifi növbəti ilə yüksəltmə və orta GPA',
                    icon: Icons.school_rounded,
                    accentColor: const Color(0xFF0284C7),
                    tag: '${appState.allDistinctClasses.length} Sinif',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ClassManagementScreen()),
                    ),
                  ),

                  // 1. Users & Permissions Directory
                  _buildAdminToolCard(
                    context: context,
                    title: 'İstifadəçi Hesabları & Yetkilər',
                    subtitle: 'Bütün müəllim, şagird və valideyn logini, şifrələri və icazələri',
                    icon: Icons.manage_accounts_rounded,
                    accentColor: const Color(0xFF0D9488),
                    tag: '${users.length} İstifadəçi',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminUsersScreen()),
                    ),
                  ),

                  // 2. School Wide Helpdesk & Tickets
                  _buildAdminToolCard(
                    context: context,
                    title: 'Məktəb Helpdesk & Müraciətlər',
                    subtitle: 'Valideynlərin və müəllimlərin göndərdiyi bütün rəsmi ticketlər',
                    icon: Icons.support_agent_rounded,
                    accentColor: Colors.purple,
                    tag: '$activeTickets Müraciət',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ParentTicketsScreen()),
                    ),
                  ),

                  // 3. School Academic Analytics
                  _buildAdminToolCard(
                    context: context,
                    title: 'Ümumi Tədris & Qiymət Statistikası',
                    subtitle: 'KSQ, BSQ və IB STR üzrə ümumi lisey tərəqqi qrafikləri',
                    icon: Icons.analytics_rounded,
                    accentColor: AppColors.primary,
                    tag: 'Qrafiklər',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GradesAnalyticsScreen()),
                    ),
                  ),

                  // 4. Cafeteria & Daily Menu Management
                  _buildAdminToolCard(
                    context: context,
                    title: 'Yeməkxana & Günlük Menyu İdarəsi',
                    subtitle: 'Həftəlik menyunu təyin etmək, yemək əlavə etmək, kalori və allergenləri idarə etmək',
                    icon: Icons.restaurant_menu_rounded,
                    accentColor: AppColors.goldDark,
                    tag: 'Kantin Menyu',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CafeteriaMenuScreen()),
                    ),
                  ),

                  // 5. School-wide Notifications & Broadcasts
                  _buildAdminToolCard(
                    context: context,
                    title: 'Rəsmi Bildiriş & Elan Sistemi',
                    subtitle: 'Müəllimlərə, şagirdlərə və ya valideynlərə toplu rəsmi bildiriş göndər',
                    icon: Icons.campaign_rounded,
                    accentColor: const Color(0xFFEF4444),
                    tag: 'Toplu Elan',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                    ),
                  ),

                  // 6. QR Inventory Registry
                  _buildAdminToolCard(
                    context: context,
                    title: 'QR İnventar Reyestri',
                    subtitle: 'Avadanlıqları QR ilə qeydiyyata al, kodu çap et — müəllim skan etdikdə cihaz avtomatik tanınar',
                    icon: Icons.qr_code_rounded,
                    accentColor: const Color(0xFF0D9488),
                    tag: 'Texniki Xidmət',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const QrInventoryManagementScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon, Color color, {bool isDark = false}) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurface.withAlpha(190)
                  : Colors.white.withAlpha(190),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.white.withAlpha(28) : Colors.white.withAlpha(50),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(10),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withAlpha(40)),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        value,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                      ),
                      Text(
                        label,
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminToolCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required String tag,
    required VoidCallback onTap,
  }) {
    return CustomCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: accentColor.withAlpha(22),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accentColor, size: 26),
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
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    StatusBadge(
                      label: tag,
                      color: accentColor,
                      fontSize: 10,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
