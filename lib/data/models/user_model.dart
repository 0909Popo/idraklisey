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
  
  // 🆕 HR məlumatları (işçi yaradılışı üçün)
  final String? firstName;     // Ad (ayrıca)
  final String? lastName;      // Soyad (ayrıca)
  final String? fatherName;    // Ata adı
  final String? finCode;       // FIN kod (7 rəqəm)
  final String? gender;        // Cins: "Kişi" / "Qadın"
  final DateTime? birthDate;   // Doğum tarixi
  final String? address;       // Yaşadığı ünvan
  final String? citizenship;   // Vətəndaşlıq (sayt modeli: vetandasligi)
  final String? idCardSerial;  // ŞV seriyası (sayt modeli: sv_seriya)
  final String? educationLevel;// Təhsil dərəcəsi (sayt modeli: tehsil_derecesi)
  final String? bankName;      // Bank adı (sayt modeli: bank_adi)

  // 🆕 İş məlumatları (HR)
  final String? position;      // Vəzifə adı (məs: "İT üzrə mütəxəssis")
  final DateTime? hireDate;    // İşə qəbul tarixi
  final double? salary;        // Əmək haqqı (AZN, gross)
  final DateTime? contractStart; // Müqavilə başlanğıc tarixi
  final DateTime? contractEnd;   // Müqavilə bitmə tarixi
  
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
  final List<String> linkedStudentIds; // Övladlar: valideynin bütün uşaqları (sayt modeli)
  final TeacherPermissions? teacherPermissions; // For teacher
  final String? assignedRoleId; // 🆕 Atanan özel rol ID'si (opsiyonel - varsayılan rol yerine)
  final bool isActive;
  final DateTime createdAt;

  AppUser({
    required this.id,
    required this.username,
    required this.password,
    required this.fullName,
    this.firstName,     // 🆕
    this.lastName,      // 🆕
    this.fatherName,    // 🆕
    this.finCode,       // 🆕
    this.gender,        // 🆕
    this.birthDate,     // 🆕
    this.address,       // 🆕
    this.citizenship,   // 🆕
    this.idCardSerial,  // 🆕
    this.educationLevel,// 🆕
    this.bankName,      // 🆕
    this.position,      // 🆕
    this.hireDate,      // 🆕
    this.salary,        // 🆕
    this.contractStart, // 🆕
    this.contractEnd,   // 🆕
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
    this.linkedStudentIds = const [],
    this.teacherPermissions,
    this.assignedRoleId, // 🆕 Opsiyonel rol ID
    this.isActive = true,
    required this.createdAt,
  });

  AppUser copyWith({
    String? username,
    String? password,
    String? fullName,
    String? firstName,    // 🆕
    String? lastName,     // 🆕
    String? fatherName,   // 🆕
    String? finCode,      // 🆕
    String? gender,       // 🆕
    DateTime? birthDate,  // 🆕
    String? address,      // 🆕
    String? citizenship,   // 🆕
    String? idCardSerial,  // 🆕
    String? educationLevel,// 🆕
    String? bankName,      // 🆕
    String? position,     // 🆕
    DateTime? hireDate,   // 🆕
    double? salary,       // 🆕
    DateTime? contractStart, // 🆕
    DateTime? contractEnd,   // 🆕
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
    List<String>? linkedStudentIds,
    TeacherPermissions? teacherPermissions,
    String? assignedRoleId, // 🆕
    bool? isActive,
  }) {
    return AppUser(
      id: id,
      username: username ?? this.username,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      firstName: firstName ?? this.firstName,           // 🆕
      lastName: lastName ?? this.lastName,              // 🆕
      fatherName: fatherName ?? this.fatherName,        // 🆕
      finCode: finCode ?? this.finCode,                 // 🆕
      gender: gender ?? this.gender,                    // 🆕
      birthDate: birthDate ?? this.birthDate,           // 🆕
      address: address ?? this.address,                 // 🆕
      citizenship: citizenship ?? this.citizenship,     // 🆕
      idCardSerial: idCardSerial ?? this.idCardSerial,  // 🆕
      educationLevel: educationLevel ?? this.educationLevel, // 🆕
      bankName: bankName ?? this.bankName,              // 🆕
      position: position ?? this.position,              // 🆕
      hireDate: hireDate ?? this.hireDate,              // 🆕
      salary: salary ?? this.salary,                    // 🆕
      contractStart: contractStart ?? this.contractStart, // 🆕
      contractEnd: contractEnd ?? this.contractEnd,     // 🆕
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
      linkedStudentIds: linkedStudentIds ?? this.linkedStudentIds,
      teacherPermissions: teacherPermissions ?? this.teacherPermissions,
      assignedRoleId: assignedRoleId ?? this.assignedRoleId, // 🆕
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }
}
