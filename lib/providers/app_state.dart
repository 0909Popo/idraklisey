import 'dart:async';

import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../data/models/timetable_model.dart';
import '../data/models/grade_model.dart';
import '../data/models/attendance_model.dart';
import '../data/models/medical_model.dart';
import '../data/models/ticket_model.dart';
import '../data/models/assignment_model.dart';
import '../data/models/student_model.dart';
import '../data/models/library_model.dart';
import '../data/models/menu_model.dart';
import '../data/models/meet_model.dart';
import '../data/models/notification_model.dart';
import '../data/models/inventory_model.dart';
import '../data/models/user_model.dart';
import '../data/mock_data.dart';
import '../services/firestore_service.dart';
import '../services/auth_storage_service.dart';

enum UserRole {
  admin, // Məktəb İdarəetməsi (Admin)
  parent, // Valideyn Paneli
  student, // Şagird Paneli
  teacher, // Müəllim Paneli
}

extension UserRoleExt on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'Admin Paneli';
      case UserRole.parent:
        return 'Valideyn Paneli';
      case UserRole.student:
        return 'Şagird Paneli';
      case UserRole.teacher:
        return 'Müəllim Paneli';
    }
  }

  IconData get icon {
    switch (this) {
      case UserRole.admin:
        return Icons.admin_panel_settings_rounded;
      case UserRole.parent:
        return Icons.family_restroom_rounded;
      case UserRole.student:
        return Icons.school_rounded;
      case UserRole.teacher:
        return Icons.psychology_rounded;
    }
  }
}

class AppState extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final AuthStorageService _authStorage = AuthStorageService();
  StreamSubscription<List<MeetRoom>>? _meetRoomsSubscription;

  // --- APPEARANCE (Light / Dark) ---
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  /// Restores the persisted theme before the first frame so the app
  /// never flashes the wrong palette on startup.
  Future<void> loadThemeMode() async {
    _isDarkMode = await _authStorage.getIsDarkMode();
    AppColors.applyDark(_isDarkMode);
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    AppColors.applyDark(_isDarkMode);
    _authStorage.saveIsDarkMode(_isDarkMode);
    notifyListeners();
  }

  // Current Logged In User
  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  // Active Role
  UserRole get currentRole => _currentUser?.role ?? UserRole.admin;

  // User Accounts Database (Default Master Admin)
  final List<AppUser> _users = [
    AppUser(
      id: 'usr-admin-1',
      username: 'admin',
      password: '123',
      fullName: 'İdrak Liseyi Baş İnzibatçısı',
      role: UserRole.admin,
      idrakCode: 'IDR-ADM-001',
      phone: '+994 (12) 598-00-00',
      email: 'admin@idrakliseyi.edu.az',
      createdAt: DateTime(2024, 1, 1),
    ),
  ];

  List<AppUser> get users => _users;

  // Real Students List
  final List<StudentProfile> _students = [];
  List<StudentProfile> get students => _students;

  // Explicit distinct classes created by Admin
  final Set<String> _customClasses = {'9B', '10A', '11A'};

  // Per-student medical cards map: studentId -> StudentMedicalCard
  final Map<String, StudentMedicalCard> _medicalCardsMap = {};

  // Per-class Timetables Map: className -> List<DayTimetable>
  final Map<String, List<DayTimetable>> _classTimetablesMap = {};

  // Get Timetable for a specific class (or default empty 5 days)
  List<DayTimetable> getClassTimetable(String className) {
    if (_classTimetablesMap.containsKey(className)) {
      return _classTimetablesMap[className]!;
    }
    final defaultDays = [
      DayTimetable(dayName: 'Bazar ertəsi', shortDay: 'B.E', lessons: []),
      DayTimetable(dayName: 'Çərşənbə axşamı', shortDay: 'Ç.A', lessons: []),
      DayTimetable(dayName: 'Çərşənbə', shortDay: 'Ç.', lessons: []),
      DayTimetable(dayName: 'Cümə axşamı', shortDay: 'C.A', lessons: []),
      DayTimetable(dayName: 'Cümə', shortDay: 'C.', lessons: []),
    ];
    _classTimetablesMap[className] = defaultDays;
    return defaultDays;
  }

  // Selected Student for Parent / Active view
  StudentProfile get student {
    if (_currentUser?.role == UserRole.parent &&
        _currentUser?.linkedStudentId != null) {
      return _students.firstWhere(
        (s) => s.id == _currentUser!.linkedStudentId,
        orElse: () => MockData.currentStudent,
      );
    }
    if (_currentUser?.role == UserRole.student) {
      return _students.firstWhere(
        (s) =>
            s.fullName.toLowerCase() == _currentUser!.fullName.toLowerCase() ||
            s.studentNumber.toLowerCase() ==
                _currentUser!.idrakCode.toLowerCase(),
        orElse: () => MockData.currentStudent,
      );
    }
    if (_students.isNotEmpty) {
      return _students.first;
    }
    return MockData.currentStudent;
  }

  // Available classes in the entire school
  List<String> get allDistinctClasses {
    final classesSet = <String>{..._customClasses};
    for (final s in _students) {
      if (s.className.isNotEmpty) classesSet.add(s.className);
    }
    for (final u in _users) {
      classesSet.addAll(u.assignedClasses);
    }
    classesSet.addAll(_classTimetablesMap.keys);
    return classesSet.toList()..sort();
  }

  // Classes claimed/taught by current teacher
  List<String> get currentTeacherClasses {
    if (_currentUser == null) return [];
    return _currentUser!.assignedClasses;
  }

  // --- INITIALIZE & SYNC FROM FIRESTORE ---
  Future<void>? _initFuture;

  /// Returns the ongoing (or a new) Firestore sync so callers can await it
  /// before relying on cloud data (e.g. auto-login needs the users list).
  Future<void> ensureDataReady() {
    return _initFuture ??= initFirebaseData();
  }

  Future<void> initFirebaseData() async {
    try {
      // Meet presence must start immediately. Waiting for every other school
      // collection can otherwise delay a live room by minutes on a weak link.
      _startMeetRoomsListener();

      // 1. Fetch Users
      final cloudUsers = await _firestoreService.fetchUsers();
      if (cloudUsers.isNotEmpty) {
        for (final u in cloudUsers) {
          if (!_users.any((x) => x.id == u.id)) {
            _users.add(u);
          }
        }
      }

      // 2. Fetch Students
      final cloudStudents = await _firestoreService.fetchStudents();
      if (cloudStudents.isNotEmpty) {
        _students.clear();
        _students.addAll(cloudStudents);
        _pendingAttendanceStudents = List.from(_students);
      }

      // 3. Fetch Timetables
      final cloudTimetables = await _firestoreService.fetchAllClassTimetables();
      if (cloudTimetables.isNotEmpty) {
        _classTimetablesMap.clear();
        _classTimetablesMap.addAll(cloudTimetables);
      }

      // 4. Fetch Books
      final cloudBooks = await _firestoreService.fetchBooks();
      if (cloudBooks.isNotEmpty) {
        _books.clear();
        _books.addAll(cloudBooks);
      }

      // 5. Fetch Assignments
      final cloudAssignments = await _firestoreService.fetchAssignments();
      if (cloudAssignments.isNotEmpty) {
        _assignments.clear();
        _assignments.addAll(cloudAssignments);
      }

      // 6. Fetch Tickets
      final cloudTickets = await _firestoreService.fetchTickets();
      if (cloudTickets.isNotEmpty) {
        _tickets.clear();
        _tickets.addAll(cloudTickets);
      }

      // 7. Fetch Menu
      final cloudMenu = await _firestoreService.fetchWeeklyMenu();
      if (cloudMenu.isNotEmpty) {
        _weeklyMenu.clear();
        _weeklyMenu.addAll(cloudMenu);
      }

      // 8. Fetch Grades
      final cloudGrades = await _firestoreService.fetchGrades(null);
      if (cloudGrades.isNotEmpty) {
        _grades.clear();
        _grades.addAll(cloudGrades);
      }

      // 9. Fetch Medical Cards
      final cloudMedicalCards = await _firestoreService.fetchAllMedicalCards();
      if (cloudMedicalCards.isNotEmpty) {
        _medicalCardsMap.addAll(cloudMedicalCards);
      }

      // 10. Fetch Attendance
      final cloudAttendance = await _firestoreService.fetchAllAttendance();
      if (cloudAttendance.isNotEmpty) {
        _studentAttendanceMap.clear();
        _studentAttendanceMap.addAll(cloudAttendance);
      }

      // 11. Fetch Meet Rooms
      final cloudMeetRooms = await _firestoreService.fetchMeetRooms();
      // Do not overwrite a newer snapshot delivered by the listener above.
      if (_meetRooms.isEmpty && cloudMeetRooms.isNotEmpty) {
        _meetRooms.addAll(cloudMeetRooms);
      }

      // 12. Fetch Notifications
      final cloudNotifs = await _firestoreService.fetchNotifications();
      if (cloudNotifs.isNotEmpty) {
        _notifications.clear();
        _notifications.addAll(cloudNotifs);
      }

      // 13. Fetch QR Inventory Items
      final cloudInventory = await _firestoreService.fetchInventoryItems();
      if (cloudInventory.isNotEmpty) {
        _inventoryItems.clear();
        _inventoryItems.addAll(cloudInventory);
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Firestore initialization sync notice: $e');
    }
  }

  void _startMeetRoomsListener() {
    _meetRoomsSubscription?.cancel();
    _meetRoomsSubscription = _firestoreService.watchMeetRooms().listen(
      (rooms) {
        _meetRooms
          ..clear()
          ..addAll(rooms);
        notifyListeners();
      },
      onError: (Object error) {
        debugPrint('Meet rooms live sync error: $error');
        // Keep existing rooms on error instead of clearing
      },
      cancelOnError: false, // Keep stream alive on Firestore reconnects
    );
  }

  // --- AUTHENTICATION ---
  String? login(String username, String password, {bool saveCredentials = true}) {
    final cleanUsername = username.trim().toLowerCase();
    final cleanPass = password.trim();

    debugPrint('[AppState] Login attempt - username: "$cleanUsername", password length: ${cleanPass.length}');
    debugPrint('[AppState] Total users in database: ${_users.length}');

    final user = _users.firstWhere(
      (u) =>
          (u.username.toLowerCase() == cleanUsername ||
              u.idrakCode.toLowerCase() == cleanUsername) &&
          u.password == cleanPass,
      orElse: () => AppUser(
        id: '',
        username: '',
        password: '',
        fullName: '',
        role: UserRole.student,
        idrakCode: '',
        createdAt: DateTime.now(),
      ),
    );

    if (user.id.isEmpty) {
      debugPrint('[AppState] Login failed - user not found');
      return 'İstifadəçi adı / İdrak kodu və ya şifrə yanlışdır!';
    }

    if (!user.isActive) {
      return 'Bu hesab inzibatçı tərəfindən deaktiv edilib.';
    }

    debugPrint('[AppState] ✓ Login successful - user: ${user.fullName}');
    _currentUser = user;
    
    // Save credentials for auto-login if requested
    if (saveCredentials) {
      debugPrint('[AppState] Saving credentials for auto-login...');
      _authStorage.saveCredentials(cleanUsername, cleanPass);
    }
    
    notifyListeners();
    return null;
  }

  /// Attempt auto-login using stored credentials.
  /// Never logs in silently: biometric confirmation is always required.
  Future<bool> tryAutoLogin() async {
    try {
      debugPrint('[AppState] Attempting auto-login...');

      // Fast local checks first, before waiting on any network sync.
      final hasCredentials = await _authStorage.hasStoredCredentials();
      final biometricEnabled = await _authStorage.isBiometricEnabled();
      debugPrint(
        '[AppState] Credentials: $hasCredentials, biometric enabled: $biometricEnabled',
      );

      // Without stored credentials or an explicit opt-in to biometric
      // login the user must always sign in manually.
      if (!hasCredentials || !biometricEnabled) return false;

      final authenticated = await _authStorage.authenticateWithBiometrics();
      debugPrint('[AppState] Biometric authenticated: $authenticated');
      if (!authenticated) return false;

      // Wait for the Firestore users sync; without it only the built-in
      // master admin exists and saved cloud users would fail to match.
      try {
        await ensureDataReady().timeout(const Duration(seconds: 10));
      } on TimeoutException {
        debugPrint('[AppState] Firestore sync timed out, trying login anyway');
      }

      debugPrint('[AppState] Users in database: ${_users.length}');

      final credentials = await _authStorage.getSavedCredentials();
      debugPrint('[AppState] Credentials found: ${credentials != null}');
      
      if (credentials == null) return false;

      debugPrint('[AppState] Saved username: "${credentials['username']}"');
      debugPrint('[AppState] Saved password length: ${credentials['password']?.length}');

      final error = login(
        credentials['username']!,
        credentials['password']!,
        saveCredentials: false, // Already saved
      );
      
      if (error == null) {
        debugPrint('[AppState] ✓ Auto-login successful');
        return true;
      } else {
        debugPrint('[AppState] ⚠️ Auto-login failed: $error');
        // Clear invalid credentials
        await _authStorage.clearAll();
        return false;
      }
    } catch (e) {
      debugPrint('[AppState] ⚠️ Auto-login error: $e');
      return false;
    }
  }

  void logout() async {
    _currentUser = null;
    await _authStorage.clearAll();
    notifyListeners();
  }

  void switchUserRoleForTesting(UserRole role) {
    final matchingUser = _users.firstWhere(
      (u) => u.role == role && u.isActive,
      orElse: () => _users.first,
    );
    _currentUser = matchingUser;
    notifyListeners();
  }

  // --- SMART CLASS MANAGEMENT & PROMOTION ---
  void addNewClass(String className) {
    _customClasses.add(className.trim());
    notifyListeners();
  }

  void deleteClass(String className) {
    _customClasses.remove(className);
    _classTimetablesMap.remove(className);
    notifyListeners();
  }

  List<StudentProfile> getStudentsForClass(String className) {
    return _students
        .where((s) => s.className.toLowerCase() == className.toLowerCase())
        .toList();
  }

  double getClassAverageGpa(String className) {
    final classStudents = getStudentsForClass(className);
    if (classStudents.isEmpty) return 0.0;
    final gradedStudents = classStudents.where((s) => s.gpa > 0).toList();
    if (gradedStudents.isEmpty) return 0.0;
    final sum = gradedStudents.map((s) => s.gpa).reduce((a, b) => a + b);
    return double.parse((sum / gradedStudents.length).toStringAsFixed(2));
  }

  int getClassAverageAttendance(String className) {
    final classStudents = getStudentsForClass(className);
    if (classStudents.isEmpty) return 0;
    final sum = classStudents
        .map((s) => s.attendanceRate)
        .reduce((a, b) => a + b);
    return (sum / classStudents.length).round();
  }

  // 🚀 PROMOTE CLASS ("Sinifi Yüksəlt")
  void promoteClass(String fromClass, String toClass) {
    for (int i = 0; i < _students.length; i++) {
      if (_students[i].className.toLowerCase() == fromClass.toLowerCase()) {
        final std = _students[i];
        _students[i] = StudentProfile(
          id: std.id,
          fullName: std.fullName,
          studentNumber: std.studentNumber,
          className: toClass,
          photoUrl: std.photoUrl,
          qrData: std.qrData.replaceAll(fromClass, toClass),
          barcodeData: std.barcodeData,
          parentName: std.parentName,
          parentPhone: std.parentPhone,
          gpa: std.gpa,
          attendanceRate: std.attendanceRate,
          academicYear: std.academicYear,
        );
        _firestoreService.updateStudentClass(std.id, toClass);
      }
    }

    // Update corresponding AppUsers
    for (int i = 0; i < _users.length; i++) {
      if (_users[i].className != null &&
          _users[i].className!.toLowerCase() == fromClass.toLowerCase()) {
        _users[i] = _users[i].copyWith(className: toClass);
      }
    }

    // Move Timetable if exists
    if (_classTimetablesMap.containsKey(fromClass)) {
      final t = _classTimetablesMap.remove(fromClass)!;
      _classTimetablesMap[toClass] = t;
      _firestoreService.saveClassTimetable(toClass, t);
    }

    _customClasses.remove(fromClass);
    _customClasses.add(toClass);

    notifyListeners();
  }

  // --- TEACHER CLASS OWNERSHIP (Sinif Sahiplənmə) ---
  void claimClassForTeacher(String className) {
    if (_currentUser == null || _currentUser!.role != UserRole.teacher) return;
    final currentClasses = List<String>.from(_currentUser!.assignedClasses);
    if (!currentClasses.contains(className)) {
      currentClasses.add(className);
      final updatedUser = _currentUser!.copyWith(
        assignedClasses: currentClasses,
      );
      _currentUser = updatedUser;
      final idx = _users.indexWhere((u) => u.id == updatedUser.id);
      if (idx != -1) _users[idx] = updatedUser;
      _firestoreService.updateTeacherAssignedClasses(
        updatedUser.id,
        currentClasses,
      );
      notifyListeners();
    }
  }

  void unclaimClassForTeacher(String className) {
    if (_currentUser == null || _currentUser!.role != UserRole.teacher) return;
    final currentClasses = List<String>.from(_currentUser!.assignedClasses);
    if (currentClasses.contains(className)) {
      currentClasses.remove(className);
      final updatedUser = _currentUser!.copyWith(
        assignedClasses: currentClasses,
      );
      _currentUser = updatedUser;
      final idx = _users.indexWhere((u) => u.id == updatedUser.id);
      if (idx != -1) _users[idx] = updatedUser;
      _firestoreService.updateTeacherAssignedClasses(
        updatedUser.id,
        currentClasses,
      );
      notifyListeners();
    }
  }

  // --- DƏRS CƏDVƏLİ ƏLAVƏ ETMƏ & SİLMƏ (TIMETABLE CRUD) ---
  void addLessonSlotToClass({
    required String className,
    required String dayName,
    required String period,
    required String time,
    required String subject,
    required String teacherName,
    required String room,
    String colorHex = '0xFF2563EB',
  }) {
    final days = getClassTimetable(className);
    final dayIndex = days.indexWhere((d) => d.dayName == dayName);

    final newSlot = LessonSlot(
      period: period,
      time: time,
      subject: subject,
      teacher: teacherName,
      room: room,
      colorHex: colorHex,
    );

    if (dayIndex != -1) {
      days[dayIndex].lessons.add(newSlot);
    } else {
      days.add(
        DayTimetable(
          dayName: dayName,
          shortDay: dayName.substring(0, 2),
          lessons: [newSlot],
        ),
      );
    }

    _classTimetablesMap[className] = days;
    _firestoreService.saveClassTimetable(className, days);
    notifyListeners();
  }

  void deleteLessonSlotFromClass({
    required String className,
    required String dayName,
    required int slotIndex,
  }) {
    final days = getClassTimetable(className);
    final dayIndex = days.indexWhere((d) => d.dayName == dayName);

    if (dayIndex != -1 &&
        slotIndex >= 0 &&
        slotIndex < days[dayIndex].lessons.length) {
      days[dayIndex].lessons.removeAt(slotIndex);
      _classTimetablesMap[className] = days;
      _firestoreService.saveClassTimetable(className, days);
      notifyListeners();
    }
  }

  // ✅ YENİ: Müəllimə görə cədvəl
  List<DayTimetable> getTeacherTimetable(String teacherId) {
    final allDays = <DayTimetable>[];

    for (final className in _classTimetablesMap.keys) {
      final classDays = _classTimetablesMap[className]!;
      for (final day in classDays) {
        final teacherLessons = day.lessons.where((l) => l.teacherId == teacherId).toList();
        if (teacherLessons.isNotEmpty) {
          final existingDayIndex = allDays.indexWhere((d) => d.dayName == day.dayName);
          if (existingDayIndex != -1) {
            allDays[existingDayIndex].lessons.addAll(teacherLessons);
          } else {
            allDays.add(DayTimetable(
              dayName: day.dayName,
              shortDay: day.shortDay,
              lessons: teacherLessons,
            ));
          }
        }
      }
    }

    return allDays;
  }

  // ✅ YENİ: Konflikt yoxlama (KƏSIŞƏN SAAT ARALIĞI)
  String? checkTimetableConflict({
    required String className,
    required String day,
    required String time,
    required String teacherId,
  }) {
    // Saatları parse et
    final timeParts = time.split(' - ');
    if (timeParts.length != 2) return 'Saat formatı yanlışdır! (məs: 09:45 - 10:55)';
    
    final newStartParts = timeParts[0].trim().split(':');
    final newEndParts = timeParts[1].trim().split(':');
    
    if (newStartParts.length != 2 || newEndParts.length != 2) {
      return 'Saat formatı yanlışdır! (məs: 09:45 - 10:55)';
    }
    
    final newStartHour = int.tryParse(newStartParts[0]);
    final newStartMin = int.tryParse(newStartParts[1]);
    final newEndHour = int.tryParse(newEndParts[0]);
    final newEndMin = int.tryParse(newEndParts[1]);
    
    if (newStartHour == null || newStartMin == null || newEndHour == null || newEndMin == null) {
      return 'Saat formatı yanlışdır!';
    }
    
    final newStart = newStartHour * 60 + newStartMin; // dəqiqə olaraq
    final newEnd = newEndHour * 60 + newEndMin;
    
    if (newStart >= newEnd) {
      return 'Başlama saatı bitmə saatından böyük və ya bərabər ola bilməz!';
    }
    
    // Helper: Saat aralığı kəsişir?
    bool isOverlapping(String existingTime) {
      final parts = existingTime.split(' - ');
      if (parts.length != 2) return false;
      
      final startParts = parts[0].trim().split(':');
      final endParts = parts[1].trim().split(':');
      
      if (startParts.length != 2 || endParts.length != 2) return false;
      
      final startHour = int.tryParse(startParts[0]);
      final startMin = int.tryParse(startParts[1]);
      final endHour = int.tryParse(endParts[0]);
      final endMin = int.tryParse(endParts[1]);
      
      if (startHour == null || startMin == null || endHour == null || endMin == null) {
        return false;
      }
      
      final existingStart = startHour * 60 + startMin;
      final existingEnd = endHour * 60 + endMin;
      
      // Kəsişmə yoxlaması: A.start < B.end VƏ B.start < A.end
      return newStart < existingEnd && existingStart < newEnd;
    }
    
    // 1. Eyni sinif + gün + kəsişən saat
    final classDays = getClassTimetable(className);
    final targetDay = classDays.firstWhere(
      (d) => d.dayName == day, 
      orElse: () => DayTimetable(dayName: day, shortDay: '', lessons: []),
    );
    
    for (final lesson in targetDay.lessons) {
      if (isOverlapping(lesson.time)) {
        return '❌ Bu saat aralığı $className sinfində artıq mövcud dərs ilə kəsişir:\n\n'
            '📚 ${lesson.subject} (${lesson.teacher})\n'
            '🕐 ${lesson.time}\n\n'
            'Zəhmət olmasa fərqli saat seçin!';
      }
    }
    
    // 2. Eyni müəllim + gün + kəsişən saat
    for (final cls in _classTimetablesMap.keys) {
      final days = _classTimetablesMap[cls]!;
      final matchDay = days.firstWhere(
        (d) => d.dayName == day, 
        orElse: () => DayTimetable(dayName: day, shortDay: '', lessons: []),
      );
      
      for (final lesson in matchDay.lessons) {
        if (lesson.teacherId == teacherId && isOverlapping(lesson.time)) {
          return '❌ Bu müəllim eyni gün və saatda başqa sinifdə dərs tədris edir:\n\n'
              '📚 $cls sinfi - ${lesson.subject}\n'
              '🕐 ${lesson.time}\n'
              '👤 ${lesson.teacher}\n\n'
              'Eyni anda iki sinifdə dərs mümkün deyil!';
        }
      }
    }
    
    return null; // Konflikt yoxdur ✅
  }

  // ✅ YENİ: Admin dərs əlavə edir
  void addLessonToClassTimetable({
    required String className,
    required String day,
    required LessonSlot lesson,
  }) {
    final days = getClassTimetable(className);
    final dayIndex = days.indexWhere((d) => d.dayName == day);

    if (dayIndex != -1) {
      days[dayIndex].lessons.add(lesson);
    } else {
      days.add(DayTimetable(
        dayName: day,
        shortDay: day.substring(0, 2),
        lessons: [lesson],
      ));
    }

    _classTimetablesMap[className] = days;
    _firestoreService.saveClassTimetable(className, days);
    notifyListeners();
  }

  // --- ADMIN: CREATE TEACHER ACCOUNT ---
  AppUser createTeacherAccount({
    required String fullName,
    required String subject,
    required String roomNumber,
    required String phone,
    required String password,
    required TeacherPermissions permissions,
    String? photoUrl,
    List<String> assignedClasses = const [],
  }) {
    final codeNum =
        100 + _users.where((u) => u.role == UserRole.teacher).length + 1;
    final idrakCode = 'IDR-TCH-$codeNum';
    final rawUsername = fullName
        .toLowerCase()
        .replaceAll(' ', '.')
        .replaceAll('ə', 'e')
        .replaceAll('ı', 'i')
        .replaceAll('ö', 'o')
        .replaceAll('ü', 'u')
        .replaceAll('ç', 'c')
        .replaceAll('ş', 's')
        .replaceAll('ğ', 'g');
    final username = '$rawUsername$codeNum';

    final newTeacher = AppUser(
      id: 'usr-tch-${DateTime.now().millisecondsSinceEpoch}',
      username: username,
      password: password.isEmpty ? '123456' : password,
      fullName: fullName,
      role: UserRole.teacher,
      idrakCode: idrakCode,
      phone: phone,
      photoUrl: photoUrl,
      subject: subject,
      roomNumber: roomNumber,
      assignedClasses: assignedClasses,
      teacherPermissions: permissions,
      createdAt: DateTime.now(),
    );

    _users.insert(0, newTeacher);
    _firestoreService.saveUser(newTeacher);
    notifyListeners();
    return newTeacher;
  }

  // --- ADMIN: CREATE STUDENT & LINKED PARENT ACCOUNT ---
  Map<String, AppUser> createStudentAndParentAccount({
    required String studentName,
    required String className,
    required String bloodGroup,
    required List<String> allergies,
    required String studentPassword,
    required String parentName,
    required String parentPhone,
    required String parentPassword,
    String? studentPhotoUrl,
  }) {
    final stdIndex = _students.length + 1;
    final stdId = 'std-${100 + stdIndex}';
    final studentIdrakCode = 'IDR-2025-0${490 + stdIndex}';
    final barcodeData = '994019${283740 + stdIndex}';

    final cleanStdName = studentName
        .toLowerCase()
        .replaceAll(' ', '.')
        .replaceAll('ə', 'e')
        .replaceAll('ı', 'i')
        .replaceAll('ö', 'o')
        .replaceAll('ü', 'u')
        .replaceAll('ç', 'c')
        .replaceAll('ş', 's')
        .replaceAll('ğ', 'g');
    final studentUsername = '$cleanStdName$stdIndex';

    // 1. Create Student Profile
    final newStudentProfile = StudentProfile(
      id: stdId,
      fullName: studentName,
      studentNumber: studentIdrakCode,
      className: className,
      photoUrl:
          studentPhotoUrl ??
          'https://ui-avatars.com/api/?name=${Uri.encodeComponent(studentName)}&background=0D47A1&color=fff&size=400',
      qrData: 'IDRAK-STUDENT-2025-$studentName-$className',
      barcodeData: barcodeData,
      parentName: parentName,
      parentPhone: parentPhone,
      gpa: 0.0,
      attendanceRate: 0,
      academicYear: '2024 - 2025',
    );
    _students.add(newStudentProfile);
    _customClasses.add(className);
    _pendingAttendanceStudents.add(newStudentProfile);
    _firestoreService.saveStudent(newStudentProfile);

    // 2. Create Student AppUser
    final studentUser = AppUser(
      id: 'usr-$stdId',
      username: studentUsername,
      password: studentPassword.isEmpty ? '123456' : studentPassword,
      fullName: studentName,
      role: UserRole.student,
      idrakCode: studentIdrakCode,
      className: className,
      phone: parentPhone,
      photoUrl: studentPhotoUrl,
      createdAt: DateTime.now(),
    );
    _users.insert(0, studentUser);
    _firestoreService.saveUser(studentUser);

    // 3. Create Linked Parent AppUser
    final parentIdrakCode = 'IDR-PAR-0${490 + stdIndex}';
    final cleanParName = parentName
        .toLowerCase()
        .replaceAll(' ', '.')
        .replaceAll('ə', 'e')
        .replaceAll('ı', 'i')
        .replaceAll('ö', 'o')
        .replaceAll('ü', 'u')
        .replaceAll('ç', 'c')
        .replaceAll('ş', 's')
        .replaceAll('ğ', 'g');
    final parentUsername = 'valideyn.$cleanParName$stdIndex';

    final parentUser = AppUser(
      id: 'usr-par-$stdId',
      username: parentUsername,
      password: parentPassword.isEmpty ? '123456' : parentPassword,
      fullName: parentName,
      role: UserRole.parent,
      idrakCode: parentIdrakCode,
      phone: parentPhone,
      linkedStudentId: stdId,
      createdAt: DateTime.now(),
    );
    _users.insert(0, parentUser);
    _firestoreService.saveUser(parentUser);

    // 4. Create Student's Clean Medical Card
    final allergyItems = allergies
        .map(
          (a) => AllergyItem(
            name: a,
            severity: 'Yüksək dərəcə',
            reaction: 'Xüsusi qida / dərman həssaslığı',
            firstAid: 'Tibb otağına məlumat verilməli və pəhriz saxlanmalıdır.',
          ),
        )
        .toList();

    final newMedicalCard = StudentMedicalCard(
      bloodGroup: bloodGroup.isEmpty ? 'Məlumat daxil edilməyib' : bloodGroup,
      heightCm: 0.0,
      weightKg: 0.0,
      allergies: allergyItems,
      chronicConditions: [],
      vaccineHistory: [],
      emergencyContactName: parentName,
      emergencyContactPhone: parentPhone,
      lyceumDoctorNotes: 'Qeydiyyat zamanı həkim baxışı gözlənilir.',
    );
    _medicalCardsMap[stdId] = newMedicalCard;
    _firestoreService.saveMedicalCard(stdId, newMedicalCard);

    notifyListeners();
    return {'student': studentUser, 'parent': parentUser};
  }

  void updateTeacherPermissions(String userId, TeacherPermissions permissions) {
    final index = _users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      _users[index] = _users[index].copyWith(teacherPermissions: permissions);
      _firestoreService.updateTeacherPermissions(userId, permissions);
      notifyListeners();
    }
  }

  void toggleUserStatus(String userId) {
    final index = _users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      final updatedStatus = !_users[index].isActive;
      _users[index] = _users[index].copyWith(isActive: updatedStatus);
      _firestoreService.updateUserStatus(userId, updatedStatus);
      notifyListeners();
    }
  }

  /// İstifadəçinin profil fotosunu yeniləyir (Cloudinary URL)
  void updateUserPhoto(String userId, String newPhotoUrl) {
    final userIndex = _users.indexWhere((u) => u.id == userId);
    if (userIndex != -1) {
      _users[userIndex] = _users[userIndex].copyWith(photoUrl: newPhotoUrl);
      _firestoreService.saveUser(_users[userIndex]);
    }
    // Əgər tələbədirsə, StudentProfile-ı da yenilə
    final stdId = userId.replaceFirst('usr-', '');
    final stdIndex = _students.indexWhere((s) => s.id == stdId);
    if (stdIndex != -1) {
      _students[stdIndex] = _students[stdIndex].copyWith(photoUrl: newPhotoUrl);
      _firestoreService.saveStudent(_students[stdIndex]);
    }
    notifyListeners();
  }

  void deleteUser(String userId) {
    _users.removeWhere((u) => u.id == userId);
    notifyListeners();
  }

  // --- TIMETABLE (DƏRS CƏDVƏLİ) ---
  List<DayTimetable> get weeklyTimetable {
    final cls = student.className.isNotEmpty ? student.className : '9B';
    return getClassTimetable(cls);
  }

  // --- GRADES & LIVE GPA CALCULATION ---
  final List<GradeRecord> _grades = [];
  List<GradeRecord> get grades => _grades;

  void recalculateStudentGpa(String targetStdId) {
    final stdIndex = _students.indexWhere((s) => s.id == targetStdId);
    if (stdIndex == -1) return;

    final studentGrades = _grades
        .where((g) => g.studentId == targetStdId)
        .toList();
    if (studentGrades.isEmpty) {
      final old = _students[stdIndex];
      _students[stdIndex] = StudentProfile(
        id: old.id,
        fullName: old.fullName,
        studentNumber: old.studentNumber,
        className: old.className,
        photoUrl: old.photoUrl,
        qrData: old.qrData,
        barcodeData: old.barcodeData,
        parentName: old.parentName,
        parentPhone: old.parentPhone,
        gpa: 0.0,
        attendanceRate: old.attendanceRate,
        academicYear: old.academicYear,
      );
      _firestoreService.updateStudentGPA(targetStdId, 0.0, old.attendanceRate);
      return;
    }

    final validPcts = studentGrades.map((g) => g.percentage).toList();
    final avgPct = validPcts.reduce((a, b) => a + b) / validPcts.length;
    final calculatedGpa = double.parse(
      ((avgPct / 100.0) * 5.0).clamp(0.0, 5.0).toStringAsFixed(2),
    );

    final old = _students[stdIndex];
    _students[stdIndex] = StudentProfile(
      id: old.id,
      fullName: old.fullName,
      studentNumber: old.studentNumber,
      className: old.className,
      photoUrl: old.photoUrl,
      qrData: old.qrData,
      barcodeData: old.barcodeData,
      parentName: old.parentName,
      parentPhone: old.parentPhone,
      gpa: calculatedGpa,
      attendanceRate: old.attendanceRate,
      academicYear: old.academicYear,
    );
    _firestoreService.updateStudentGPA(
      targetStdId,
      calculatedGpa,
      old.attendanceRate,
    );
  }

  void addGrade(GradeRecord grade, [String? studentId]) {
    final targetStdId = studentId ?? grade.studentId ?? student.id;
    final stdIndex = _students.indexWhere((s) => s.id == targetStdId);
    final stdName = stdIndex != -1
        ? _students[stdIndex].fullName
        : student.fullName;

    // Sanitize score if out of bounds
    double sanitizedScore = grade.score;
    if (grade.maxScore == 100.0 &&
        sanitizedScore > 100.0 &&
        sanitizedScore <= 1000.0) {
      sanitizedScore = sanitizedScore / 10.0;
    } else if (sanitizedScore > grade.maxScore) {
      sanitizedScore = grade.maxScore;
    }

    final completeGrade = GradeRecord(
      id: grade.id,
      studentId: targetStdId,
      studentName: stdName,
      subject: grade.subject,
      type: grade.type,
      title: grade.title,
      score: sanitizedScore,
      maxScore: grade.maxScore,
      gradeLetter: grade.gradeLetter,
      date: grade.date,
      teacherFeedback: grade.teacherFeedback,
    );

    _grades.insert(0, completeGrade);
    _firestoreService.saveGrade(completeGrade, targetStdId, stdName);

    recalculateStudentGpa(targetStdId);
    notifyListeners();
  }

  void deleteGrade(String gradeId, [String? studentId]) {
    final targetGrade = _grades.firstWhere(
      (g) => g.id == gradeId,
      orElse: () => GradeRecord(
        id: '',
        subject: '',
        type: AssessmentType.ksq,
        title: '',
        score: 0,
        gradeLetter: '',
        date: DateTime.now(),
      ),
    );
    final targetStdId = studentId ?? targetGrade.studentId ?? student.id;

    _grades.removeWhere((g) => g.id == gradeId);
    _firestoreService.deleteGrade(gradeId);

    recalculateStudentGpa(targetStdId);
    notifyListeners();
  }

  // Attendance: studentId -> (dayOfMonth -> DayAttendance)
  final Map<String, Map<int, DayAttendance>> _studentAttendanceMap = {};

  Map<int, DayAttendance> getStudentAttendance(String studentId) {
    if (_studentAttendanceMap.containsKey(studentId)) {
      return _studentAttendanceMap[studentId]!;
    }
    final emptyMap = <int, DayAttendance>{};
    _studentAttendanceMap[studentId] = emptyMap;
    return emptyMap;
  }

  Map<int, DayAttendance> get attendance => getStudentAttendance(student.id);

  // --- MEDICAL CARD & PHYSICAL STATS (BOY / ÇƏKİ & BMI) ---
  StudentMedicalCard getMedicalCardForStudent(String studentId) {
    if (_medicalCardsMap.containsKey(studentId)) {
      return _medicalCardsMap[studentId]!;
    }
    final cleanCard = StudentMedicalCard(
      bloodGroup: 'Məlumat yoxdur',
      heightCm: 0.0,
      weightKg: 0.0,
      allergies: [],
      chronicConditions: [],
      vaccineHistory: [],
      emergencyContactName: '',
      emergencyContactPhone: '',
      lyceumDoctorNotes: 'Həkim qeydi yoxdur.',
    );
    _medicalCardsMap[studentId] = cleanCard;
    return cleanCard;
  }

  StudentMedicalCard get medicalCard => getMedicalCardForStudent(student.id);

  void updateStudentPhysicalStats({
    required String studentId,
    required double heightCm,
    required double weightKg,
    String? bloodGroup,
    String? doctorNote,
  }) {
    final card = getMedicalCardForStudent(studentId);
    final updatedCard = card.copyWith(
      heightCm: heightCm,
      weightKg: weightKg,
      bloodGroup: bloodGroup ?? card.bloodGroup,
      lyceumDoctorNotes: doctorNote ?? card.lyceumDoctorNotes,
    );
    _medicalCardsMap[studentId] = updatedCard;
    _firestoreService.saveMedicalCard(studentId, updatedCard);
    notifyListeners();
  }

  void addAllergyToStudent(String studentId, AllergyItem allergy) {
    final card = getMedicalCardForStudent(studentId);
    card.allergies.insert(0, allergy);
    _medicalCardsMap[studentId] = card;
    _firestoreService.saveMedicalCard(studentId, card);
    notifyListeners();
  }

  void addAllergy(AllergyItem allergy) {
    addAllergyToStudent(student.id, allergy);
  }

  void addVaccineRecordToStudent(String studentId, VaccineRecord vaccine) {
    final card = getMedicalCardForStudent(studentId);
    card.vaccineHistory.insert(0, vaccine);
    _medicalCardsMap[studentId] = card;
    _firestoreService.saveMedicalCard(studentId, card);
    notifyListeners();
  }

  void addVaccineRecord(VaccineRecord vaccine) {
    addVaccineRecordToStudent(student.id, vaccine);
  }

  void addParentMedicalNote(String studentId, String noteText) {
    final card = getMedicalCardForStudent(studentId);
    final parName = _currentUser?.fullName ?? 'Valideyn';
    final newNote = ParentMedicalNote(
      id: 'pnote-${DateTime.now().millisecondsSinceEpoch}',
      note: noteText,
      date: DateTime.now(),
      parentName: parName,
    );
    final updatedList = List<ParentMedicalNote>.from(card.parentNotes)
      ..insert(0, newNote);
    final updatedCard = card.copyWith(parentNotes: updatedList);
    _medicalCardsMap[studentId] = updatedCard;
    _firestoreService.saveMedicalCard(studentId, updatedCard);
    notifyListeners();
  }

  // QR Inventory Items
  final List<InventoryItem> _inventoryItems = [];
  List<InventoryItem> get inventoryItems => _inventoryItems;

  /// Resolves a scanned QR payload to its registered equipment, if any.
  InventoryItem? findInventoryItemByQr(String qrCode) {
    final clean = qrCode.trim();
    for (final item in _inventoryItems) {
      if (item.qrCode.trim() == clean) return item;
    }
    return null;
  }

  void addInventoryItem(InventoryItem item) {
    _inventoryItems.insert(0, item);
    _firestoreService.saveInventoryItem(item);
    notifyListeners();
  }

  void updateInventoryItem(InventoryItem item) {
    final index = _inventoryItems.indexWhere((i) => i.id == item.id);
    if (index != -1) {
      _inventoryItems[index] = item;
      _firestoreService.saveInventoryItem(item);
      notifyListeners();
    }
  }

  Future<void> deleteInventoryItem(String id) async {
    _inventoryItems.removeWhere((i) => i.id == id);
    await _firestoreService.deleteInventoryItem(id);
    notifyListeners();
  }

  // Tickets
  final List<HelpdeskTicket> _tickets = [];
  List<HelpdeskTicket> get tickets => _tickets;

  void addTicket(HelpdeskTicket ticket) {
    _tickets.insert(0, ticket);
    _firestoreService.saveTicket(ticket);
    notifyListeners();
  }

  void addTicketMessage(String ticketId, TicketMessage message) {
    final index = _tickets.indexWhere((t) => t.id == ticketId);
    if (index != -1) {
      final ticket = _tickets[index];
      final updatedMessages = List<TicketMessage>.from(ticket.messages)
        ..add(message);
      final updatedTicket = HelpdeskTicket(
        id: ticket.id,
        title: ticket.title,
        category: ticket.category,
        status: ticket.status,
        priority: ticket.priority,
        senderName: ticket.senderName,
        senderRole: ticket.senderRole,
        description: ticket.description,
        createdAt: ticket.createdAt,
        roomNumber: ticket.roomNumber,
        inventoryCode: ticket.inventoryCode,
        attachedImage: ticket.attachedImage,
        messages: updatedMessages,
      );
      _tickets[index] = updatedTicket;
      _firestoreService.saveTicket(updatedTicket);
      notifyListeners();
    }
  }

  // Assignments
  final List<HomeworkAssignment> _assignments = [];
  List<HomeworkAssignment> get assignments => _assignments;

  // Filtered assignments for currently logged in teacher (Admin sees all)
  List<HomeworkAssignment> get currentTeacherAssignments {
    if (_currentUser == null || _currentUser!.role == UserRole.admin) {
      return _assignments;
    }
    final teacherName = _currentUser!.fullName.trim().toLowerCase();
    return _assignments.where((a) {
      final aTeacher = a.teacherName.trim().toLowerCase();
      return aTeacher == teacherName ||
          aTeacher.contains(teacherName) ||
          teacherName.contains(aTeacher);
    }).toList();
  }

  void createAssignment(HomeworkAssignment assignment) {
    _assignments.insert(0, assignment);
    _firestoreService.saveAssignment(assignment);
    notifyListeners();
  }

  void submitHomework({
    required String assignmentId,
    required String studentId,
    required String studentName,
    required List<String> images,
    required String note,
  }) {
    final index = _assignments.indexWhere((a) => a.id == assignmentId);
    if (index != -1) {
      final old = _assignments[index];
      final newSubmissions = Map<String, AssignmentSubmission>.from(
        old.submissions,
      );
      newSubmissions[studentId] = AssignmentSubmission(
        studentId: studentId,
        studentName: studentName,
        submittedAt: DateTime.now(),
        scannedImages: images,
        studentNote: note,
      );

      final updated = HomeworkAssignment(
        id: old.id,
        subject: old.subject,
        title: old.title,
        teacherName: old.teacherName,
        instructions: old.instructions,
        assignedDate: old.assignedDate,
        dueDate: old.dueDate,
        attachmentDocUrl: old.attachmentDocUrl,
        assignedClass: old.assignedClass,
        assignedStudentIds: old.assignedStudentIds,
        submissions: newSubmissions,
      );
      _assignments[index] = updated;
      _firestoreService.saveAssignment(updated);
      notifyListeners();
    }
  }

  void gradeHomework({
    required String assignmentId,
    required String studentId,
    required double score,
    required String comment,
  }) {
    final index = _assignments.indexWhere((a) => a.id == assignmentId);
    if (index != -1) {
      final old = _assignments[index];
      final oldSub = old.submissions[studentId];
      if (oldSub != null) {
        final sanitizedScore = (score > 100.0)
            ? (score / 10.0).clamp(0.0, 100.0)
            : score.clamp(0.0, 100.0);
        final newSubmissions = Map<String, AssignmentSubmission>.from(
          old.submissions,
        );
        newSubmissions[studentId] = AssignmentSubmission(
          studentId: oldSub.studentId,
          studentName: oldSub.studentName,
          submittedAt: oldSub.submittedAt,
          scannedImages: oldSub.scannedImages,
          studentNote: oldSub.studentNote,
          score: sanitizedScore,
          teacherComment: comment,
          gradedAt: DateTime.now(),
        );

        final updated = HomeworkAssignment(
          id: old.id,
          subject: old.subject,
          title: old.title,
          teacherName: old.teacherName,
          instructions: old.instructions,
          assignedDate: old.assignedDate,
          dueDate: old.dueDate,
          attachmentDocUrl: old.attachmentDocUrl,
          assignedClass: old.assignedClass,
          assignedStudentIds: old.assignedStudentIds,
          submissions: newSubmissions,
        );

        _assignments[index] = updated;
        _firestoreService.saveAssignment(updated);

        // Auto-sync into student GradeRecords so parents see the grade and GPA is updated
        final targetStd = _students.firstWhere(
          (s) => s.id == studentId,
          orElse: () => student,
        );

        final gradeRecord = GradeRecord(
          id: 'gr-hw-${old.id}-$studentId',
          studentId: targetStd.id,
          studentName: targetStd.fullName,
          subject: old.subject,
          type: AssessmentType.ksq,
          title: 'Tapşırıq: ${old.title}',
          score: sanitizedScore,
          maxScore: 100.0,
          gradeLetter: sanitizedScore >= 90
              ? 'A'
              : (sanitizedScore >= 80
                    ? 'B'
                    : (sanitizedScore >= 70
                          ? 'C'
                          : (sanitizedScore >= 60 ? 'D' : 'E'))),
          date: DateTime.now(),
          teacherFeedback: comment.isNotEmpty
              ? comment
              : 'Müəllim (${old.teacherName}) tərəfindən yoxlanıldı.',
        );

        final existingGradeIdx = _grades.indexWhere(
          (g) => g.id == 'gr-hw-${old.id}-$studentId',
        );
        if (existingGradeIdx != -1) {
          _grades[existingGradeIdx] = gradeRecord;
        } else {
          _grades.insert(0, gradeRecord);
        }
        _firestoreService.saveGrade(
          gradeRecord,
          targetStd.id,
          targetStd.fullName,
        );
        recalculateStudentGpa(targetStd.id);

        notifyListeners();
      }
    }
  }

  void deleteAssignment(String assignmentId) {
    _assignments.removeWhere((a) => a.id == assignmentId);
    _firestoreService.deleteAssignment(assignmentId);
    notifyListeners();
  }

  // --- MEET İDRAK (VOICE ROOMS) ---
  final List<MeetRoom> _meetRooms = [];
  List<MeetRoom> get meetRooms => _meetRooms;

  List<MeetRoom> get onlineLessons => getMeetRoomsForCurrentUser();

  List<MeetRoom> getMeetRoomsForCurrentUser() {
    final user = _currentUser;
    if (user == null) return _meetRooms;

    if (user.role == UserRole.admin) {
      return _meetRooms;
    }

    if (user.role == UserRole.teacher) {
      return _meetRooms.where((room) {
        if (room.hostId == user.id) return true;
        if (room.allowTeachers) return true;
        return false;
      }).toList();
    }

    if (user.role == UserRole.student) {
      final studentClass = user.className ?? student.className;
      return _meetRooms.where((room) {
        if (!room.allowStudents) return false;
        if (room.targetClasses.isEmpty) return true;
        return room.targetClasses.contains(studentClass);
      }).toList();
    }

    if (user.role == UserRole.parent) {
      final childClass = student.className;
      return _meetRooms.where((room) {
        if (!room.allowStudents) return false;
        if (room.targetClasses.isEmpty) return true;
        return room.targetClasses.contains(childClass);
      }).toList();
    }

    return _meetRooms;
  }

  Future<MeetRoom> createMeetRoom({
    required String title,
    required String subject,
    List<String> targetClasses = const [],
    bool allowTeachers = true,
    bool allowStudents = true,
    DateTime? scheduledTime,
  }) async {
    final host = _currentUser;
    final hostId = host?.id ?? 'usr-tch-1';
    final hostName = host?.fullName ?? 'Fənn Müəllimi';
    final hostPhoto = host?.photoUrl;
    final roomId = 'meet-${DateTime.now().millisecondsSinceEpoch}';
    final channelName =
        'idrak_meet_${DateTime.now().millisecondsSinceEpoch % 100000}';

    // Host is automatically the first participant
    final hostParticipant = MeetParticipant(
      userId: hostId,
      fullName: hostName,
      role: 'host',
      photoUrl: hostPhoto,
      className: host?.className,
      agoraUid: agoraUidForUser(hostId),
      isMuted: false,
      isMutedByHost: false,
      isSpeaking: false,
    );

    final room = MeetRoom(
      id: roomId,
      title: title,
      hostId: hostId,
      hostName: hostName,
      hostPhotoUrl: hostPhoto,
      subject: subject,
      channelName: channelName,
      targetClasses: targetClasses,
      allowTeachers: allowTeachers,
      allowStudents: allowStudents,
      status: 'live',
      scheduledTime: scheduledTime,
      participants: [hostParticipant],
    );

    _meetRooms.insert(0, room);
    await _firestoreService.saveMeetRoom(room);
    notifyListeners();
    return room;
  }

  Future<void> endMeetRoom(String roomId) async {
    final index = _meetRooms.indexWhere((r) => r.id == roomId);
    if (index != -1) {
      _meetRooms[index] = _meetRooms[index].copyWith(status: 'ended');
      await _firestoreService.setMeetRoomStatus(roomId, 'ended');
      notifyListeners();
    }
  }

  Future<void> deleteMeetRoom(String roomId) async {
    _meetRooms.removeWhere((r) => r.id == roomId);
    await _firestoreService.deleteMeetRoom(roomId);
    notifyListeners();
  }

  Future<void> joinMeetRoom(String roomId) async {
    final index = _meetRooms.indexWhere((r) => r.id == roomId);
    if (index == -1) return;

    final room = _meetRooms[index];
    final user = _currentUser;
    final userId = user?.id ?? student.id;
    final userName = user?.fullName ?? student.fullName;
    final userRole = user?.role == UserRole.teacher
        ? 'teacher'
        : (user?.role == UserRole.admin ? 'admin' : 'student');
    final userPhoto = user?.photoUrl ?? student.photoUrl;
    final userClass = user?.className ?? student.className;
    final agoraUid = agoraUidForUser(userId);

    final newParticipant = MeetParticipant(
      userId: userId,
      fullName: userName,
      role: room.hostId == userId ? 'host' : userRole,
      photoUrl: userPhoto,
      className: userClass,
      agoraUid: agoraUid,
      isMuted: false,
      isMutedByHost: false,
    );

    // Immediately update local state for responsive UI
    final localParticipants = List<MeetParticipant>.from(room.participants);
    final existingIndex = localParticipants.indexWhere(
      (p) => p.userId == userId,
    );
    if (existingIndex == -1) {
      localParticipants.add(newParticipant);
    } else {
      localParticipants[existingIndex] = newParticipant;
    }
    _meetRooms[index] = room.copyWith(participants: localParticipants);
    notifyListeners();

    // Sync to Firestore in background (don't block UI)
    try {
      final updatedParticipants = await _firestoreService.joinMeetParticipant(
        roomId,
        newParticipant,
      );
      final currentIndex = _meetRooms.indexWhere((r) => r.id == roomId);
      if (currentIndex != -1) {
        _meetRooms[currentIndex] = _meetRooms[currentIndex]
            .copyWith(participants: updatedParticipants);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('⚠️ Firestore sync failed (local state preserved): $e');
    }
  }

  Future<void> leaveMeetRoom(String roomId) async {
    final index = _meetRooms.indexWhere((r) => r.id == roomId);
    if (index == -1) return;

    final room = _meetRooms[index];
    final userId = _currentUser?.id ?? student.id;

    // Immediately update local state
    final localParticipants = List<MeetParticipant>.from(room.participants);
    localParticipants.removeWhere((p) => p.userId == userId);
    _meetRooms[index] = room.copyWith(participants: localParticipants);
    notifyListeners();

    // Sync to Firestore in background
    try {
      final updatedParticipants = await _firestoreService.leaveMeetParticipant(
        roomId,
        userId,
      );
      final currentIndex = _meetRooms.indexWhere((r) => r.id == roomId);
      if (currentIndex != -1) {
        _meetRooms[currentIndex] = _meetRooms[currentIndex]
            .copyWith(participants: updatedParticipants);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('⚠️ Firestore leave sync failed (local state preserved): $e');
    }
  }

  Future<void> toggleMyMuteInRoom(String roomId) async {
    final index = _meetRooms.indexWhere((r) => r.id == roomId);
    if (index == -1) return;

    final room = _meetRooms[index];
    final userId = _currentUser?.id ?? student.id;

    final currentParticipant = room.participants
        .where((p) => p.userId == userId)
        .firstOrNull;
    if (currentParticipant?.isMutedByHost ?? false) return;
    final updatedParticipants = await _firestoreService.setMeetParticipantMuted(
      roomId,
      userId,
      !(currentParticipant?.isMuted ?? false),
    );

    _meetRooms[index] = room.copyWith(participants: updatedParticipants);
    notifyListeners();
  }

  Future<void> setParticipantMuteByHost(
    String roomId,
    String targetUserId,
    bool mute,
  ) async {
    final index = _meetRooms.indexWhere((r) => r.id == roomId);
    if (index == -1) return;

    final room = _meetRooms[index];
    final updatedParticipants = await _firestoreService.setMeetParticipantMuted(
      roomId,
      targetUserId,
      mute,
      mutedByHost: mute,
    );

    _meetRooms[index] = room.copyWith(participants: updatedParticipants);
    notifyListeners();
  }

  Future<void> muteAllInRoom(String roomId, bool mute) async {
    final index = _meetRooms.indexWhere((r) => r.id == roomId);
    if (index == -1) return;

    final room = _meetRooms[index];
    final updatedParticipants = await _firestoreService.muteAllMeetParticipants(
      roomId,
      mute,
    );

    _meetRooms[index] = room.copyWith(participants: updatedParticipants);
    notifyListeners();
  }

  void updateParticipantSpeaking(
    String roomId,
    String userId,
    bool isSpeaking,
  ) {
    final index = _meetRooms.indexWhere((r) => r.id == roomId);
    if (index == -1) return;

    final room = _meetRooms[index];
    final updatedParticipants = room.participants.map((p) {
      if (p.userId == userId) {
        return p.copyWith(isSpeaking: isSpeaking);
      }
      return p;
    }).toList();

    _meetRooms[index] = room.copyWith(participants: updatedParticipants);
    notifyListeners();
  }

  // Library
  final List<BookItem> _books = [];
  List<BookItem> get books => _books;

  void addBook(BookItem book) {
    _books.insert(0, book);
    _firestoreService.saveBook(book);
    notifyListeners();
  }

  void toggleBorrowBook(String bookId) {
    final index = _books.indexWhere((b) => b.id == bookId);
    if (index != -1) {
      final old = _books[index];
      final newBorrowed = !old.isBorrowedByMe;
      final updated = BookItem(
        id: old.id,
        title: old.title,
        author: old.author,
        category: old.category,
        coverUrl: old.coverUrl,
        type: old.type,
        pageCount: old.pageCount,
        language: old.language,
        availableCopies: newBorrowed
            ? old.availableCopies - 1
            : old.availableCopies + 1,
        isBorrowedByMe: newBorrowed,
        returnDeadline: newBorrowed
            ? DateTime.now().add(const Duration(days: 14))
            : null,
        description: old.description,
        rating: old.rating,
      );
      _books[index] = updated;
      _firestoreService.saveBook(updated);
      notifyListeners();
    }
  }

  // Cafeteria Menu
  final List<DailyMenu> _weeklyMenu = List.from(MockData.weeklyMenu);
  List<DailyMenu> get weeklyMenu => _weeklyMenu;

  void addMenuItemToDay(int dayIndex, MenuItem item) {
    if (dayIndex >= 0 && dayIndex < _weeklyMenu.length) {
      _weeklyMenu[dayIndex].items.add(item);
      _weeklyMenu[dayIndex] = DailyMenu(
        dayName: _weeklyMenu[dayIndex].dayName,
        date: _weeklyMenu[dayIndex].date,
        mealTime: _weeklyMenu[dayIndex].mealTime,
        totalCalories: _weeklyMenu[dayIndex].totalCalories + item.calories,
        items: _weeklyMenu[dayIndex].items,
      );
      _firestoreService.saveWeeklyMenu(_weeklyMenu);
      notifyListeners();
    }
  }

  void removeMenuItemFromDay(int dayIndex, int itemIndex) {
    if (dayIndex >= 0 && dayIndex < _weeklyMenu.length) {
      if (itemIndex >= 0 && itemIndex < _weeklyMenu[dayIndex].items.length) {
        final removed = _weeklyMenu[dayIndex].items.removeAt(itemIndex);
        _weeklyMenu[dayIndex] = DailyMenu(
          dayName: _weeklyMenu[dayIndex].dayName,
          date: _weeklyMenu[dayIndex].date,
          mealTime: _weeklyMenu[dayIndex].mealTime,
          totalCalories:
              (_weeklyMenu[dayIndex].totalCalories - removed.calories).clamp(
                0,
                99999,
              ),
          items: _weeklyMenu[dayIndex].items,
        );
        _firestoreService.saveWeeklyMenu(_weeklyMenu);
        notifyListeners();
      }
    }
  }

  // --- TEACHER HUB: SMART ATTENDANCE TINDER-STYLE STATE ---
  late List<StudentProfile> _pendingAttendanceStudents = List.from(_students);
  List<StudentProfile> get pendingAttendanceStudents =>
      _pendingAttendanceStudents;

  final Map<String, AttendanceStatus> _currentSessionAttendance = {};
  Map<String, AttendanceStatus> get currentSessionAttendance =>
      _currentSessionAttendance;

  final List<MapEntry<String, AttendanceStatus>> _attendanceHistory = [];

  String _currentSessionClass = '';
  String get currentSessionClass => _currentSessionClass;
  String _currentSessionSubject = '';
  String get currentSessionSubject => _currentSessionSubject;

  void startAttendanceForLesson({
    required String className,
    required String subject,
    required String time,
  }) {
    _currentSessionClass = className;
    _currentSessionSubject = subject;
    final classStudents = getStudentsForClass(className);
    _pendingAttendanceStudents = List.from(classStudents);
    _currentSessionAttendance.clear();
    _attendanceHistory.clear();
    notifyListeners();
  }

  void recordSwipeAttendance(String studentId, AttendanceStatus status) {
    _currentSessionAttendance[studentId] = status;
    _attendanceHistory.add(MapEntry(studentId, status));
    _pendingAttendanceStudents.removeWhere((s) => s.id == studentId);
    notifyListeners();
  }

  final Map<String, DateTime> _attendanceLockTimestamps = {};

  bool isAttendanceLocked(String className, String subject) {
    if (_currentUser?.role == UserRole.admin) return false;
    final now = DateTime.now();
    final key =
        '${className.trim().toLowerCase()}_${subject.trim().toLowerCase()}_${now.year}_${now.month}_${now.day}';
    final submittedTime = _attendanceLockTimestamps[key];
    if (submittedTime == null) return false;
    final diff = now.difference(submittedTime);
    return diff.inMinutes >= 5;
  }

  DateTime? getAttendanceSubmittedTime(String className, String subject) {
    final now = DateTime.now();
    final key =
        '${className.trim().toLowerCase()}_${subject.trim().toLowerCase()}_${now.year}_${now.month}_${now.day}';
    return _attendanceLockTimestamps[key];
  }

  void completeAttendanceSession() {
    final now = DateTime.now();
    final dayNum = now.day;
    final subjectName = _currentSessionSubject.isNotEmpty
        ? _currentSessionSubject
        : 'Dərs';
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final lockKey =
        '${_currentSessionClass.trim().toLowerCase()}_${_currentSessionSubject.trim().toLowerCase()}_${now.year}_${now.month}_${now.day}';
    _attendanceLockTimestamps[lockKey] = now;

    _currentSessionAttendance.forEach((studentId, status) {
      final studentAttMap = _studentAttendanceMap.putIfAbsent(
        studentId,
        () => {},
      );
      final existingDay = studentAttMap[dayNum];

      List<PeriodAttendance> periods = [];
      if (existingDay != null) {
        periods = List<PeriodAttendance>.from(existingDay.periodDetails);
      }

      // Check if this subject already exists in today's lesson list; if so, update, otherwise append!
      final existingPeriodIndex = periods.indexWhere(
        (p) => p.subject.toLowerCase() == subjectName.toLowerCase(),
      );
      final newPeriod = PeriodAttendance(
        period:
            '${existingPeriodIndex != -1 ? existingPeriodIndex + 1 : periods.length + 1}-ci dərs',
        subject: subjectName,
        status: status,
        time: timeStr,
      );

      if (existingPeriodIndex != -1) {
        periods[existingPeriodIndex] = newPeriod;
      } else {
        periods.add(newPeriod);
      }

      // Overall status for the day:
      // If any period is absent -> absent, else if any is late -> late, else present!
      AttendanceStatus overallStatus = AttendanceStatus.present;
      if (periods.any((p) => p.status == AttendanceStatus.absent)) {
        overallStatus = AttendanceStatus.absent;
      } else if (periods.any((p) => p.status == AttendanceStatus.late)) {
        overallStatus = AttendanceStatus.late;
      }

      final hasLate = periods.any((p) => p.status == AttendanceStatus.late);
      final hasAbsent = periods.any((p) => p.status == AttendanceStatus.absent);
      final noteText = hasAbsent
          ? 'Qayıb dərslər var'
          : (hasLate
                ? 'Dərsə gecikmə qeydə alınıb'
                : 'Bütün dərslərdə tam iştirak edib');

      final dayAtt = DayAttendance(
        date: now,
        status: overallStatus,
        note: noteText,
        periodDetails: periods,
      );

      studentAttMap[dayNum] = dayAtt;
      _firestoreService.saveStudentDayAttendance(studentId, dayNum, dayAtt);
    });

    // Recalculate attendance rate for students
    for (final studentId in _currentSessionAttendance.keys) {
      final stdIndex = _students.indexWhere((s) => s.id == studentId);
      if (stdIndex != -1) {
        final stdAttMap = _studentAttendanceMap[studentId] ?? {};
        if (stdAttMap.isNotEmpty) {
          int totalPeriods = 0;
          int attendedPeriods = 0;
          for (final d in stdAttMap.values) {
            totalPeriods += d.periodDetails.length;
            attendedPeriods += d.periodDetails
                .where(
                  (p) =>
                      p.status == AttendanceStatus.present ||
                      p.status == AttendanceStatus.late,
                )
                .length;
          }
          final rate = totalPeriods > 0
              ? ((attendedPeriods / totalPeriods) * 100).round()
              : 100;
          final old = _students[stdIndex];
          _students[stdIndex] = StudentProfile(
            id: old.id,
            fullName: old.fullName,
            studentNumber: old.studentNumber,
            className: old.className,
            photoUrl: old.photoUrl,
            qrData: old.qrData,
            barcodeData: old.barcodeData,
            parentName: old.parentName,
            parentPhone: old.parentPhone,
            gpa: old.gpa,
            attendanceRate: rate,
            academicYear: old.academicYear,
          );
          _firestoreService.updateStudentGPA(studentId, old.gpa, rate);
        }
      }
    }

    notifyListeners();
  }

  void undoLastSwipe() {
    if (_attendanceHistory.isNotEmpty) {
      final last = _attendanceHistory.removeLast();
      _currentSessionAttendance.remove(last.key);
      final restoredStudent = _students.firstWhere(
        (s) => s.id == last.key,
        orElse: () => MockData.currentStudent,
      );
      if (restoredStudent.id != 'std-empty') {
        _pendingAttendanceStudents.insert(0, restoredStudent);
      }
      notifyListeners();
    }
  }

  void resetAttendanceSession() {
    _pendingAttendanceStudents = _currentSessionClass.isNotEmpty
        ? List.from(getStudentsForClass(_currentSessionClass))
        : List.from(_students);
    _currentSessionAttendance.clear();
    _attendanceHistory.clear();
    notifyListeners();
  }

  // --- NOTIFICATIONS & ANNOUNCEMENTS ---
  final List<AppNotification> _notifications = [];
  List<AppNotification> get notifications => _notifications;

  List<AppNotification> get notificationsForCurrentUser {
    final user = _currentUser;
    if (user == null) return [];

    final userId = user.id;
    final userRole = user.role;

    if (userRole == UserRole.admin) {
      return _notifications;
    }

    return _notifications.where((n) {
      // 1. Direct message targeted to this user or sent by this user
      if (n.targetParentId == userId ||
          n.targetStudentId == userId ||
          n.senderId == userId) {
        return true;
      }

      // 2. Teacher filtering
      if (userRole == UserRole.teacher) {
        if (n.targetRoles.isNotEmpty && !n.targetRoles.contains('teacher')) {
          return false;
        }
        return true;
      }

      // 3. Student filtering
      if (userRole == UserRole.student) {
        if (n.targetStudentId != null &&
            n.targetStudentId != userId &&
            n.targetStudentId != student.id) {
          return false;
        }
        if (n.targetRoles.isNotEmpty && !n.targetRoles.contains('student')) {
          return false;
        }
        final sClass = user.className ?? student.className;
        if (n.targetClasses.isNotEmpty && !n.targetClasses.contains(sClass)) {
          return false;
        }
        return true;
      }

      // 4. Parent filtering
      if (userRole == UserRole.parent) {
        final childId = user.linkedStudentId ?? student.id;
        final childClass = student.className;

        if (n.targetStudentId != null && n.targetStudentId != childId) {
          return false;
        }
        if (n.targetParentId != null && n.targetParentId != userId) {
          return false;
        }
        if (n.targetRoles.isNotEmpty && !n.targetRoles.contains('parent')) {
          return false;
        }
        if (n.targetClasses.isNotEmpty &&
            !n.targetClasses.contains(childClass)) {
          return false;
        }
        return true;
      }

      return false;
    }).toList();
  }

  int get unreadNotificationCount {
    final user = _currentUser;
    if (user == null) return 0;
    final userId = user.id;
    return notificationsForCurrentUser.where((n) => !n.isReadBy(userId)).length;
  }

  Future<AppNotification> sendNotification({
    required String title,
    required String message,
    NotificationCategory category = NotificationCategory.general,
    String? targetStudentId,
    String? targetStudentName,
    String? targetParentId,
    List<String> targetClasses = const [],
    List<String> targetRoles = const [],
    String priority = 'normal',
  }) async {
    final user = _currentUser;
    final senderId = user?.id ?? 'school';
    final senderName = user?.fullName ?? 'İdrak Liseyi Rəhbərliyi';
    final senderRole = user?.role == UserRole.teacher
        ? 'teacher'
        : (user?.role == UserRole.admin ? 'admin' : 'school');
    final senderSubject = user?.subject;
    final senderPhoto = user?.photoUrl;
    final notifId = 'notif-${DateTime.now().millisecondsSinceEpoch}';

    final notif = AppNotification(
      id: notifId,
      title: title,
      message: message,
      category: category,
      senderId: senderId,
      senderName: senderName,
      senderPhotoUrl: senderPhoto,
      senderRole: senderRole,
      senderSubject: senderSubject,
      targetStudentId: targetStudentId,
      targetStudentName: targetStudentName,
      targetParentId: targetParentId,
      targetClasses: targetClasses,
      targetRoles: targetRoles,
      priority: priority,
    );

    _notifications.insert(0, notif);
    await _firestoreService.saveNotification(notif);
    notifyListeners();
    return notif;
  }

  Future<void> markNotificationAsRead(String notifId) async {
    final user = _currentUser;
    if (user == null) return;
    final userId = user.id;

    final idx = _notifications.indexWhere((n) => n.id == notifId);
    if (idx != -1) {
      if (!_notifications[idx].readByUserIds.contains(userId)) {
        final updatedIds = List<String>.from(_notifications[idx].readByUserIds)
          ..add(userId);
        _notifications[idx] = _notifications[idx].copyWith(
          readByUserIds: updatedIds,
        );
        await _firestoreService.markNotificationRead(notifId, userId);
        notifyListeners();
      }
    }
  }

  Future<void> markAllNotificationsAsRead() async {
    final user = _currentUser;
    if (user == null) return;
    final userId = user.id;

    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].readByUserIds.contains(userId)) {
        final updatedIds = List<String>.from(_notifications[i].readByUserIds)
          ..add(userId);
        _notifications[i] = _notifications[i].copyWith(
          readByUserIds: updatedIds,
        );
        _firestoreService.markNotificationRead(_notifications[i].id, userId);
      }
    }
    notifyListeners();
  }

  Future<void> deleteNotification(String notifId) async {
    _notifications.removeWhere((n) => n.id == notifId);
    await _firestoreService.deleteNotification(notifId);
    notifyListeners();
  }
}
