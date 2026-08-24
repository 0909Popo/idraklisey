class StudentProfile {
  final String id;
  final String fullName;
  final String studentNumber; // e.g. "IDR-2024-0492"
  final String className;     // e.g. "9B - IB MYP"
  final String photoUrl;
  final String qrData;
  final String barcodeData;
  
  // 🆕 Genişləndirilmiş şagird məlumatları
  final String? firstName;
  final String? lastName;
  final String? fatherName;    // Ata adı
  final String? finCode;       // 7 rəqəm
  final String? gender;        // Kişi / Qadın
  final DateTime? birthDate;
  final String? address;
  final String? email;         // avtomatik yaradılır
  final String? bloodGroup;    // Qan qrupu
  final List<String>? allergies; // Alergiyalar
  
  // Veli məlumatları
  final String parentName;
  final String parentPhone;
  final String? parentEmail;   // 🆕 avtomatik yaradılır
  final String? parentAddress; // 🆕
  
  // Akademik məlumatlar
  final double gpa;           // e.g. 4.8 / 5.0
  final int attendanceRate;   // e.g. 96%
  final String academicYear;  // "2024 - 2025"

  StudentProfile({
    required this.id,
    required this.fullName,
    required this.studentNumber,
    required this.className,
    required this.photoUrl,
    required this.qrData,
    required this.barcodeData,
    this.firstName,
    this.lastName,
    this.fatherName,
    this.finCode,
    this.gender,
    this.birthDate,
    this.address,
    this.email,
    this.bloodGroup,
    this.allergies,
    required this.parentName,
    required this.parentPhone,
    this.parentEmail,
    this.parentAddress,
    required this.gpa,
    required this.attendanceRate,
    required this.academicYear,
  });

  StudentProfile copyWith({
    String? fullName,
    String? studentNumber,
    String? className,
    String? photoUrl,
    String? qrData,
    String? barcodeData,
    String? firstName,
    String? lastName,
    String? fatherName,
    String? finCode,
    String? gender,
    DateTime? birthDate,
    String? address,
    String? email,
    String? bloodGroup,
    List<String>? allergies,
    String? parentName,
    String? parentPhone,
    String? parentEmail,
    String? parentAddress,
    double? gpa,
    int? attendanceRate,
    String? academicYear,
  }) {
    return StudentProfile(
      id: id,
      fullName: fullName ?? this.fullName,
      studentNumber: studentNumber ?? this.studentNumber,
      className: className ?? this.className,
      photoUrl: photoUrl ?? this.photoUrl,
      qrData: qrData ?? this.qrData,
      barcodeData: barcodeData ?? this.barcodeData,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      fatherName: fatherName ?? this.fatherName,
      finCode: finCode ?? this.finCode,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      address: address ?? this.address,
      email: email ?? this.email,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      allergies: allergies ?? this.allergies,
      parentName: parentName ?? this.parentName,
      parentPhone: parentPhone ?? this.parentPhone,
      parentEmail: parentEmail ?? this.parentEmail,
      parentAddress: parentAddress ?? this.parentAddress,
      gpa: gpa ?? this.gpa,
      attendanceRate: attendanceRate ?? this.attendanceRate,
      academicYear: academicYear ?? this.academicYear,
    );
  }
}
