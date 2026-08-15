import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../data/models/user_model.dart';
import '../providers/app_state.dart';
import '../data/models/student_model.dart';
import '../data/models/medical_model.dart';
import '../data/models/assignment_model.dart';
import '../data/models/grade_model.dart';
import '../data/models/ticket_model.dart';
import '../data/models/library_model.dart';
import '../data/models/menu_model.dart';
import '../data/models/timetable_model.dart';
import '../data/models/attendance_model.dart';
import '../data/models/meet_model.dart';
import '../data/models/notification_model.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  FirebaseFirestore? _firestore;

  FirebaseFirestore get db {
    _firestore ??= FirebaseFirestore.instance;
    return _firestore!;
  }

  // --- USERS ---
  Future<void> saveUser(AppUser user) async {
    try {
      await db.collection('users').doc(user.id).set({
        'id': user.id,
        'username': user.username,
        'password': user.password,
        'fullName': user.fullName,
        'role': user.role.name,
        'idrakCode': user.idrakCode,
        'phone': user.phone,
        'email': user.email,
        'photoUrl': user.photoUrl,
        'className': user.className,
        'assignedClasses': user.assignedClasses,
        'subject': user.subject,
        'roomNumber': user.roomNumber,
        'linkedStudentId': user.linkedStudentId,
        'isActive': user.isActive,
        'createdAt': user.createdAt.toIso8601String(),
        'teacherPermissions': user.teacherPermissions != null
            ? {
                'canManageCafeteria': user.teacherPermissions!.canManageCafeteria,
                'canManageMedical': user.teacherPermissions!.canManageMedical,
                'canManageInventory': user.teacherPermissions!.canManageInventory,
              }
            : null,
      });
    } catch (e) {
      debugPrint('Firestore saveUser error: $e');
    }
  }

  Future<List<AppUser>> fetchUsers() async {
    try {
      final snapshot = await db.collection('users').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        TeacherPermissions? permissions;
        if (data['teacherPermissions'] != null) {
          final p = data['teacherPermissions'] as Map<String, dynamic>;
          permissions = TeacherPermissions(
            canManageCafeteria: p['canManageCafeteria'] ?? false,
            canManageMedical: p['canManageMedical'] ?? false,
            canManageInventory: p['canManageInventory'] ?? false,
          );
        }
        return AppUser(
          id: data['id'] ?? doc.id,
          username: data['username'] ?? '',
          password: data['password'] ?? '123',
          fullName: data['fullName'] ?? '',
          role: UserRole.values.firstWhere(
            (r) => r.name == data['role'],
            orElse: () => UserRole.student,
          ),
          idrakCode: data['idrakCode'] ?? '',
          phone: data['phone'] ?? '',
          email: data['email'],
          photoUrl: data['photoUrl'],
          className: data['className'],
          assignedClasses: List<String>.from(data['assignedClasses'] ?? []),
          subject: data['subject'],
          roomNumber: data['roomNumber'],
          linkedStudentId: data['linkedStudentId'],
          isActive: data['isActive'] ?? true,
          createdAt: data['createdAt'] != null
              ? DateTime.tryParse(data['createdAt']) ?? DateTime.now()
              : DateTime.now(),
          teacherPermissions: permissions,
        );
      }).toList();
    } catch (e) {
      debugPrint('Firestore fetchUsers error: $e');
      return [];
    }
  }

  Future<void> updateUserStatus(String userId, bool isActive) async {
    try {
      await db.collection('users').doc(userId).update({'isActive': isActive});
    } catch (e) {
      debugPrint('Firestore updateUserStatus error: $e');
    }
  }

  Future<void> updateTeacherPermissions(String userId, TeacherPermissions perms) async {
    try {
      await db.collection('users').doc(userId).update({
        'teacherPermissions': {
          'canManageCafeteria': perms.canManageCafeteria,
          'canManageMedical': perms.canManageMedical,
          'canManageInventory': perms.canManageInventory,
        }
      });
    } catch (e) {
      debugPrint('Firestore updateTeacherPermissions error: $e');
    }
  }

  Future<void> updateTeacherAssignedClasses(String userId, List<String> classes) async {
    try {
      await db.collection('users').doc(userId).update({
        'assignedClasses': classes,
      });
    } catch (e) {
      debugPrint('Firestore updateTeacherAssignedClasses error: $e');
    }
  }

  // --- TIMETABLE PER CLASS ---
  Future<void> saveClassTimetable(String className, List<DayTimetable> timetable) async {
    try {
      final daysMap = timetable.map((day) => {
        'dayName': day.dayName,
        'shortDay': day.shortDay,
        'lessons': day.lessons.map((l) => {
          'period': l.period,
          'time': l.time,
          'subject': l.subject,
          'teacher': l.teacher,
          'room': l.room,
          'colorHex': l.colorHex,
          'isCurrent': l.isCurrent,
        }).toList(),
      }).toList();

      await db.collection('timetables').doc(className).set({
        'className': className,
        'updatedAt': DateTime.now().toIso8601String(),
        'days': daysMap,
      });
    } catch (e) {
      debugPrint('Firestore saveClassTimetable error: $e');
    }
  }

  Future<Map<String, List<DayTimetable>>> fetchAllClassTimetables() async {
    try {
      final snapshot = await db.collection('timetables').get();
      final Map<String, List<DayTimetable>> result = {};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final className = data['className'] ?? doc.id;
        final daysData = (data['days'] as List<dynamic>?) ?? [];

        final daysList = daysData.map((d) {
          final dm = d as Map<String, dynamic>;
          final lessonsData = (dm['lessons'] as List<dynamic>?) ?? [];
          final lessons = lessonsData.map((lm) {
            final l = lm as Map<String, dynamic>;
            return LessonSlot(
              period: l['period'] ?? '',
              time: l['time'] ?? '',
              subject: l['subject'] ?? '',
              teacher: l['teacher'] ?? '',
              room: l['room'] ?? '',
              colorHex: l['colorHex'] ?? '0xFF2563EB',
              isCurrent: l['isCurrent'] ?? false,
            );
          }).toList();

          return DayTimetable(
            dayName: dm['dayName'] ?? '',
            shortDay: dm['shortDay'] ?? '',
            lessons: lessons,
          );
        }).toList();

        result[className] = daysList;
      }
      return result;
    } catch (e) {
      debugPrint('Firestore fetchAllClassTimetables error: $e');
      return {};
    }
  }

  // --- STUDENTS ---
  Future<void> saveStudent(StudentProfile student) async {
    try {
      await db.collection('students').doc(student.id).set({
        'id': student.id,
        'fullName': student.fullName,
        'studentNumber': student.studentNumber,
        'className': student.className,
        'photoUrl': student.photoUrl,
        'qrData': student.qrData,
        'barcodeData': student.barcodeData,
        'parentName': student.parentName,
        'parentPhone': student.parentPhone,
        'gpa': student.gpa,
        'attendanceRate': student.attendanceRate,
        'academicYear': student.academicYear,
      });
    } catch (e) {
      debugPrint('Firestore saveStudent error: $e');
    }
  }

  Future<void> updateStudentClass(String studentId, String newClassName) async {
    try {
      await db.collection('students').doc(studentId).update({'className': newClassName});
      await db.collection('users').doc('usr-$studentId').update({'className': newClassName});
    } catch (e) {
      debugPrint('Firestore updateStudentClass error: $e');
    }
  }

  Future<void> updateStudentGPA(String studentId, double gpa, int attendanceRate) async {
    try {
      await db.collection('students').doc(studentId).update({
        'gpa': gpa,
        'attendanceRate': attendanceRate,
      });
    } catch (e) {
      debugPrint('Firestore updateStudentGPA error: $e');
    }
  }

  Future<List<StudentProfile>> fetchStudents() async {
    try {
      final snapshot = await db.collection('students').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return StudentProfile(
          id: data['id'] ?? doc.id,
          fullName: data['fullName'] ?? '',
          studentNumber: data['studentNumber'] ?? '',
          className: data['className'] ?? '',
          photoUrl: data['photoUrl'] ?? '',
          qrData: data['qrData'] ?? '',
          barcodeData: data['barcodeData'] ?? '',
          parentName: data['parentName'] ?? '',
          parentPhone: data['parentPhone'] ?? '',
          gpa: (data['gpa'] as num?)?.toDouble() ?? 0.0,
          attendanceRate: (data['attendanceRate'] as num?)?.toInt() ?? 0,
          academicYear: data['academicYear'] ?? '2024 - 2025',
        );
      }).toList();
    } catch (e) {
      debugPrint('Firestore fetchStudents error: $e');
      return [];
    }
  }

  // --- MEDICAL CARDS (Per Student) ---
  Future<void> saveMedicalCard(String studentId, StudentMedicalCard card) async {
    try {
      await db.collection('medical_cards').doc(studentId).set({
        'studentId': studentId,
        'bloodGroup': card.bloodGroup,
        'heightCm': card.heightCm,
        'weightKg': card.weightKg,
        'emergencyContactName': card.emergencyContactName,
        'emergencyContactPhone': card.emergencyContactPhone,
        'lyceumDoctorNotes': card.lyceumDoctorNotes,
        'chronicConditions': card.chronicConditions,
        'allergies': card.allergies.map((a) => {
          'name': a.name,
          'severity': a.severity,
          'reaction': a.reaction,
          'firstAid': a.firstAid,
        }).toList(),
        'vaccineHistory': card.vaccineHistory.map((v) => {
          'name': v.name,
          'date': v.date.toIso8601String(),
          'status': v.status,
          'doctor': v.doctor,
        }).toList(),
        'parentNotes': card.parentNotes.map((p) => {
          'id': p.id,
          'note': p.note,
          'date': p.date.toIso8601String(),
          'parentName': p.parentName,
        }).toList(),
      });
    } catch (e) {
      debugPrint('Firestore saveMedicalCard error: $e');
    }
  }

  Future<StudentMedicalCard?> fetchMedicalCard(String studentId) async {
    try {
      final doc = await db.collection('medical_cards').doc(studentId).get();
      if (!doc.exists || doc.data() == null) return null;
      final data = doc.data()!;

      final allergiesList = (data['allergies'] as List<dynamic>?)?.map((item) {
        final m = item as Map<String, dynamic>;
        return AllergyItem(
          name: m['name'] ?? '',
          severity: m['severity'] ?? '',
          reaction: m['reaction'] ?? '',
          firstAid: m['firstAid'] ?? '',
        );
      }).toList() ?? [];

      final vaccinesList = (data['vaccineHistory'] as List<dynamic>?)?.map((item) {
        final m = item as Map<String, dynamic>;
        return VaccineRecord(
          name: m['name'] ?? '',
          date: DateTime.tryParse(m['date'] ?? '') ?? DateTime.now(),
          status: m['status'] ?? '',
          doctor: m['doctor'] ?? '',
        );
      }).toList() ?? [];

      final parentNotesList = (data['parentNotes'] as List<dynamic>?)?.map((item) {
        final m = item as Map<String, dynamic>;
        return ParentMedicalNote.fromMap(m);
      }).toList() ?? [];

      return StudentMedicalCard(
        bloodGroup: data['bloodGroup'] ?? 'Məlumat yoxdur',
        heightCm: (data['heightCm'] as num?)?.toDouble() ?? 0.0,
        weightKg: (data['weightKg'] as num?)?.toDouble() ?? 0.0,
        allergies: allergiesList,
        chronicConditions: List<String>.from(data['chronicConditions'] ?? []),
        vaccineHistory: vaccinesList,
        parentNotes: parentNotesList,
        emergencyContactName: data['emergencyContactName'] ?? '',
        emergencyContactPhone: data['emergencyContactPhone'] ?? '',
        lyceumDoctorNotes: data['lyceumDoctorNotes'] ?? '',
      );
    } catch (e) {
      debugPrint('Firestore fetchMedicalCard error: $e');
      return null;
    }
  }

  Future<Map<String, StudentMedicalCard>> fetchAllMedicalCards() async {
    try {
      final snapshot = await db.collection('medical_cards').get();
      final Map<String, StudentMedicalCard> result = {};
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final studentId = data['studentId'] ?? doc.id;

        final allergiesList = (data['allergies'] as List<dynamic>?)?.map((item) {
          final m = item as Map<String, dynamic>;
          return AllergyItem(
            name: m['name'] ?? '',
            severity: m['severity'] ?? '',
            reaction: m['reaction'] ?? '',
            firstAid: m['firstAid'] ?? '',
          );
        }).toList() ?? [];

        final vaccinesList = (data['vaccineHistory'] as List<dynamic>?)?.map((item) {
          final m = item as Map<String, dynamic>;
          return VaccineRecord(
            name: m['name'] ?? '',
            date: DateTime.tryParse(m['date'] ?? '') ?? DateTime.now(),
            status: m['status'] ?? '',
            doctor: m['doctor'] ?? '',
          );
        }).toList() ?? [];

        final parentNotesList = (data['parentNotes'] as List<dynamic>?)?.map((item) {
          final m = item as Map<String, dynamic>;
          return ParentMedicalNote.fromMap(m);
        }).toList() ?? [];

        result[studentId] = StudentMedicalCard(
          bloodGroup: data['bloodGroup'] ?? 'Məlumat yoxdur',
          heightCm: (data['heightCm'] as num?)?.toDouble() ?? 0.0,
          weightKg: (data['weightKg'] as num?)?.toDouble() ?? 0.0,
          allergies: allergiesList,
          chronicConditions: List<String>.from(data['chronicConditions'] ?? []),
          vaccineHistory: vaccinesList,
          parentNotes: parentNotesList,
          emergencyContactName: data['emergencyContactName'] ?? '',
          emergencyContactPhone: data['emergencyContactPhone'] ?? '',
          lyceumDoctorNotes: data['lyceumDoctorNotes'] ?? '',
        );
      }
      return result;
    } catch (e) {
      debugPrint('Firestore fetchAllMedicalCards error: $e');
      return {};
    }
  }

  // --- HOMEWORK ASSIGNMENTS ---
  Future<void> saveAssignment(HomeworkAssignment assignment) async {
    try {
      final submissionsData = <String, dynamic>{};
      assignment.submissions.forEach((k, v) {
        submissionsData[k] = v.toMap();
      });

      await db.collection('assignments').doc(assignment.id).set({
        'id': assignment.id,
        'subject': assignment.subject,
        'title': assignment.title,
        'teacherName': assignment.teacherName,
        'instructions': assignment.instructions,
        'assignedDate': assignment.assignedDate.toIso8601String(),
        'dueDate': assignment.dueDate.toIso8601String(),
        'attachmentDocUrl': assignment.attachmentDocUrl,
        'assignedClass': assignment.assignedClass,
        'assignedStudentIds': assignment.assignedStudentIds,
        'submissions': submissionsData,
      });
    } catch (e) {
      debugPrint('Firestore saveAssignment error: $e');
    }
  }

  Future<List<HomeworkAssignment>> fetchAssignments() async {
    try {
      final snapshot = await db.collection('assignments').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final submissionsMap = <String, AssignmentSubmission>{};

        if (data['submissions'] != null && data['submissions'] is Map) {
          final rawMap = data['submissions'] as Map<String, dynamic>;
          rawMap.forEach((stdId, subData) {
            if (subData is Map<String, dynamic>) {
              submissionsMap[stdId] = AssignmentSubmission.fromMap(subData);
            }
          });
        } else if (data['submission'] != null && data['submission'] is Map) {
          // Legacy migration
          final s = data['submission'] as Map<String, dynamic>;
          final stdId = s['submittedByStudentId'] ?? 'legacy-std';
          submissionsMap[stdId] = AssignmentSubmission.fromMap(s);
        }

        return HomeworkAssignment(
          id: data['id'] ?? doc.id,
          subject: data['subject'] ?? '',
          title: data['title'] ?? '',
          teacherName: data['teacherName'] ?? '',
          instructions: data['instructions'] ?? '',
          assignedDate: DateTime.tryParse(data['assignedDate'] ?? '') ?? DateTime.now(),
          dueDate: DateTime.tryParse(data['dueDate'] ?? '') ?? DateTime.now(),
          attachmentDocUrl: data['attachmentDocUrl'],
          assignedClass: data['assignedClass'],
          assignedStudentIds: List<String>.from(data['assignedStudentIds'] ?? []),
          submissions: submissionsMap,
        );
      }).toList();
    } catch (e) {
      debugPrint('Firestore fetchAssignments error: $e');
      return [];
    }
  }

  Future<void> deleteAssignment(String assignmentId) async {
    try {
      await db.collection('assignments').doc(assignmentId).delete();
    } catch (e) {
      debugPrint('Firestore deleteAssignment error: $e');
    }
  }

  // --- LIBRARY BOOKS ---
  Future<void> saveBook(BookItem book) async {
    try {
      await db.collection('books').doc(book.id).set({
        'id': book.id,
        'title': book.title,
        'author': book.author,
        'category': book.category,
        'coverUrl': book.coverUrl,
        'type': book.type.name,
        'pageCount': book.pageCount,
        'language': book.language,
        'availableCopies': book.availableCopies,
        'isBorrowedByMe': book.isBorrowedByMe,
        'returnDeadline': book.returnDeadline?.toIso8601String(),
        'description': book.description,
        'rating': book.rating,
      });
    } catch (e) {
      debugPrint('Firestore saveBook error: $e');
    }
  }

  Future<List<BookItem>> fetchBooks() async {
    try {
      final snapshot = await db.collection('books').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return BookItem(
          id: data['id'] ?? doc.id,
          title: data['title'] ?? '',
          author: data['author'] ?? '',
          category: data['category'] ?? 'Dərslik',
          coverUrl: data['coverUrl'] ?? '',
          type: BookType.values.firstWhere(
            (t) => t.name == data['type'],
            orElse: () => BookType.both,
          ),
          pageCount: data['pageCount'] ?? 200,
          language: data['language'] ?? 'Azərbaycan',
          availableCopies: data['availableCopies'] ?? 10,
          isBorrowedByMe: data['isBorrowedByMe'] ?? false,
          returnDeadline: data['returnDeadline'] != null
              ? DateTime.tryParse(data['returnDeadline'])
              : null,
          description: data['description'] ?? '',
          rating: (data['rating'] as num?)?.toDouble() ?? 5.0,
        );
      }).toList();
    } catch (e) {
      debugPrint('Firestore fetchBooks error: $e');
      return [];
    }
  }

  // --- CAFETERIA MENU ---
  Future<void> saveWeeklyMenu(List<DailyMenu> menu) async {
    try {
      final batch = db.batch();
      for (final day in menu) {
        final docRef = db.collection('cafeteria_menu').doc(day.dayName);
        batch.set(docRef, {
          'dayName': day.dayName,
          'date': day.date.toIso8601String(),
          'mealTime': day.mealTime,
          'totalCalories': day.totalCalories,
          'items': day.items.map((i) => {
            'name': i.name,
            'category': i.category,
            'calories': i.calories,
            'weightGram': i.weightGram,
            'allergens': i.allergens,
            'imageUrl': i.imageUrl,
          }).toList(),
        });
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Firestore saveWeeklyMenu error: $e');
    }
  }

  Future<List<DailyMenu>> fetchWeeklyMenu() async {
    try {
      final snapshot = await db.collection('cafeteria_menu').get();
      if (snapshot.docs.isEmpty) return [];
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final items = (data['items'] as List<dynamic>?)?.map((it) {
          final m = it as Map<String, dynamic>;
          return MenuItem(
            name: m['name'] ?? '',
            category: m['category'] ?? '',
            calories: m['calories'] ?? 200,
            weightGram: m['weightGram'] ?? '',
            allergens: List<String>.from(m['allergens'] ?? []),
            imageUrl: m['imageUrl'] ?? '',
          );
        }).toList() ?? [];

        return DailyMenu(
          dayName: data['dayName'] ?? doc.id,
          date: DateTime.tryParse(data['date'] ?? '') ?? DateTime.now(),
          mealTime: data['mealTime'] ?? 'Nahar (12:30 - 13:30)',
          totalCalories: data['totalCalories'] ?? 0,
          items: items,
        );
      }).toList();
    } catch (e) {
      debugPrint('Firestore fetchWeeklyMenu error: $e');
      return [];
    }
  }

  // --- GRADES ---
  Future<void> saveGrade(GradeRecord grade, String studentId, String? studentName) async {
    try {
      await db.collection('grades').doc(grade.id).set({
        'id': grade.id,
        'studentId': studentId,
        'studentName': studentName,
        'subject': grade.subject,
        'type': grade.type.name,
        'title': grade.title,
        'score': grade.score,
        'maxScore': grade.maxScore,
        'gradeLetter': grade.gradeLetter,
        'date': grade.date.toIso8601String(),
        'teacherFeedback': grade.teacherFeedback,
      });
    } catch (e) {
      debugPrint('Firestore saveGrade error: $e');
    }
  }

  Future<List<GradeRecord>> fetchGrades(String? studentId) async {
    try {
      Query query = db.collection('grades');
      if (studentId != null && studentId.isNotEmpty) {
        query = query.where('studentId', isEqualTo: studentId);
      }
      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return GradeRecord(
          id: data['id'] ?? doc.id,
          studentId: data['studentId'],
          studentName: data['studentName'],
          subject: data['subject'] ?? '',
          type: AssessmentType.values.firstWhere(
            (t) => t.name == data['type'],
            orElse: () => AssessmentType.ksq,
          ),
          title: data['title'] ?? '',
          score: (data['score'] as num?)?.toDouble() ?? 0.0,
          maxScore: (data['maxScore'] as num?)?.toDouble() ?? 100.0,
          gradeLetter: data['gradeLetter'] ?? '',
          date: DateTime.tryParse(data['date'] ?? '') ?? DateTime.now(),
          teacherFeedback: data['teacherFeedback'] ?? '',
        );
      }).toList();
    } catch (e) {
      debugPrint('Firestore fetchGrades error: $e');
      return [];
    }
  }

  Future<void> deleteGrade(String gradeId) async {
    try {
      await db.collection('grades').doc(gradeId).delete();
    } catch (e) {
      debugPrint('Firestore deleteGrade error: $e');
    }
  }

  // --- ATTENDANCE ---
  Future<void> saveStudentDayAttendance(String studentId, int dayOfMonth, DayAttendance attendance) async {
    try {
      await db.collection('attendance').doc('${studentId}_$dayOfMonth').set({
        'studentId': studentId,
        'dayOfMonth': dayOfMonth,
        'date': attendance.date.toIso8601String(),
        'status': attendance.status.name,
        'note': attendance.note,
        'periodDetails': attendance.periodDetails.map((p) => {
          'period': p.period,
          'subject': p.subject,
          'status': p.status.name,
          'time': p.time,
        }).toList(),
      });
    } catch (e) {
      debugPrint('Firestore saveStudentDayAttendance error: $e');
    }
  }

  Future<Map<int, DayAttendance>> fetchAttendance(String studentId) async {
    try {
      final snapshot = await db.collection('attendance').where('studentId', isEqualTo: studentId).get();
      final Map<int, DayAttendance> result = {};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final day = (data['dayOfMonth'] as num?)?.toInt() ?? 1;
        final periodsData = (data['periodDetails'] as List<dynamic>?) ?? [];
        final periods = periodsData.map((p) {
          final pm = p as Map<String, dynamic>;
          return PeriodAttendance(
            period: pm['period'] ?? '',
            subject: pm['subject'] ?? '',
            status: AttendanceStatus.values.firstWhere(
              (s) => s.name == pm['status'],
              orElse: () => AttendanceStatus.present,
            ),
            time: pm['time'] ?? '',
          );
        }).toList();

        result[day] = DayAttendance(
          date: DateTime.tryParse(data['date'] ?? '') ?? DateTime.now(),
          status: AttendanceStatus.values.firstWhere(
            (s) => s.name == data['status'],
            orElse: () => AttendanceStatus.present,
          ),
          note: data['note'],
          periodDetails: periods,
        );
      }
      return result;
    } catch (e) {
      debugPrint('Firestore fetchAttendance error: $e');
      return {};
    }
  }

  Future<Map<String, Map<int, DayAttendance>>> fetchAllAttendance() async {
    try {
      final snapshot = await db.collection('attendance').get();
      final Map<String, Map<int, DayAttendance>> result = {};

      for (final doc in snapshot.docs) {
        final data = doc.data();
        final studentId = data['studentId'] ?? '';
        if (studentId.isEmpty) continue;

        final day = (data['dayOfMonth'] as num?)?.toInt() ?? 1;
        final periodsData = (data['periodDetails'] as List<dynamic>?) ?? [];
        final periods = periodsData.map((p) {
          final pm = p as Map<String, dynamic>;
          return PeriodAttendance(
            period: pm['period'] ?? '',
            subject: pm['subject'] ?? '',
            status: AttendanceStatus.values.firstWhere(
              (s) => s.name == pm['status'],
              orElse: () => AttendanceStatus.present,
            ),
            time: pm['time'] ?? '',
          );
        }).toList();

        final dayAtt = DayAttendance(
          date: DateTime.tryParse(data['date'] ?? '') ?? DateTime.now(),
          status: AttendanceStatus.values.firstWhere(
            (s) => s.name == data['status'],
            orElse: () => AttendanceStatus.present,
          ),
          note: data['note'],
          periodDetails: periods,
        );

        result.putIfAbsent(studentId, () => {})[day] = dayAtt;
      }
      return result;
    } catch (e) {
      debugPrint('Firestore fetchAllAttendance error: $e');
      return {};
    }
  }

  // --- TICKETS ---
  Future<void> saveTicket(HelpdeskTicket ticket) async {
    try {
      await db.collection('tickets').doc(ticket.id).set({
        'id': ticket.id,
        'title': ticket.title,
        'category': ticket.category.name,
        'status': ticket.status.name,
        'priority': ticket.priority.name,
        'senderName': ticket.senderName,
        'senderRole': ticket.senderRole,
        'description': ticket.description,
        'createdAt': ticket.createdAt.toIso8601String(),
        'roomNumber': ticket.roomNumber,
        'inventoryCode': ticket.inventoryCode,
        'attachedImage': ticket.attachedImage,
        'messages': ticket.messages.map((m) => {
          'sender': m.sender,
          'message': m.message,
          'timestamp': m.timestamp.toIso8601String(),
          'isFromStaff': m.isFromStaff,
        }).toList(),
      });
    } catch (e) {
      debugPrint('Firestore saveTicket error: $e');
    }
  }

  Future<List<HelpdeskTicket>> fetchTickets() async {
    try {
      final snapshot = await db.collection('tickets').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final msgs = (data['messages'] as List<dynamic>?)?.map((item) {
          final m = item as Map<String, dynamic>;
          return TicketMessage(
            sender: m['sender'] ?? '',
            message: m['message'] ?? '',
            timestamp: DateTime.tryParse(m['timestamp'] ?? '') ?? DateTime.now(),
            isFromStaff: m['isFromStaff'] ?? false,
          );
        }).toList() ?? [];

        return HelpdeskTicket(
          id: data['id'] ?? doc.id,
          title: data['title'] ?? '',
          category: TicketCategory.values.firstWhere(
            (c) => c.name == data['category'],
            orElse: () => TicketCategory.academic,
          ),
          status: TicketStatus.values.firstWhere(
            (s) => s.name == data['status'],
            orElse: () => TicketStatus.open,
          ),
          priority: TicketPriority.values.firstWhere(
            (p) => p.name == data['priority'],
            orElse: () => TicketPriority.medium,
          ),
          senderName: data['senderName'] ?? '',
          senderRole: data['senderRole'] ?? '',
          description: data['description'] ?? '',
          createdAt: DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
          roomNumber: data['roomNumber'],
          inventoryCode: data['inventoryCode'],
          attachedImage: data['attachedImage'],
          messages: msgs,
        );
      }).toList();
    } catch (e) {
      debugPrint('Firestore fetchTickets error: $e');
      return [];
    }
  }

  // --- MEET IDRAK ROOMS ---
  Future<void> saveMeetRoom(MeetRoom room) async {
    try {
      await db.collection('meet_rooms').doc(room.id).set(room.toJson());
    } catch (e) {
      debugPrint('Firestore saveMeetRoom error: $e');
    }
  }

  Future<List<MeetRoom>> fetchMeetRooms() async {
    try {
      final snap = await db.collection('meet_rooms').get();
      return snap.docs.map((d) => MeetRoom.fromJson(d.data())).toList();
    } catch (e) {
      debugPrint('Firestore fetchMeetRooms error: $e');
      return [];
    }
  }

  Future<void> deleteMeetRoom(String roomId) async {
    try {
      await db.collection('meet_rooms').doc(roomId).delete();
    } catch (e) {
      debugPrint('Firestore deleteMeetRoom error: $e');
    }
  }

  Future<void> updateMeetParticipants(String roomId, List<MeetParticipant> participants) async {
    try {
      await db.collection('meet_rooms').doc(roomId).update({
        'participants': participants.map((p) => p.toJson()).toList(),
      });
    } catch (e) {
      debugPrint('Firestore updateMeetParticipants error: $e');
    }
  }

  // --- NOTIFICATIONS ---
  Future<void> saveNotification(AppNotification notification) async {
    try {
      await db.collection('notifications').doc(notification.id).set(notification.toJson());
    } catch (e) {
      debugPrint('Firestore saveNotification error: $e');
    }
  }

  Future<List<AppNotification>> fetchNotifications() async {
    try {
      final snap = await db.collection('notifications').orderBy('createdAt', descending: true).get();
      return snap.docs.map((d) => AppNotification.fromJson(d.data())).toList();
    } catch (e) {
      debugPrint('Firestore fetchNotifications error: $e');
      return [];
    }
  }

  Future<void> markNotificationRead(String notificationId, String userId) async {
    try {
      await db.collection('notifications').doc(notificationId).update({
        'readByUserIds': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      debugPrint('Firestore markNotificationRead error: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await db.collection('notifications').doc(notificationId).delete();
    } catch (e) {
      debugPrint('Firestore deleteNotification error: $e');
    }
  }
}

