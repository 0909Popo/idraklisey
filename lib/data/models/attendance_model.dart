enum AttendanceStatus {
  present, // Yaşıl - İştirak edib (W / İ)
  late,    // Sarı - Dərsə gecikib (G)
  absent,  // Qırmızı - Qayıb (Q)
  holiday, // Tətil / İstirahət günü
}

class DayAttendance {
  final DateTime date;
  final AttendanceStatus status;
  final String? note; // e.g. "10 dəqiqə gecikmə", "Üzürlü (Həkim arayışı)"
  final List<PeriodAttendance> periodDetails;

  DayAttendance({
    required this.date,
    required this.status,
    this.note,
    this.periodDetails = const [],
  });
}

class PeriodAttendance {
  final String period;
  final String subject;
  final AttendanceStatus status;
  final String? time;

  PeriodAttendance({
    required this.period,
    required this.subject,
    required this.status,
    this.time,
  });
}
