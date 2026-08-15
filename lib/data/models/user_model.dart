import '../../providers/app_state.dart';

class TeacherPermissions {
  final bool canManageCafeteria; // Kantin / Yeməkxana menyusunu dəyişə bilsin
  final bool canManageMedical;   // Şagirdin xəstəlik və tibbi qeydlərinə əlavə edə bilsin
  final bool canManageInventory; // İnventar QR ticketlərini idarə edə bilsin

  const TeacherPermissions({
    this.canManageCafeteria = false,
    this.canManageMedical = false,
    this.canManageInventory = true,
  });

  TeacherPermissions copyWith({
    bool? canManageCafeteria,
    bool? canManageMedical,
    bool? canManageInventory,
  }) {
    return TeacherPermissions(
      canManageCafeteria: canManageCafeteria ?? this.canManageCafeteria,
      canManageMedical: canManageMedical ?? this.canManageMedical,
      canManageInventory: canManageInventory ?? this.canManageInventory,
    );
  }

  Map<String, dynamic> toJson() => {
    'canManageCafeteria': canManageCafeteria,
    'canManageMedical': canManageMedical,
    'canManageInventory': canManageInventory,
  };
}

class AppUser {
  final String id;
  final String username;
  final String password;
  final String fullName;
  final UserRole role; // admin, teacher, student, parent
  final String idrakCode; // e.g. "IDR-2025-0492" or "IDR-TCH-102"
  final String phone;
  final String? email;
  final String? photoUrl;
  final String? className; // for student
  final List<String> assignedClasses; // for teacher (e.g. ['9B', '10A'])
  final String? subject;   // for teacher
  final String? roomNumber;// for teacher
  final String? linkedStudentId; // For parent to link to their child
  final TeacherPermissions? teacherPermissions; // For teacher
  final bool isActive;
  final DateTime createdAt;

  AppUser({
    required this.id,
    required this.username,
    required this.password,
    required this.fullName,
    required this.role,
    required this.idrakCode,
    this.phone = '',
    this.email,
    this.photoUrl,
    this.className,
    this.assignedClasses = const [],
    this.subject,
    this.roomNumber,
    this.linkedStudentId,
    this.teacherPermissions,
    this.isActive = true,
    required this.createdAt,
  });

  AppUser copyWith({
    String? username,
    String? password,
    String? fullName,
    UserRole? role,
    String? idrakCode,
    String? phone,
    String? email,
    String? photoUrl,
    String? className,
    List<String>? assignedClasses,
    String? subject,
    String? roomNumber,
    String? linkedStudentId,
    TeacherPermissions? teacherPermissions,
    bool? isActive,
  }) {
    return AppUser(
      id: id,
      username: username ?? this.username,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      idrakCode: idrakCode ?? this.idrakCode,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      className: className ?? this.className,
      assignedClasses: assignedClasses ?? this.assignedClasses,
      subject: subject ?? this.subject,
      roomNumber: roomNumber ?? this.roomNumber,
      linkedStudentId: linkedStudentId ?? this.linkedStudentId,
      teacherPermissions: teacherPermissions ?? this.teacherPermissions,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }
}
