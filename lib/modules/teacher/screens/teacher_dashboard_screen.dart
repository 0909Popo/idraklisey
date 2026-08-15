import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/idrak_logo.dart';
import '../../../providers/app_state.dart';
import 'quick_grading_screen.dart';
import 'qr_inventory_ticket_screen.dart';
import 'teacher_students_screen.dart';
import 'create_assignment_screen.dart';
import 'review_submissions_screen.dart';
import 'manage_timetable_screen.dart';
import '../../student/screens/library_screen.dart';
import 'teacher_id_card_screen.dart';
import '../../student/screens/meet_idrak_screen.dart';
import '../../shared/screens/notifications_screen.dart';

class TeacherDashboardScreen extends StatelessWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final currentUser = appState.currentUser;

    final teacherName = currentUser?.fullName ?? 'Müəllim';
    final teacherSubject = currentUser?.subject ?? 'Tədris Şöbəsi';
    final teacherRoom = currentUser?.roomNumber ?? 'Otaq 302';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Dynamic Teacher Header
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
                      ),
                      child: CircleAvatar(
                        radius: 36,
                        backgroundImage: NetworkImage(
                          currentUser?.photoUrl ?? 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400',
                        ),
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
                                'MÜƏLLİM HUB',
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
                            teacherName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$teacherSubject • $teacherRoom',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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

          // Main Teacher Hub Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Fast Task / Homework Action Banner
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CreateAssignmentScreen()),
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
                                  color: Colors.white.withAlpha(30),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.add_task_rounded, color: Colors.white, size: 28),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Yeni Dərs Tapşırığı Təyin Et',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Bütün sinfə və ya fərdi şagirdlərə dərs tapşırığı göndərin',
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

                  // Digital ID Card Launcher
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1A0A2E), Color(0xFF2D1B55), Color(0xFF1E3A5F)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.gold.withAlpha(80)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2D1B55).withAlpha(60),
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
                            MaterialPageRoute(builder: (_) => const TeacherIdCardScreen()),
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
                                  color: AppColors.gold.withAlpha(30),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.badge_rounded, color: AppColors.goldLight, size: 28),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Rəqəmsal Kimlik Vəsiqəsi',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'QR keçid, NFC turniket və rəsmi 3D müəllim vəsiqəniz',
                                      style: TextStyle(color: Colors.white70, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.gold.withAlpha(25),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.qr_code_rounded, color: AppColors.goldLight, size: 20),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  const SectionHeader(
                    title: 'Müəllim İş Alətləri',
                    subtitle: 'Tədris və şagird idarəetmə modulları',
                  ),

                  // 0. Dərs Cədvəli İdarəsi & Sinif Sahiplənmə
                  _buildTeacherToolCard(
                    context: context,
                    title: 'Dərs Cədvəli İdarəsi & Siniflər',
                    subtitle: 'Tədris etdiyiniz sinifləri seçin, dərs saatlarını və otaqları qurun',
                    icon: Icons.calendar_month_rounded,
                    accentColor: const Color(0xFF0284C7),
                    tag: 'Cədvəl & Siniflər',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ManageTimetableScreen()),
                    ),
                  ),

                  // Meet İdrak — Canlı Səsli Dərslər & Toplantı
                  _buildTeacherToolCard(
                    context: context,
                    title: 'Meet İdrak • Canlı Səsli Toplantı',
                    subtitle: 'Siniflər üçün gecikməsiz səsli otaq yaratmaq və idarə etmək',
                    icon: Icons.mic_external_on_rounded,
                    accentColor: const Color(0xFF0D9488),
                    tag: 'Canlı Dərs',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MeetIdrakScreen()),
                    ),
                  ),

                  // 1. Şagirdlər Kataloqu & Sağlamlıq
                  _buildTeacherToolCard(
                    context: context,
                    title: 'Şagirdlər Kataloqu & Sağlamlıq',
                    subtitle: 'Bütün şagirdlər, əlaqə məlumatı, fərdi tapşırıq və tibbi kart',
                    icon: Icons.groups_rounded,
                    accentColor: AppColors.primaryAccent,
                    tag: '${appState.students.length} Şagird',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TeacherStudentsScreen()),
                    ),
                  ),

                  // 2. Tapşırıq Təhvili & Yoxlanış (Review Submissions)
                  _buildTeacherToolCard(
                    context: context,
                    title: 'Tapşırıq Təhvili & Yoxlanış',
                    subtitle: 'Şagirdlərin göndərdiyi şəkilləri yoxlayın, bal və rəy yazın',
                    icon: Icons.assignment_turned_in_rounded,
                    accentColor: Colors.teal,
                    tag: '${appState.currentTeacherAssignments.length} Tapşırıq',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ReviewSubmissionsScreen()),
                    ),
                  ),

                  // 4. Sürətli Qiymətləndirmə və Səsli Rəy (Voice-to-Text)
                  _buildTeacherToolCard(
                    context: context,
                    title: 'Sürətli Qiymət & Səsli Rəy',
                    subtitle: 'IB STR / AZ 100 Bal və Voice-to-Text mikrofonla rəy daxil etmə',
                    icon: Icons.mic_rounded,
                    accentColor: Colors.purple,
                    tag: 'Voice-to-Text',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const QuickGradingScreen()),
                    ),
                  ),

                  // 4. Kitabxana və Resurslar
                  _buildTeacherToolCard(
                    context: context,
                    title: 'Elektron Kitabxana & İcarə',
                    subtitle: 'Müəllim üçün dərslik, metodik vəsaitlər və yeni kitab əlavəsi',
                    icon: Icons.local_library_rounded,
                    accentColor: AppColors.goldDark,
                    tag: '${appState.books.length} Kitab',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LibraryScreen(isTeacherView: true)),
                    ),
                  ),

                  // 5. Valideyn və Şagird Bildirişləri
                  _buildTeacherToolCard(
                    context: context,
                    title: 'Valideyn & Şagird Bildirişləri',
                    subtitle: 'Valideynlərə və ya bütün sinfə fərdi bildiriş, qeyd və xəbərdarlıq göndər',
                    icon: Icons.notifications_active_rounded,
                    accentColor: const Color(0xFFE11D48),
                    tag: 'Bildiriş Göndər',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                    ),
                  ),

                  // 6. Ticket sistemi (İnventar & QR proyektor/kompüter nasazlıq şikayəti)
                  _buildTeacherToolCard(
                    context: context,
                    title: 'İnventar QR Ticket Sistemi',
                    subtitle: 'Proyektor və ya kompüter xarab olduqda sıfırdan şikayət göndər',
                    icon: Icons.qr_code_scanner_rounded,
                    accentColor: AppColors.danger,
                    tag: 'Avadanlıq Dəstək',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const QrInventoryTicketScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateAssignmentScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_task_rounded, color: Colors.white),
        label: const Text('Yeni Tapşırıq', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildTeacherToolCard({
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
