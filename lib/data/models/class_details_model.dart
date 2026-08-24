/// Sinif detalları — 'classes' kolleksiyasında sinif adı ilə açarlanır.
/// Mövcud siniflər hələ strings kimi istifadə olunur (timetable, şagird
/// className), bu model yalnız əlavə detalları daşıyır.
class ClassDetails {
  final String name;              // Sinif adı (açar): "9B"
  final String? room;             // Sinif otağı
  final String? curatorTeacherId; // Sinif rəhbəri (müəllim ID)
  final String academicYear;      // "2025 - 2026"
  final String? note;             // Qeyd

  const ClassDetails({
    required this.name,
    this.room,
    this.curatorTeacherId,
    this.academicYear = '2025 - 2026',
    this.note,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'room': room,
        'curatorTeacherId': curatorTeacherId,
        'academicYear': academicYear,
        'note': note,
      };

  factory ClassDetails.fromJson(Map<String, dynamic> json) => ClassDetails(
        name: json['name'] ?? '',
        room: json['room'],
        curatorTeacherId: json['curatorTeacherId'],
        academicYear: json['academicYear'] ?? '2025 - 2026',
        note: json['note'],
      );
}
