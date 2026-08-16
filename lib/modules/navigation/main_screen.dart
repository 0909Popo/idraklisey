import 'dart:ui';
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

import '../teacher/screens/teacher_dashboard_screen.dart';
import '../teacher/screens/teacher_students_screen.dart';
import '../teacher/screens/manage_timetable_screen.dart';
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

    // If not authenticated, render LoginScreen
    if (!appState.isAuthenticated) {
      return const LoginScreen();
    }

    final currentUser = appState.currentUser!;
    final currentRole = currentUser.role;

    List<Widget> screens;
    List<BottomNavigationBarItem> navItems;

    switch (currentRole) {
      case UserRole.admin:
        screens = const [
          AdminDashboardScreen(),
          AdminUsersScreen(),
          ParentTicketsScreen(),
          GradesAnalyticsScreen(),
        ];
        navItems = const [
          BottomNavigationBarItem(icon: Icon(Icons.admin_panel_settings_rounded), label: 'İnzibatçı'),
          BottomNavigationBarItem(icon: Icon(Icons.manage_accounts_rounded), label: 'Hesablar'),
          BottomNavigationBarItem(icon: Icon(Icons.support_agent_rounded), label: 'Müraciətlər'),
          BottomNavigationBarItem(icon: Icon(Icons.analytics_rounded), label: 'Analitika'),
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
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Panel'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view_rounded), label: 'Gündəlik'),
          BottomNavigationBarItem(icon: Icon(Icons.insights_rounded), label: 'Qiymətlər'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'Davamiyyət'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_rounded), label: 'Tibbi Kart'),
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
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Şagird'),
          BottomNavigationBarItem(icon: Icon(Icons.badge_rounded), label: 'Digital ID'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_rounded), label: 'Tapşırıqlar'),
          BottomNavigationBarItem(icon: Icon(Icons.video_camera_front_rounded), label: 'Meet İdrak'),
          BottomNavigationBarItem(icon: Icon(Icons.local_library_rounded), label: 'Kitabxana'),
        ];
        break;

      case UserRole.teacher:
        screens = const [
          TeacherDashboardScreen(),
          TeacherStudentsScreen(),
          ManageTimetableScreen(),
          QuickGradingScreen(),
          QrInventoryTicketScreen(),
        ];
        navItems = const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Müəllim'),
          BottomNavigationBarItem(icon: Icon(Icons.groups_rounded), label: 'Şagirdlər'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_month_rounded), label: 'Davamiyyət'),
          BottomNavigationBarItem(icon: Icon(Icons.edit_note_rounded), label: 'Qiymətlər'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner_rounded), label: 'İnventar'),
        ];
        break;
    }

    // Ensure index is within range
    if (_currentTabIndex >= screens.length) {
      _currentTabIndex = 0;
    }

    final isDark = appState.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 56,
        backgroundColor: isDark
            ? AppColors.darkSurface
            : (currentRole == UserRole.admin ? const Color(0xFF0F172A) : AppColors.primary),
        elevation: 0,
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              decoration: BoxDecoration(
                color: (isDark
                        ? AppColors.darkSurface
                        : (currentRole == UserRole.admin
                            ? const Color(0xFF0F172A)
                            : AppColors.primary))
                    .withAlpha(230),
              ),
            ),
          ),
        ),
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
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
            Text(
              currentUser.fullName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.goldLight,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          // Light / Dark theme toggle
          IconButton(
            icon: Icon(
              appState.isDarkMode
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
              color: AppColors.goldLight,
              size: 22,
            ),
            tooltip: appState.isDarkMode ? 'Açıq rejim' : 'Tünd rejim',
            onPressed: () => appState.toggleTheme(),
          ),

          // Notification Bell with Badge
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_rounded, color: Colors.white, size: 24),
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
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${appState.unreadNotificationCount}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          // Logout Button
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white70, size: 20),
            tooltip: 'Hesabdan Çıxış',
            onPressed: () {
              appState.logout();
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: IndexedStack(
        index: _currentTabIndex,
        children: screens,
      ),
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkSurface.withAlpha(200)
                  : Colors.white.withAlpha(200),
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? Colors.white.withAlpha(25)
                      : Colors.white.withAlpha(40),
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(8),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentTabIndex,
              onTap: (index) => setState(() => _currentTabIndex = index),
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.transparent,
              selectedItemColor: isDark
                  ? AppColors.goldLight
                  : (currentRole == UserRole.admin ? const Color(0xFF0F172A) : AppColors.primary),
              unselectedItemColor: AppColors.textMuted,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          elevation: 0,
          items: navItems,
            ),
          ),
        ),
      ),
    );
  }
}
