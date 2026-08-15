class StudentProfile {
  final String id;
  final String fullName;
  final String studentNumber; // e.g. "IDR-2024-0492"
  final String className;     // e.g. "9B - IB MYP"
  final String photoUrl;
  final String qrData;
  final String barcodeData;
  final String parentName;
  final String parentPhone;
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
    required this.parentName,
    required this.parentPhone,
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
    String? parentName,
    String? parentPhone,
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
      parentName: parentName ?? this.parentName,
      parentPhone: parentPhone ?? this.parentPhone,
      gpa: gpa ?? this.gpa,
      attendanceRate: attendanceRate ?? this.attendanceRate,
      academicYear: academicYear ?? this.academicYear,
    );
  }
}
