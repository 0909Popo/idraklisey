enum AssignmentStatus {
  pending,   // Yeni / Gözləmədə
  inProgress,// İcrada
  submitted, // Təhvil verildi
  graded,    // Yoxlanıldı / Qiymətləndirildi
}

class AssignmentSubmission {
  final String studentId;
  final String studentName;
  final DateTime submittedAt;
  final List<String> scannedImages; // Photos taken via camera
  final String? studentNote;
  final double? score;
  final String? teacherComment;
  final DateTime? gradedAt;

  AssignmentSubmission({
    required this.studentId,
    required this.studentName,
    required this.submittedAt,
    required this.scannedImages,
    this.studentNote,
    this.score,
    this.teacherComment,
    this.gradedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'submittedAt': submittedAt.toIso8601String(),
      'scannedImages': scannedImages,
      'studentNote': studentNote,
      'score': score,
      'teacherComment': teacherComment,
      'gradedAt': gradedAt?.toIso8601String(),
    };
  }

  factory AssignmentSubmission.fromMap(Map<String, dynamic> map) {
    return AssignmentSubmission(
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      submittedAt: DateTime.tryParse(map['submittedAt'] ?? '') ?? DateTime.now(),
      scannedImages: List<String>.from(map['scannedImages'] ?? []),
      studentNote: map['studentNote'],
      score: (map['score'] as num?)?.toDouble(),
      teacherComment: map['teacherComment'],
      gradedAt: map['gradedAt'] != null ? DateTime.tryParse(map['gradedAt']) : null,
    );
  }
}

class HomeworkAssignment {
  final String id;
  final String subject;
  final String title;
  final String teacherName;
  final String instructions;
  final DateTime assignedDate;
  final DateTime dueDate;
  final String? attachmentDocUrl;
  final String? assignedClass;
  final List<String> assignedStudentIds;
  final Map<String, AssignmentSubmission> submissions; // studentId -> AssignmentSubmission

  HomeworkAssignment({
    required this.id,
    required this.subject,
    required this.title,
    required this.teacherName,
    required this.instructions,
    required this.assignedDate,
    required this.dueDate,
    this.attachmentDocUrl,
    this.assignedClass,
    this.assignedStudentIds = const [],
    this.submissions = const {},
  });

  AssignmentSubmission? getSubmissionForStudent(String studentId) => submissions[studentId];

  AssignmentStatus getStatusForStudent(String studentId) {
    final sub = submissions[studentId];
    if (sub == null) return AssignmentStatus.pending;
    if (sub.score != null) return AssignmentStatus.graded;
    return AssignmentStatus.submitted;
  }

  bool isOverdueForStudent(String studentId) {
    final status = getStatusForStudent(studentId);
    return DateTime.now().isAfter(dueDate) &&
        status != AssignmentStatus.submitted &&
        status != AssignmentStatus.graded;
  }

  int get submittedCount => submissions.values.where((s) => s.score == null).length;
  int get gradedCount => submissions.values.where((s) => s.score != null).length;
  int get totalSubmissionsCount => submissions.length;
}
