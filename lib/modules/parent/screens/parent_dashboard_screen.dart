import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/idrak_logo.dart';
import '../../../providers/app_state.dart';
import 'timetable_matrix_screen.dart';
import 'grades_analytics_screen.dart';
import 'attendance_calendar_screen.dart';
import 'medical_card_screen.dart';
import 'parent_tickets_screen.dart';

class ParentDashboardScreen extends StatelessWidget {
  const ParentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final student = appState.student;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Elegant Header with Student Profile
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                padding: const EdgeInsets.only(left: 20, right: 20, top: 45, bottom: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Student Photo with Gold Border
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.gold, width: 2.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(50),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 36,
                        backgroundImage: NetworkImage(student.photoUrl),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const IdrakLogo(size: 18),
                              const SizedBox(width: 6),
                              Text(
                                'VALİDEYN KABİNETİ',
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
                          Text(
                            student.fullName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${student.className} • ${student.studentNumber}',
                            style: const TextStyle(
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

          // Main Dashboard Body
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 4 Quick Stats Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _buildQuickStat('GPA Nəticəsi', '${student.gpa}', Icons.school_rounded, AppColors.primary, isDark: appState.isDarkMode),
                        const SizedBox(width: 8),
                        _buildQuickStat('Davamiyyət', '${student.attendanceRate}%', Icons.event_available_rounded, AppColors.success, isDark: appState.isDarkMode),
                        const SizedBox(width: 8),
                        _buildQuickStat('Qan Qrupu', 'A(II)+', Icons.favorite_rounded, AppColors.danger, isDark: appState.isDarkMode),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  const SectionHeader(
                    title: 'Əsas Bölmələr',
                    subtitle: 'Valideyn idarəetmə və nəzarət modulları',
                  ),

                  // 1. Həftəlik Matris Gündəlik Card
                  _buildModuleActionCard(
                    context: context,
                    title: 'Həftəlik Matris Gündəlik',
                    subtitle: 'B.E - Cümə tam grid cədvəl, dərslər və müəllimlər',
                    icon: Icons.grid_view_rounded,
                    accentColor: AppColors.primaryAccent,
                    tag: '5 Tədris Günü',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TimetableMatrixScreen()),
                    ),
                  ),

                  // 2. Qiymətlər və İnteraktiv Qrafiklər Card
                  _buildModuleActionCard(
                    context: context,
                    title: 'Qiymətlər & İnteraktiv Qrafiklər',
                    subtitle: 'KSQ, BSQ, Diaqnostik və IB STR dinamika diaqramları',
                    icon: Icons.insights_rounded,
                    accentColor: Colors.purple,
                    tag: 'Line & Bar Chart',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GradesAnalyticsScreen()),
                    ),
                  ),

                  // 3. Davamiyyət Təqvimi Card
                  _buildModuleActionCard(
                    context: context,
                    title: 'Davamiyyət Təqvimi',
                    subtitle: '🟢 İştirak, 🟡 Gecikmə, 🔴 Qayıb rəqəmsal rəngli aylıq təqvim',
                    icon: Icons.calendar_month_rounded,
                    accentColor: AppColors.success,
                    tag: 'Fevral 2025',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AttendanceCalendarScreen()),
                    ),
                  ),

                  // 4. Tibbi İzləmə Paneli Card
                  _buildModuleActionCard(
                    context: context,
                    title: 'Tibbi İzləmə Paneli (Rəqəmsal Kart)',
                    subtitle: 'Qan qrupu, allergiyalar (qlüten, qoz, penisillin), peyvəndlər',
                    icon: Icons.medical_services_rounded,
                    accentColor: AppColors.danger,
                    tag: 'Tibb Mərkəzi',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MedicalCardScreen()),
                    ),
                  ),

                  // 5. Helpdesk Ticket Müraciətlər Card
                  _buildModuleActionCard(
                    context: context,
                    title: 'Ünsiyyət & Elektron Müraciətlər',
                    subtitle: 'Rəhbərlik, psixoloq və müəllimlə birbaşa Ticket əlaqəsi',
                    icon: Icons.support_agent_rounded,
                    accentColor: AppColors.goldDark,
                    tag: 'Helpdesk Sistem',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ParentTicketsScreen()),
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

  Widget _buildQuickStat(String title, String value, IconData icon, Color color, {bool isDark = false}) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurface.withAlpha(190)
                  : Colors.white.withAlpha(190),
              borderRadius: BorderRadius.circular(14),
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
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withAlpha(30),
                    shape: BoxShape.circle,
                    border: Border.all(color: color.withAlpha(40)),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModuleActionCard({
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
            child: Icon(icon, color: accentColor, size: 28),
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
