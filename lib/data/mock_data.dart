import 'models/timetable_model.dart';
import 'models/grade_model.dart';
import 'models/attendance_model.dart';
import 'models/medical_model.dart';
import 'models/ticket_model.dart';
import 'models/assignment_model.dart';
import 'models/student_model.dart';
import 'models/library_model.dart';
import 'models/menu_model.dart';
import 'models/meet_model.dart';

class MockData {
  // Empty default student placeholder (used when no student is active)
  static final StudentProfile currentStudent = StudentProfile(
    id: 'std-empty',
    fullName: 'Şagird Təyin Olunmayıb',
    studentNumber: 'IDR-2025-0000',
    className: 'Sinif Seçilməyib',
    photoUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
    qrData: 'IDRAK-STUDENT-EMPTY',
    barcodeData: '000000000000',
    parentName: 'Valideyn qeyd olunmayıb',
    parentPhone: '-',
    gpa: 0.0,
    attendanceRate: 0,
    academicYear: '2024 - 2025',
  );

  // All student lists start empty - only real accounts created by Admin will exist!
  static final List<StudentProfile> classStudents = [];

  // Default timetable template structure
  static final List<DayTimetable> weeklyTimetable = [
    DayTimetable(
      dayName: 'Bazar ertəsi',
      shortDay: 'B.E',
      lessons: [
        LessonSlot(period: '1-ci dərs', time: '08:30 - 09:15', subject: 'Riyaziyyat (Cəbr)', teacher: 'Müəllim Təyin Olunub', room: 'Otaq 302', isCurrent: true),
        LessonSlot(period: '2-ci dərs', time: '09:25 - 10:10', subject: 'Azərbaycan Dili', teacher: 'Tədris Şöbəsi', room: 'Otaq 204'),
        LessonSlot(period: '3-ci dərs', time: '10:20 - 11:05', subject: 'Fizika', teacher: 'Tədris Şöbəsi', room: 'Laboratoriya 1'),
        LessonSlot(period: '4-ci dərs', time: '11:15 - 12:00', subject: 'İngilis Dili', teacher: 'Tədris Şöbəsi', room: 'Otaq 401'),
        LessonSlot(period: '5-ci dərs', time: '12:45 - 13:30', subject: 'Kimya', teacher: 'Tədris Şöbəsi', room: 'Laboratoriya 2'),
      ],
    ),
    DayTimetable(
      dayName: 'Çərşənbə axşamı',
      shortDay: 'Ç.A',
      lessons: [
        LessonSlot(period: '1-ci dərs', time: '08:30 - 09:15', subject: 'İnformatika', teacher: 'Tədris Şöbəsi', room: 'Kompüter Zalı'),
        LessonSlot(period: '2-ci dərs', time: '09:25 - 10:10', subject: 'Riyaziyyat (Həndəsə)', teacher: 'Tədris Şöbəsi', room: 'Otaq 302'),
        LessonSlot(period: '3-ci dərs', time: '10:20 - 11:05', subject: 'Biologiya', teacher: 'Tədris Şöbəsi', room: 'Bio-Lab'),
        LessonSlot(period: '4-ci dərs', time: '11:15 - 12:00', subject: 'Ədəbiyyat', teacher: 'Tədris Şöbəsi', room: 'Otaq 204'),
      ],
    ),
    DayTimetable(
      dayName: 'Çərşənbə',
      shortDay: 'Ç.',
      lessons: [
        LessonSlot(period: '1-ci dərs', time: '08:30 - 09:15', subject: 'Fizika', teacher: 'Tədris Şöbəsi', room: 'Laboratoriya 1'),
        LessonSlot(period: '2-ci dərs', time: '09:25 - 10:10', subject: 'İngilis Dili', teacher: 'Tədris Şöbəsi', room: 'Otaq 401'),
        LessonSlot(period: '3-ci dərs', time: '10:20 - 11:05', subject: 'Riyaziyyat', teacher: 'Tədris Şöbəsi', room: 'Otaq 302'),
        LessonSlot(period: '4-ci dərs', time: '11:15 - 12:00', subject: 'Coğrafiya', teacher: 'Tədris Şöbəsi', room: 'Otaq 210'),
      ],
    ),
    DayTimetable(
      dayName: 'Cümə axşamı',
      shortDay: 'C.A',
      lessons: [
        LessonSlot(period: '1-ci dərs', time: '08:30 - 09:15', subject: 'Kimya', teacher: 'Tədris Şöbəsi', room: 'Laboratoriya 2'),
        LessonSlot(period: '2-ci dərs', time: '09:25 - 10:10', subject: 'Azərbaycan Dili', teacher: 'Tədris Şöbəsi', room: 'Otaq 204'),
        LessonSlot(period: '3-ci dərs', time: '10:20 - 11:05', subject: 'Riyaziyyat', teacher: 'Tədris Şöbəsi', room: 'Otaq 302'),
      ],
    ),
    DayTimetable(
      dayName: 'Cümə',
      shortDay: 'C.',
      lessons: [
        LessonSlot(period: '1-ci dərs', time: '08:30 - 09:15', subject: 'İngilis Dili', teacher: 'Tədris Şöbəsi', room: 'Otaq 401'),
        LessonSlot(period: '2-ci dərs', time: '09:25 - 10:10', subject: 'Biologiya', teacher: 'Tədris Şöbəsi', room: 'Bio-Lab'),
        LessonSlot(period: '3-ci dərs', time: '10:20 - 11:05', subject: 'Tarix', teacher: 'Tədris Şöbəsi', room: 'Otaq 108'),
      ],
    ),
  ];

  // Grades - Starts empty!
  static final List<GradeRecord> gradesList = [];

  // Subject Progress for Analytics - Starts empty
  static final List<SubjectProgress> subjectProgressList = [];

  // Attendance - Starts empty!
  static final Map<int, DayAttendance> monthlyAttendance = {};

  // Clean empty Medical Card
  static final StudentMedicalCard medicalCard = StudentMedicalCard(
    bloodGroup: 'Məlumat daxil edilməyib',
    heightCm: 0.0,
    weightKg: 0.0,
    allergies: [],
    chronicConditions: [],
    vaccineHistory: [],
    emergencyContactName: '',
    emergencyContactPhone: '',
    lyceumDoctorNotes: 'Həkim qeydi yoxdur.',
  );

  // Tickets - Starts empty!
  static final List<HelpdeskTicket> tickets = [];

  // Assignments - Starts empty!
  static final List<HomeworkAssignment> assignments = [];

  // Meet Idrak lessons
  static final List<OnlineLesson> onlineLessons = [];

  // Library Books - Starts empty!
  static final List<BookItem> libraryBooks = [];

  // Cafeteria Menu - Default Days
  static final List<DailyMenu> weeklyMenu = [
    DailyMenu(
      dayName: 'Bazar ertəsi',
      date: DateTime.now(),
      mealTime: 'Nahar (12:30 - 13:30)',
      totalCalories: 0,
      items: [],
    ),
    DailyMenu(
      dayName: 'Çərşənbə axşamı',
      date: DateTime.now().add(const Duration(days: 1)),
      mealTime: 'Nahar (12:30 - 13:30)',
      totalCalories: 0,
      items: [],
    ),
    DailyMenu(
      dayName: 'Çərşənbə',
      date: DateTime.now().add(const Duration(days: 2)),
      mealTime: 'Nahar (12:30 - 13:30)',
      totalCalories: 0,
      items: [],
    ),
    DailyMenu(
      dayName: 'Cümə axşamı',
      date: DateTime.now().add(const Duration(days: 3)),
      mealTime: 'Nahar (12:30 - 13:30)',
      totalCalories: 0,
      items: [],
    ),
    DailyMenu(
      dayName: 'Cümə',
      date: DateTime.now().add(const Duration(days: 4)),
      mealTime: 'Nahar (12:30 - 13:30)',
      totalCalories: 0,
      items: [],
    ),
  ];
}
