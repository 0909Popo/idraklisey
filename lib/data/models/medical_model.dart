import 'package:flutter/material.dart';

class VaccineRecord {
  final String name; // e.g. "Hepatit B", "QPM (Qızılca, Parotit, Məxmərək)"
  final DateTime date;
  final String status; // "Tamamlandı", "Növbəti doza"
  final String doctor;

  VaccineRecord({
    required this.name,
    required this.date,
    required this.status,
    required this.doctor,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'date': date.toIso8601String(),
    'status': status,
    'doctor': doctor,
  };

  factory VaccineRecord.fromMap(Map<String, dynamic> map) => VaccineRecord(
    name: map['name'] ?? '',
    date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
    status: map['status'] ?? 'Tamamlandı',
    doctor: map['doctor'] ?? '',
  );
}

class AllergyItem {
  final String name; // "Qlüten", "Qoz", "Penisillin", "Tozcuq"
  final String severity; // "Yüksək", "Orta", "Həssas"
  final String reaction; // "Dəri səpgisi", "Nəfəs darlığı"
  final String firstAid; // "Antihistamin verilməlidir"

  AllergyItem({
    required this.name,
    required this.severity,
    required this.reaction,
    required this.firstAid,
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'severity': severity,
    'reaction': reaction,
    'firstAid': firstAid,
  };

  factory AllergyItem.fromMap(Map<String, dynamic> map) => AllergyItem(
    name: map['name'] ?? '',
    severity: map['severity'] ?? 'Orta',
    reaction: map['reaction'] ?? '',
    firstAid: map['firstAid'] ?? '',
  );
}

class ParentMedicalNote {
  final String id;
  final String note;
  final DateTime date;
  final String parentName;

  ParentMedicalNote({
    required this.id,
    required this.note,
    required this.date,
    required this.parentName,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'note': note,
    'date': date.toIso8601String(),
    'parentName': parentName,
  };

  factory ParentMedicalNote.fromMap(Map<String, dynamic> map) => ParentMedicalNote(
    id: map['id'] ?? '',
    note: map['note'] ?? '',
    date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(),
    parentName: map['parentName'] ?? 'Valideyn',
  );
}

class StudentMedicalCard {
  final String bloodGroup; // "A(II) Rh+"
  final double heightCm;   // 148
  final double weightKg;   // 42
  final List<AllergyItem> allergies;
  final List<String> chronicConditions; // "Astma (Yüngül)", "Miopiya (-1.25)"
  final List<VaccineRecord> vaccineHistory;
  final List<ParentMedicalNote> parentNotes;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final String lyceumDoctorNotes;

  StudentMedicalCard({
    required this.bloodGroup,
    required this.heightCm,
    required this.weightKg,
    required this.allergies,
    required this.chronicConditions,
    required this.vaccineHistory,
    this.parentNotes = const [],
    required this.emergencyContactName,
    required this.emergencyContactPhone,
    required this.lyceumDoctorNotes,
  });

  // Calculate BMI (Bədən Kütlə İndeksi)
  double get bmi {
    if (heightCm <= 0 || weightKg <= 0) return 0.0;
    final hMeter = heightCm / 100.0;
    return weightKg / (hMeter * hMeter);
  }

  String get bmiDisplay => bmi > 0 ? bmi.toStringAsFixed(1) : 'Hesablanmayıb';

  String get bmiCategory {
    final b = bmi;
    if (b <= 0) return 'Məlumat yoxdur';
    if (b < 18.5) return 'Çəki azlığı (Underweight)';
    if (b <= 24.9) return 'Normal və Sağlam (Normal)';
    if (b <= 29.9) return 'Artıq çəki (Overweight)';
    return 'Piylənmə riski (Obese)';
  }

  Color get bmiColor {
    final b = bmi;
    if (b <= 0) return const Color(0xFF64748B);
    if (b < 18.5) return const Color(0xFFF59E0B); // Yellow warning
    if (b <= 24.9) return const Color(0xFF10B981); // Green healthy
    if (b <= 29.9) return const Color(0xFFF97316); // Orange overweight
    return const Color(0xFFEF4444); // Red obesity
  }

  String? get bmiWarning {
    final b = bmi;
    if (b <= 0) return null;
    if (b < 18.5) {
      return '⚠️ Diqqət: Şagirdin çəkisi yaş/boy normativinə görə aşağıdır. Yeməkxanada kalorili qidalanma və həkim məsləhəti tövsiyə olunur.';
    }
    if (b >= 25.0 && b <= 29.9) {
      return '⚠️ Xəbərdarlıq: Şagirdin bədən kütlə indeksi artıq çəki kateqoriyasındadır. Fiziki fəallıq və balanslı pəhriz tövsiyə olunur.';
    }
    if (b >= 30.0) {
      return '🚨 Təcili Xəbərdarlıq: Piylənmə riski aşkarlandı. Məktəb həkimi və valideyn nəzarəti tələb olunur.';
    }
    return null;
  }

  StudentMedicalCard copyWith({
    String? bloodGroup,
    double? heightCm,
    double? weightKg,
    List<AllergyItem>? allergies,
    List<String>? chronicConditions,
    List<VaccineRecord>? vaccineHistory,
    List<ParentMedicalNote>? parentNotes,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? lyceumDoctorNotes,
  }) {
    return StudentMedicalCard(
      bloodGroup: bloodGroup ?? this.bloodGroup,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      allergies: allergies ?? this.allergies,
      chronicConditions: chronicConditions ?? this.chronicConditions,
      vaccineHistory: vaccineHistory ?? this.vaccineHistory,
      parentNotes: parentNotes ?? this.parentNotes,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      lyceumDoctorNotes: lyceumDoctorNotes ?? this.lyceumDoctorNotes,
    );
  }
}
