import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/idrak_logo.dart';
import '../../providers/app_state.dart';
import '../auth/screens/login_screen.dart';
import '../shared/screens/notifications_screen.dart';

// Admin Screens
import '../admin/screens/admin_dashboard_screen.dart';
import '../admin/screens/admin_users_screen.dart';

// Parent Screens
import '../parent/screens/parent_dashboard_screen.dart';
import '../parent/screens/timetable_matrix_screen.dart';
import '../parent/screens/grades_analytics_screen.dart';
import '../parent/screens/attendance_calendar_screen.dart';
import '../parent/screens/medical_card_screen.dart';
import '../parent/screens/parent_tickets_screen.dart';

// Student Screens
import '../student/screens/student_dashboard_screen.dart';
import '../student/screens/digital_id_card_screen.dart';
import '../student/screens/assignments_timeline_screen.dart';
import '../student/screens/meet_idrak_screen.dart';
import '../student/screens/library_screen.dart';

// Teacher Screens
import '../teacher/screens/teacher_dashboard_screen.dart';
import '../teacher/screens/teacher_students_screen.dart';
import '../teacher/screens/teacher_timetable_view_screen.dart';
import '../teacher/screens/quick_grading_screen.dart';
import '../teacher/screens/qr_inventory_ticket_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    if (!appState.isAuthenticated) {
      return const LoginScreen();
    }

    final currentUser = appState.currentUser!;
    final currentRole = currentUser.role;

    List<Widget> screens;
    List<BottomNavigationBarItem> navItems;

    switch (currentRole) {
      case UserRole.admin:
        // Səlahiyyətə görə: rolu olan işçi yalnız icazə verdiyi tabları görür
        screens = [
          const AdminDashboardScreen(),
          if (appState.hasPermission('view_users')) const AdminUsersScreen(),
          if (appState.hasPermission('view_tickets')) const ParentTicketsScreen(),
          if (appState.hasPermission('view_reports')) const GradesAnalyticsScreen(),
        ];
        navItems = [
          const BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard_rounded), label: 'İnzibatçı'),
          if (appState.hasPermission('view_users'))
            const BottomNavigationBarItem(icon: Icon(Icons.manage_accounts_outlined), activeIcon: Icon(Icons.manage_accounts_rounded), label: 'Hesablar'),
          if (appState.hasPermission('view_tickets'))
            const BottomNavigationBarItem(icon: Icon(Icons.support_agent_outlined), activeIcon: Icon(Icons.support_agent_rounded), label: 'Müraciətlər'),
          if (appState.hasPermission('view_reports'))
            const BottomNavigationBarItem(icon: Icon(Icons.analytics_outlined), activeIcon: Icon(Icons.analytics_rounded), label: 'Analitika'),
        ];
        break;

      case UserRole.parent:
        screens = const [
          ParentDashboardScreen(),
          TimetableMatrixScreen(),
          GradesAnalyticsScreen(),
          AttendanceCalendarScreen(),
          MedicalCardScreen(),
        ];
        navItems = const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard_rounded), label: 'Panel'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_outlined), activeIcon: Icon(Icons.grid_view_rounded), label: 'Gündəlik'),
          BottomNavigationBarItem(icon: Icon(Icons.insights_outlined), activeIcon: Icon(Icons.insights_rounded), label: 'Qiymətlər'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), activeIcon: Icon(Icons.calendar_month_rounded), label: 'Davamiyyət'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_outline_rounded), activeIcon: Icon(Icons.favorite_rounded), label: 'Tibbi Kart'),
        ];
        break;

      case UserRole.student:
        screens = const [
          StudentDashboardScreen(),
          DigitalIdCardScreen(),
          AssignmentsTimelineScreen(),
          MeetIdrakScreen(),
          LibraryScreen(),
        ];
        navItems = const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard_rounded), label: 'Şagird'),
          BottomNavigationBarItem(icon: Icon(Icons.badge_outlined), activeIcon: Icon(Icons.badge_rounded), label: 'Digital ID'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), activeIcon: Icon(Icons.assignment_rounded), label: 'Tapşırıqlar'),
          BottomNavigationBarItem(icon: Icon(Icons.video_camera_front_outlined), activeIcon: Icon(Icons.video_camera_front_rounded), label: 'Meet İdrak'),
          BottomNavigationBarItem(icon: Icon(Icons.local_library_outlined), activeIcon: Icon(Icons.local_library_rounded), label: 'Kitabxana'),
        ];
        break;

      case UserRole.teacher:
        screens = const [
          TeacherDashboardScreen(),
          TeacherStudentsScreen(),
          TeacherTimetableViewScreen(),
          QuickGradingScreen(),
          QrInventoryTicketScreen(),
        ];
        navItems = const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard_rounded), label: 'Müəllim'),
          BottomNavigationBarItem(icon: Icon(Icons.groups_outlined), activeIcon: Icon(Icons.groups_rounded), label: 'Şagirdlər'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_outlined), activeIcon: Icon(Icons.calendar_month_rounded), label: 'Davamiyyət'),
          BottomNavigationBarItem(icon: Icon(Icons.edit_note_outlined), activeIcon: Icon(Icons.edit_note_rounded), label: 'Qiymətlər'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner_outlined), activeIcon: Icon(Icons.qr_code_scanner_rounded), label: 'İnventar'),
        ];
        break;
    }

    if (_currentTabIndex >= screens.length) {
      _currentTabIndex = 0;
    }

    final isDark = appState.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 56,
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.primary,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.only(left: 12),
          child: Center(
            child: IdrakLogo(size: 32),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'İDRAK LİSEYİ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
            Text(
              currentUser.fullName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.primaryAccent,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              appState.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: Colors.white,
              size: 20,
            ),
            tooltip: appState.isDarkMode ? 'Açıq rejim' : 'Tünd rejim',
            onPressed: () => appState.toggleTheme(),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 22),
                tooltip: 'Bildirişlər & Elanlar',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NotificationsScreen()),
                  );
                },
              ),
              if (appState.unreadNotificationCount > 0)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.danger,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 15, minHeight: 15),
                    child: Text(
                      '${appState.unreadNotificationCount}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white70, size: 20),
            tooltip: 'Hesabdan Çıxış',
            onPressed: () => appState.logout(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: IndexedStack(
        index: _currentTabIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.cardBorder)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentTabIndex,
          onTap: (index) => setState(() => _currentTabIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primaryAccent,
          unselectedItemColor: AppColors.textMuted,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          elevation: 0,
          items: navItems,
        ),
      ),
    );
  }
}
