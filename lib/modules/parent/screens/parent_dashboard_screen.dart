import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
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
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Floating Parent Header Bar
            SliverAppBar(
              expandedHeight: 130.0,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: AppColors.primary,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                  padding: const EdgeInsets.only(left: 20, right: 20, top: 48, bottom: 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primaryAccent, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 26,
                          backgroundImage: NetworkImage(student.photoUrl),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const IdrakLogo(size: 15),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryAccent.withAlpha(30),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'VALİDEYN KABİNETİ',
                                    style: TextStyle(
                                      color: AppColors.primaryAccent,
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              student.fullName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Övladınız: ${student.className} • ${student.studentNumber}',
                              style: TextStyle(
                                color: Colors.white.withAlpha(190),
                                fontSize: 11.5,
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

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Stats Bar
                    Row(
                      children: [
                        _buildParentStatChip('GPA Balı', '${student.gpa}', Icons.star_rounded, AppColors.goldDark),
                        const SizedBox(width: 8),
                        _buildParentStatChip('Davamiyyət', '${student.attendanceRate}%', Icons.check_circle_rounded, AppColors.success),
                        const SizedBox(width: 8),
                        _buildParentStatChip('Qan Qrupu', 'A(II)+', Icons.favorite_rounded, AppColors.danger),
                      ],
                    ),

                    const SizedBox(height: 20),

                    const SectionHeader(
                      title: 'Nəzarət və İzləmə Modulları',
                      subtitle: 'Qiymətlər, davamiyyət, tibb və müəllim əlaqəsi',
                      padding: EdgeInsets.zero,
                    ),

                    const SizedBox(height: 12),

                    // 2-Column Grid for Parent Modules
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.25,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildParentGridTile(
                          context: context,
                          title: 'Həftəlik Matris',
                          subtitle: 'Gündəlik dərslər',
                          icon: Icons.grid_view_outlined,
                          accentColor: const Color(0xFF0284C7),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const TimetableMatrixScreen()),
                          ),
                        ),
                        _buildParentGridTile(
                          context: context,
                          title: 'Qiymət Qrafiki',
                          subtitle: 'KSQ / BSQ dinamika',
                          icon: Icons.insights_outlined,
                          accentColor: AppColors.primaryAccent,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const GradesAnalyticsScreen()),
                          ),
                        ),
                        _buildParentGridTile(
                          context: context,
                          title: 'Davamiyyət',
                          subtitle: 'Rəqəmsal təqvim',
                          icon: Icons.calendar_month_outlined,
                          accentColor: AppColors.success,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AttendanceCalendarScreen()),
                          ),
                        ),
                        _buildParentGridTile(
                          context: context,
                          title: 'Tibbi Kart',
                          subtitle: 'Allergiya & Peyvənd',
                          icon: Icons.medical_services_outlined,
                          accentColor: AppColors.danger,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const MedicalCardScreen()),
                          ),
                        ),
                        _buildParentGridTile(
                          context: context,
                          title: 'Helpdesk Ticket',
                          subtitle: 'Məktəb & Psixoloq',
                          icon: Icons.support_agent_outlined,
                          accentColor: AppColors.goldDark,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ParentTicketsScreen()),
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
    );
  }

  Widget _buildParentStatChip(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
          boxShadow: AppShadows.sm,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 13),
                const SizedBox(width: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                fontSize: 9.5,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParentGridTile({
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppShadows.sm,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: accentColor.withAlpha(18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: accentColor, size: 18),
                    ),
                    Icon(Icons.arrow_outward_rounded, size: 15, color: AppColors.textMuted),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5,
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
