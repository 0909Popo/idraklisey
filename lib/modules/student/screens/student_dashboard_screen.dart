import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/widgets/modern_avatar.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/idrak_logo.dart';
import '../../../providers/app_state.dart';
import 'digital_id_card_screen.dart';
import 'assignments_timeline_screen.dart';
import 'meet_idrak_screen.dart';
import 'library_screen.dart';
import 'cafeteria_menu_screen.dart';
import '../../parent/screens/timetable_matrix_screen.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

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
            // Modern Header Bar
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
                        child: ModernAvatar(
                          imageUrl: student.photoUrl,
                          name: student.fullName,
                          size: 52,
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
                                    'ŞAGİRD PORTALI',
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
                              'Sinif: ${student.className} • No: ${student.studentNumber}',
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
                    // Quick Stats Chips Row
                    Row(
                      children: [
                        _buildQuickMetricChip(
                          title: 'GPA Balı',
                          value: '${student.gpa}',
                          icon: Icons.star_rounded,
                          color: AppColors.goldDark,
                        ),
                        const SizedBox(width: 8),
                        _buildQuickMetricChip(
                          title: 'Davamiyyət',
                          value: '${student.attendanceRate}%',
                          icon: Icons.check_circle_rounded,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 8),
                        _buildQuickMetricChip(
                          title: 'Status',
                          value: 'Aktiv',
                          icon: Icons.verified_user_rounded,
                          color: AppColors.primaryAccent,
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Modern Digital ID Pass Banner
                    Container(
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white.withAlpha(25)),
                        boxShadow: AppShadows.sm,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const DigitalIdCardScreen()),
                            );
                          },
                          borderRadius: BorderRadius.circular(18),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryAccent.withAlpha(30),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.primaryAccent.withAlpha(60)),
                                  ),
                                  child: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.primaryAccent, size: 24),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Rəqəmsal Kimlik Passı',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.2,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Turniket və kitabxana üçün 3D Smart QR Pass',
                                        style: TextStyle(color: Colors.white60, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(20),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Row(
                                    children: [
                                      Text(
                                        'Bax',
                                        style: TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(width: 3),
                                      Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 12),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const SectionHeader(
                      title: 'Xidmətlər və Portal',
                      subtitle: 'Gündəlik dərslər, tapşırıqlar və məktəb resursları',
                      padding: EdgeInsets.zero,
                    ),

                    const SizedBox(height: 12),

                    // Modern 2-Column Action Cards Grid
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.25,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        _buildGridTile(
                          context: context,
                          title: 'Dərs Cədvəli',
                          subtitle: 'Həftəlik dərslər',
                          icon: Icons.calendar_month_outlined,
                          accentColor: const Color(0xFF0284C7),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const TimetableMatrixScreen()),
                          ),
                        ),
                        _buildGridTile(
                          context: context,
                          title: 'Tapşırıqlar',
                          subtitle: 'Kamera ilə təhvil',
                          icon: Icons.assignment_outlined,
                          accentColor: AppColors.primaryAccent,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AssignmentsTimelineScreen()),
                          ),
                        ),
                        _buildGridTile(
                          context: context,
                          title: 'Meet İdrak',
                          subtitle: 'Canlı dərs otağı',
                          icon: Icons.video_camera_front_outlined,
                          accentColor: AppColors.success,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const MeetIdrakScreen()),
                          ),
                        ),
                        _buildGridTile(
                          context: context,
                          title: 'E-Kitabxana',
                          subtitle: 'Dərsliklər & PDF',
                          icon: Icons.local_library_outlined,
                          accentColor: const Color(0xFF8B5CF6),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const LibraryScreen()),
                          ),
                        ),
                        _buildGridTile(
                          context: context,
                          title: 'Yeməkxana',
                          subtitle: 'Günün nahar menyusu',
                          icon: Icons.restaurant_menu_outlined,
                          accentColor: AppColors.goldDark,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CafeteriaMenuScreen()),
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

  Widget _buildQuickMetricChip({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
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

  Widget _buildGridTile({
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
