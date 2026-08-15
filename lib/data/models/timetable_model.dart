import 'package:flutter/material.dart';

class LessonSlot {
  final String period; // e.g. "1-ci dərs"
  final String time;   // e.g. "08:30 - 09:15"
  final String subject;
  final String teacher;
  final String room;
  final String colorHex;
  final bool isCurrent;

  LessonSlot({
    required this.period,
    required this.time,
    required this.subject,
    required this.teacher,
    required this.room,
    this.colorHex = '0xFF2563EB',
    this.isCurrent = false,
  });

  Color get subjectColor {
    final s = subject.toLowerCase();
    if (s.contains('riyaziyyat') || s.contains('cəbr') || s.contains('həndəsə')) {
      return const Color(0xFF2563EB); // Royal Blue
    } else if (s.contains('fizika')) {
      return const Color(0xFF0284C7); // Ocean Sky
    } else if (s.contains('kimya')) {
      return const Color(0xFF7C3AED); // Vivid Purple
    } else if (s.contains('biologiya') || s.contains('həyat bilgisi') || s.contains('təbiət')) {
      return const Color(0xFF059669); // Emerald Green
    } else if (s.contains('ingilis') || s.contains('rus') || s.contains('alman') || s.contains('xarici dil')) {
      return const Color(0xFFD97706); // Amber Gold
    } else if (s.contains('tarix') || s.contains('zəfər')) {
      return const Color(0xFFE11D48); // Rose Crimson
    } else if (s.contains('azərbaycan') || s.contains('ədəbiyyat')) {
      return const Color(0xFF1D4ED8); // Deep Blue
    } else if (s.contains('informatika') || s.contains('rəqəmsal')) {
      return const Color(0xFF4F46E5); // Indigo
    } else if (s.contains('coğrafiya')) {
      return const Color(0xFF65A30D); // Lime
    } else if (s.contains('idman') || s.contains('bədən')) {
      return const Color(0xFFEA580C); // Warm Orange
    } else if (s.contains('musiqi') || s.contains('incəsənət') || s.contains('rəsm')) {
      return const Color(0xFFDB2777); // Pink
    }
    return const Color(0xFF1E3A8A); // Idrak Navy
  }

  IconData get subjectIcon {
    final s = subject.toLowerCase();
    if (s.contains('riyaziyyat') || s.contains('cəbr') || s.contains('həndəsə')) {
      return Icons.calculate_rounded;
    } else if (s.contains('fizika')) {
      return Icons.wb_twilight_rounded;
    } else if (s.contains('kimya')) {
      return Icons.biotech_rounded;
    } else if (s.contains('biologiya') || s.contains('həyat bilgisi') || s.contains('təbiət')) {
      return Icons.eco_rounded;
    } else if (s.contains('ingilis') || s.contains('rus') || s.contains('alman') || s.contains('xarici dil')) {
      return Icons.translate_rounded;
    } else if (s.contains('tarix') || s.contains('zəfər')) {
      return Icons.history_edu_rounded;
    } else if (s.contains('azərbaycan') || s.contains('ədəbiyyat')) {
      return Icons.menu_book_rounded;
    } else if (s.contains('informatika') || s.contains('rəqəmsal')) {
      return Icons.computer_rounded;
    } else if (s.contains('coğrafiya')) {
      return Icons.public_rounded;
    } else if (s.contains('idman') || s.contains('bədən')) {
      return Icons.sports_volleyball_rounded;
    } else if (s.contains('musiqi') || s.contains('incəsənət') || s.contains('rəsm')) {
      return Icons.palette_rounded;
    }
    return Icons.school_rounded;
  }
}

class DayTimetable {
  final String dayName; // "Bazar ertəsi", "Çərşənbə axşamı", etc.
  final String shortDay; // "B.E", "Ç.A", "Ç.", "C.A", "C."
  final List<LessonSlot> lessons;

  DayTimetable({
    required this.dayName,
    required this.shortDay,
    required this.lessons,
  });
}
