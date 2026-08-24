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
import '../data/models/inventory_model.dart';
import '../data/models/role_model.dart';
import '../data/models/class_details_model.dart';

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
        // 🆕 HR məlumatları
        'firstName': user.firstName,
        'lastName': user.lastName,
        'fatherName': user.fatherName,
        'finCode': user.finCode,
        'gender': user.gender,
        'birthDate': user.birthDate?.toIso8601String(),
        'address': user.address,
        'citizenship': user.citizenship,
        'idCardSerial': user.idCardSerial,
        'educationLevel': user.educationLevel,
        'bankName': user.bankName,
        // 🆕 İş məlumatları (HR)
        'position': user.position,
        'hireDate': user.hireDate?.toIso8601String(),
        'salary': user.salary,
        'contractStart': user.contractStart?.toIso8601String(),
        'contractEnd': user.contractEnd?.toIso8601String(),
        // mövcud sahələr
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
        'linkedStudentIds': user.linkedStudentIds,
        'assignedRoleId': user.assignedRoleId, // 🆕 rol təyinatı
        'isActive': user.isActive,
        'createdAt': user.createdAt.toIso8601String(),
        'teacherPermissions': user.teacherPermissions != null
            ? {
                'canManageCafeteria':
                    user.teacherPermissions!.canManageCafeteria,
                'canManageMedical': user.teacherPermissions!.canManageMedical,
                'canManageInventory':
                    user.teacherPermissions!.canManageInventory,
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
          // 🆕 HR məlumatları
          firstName: data['firstName'],
          lastName: data['lastName'],
          fatherName: data['fatherName'],
          finCode: data['finCode'],
          gender: data['gender'],
          birthDate: data['birthDate'] != null
              ? DateTime.tryParse(data['birthDate'])
              : null,
          address: data['address'],
          citizenship: data['citizenship'],
          idCardSerial: data['idCardSerial'],
          educationLevel: data['educationLevel'],
          bankName: data['bankName'],
          // 🆕 İş məlumatları (HR)
          position: data['position'],
          hireDate: data['hireDate'] != null
              ? DateTime.tryParse(data['hireDate'])
              : null,
          salary: (data['salary'] as num?)?.toDouble(),
          contractStart: data['contractStart'] != null
              ? DateTime.tryParse(data['contractStart'])
              : null,
          contractEnd: data['contractEnd'] != null
              ? DateTime.tryParse(data['contractEnd'])
              : null,
          // mövcud sahələr
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
          linkedStudentIds: List<String>.from(data['linkedStudentIds'] ?? []),
          assignedRoleId: data['assignedRoleId'], // 🆕
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

  Future<void> updateTeacherPermissions(
    String userId,
    TeacherPermissions perms,
  ) async {
    try {
      await db.collection('users').doc(userId).update({
        'teacherPermissions': {
          'canManageCafeteria': perms.canManageCafeteria,
          'canManageMedical': perms.canManageMedical,
          'canManageInventory': perms.canManageInventory,
        },
      });
    } catch (e) {
      debugPrint('Firestore updateTeacherPermissions error: $e');
    }
  }

  Future<void> updateTeacherAssignedClasses(
    String userId,
    List<String> classes,
  ) async {
    try {
      await db.collection('users').doc(userId).update({
        'assignedClasses': classes,
      });
    } catch (e) {
      debugPrint('Firestore updateTeacherAssignedClasses error: $e');
    }
  }

  // --- TIMETABLE PER CLASS ---
  Future<void> saveClassTimetable(
    String className,
    List<DayTimetable> timetable,
  ) async {
    try {
      final daysMap = timetable
          .map(
            (day) => {
              'dayName': day.dayName,
              'shortDay': day.shortDay,
              'lessons': day.lessons
                  .map(
                    (l) => {
                      'period': l.period,
                      'time': l.time,
                      'subject': l.subject,
                      'teacher': l.teacher,
                      'room': l.room,
                      'colorHex': l.colorHex,
                      'isCurrent': l.isCurrent,
                      'teacherId': l.teacherId,           // ✅ YENİ
                      'teacherPhotoUrl': l.teacherPhotoUrl, // ✅ YENİ
                    },
                  )
                  .toList(),
            },
          )
          .toList();

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
              teacherId: l['teacherId'],           // ✅ YENİ
              teacherPhotoUrl: l['teacherPhotoUrl'], // ✅ YENİ
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
        // 🆕 Genişləndirilmiş şagird məlumatları
        'firstName': student.firstName,
        'lastName': student.lastName,
        'fatherName': student.fatherName,
        'finCode': student.finCode,
        'gender': student.gender,
        'birthDate': student.birthDate?.toIso8601String(),
        'address': student.address,
        'email': student.email,
        'bloodGroup': student.bloodGroup,
        'allergies': student.allergies,
        // Veli məlumatları
        'parentName': student.parentName,
        'parentPhone': student.parentPhone,
        'parentEmail': student.parentEmail, // 🆕
        'parentAddress': student.parentAddress, // 🆕
        // Akademik
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
      await db.collection('students').doc(studentId).update({
        'className': newClassName,
      });
      await db.collection('users').doc('usr-$studentId').update({
        'className': newClassName,
      });
    } catch (e) {
      debugPrint('Firestore updateStudentClass error: $e');
    }
  }

  Future<void> updateStudentGPA(
    String studentId,
    double gpa,
    int attendanceRate,
  ) async {
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
          // 🆕 Yeni sahələr
          firstName: data['firstName'],
          lastName: data['lastName'],
          fatherName: data['fatherName'],
          finCode: data['finCode'],
          gender: data['gender'],
          birthDate: data['birthDate'] != null 
              ? DateTime.tryParse(data['birthDate']) 
              : null,
          address: data['address'],
          email: data['email'],
          bloodGroup: data['bloodGroup'],
          allergies: data['allergies'] != null 
              ? List<String>.from(data['allergies']) 
              : null,
          // Veli
          parentName: data['parentName'] ?? '',
          parentPhone: data['parentPhone'] ?? '',
          parentEmail: data['parentEmail'],
          parentAddress: data['parentAddress'],
          // Akademik
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
  Future<void> saveMedicalCard(
    String studentId,
    StudentMedicalCard card,
  ) async {
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
        'allergies': card.allergies
            .map(
              (a) => {
                'name': a.name,
                'severity': a.severity,
                'reaction': a.reaction,
                'firstAid': a.firstAid,
              },
            )
            .toList(),
        'vaccineHistory': card.vaccineHistory
            .map(
              (v) => {
                'name': v.name,
                'date': v.date.toIso8601String(),
                'status': v.status,
                'doctor': v.doctor,
              },
            )
            .toList(),
        'parentNotes': card.parentNotes
            .map(
              (p) => {
                'id': p.id,
                'note': p.note,
                'date': p.date.toIso8601String(),
                'parentName': p.parentName,
              },
            )
            .toList(),
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

      final allergiesList =
          (data['allergies'] as List<dynamic>?)?.map((item) {
            final m = item as Map<String, dynamic>;
            return AllergyItem(
              name: m['name'] ?? '',
              severity: m['severity'] ?? '',
              reaction: m['reaction'] ?? '',
              firstAid: m['firstAid'] ?? '',
            );
          }).toList() ??
          [];

      final vaccinesList =
          (data['vaccineHistory'] as List<dynamic>?)?.map((item) {
            final m = item as Map<String, dynamic>;
            return VaccineRecord(
              name: m['name'] ?? '',
              date: DateTime.tryParse(m['date'] ?? '') ?? DateTime.now(),
              status: m['status'] ?? '',
              doctor: m['doctor'] ?? '',
            );
          }).toList() ??
          [];

      final parentNotesList =
          (data['parentNotes'] as List<dynamic>?)?.map((item) {
            final m = item as Map<String, dynamic>;
            return ParentMedicalNote.fromMap(m);
          }).toList() ??
          [];

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

        final allergiesList =
            (data['allergies'] as List<dynamic>?)?.map((item) {
              final m = item as Map<String, dynamic>;
              return AllergyItem(
                name: m['name'] ?? '',
                severity: m['severity'] ?? '',
                reaction: m['reaction'] ?? '',
                firstAid: m['firstAid'] ?? '',
              );
            }).toList() ??
            [];

        final vaccinesList =
            (data['vaccineHistory'] as List<dynamic>?)?.map((item) {
              final m = item as Map<String, dynamic>;
              return VaccineRecord(
                name: m['name'] ?? '',
                date: DateTime.tryParse(m['date'] ?? '') ?? DateTime.now(),
                status: m['status'] ?? '',
                doctor: m['doctor'] ?? '',
              );
            }).toList() ??
            [];

        final parentNotesList =
            (data['parentNotes'] as List<dynamic>?)?.map((item) {
              final m = item as Map<String, dynamic>;
              return ParentMedicalNote.fromMap(m);
            }).toList() ??
            [];

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
          assignedDate:
              DateTime.tryParse(data['assignedDate'] ?? '') ?? DateTime.now(),
          dueDate: DateTime.tryParse(data['dueDate'] ?? '') ?? DateTime.now(),
          attachmentDocUrl: data['attachmentDocUrl'],
          assignedClass: data['assignedClass'],
          assignedStudentIds: List<String>.from(
            data['assignedStudentIds'] ?? [],
          ),
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
          'items': day.items
              .map(
                (i) => {
                  'name': i.name,
                  'category': i.category,
                  'calories': i.calories,
                  'weightGram': i.weightGram,
                  'allergens': i.allergens,
                  'imageUrl': i.imageUrl,
                },
              )
              .toList(),
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
        final items =
            (data['items'] as List<dynamic>?)?.map((it) {
              final m = it as Map<String, dynamic>;
              return MenuItem(
                name: m['name'] ?? '',
                category: m['category'] ?? '',
                calories: m['calories'] ?? 200,
                weightGram: m['weightGram'] ?? '',
                allergens: List<String>.from(m['allergens'] ?? []),
                imageUrl: m['imageUrl'] ?? '',
              );
            }).toList() ??
            [];

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
  Future<void> saveGrade(
    GradeRecord grade,
    String studentId,
    String? studentName,
  ) async {
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
  Future<void> saveStudentDayAttendance(
    String studentId,
    int dayOfMonth,
    DayAttendance attendance,
  ) async {
    try {
      await db.collection('attendance').doc('${studentId}_$dayOfMonth').set({
        'studentId': studentId,
        'dayOfMonth': dayOfMonth,
        'date': attendance.date.toIso8601String(),
        'status': attendance.status.name,
        'note': attendance.note,
        'periodDetails': attendance.periodDetails
            .map(
              (p) => {
                'period': p.period,
                'subject': p.subject,
                'status': p.status.name,
                'time': p.time,
              },
            )
            .toList(),
      });
    } catch (e) {
      debugPrint('Firestore saveStudentDayAttendance error: $e');
    }
  }

  Future<Map<int, DayAttendance>> fetchAttendance(String studentId) async {
    try {
      final snapshot = await db
          .collection('attendance')
          .where('studentId', isEqualTo: studentId)
          .get();
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

  // --- QR INVENTORY ITEMS ---
  Future<void> saveInventoryItem(InventoryItem item) async {
    try {
      await db.collection('inventory_items').doc(item.id).set({
        'id': item.id,
        'qrCode': item.qrCode,
        'name': item.name,
        'category': item.category,
        'room': item.room,
        'serialNumber': item.serialNumber,
        'notes': item.notes,
        'isActive': item.isActive,
        'createdAt': item.createdAt.toIso8601String(),
      });
    } catch (e) {
      debugPrint('Firestore saveInventoryItem error: $e');
    }
  }

  Future<List<InventoryItem>> fetchInventoryItems() async {
    try {
      final snapshot = await db.collection('inventory_items').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return InventoryItem(
          id: data['id'] ?? doc.id,
          qrCode: data['qrCode'] ?? '',
          name: data['name'] ?? '',
          category: data['category'] ?? 'Digər',
          room: data['room'] ?? '',
          serialNumber: data['serialNumber'] ?? '',
          notes: data['notes'] ?? '',
          isActive: data['isActive'] ?? true,
          createdAt: DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
        );
      }).toList();
    } catch (e) {
      debugPrint('Firestore fetchInventoryItems error: $e');
      return [];
    }
  }

  Future<void> deleteInventoryItem(String id) async {
    try {
      await db.collection('inventory_items').doc(id).delete();
    } catch (e) {
      debugPrint('Firestore deleteInventoryItem error: $e');
    }
  }

  // --- TICKETS ---
  /// Biletin statusunu yeniləyir (helpdesk / admin)
  Future<void> updateTicketStatus(String ticketId, TicketStatus status) async {
    try {
      await db.collection('tickets').doc(ticketId).update({'status': status.name});
    } catch (e) {
      debugPrint('Firestore updateTicketStatus error: $e');
    }
  }

  Future<void> saveTicket(HelpdeskTicket ticket) async {    try {
      await db.collection('tickets').doc(ticket.id).set({
        'id': ticket.id,
        'title': ticket.title,
        'category': ticket.category.name,
        'status': ticket.status.name,
        'priority': ticket.priority.name,
        'senderName': ticket.senderName,
        'senderRole': ticket.senderRole,
        'senderId': ticket.senderId,
        'description': ticket.description,
        'createdAt': ticket.createdAt.toIso8601String(),
        'roomNumber': ticket.roomNumber,
        'inventoryCode': ticket.inventoryCode,
        'attachedImage': ticket.attachedImage,
        'messages': ticket.messages
            .map(
              (m) => {
                'sender': m.sender,
                'message': m.message,
                'timestamp': m.timestamp.toIso8601String(),
                'isFromStaff': m.isFromStaff,
              },
            )
            .toList(),
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
        final msgs =
            (data['messages'] as List<dynamic>?)?.map((item) {
              final m = item as Map<String, dynamic>;
              return TicketMessage(
                sender: m['sender'] ?? '',
                message: m['message'] ?? '',
                timestamp:
                    DateTime.tryParse(m['timestamp'] ?? '') ?? DateTime.now(),
                isFromStaff: m['isFromStaff'] ?? false,
              );
            }).toList() ??
            [];

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
          senderId: data['senderId'],
          description: data['description'] ?? '',
          createdAt:
              DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now(),
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

  /// Delivers room and participant changes immediately to every connected app.
  Stream<List<MeetRoom>> watchMeetRooms() {
    return db
        .collection('meet_rooms')
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) {
      if (snapshot.metadata.isFromCache) {
        debugPrint('⚠️ Meet rooms loaded from cache (offline mode)');
      }
      final rooms = snapshot.docs
          .map((doc) => MeetRoom.fromJson(doc.data()))
          .toList();
      rooms.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return rooms;
    }).handleError((error) {
      debugPrint('Firestore watchMeetRooms error: $error');
      // Return empty list on error to prevent stream from breaking
      return <MeetRoom>[];
    });
  }

  Future<void> deleteMeetRoom(String roomId) async {
    try {
      await db.collection('meet_rooms').doc(roomId).delete();
    } catch (e) {
      debugPrint('Firestore deleteMeetRoom error: $e');
    }
  }

  /// Updates the participant list in a transaction so simultaneous joins never
  /// overwrite one another.
  Future<List<MeetParticipant>> joinMeetParticipant(
    String roomId,
    MeetParticipant participant,
  ) {
    return _changeMeetParticipants(roomId, (participants, room) {
      final existingIndex = participants.indexWhere(
        (p) => p.userId == participant.userId,
      );
      if (existingIndex == -1) {
        participants.add(participant);
      } else {
        // Keep moderation state if a user reconnects to the same room.
        final existing = participants[existingIndex];
        participants[existingIndex] = participant.copyWith(
          isMuted: existing.isMuted,
          isMutedByHost: existing.isMutedByHost,
        );
      }
      return participants;
    });
  }

  Future<List<MeetParticipant>> leaveMeetParticipant(
    String roomId,
    String userId,
  ) {
    return _changeMeetParticipants(roomId, (participants, room) {
      participants.removeWhere((p) => p.userId == userId);
      return participants;
    });
  }

  Future<List<MeetParticipant>> setMeetParticipantMuted(
    String roomId,
    String userId,
    bool muted, {
    bool? mutedByHost,
  }) {
    return _changeMeetParticipants(roomId, (participants, room) {
      return participants.map((participant) {
        if (participant.userId != userId) return participant;
        return participant.copyWith(
          isMuted: muted,
          isMutedByHost: mutedByHost ?? participant.isMutedByHost,
        );
      }).toList();
    });
  }

  Future<List<MeetParticipant>> muteAllMeetParticipants(
    String roomId,
    bool muted,
  ) {
    return _changeMeetParticipants(roomId, (participants, room) {
      return participants.map((participant) {
        if (participant.userId == room.hostId) return participant;
        return participant.copyWith(isMuted: muted, isMutedByHost: muted);
      }).toList();
    });
  }

  Future<void> setMeetRoomStatus(String roomId, String status) {
    return db.collection('meet_rooms').doc(roomId).update({'status': status});
  }

  Future<List<MeetParticipant>> _changeMeetParticipants(
    String roomId,
    List<MeetParticipant> Function(List<MeetParticipant>, MeetRoom) change,
  ) async {
    final roomRef = db.collection('meet_rooms').doc(roomId);
    
    // Retry logic for Firestore connection issues
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        return await db.runTransaction((transaction) async {
          final snapshot = await transaction.get(roomRef);
          final data = snapshot.data();
          if (!snapshot.exists || data == null) {
            throw StateError('Meet room no longer exists.');
          }

          final room = MeetRoom.fromJson(data);
          final updated = change(
            List<MeetParticipant>.from(room.participants),
            room,
          );
          transaction.update(roomRef, {
            'participants': updated
                .map((participant) => participant.toJson())
                .toList(),
          });
          return updated;
        }, timeout: const Duration(seconds: 15));
      } catch (e) {
        if (attempt < 2) {
          debugPrint('Firestore transaction attempt ${attempt + 1}/3 failed: $e');
          await Future.delayed(Duration(seconds: 2 * (attempt + 1)));
        } else {
          rethrow;
        }
      }
    }
    throw StateError('Firestore transaction failed after 3 attempts');
  }

  // --- NOTIFICATIONS ---
  Future<void> saveNotification(AppNotification notification) async {
    try {
      await db
          .collection('notifications')
          .doc(notification.id)
          .set(notification.toJson());
    } catch (e) {
      debugPrint('Firestore saveNotification error: $e');
    }
  }

  Future<List<AppNotification>> fetchNotifications() async {
    try {
      final snap = await db
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .get();
      return snap.docs.map((d) => AppNotification.fromJson(d.data())).toList();
    } catch (e) {
      debugPrint('Firestore fetchNotifications error: $e');
      return [];
    }
  }

  Future<void> markNotificationRead(
    String notificationId,
    String userId,
  ) async {
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

  // --- CLASS DETAILS (sinif detalları: otaq, rəhbər, il, qeyd) ---
  Future<void> saveClassDetails(ClassDetails details) async {
    try {
      await db.collection('classes').doc(details.name).set(details.toJson());
    } catch (e) {
      debugPrint('Firestore saveClassDetails error: $e');
    }
  }

  Future<Map<String, ClassDetails>> fetchClassDetails() async {
    try {
      final snapshot = await db.collection('classes').get();
      final map = <String, ClassDetails>{};
      for (final doc in snapshot.docs) {
        final d = ClassDetails.fromJson(doc.data());
        if (d.name.isNotEmpty) map[d.name] = d;
      }
      return map;
    } catch (e) {
      debugPrint('Firestore fetchClassDetails error: $e');
      return {};
    }
  }

  Future<void> deleteClassDetails(String name) async {
    try {
      await db.collection('classes').doc(name).delete();
    } catch (e) {
      debugPrint('Firestore deleteClassDetails error: $e');
    }
  }

  // --- ROLES & PERMISSIONS ---  
  /// Rol kaydetme
  Future<void> saveRole(Role role) async {
    try {
      await db.collection('roles').doc(role.id).set(role.toJson());
    } catch (e) {
      debugPrint('Firestore saveRole error: $e');
    }
  }

  /// Tüm rolleri getir
  Future<List<Role>> fetchRoles() async {
    try {
      final snapshot = await db.collection('roles').get();
      if (snapshot.docs.isEmpty) {
        // İlk kez çalışıyorsa default rolleri oluştur
        final defaultRoles = DefaultRoles.createAll();
        for (final role in defaultRoles) {
          await saveRole(role);
        }
        return defaultRoles;
      }
      final roles = snapshot.docs.map((doc) => Role.fromJson(doc.data())).toList();
      // Sistem (default) rolları kod ilə sinxronlaşdır — icazə yeniləmələri
      // tətbiq yenilənəndə mövcud qeydlərə də tətbiq olunsun. Xüsusi
      // (isDefault olmayan) rollara toxunulmur.
      final defaults = DefaultRoles.createAll();
      for (var i = 0; i < roles.length; i++) {
        if (!roles[i].isDefault) continue;
        for (final def in defaults) {
          if (def.id != roles[i].id) continue;
          final old = roles[i].permissionIds.toSet();
          final neu = def.permissionIds.toSet();
          if (old.length != neu.length || !old.containsAll(neu)) {
            roles[i] = roles[i].copyWith(permissionIds: def.permissionIds);
            await saveRole(roles[i]);
          }
          break;
        }
      }
      return roles;
    } catch (e) {
      debugPrint('Firestore fetchRoles error: $e');
      // Hata durumunda default rolleri döndür
      return DefaultRoles.createAll();
    }
  }

  /// Tek bir rolü getir
  Future<Role?> fetchRole(String roleId) async {
    try {
      final doc = await db.collection('roles').doc(roleId).get();
      if (!doc.exists || doc.data() == null) return null;
      return Role.fromJson(doc.data()!);
    } catch (e) {
      debugPrint('Firestore fetchRole error: $e');
      return null;
    }
  }

  /// Rol güncelleme
  Future<void> updateRole(Role role) async {
    try {
      await db.collection('roles').doc(role.id).update(role.toJson());
    } catch (e) {
      debugPrint('Firestore updateRole error: $e');
    }
  }

  /// Rol silme
  Future<void> deleteRole(String roleId) async {
    try {
      await db.collection('roles').doc(roleId).delete();
    } catch (e) {
      debugPrint('Firestore deleteRole error: $e');
    }
  }

  /// Kullanıcıya rol atama (yeni sistem)
  Future<void> assignRoleToUser(String userId, String roleId) async {
    try {
      await db.collection('users').doc(userId).update({
        'roleId': roleId,
      });
    } catch (e) {
      debugPrint('Firestore assignRoleToUser error: $e');
    }
  }

  /// Sınıfa öğretmen atama (yeni sistem)
  Future<void> assignTeacherToClass({
    required String className,
    required String teacherId,
    bool isClassTeacher = false,
    String? subject,
  }) async {
    try {
      final docId = '${className}_$teacherId';
      await db.collection('class_teachers').doc(docId).set({
        'className': className,
        'teacherId': teacherId,
        'isClassTeacher': isClassTeacher,
        'subject': subject,
        'assignedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('Firestore assignTeacherToClass error: $e');
    }
  }

  /// Sınıftan öğretmen kaldırma
  Future<void> removeTeacherFromClass({
    required String className,
    required String teacherId,
  }) async {
    try {
      final docId = '${className}_$teacherId';
      await db.collection('class_teachers').doc(docId).delete();
    } catch (e) {
      debugPrint('Firestore removeTeacherFromClass error: $e');
    }
  }

  /// Sınıfın öğretmenlerini getir
  Future<List<Map<String, dynamic>>> fetchClassTeachers(String className) async {
    try {
      final snapshot = await db
          .collection('class_teachers')
          .where('className', isEqualTo: className)
          .get();
      
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      debugPrint('Firestore fetchClassTeachers error: $e');
      return [];
    }
  }
}
