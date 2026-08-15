import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/status_badge.dart';
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
                        onBackgroundImageError: (e, s) {},
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
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
                                'ŞAGİRD PORTALI',
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

          // Main Student Dashboard Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Prominent Digital ID Card Quick Launcher
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF0F2552), Color(0xFF1E3E7B), Color(0xFF2563EB)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(70),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
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
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(25),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: AppColors.goldLight),
                                ),
                                child: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.goldLight, size: 28),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Rəqəmsal Kimlik Kartı (Digital ID)',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Turniket, kitabxana və yeməkxana üçün QR kod',
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

                  const SizedBox(height: 20),

                  const SectionHeader(
                    title: 'Tədris və Xidmətlər',
                    subtitle: 'Gündəlik dərslər, tapşırıqlar və məktəb resursları',
                  ),

                  // 0. Weekly Timetable (Dərs Cədvəli & Otaqlar)
                  _buildStudentActionCard(
                    context: context,
                    title: 'Dərs Cədvəli & Otaqlar',
                    subtitle: '${student.className} sinfi üçün həftəlik dərslər, müəllimlər və otaqlar',
                    icon: Icons.calendar_month_rounded,
                    accentColor: const Color(0xFF0284C7),
                    tag: 'Cədvəl & Zallar',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TimetableMatrixScreen()),
                    ),
                  ),

                  // 1. Interactive Assignments & Camera Submission
                  _buildStudentActionCard(
                    context: context,
                    title: 'Tapşırıqların Təhvili & Kamera',
                    subtitle: 'Müəllim təlimatı, dəftər şəkillərini çəkib göndərmək',
                    icon: Icons.camera_alt_rounded,
                    accentColor: AppColors.primaryAccent,
                    tag: 'Kamera ilə Sürətli Təhvil',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AssignmentsTimelineScreen()),
                    ),
                  ),

                  // 2. Meet Idrak
                  _buildStudentActionCard(
                    context: context,
                    title: 'Meet İdrak (Onlayn Dərs Otağı)',
                    subtitle: 'Canlı virtual dərslərə qoşulma və arxiv video dərslər',
                    icon: Icons.video_camera_front_rounded,
                    accentColor: AppColors.success,
                    tag: 'Canlı Dərs Aktiv',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MeetIdrakScreen()),
                    ),
                  ),

                  // 3. E-Kitabxana
                  _buildStudentActionCard(
                    context: context,
                    title: 'İdrak E-Kitabxana',
                    subtitle: 'Dərsliklər, IB vəsaitləri, PDF oxuyucu və kitab icarəsi',
                    icon: Icons.local_library_rounded,
                    accentColor: Colors.purple,
                    tag: 'Kataloq & E-Oxu',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LibraryScreen()),
                    ),
                  ),

                  // 4. Cafeteria Menu
                  _buildStudentActionCard(
                    context: context,
                    title: 'Yeməkxana Menyusu',
                    subtitle: 'Gündəlik nahar menyusu, kalori və allergen məlumatı',
                    icon: Icons.restaurant_menu_rounded,
                    accentColor: AppColors.goldDark,
                    tag: 'Günün Menyusu',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CafeteriaMenuScreen()),
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

  Widget _buildStudentActionCard({
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
                        style: const TextStyle(
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
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
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
}
