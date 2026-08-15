import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../providers/app_state.dart';
import '../../../data/models/assignment_model.dart';
import '../../../data/models/student_model.dart';

class CreateAssignmentScreen extends StatefulWidget {
  final StudentProfile? preSelectedStudent;

  const CreateAssignmentScreen({super.key, this.preSelectedStudent});

  @override
  State<CreateAssignmentScreen> createState() => _CreateAssignmentScreenState();
}

class _CreateAssignmentScreenState extends State<CreateAssignmentScreen> {
  final _titleCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _instructionsCtrl = TextEditingController();
  final _attachmentCtrl = TextEditingController();
  final _customClassCtrl = TextEditingController();

  String _selectedClass = 'Hamısı';
  DateTime _dueDate = DateTime.now().add(const Duration(days: 2, hours: 8));
  int _targetType = 0; // 0: Sinif Üzrə, 1: Fərdi Şagirdlər
  final Set<String> _selectedStudentIds = {};

  // Student filter helpers for individual selection
  String _studentSearchQuery = '';
  String _studentFilterClass = 'Hamısı';

  static const List<String> _commonSubjects = [
    'Riyaziyyat',
    'Azərbaycan Dili',
    'İngilis Dili',
    'Fizika',
    'Kimya',
    'Biologiya',
    'Tarix',
    'İnformatika',
    'Coğrafiya',
    'Ədəbiyyat',
  ];

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    final teacherSubject = appState.currentUser?.subject;
    if (teacherSubject != null && teacherSubject.isNotEmpty) {
      _subjectCtrl.text = teacherSubject;
    } else {
      _subjectCtrl.text = 'Riyaziyyat';
    }

    final teacherClasses = appState.currentTeacherClasses;
    if (teacherClasses.isNotEmpty) {
      _selectedClass = teacherClasses.first;
    } else if (appState.allDistinctClasses.isNotEmpty) {
      _selectedClass = appState.allDistinctClasses.first;
    }

    if (widget.preSelectedStudent != null) {
      _targetType = 1;
      _selectedStudentIds.add(widget.preSelectedStudent!.id);
      _selectedClass = widget.preSelectedStudent!.className;
      _studentFilterClass = widget.preSelectedStudent!.className;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _subjectCtrl.dispose();
    _instructionsCtrl.dispose();
    _attachmentCtrl.dispose();
    _customClassCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && mounted) {
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_dueDate),
      );

      if (pickedTime != null && mounted) {
        setState(() {
          _dueDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _setQuickDueDate(Duration duration) {
    setState(() {
      _dueDate = DateTime.now().add(duration);
    });
  }

  void _submitAssignment(AppState appState) {
    final title = _titleCtrl.text.trim();
    final subject = _subjectCtrl.text.trim();
    final instructions = _instructionsCtrl.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Zəhmət olmasa tapşırığın başlığını daxil edin!'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    if (subject.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Zəhmət olmasa fənn adını qeyd edin!'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    if (instructions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Zəhmət olmasa tapşırığın ətraflı təlimatını qeyd edin!'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    if (_targetType == 1 && _selectedStudentIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fərdi rejimdə ən azı bir şagird seçilməlidir!'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final targetClass = _targetType == 0
        ? (_selectedClass == 'Digər'
            ? _customClassCtrl.text.trim()
            : (_selectedClass == 'Hamısı' ? null : _selectedClass))
        : null;

    final newAssignment = HomeworkAssignment(
      id: 'hw-${DateTime.now().millisecondsSinceEpoch}',
      subject: subject,
      title: title,
      teacherName: appState.currentUser?.fullName ?? 'Müəllim',
      instructions: instructions,
      assignedDate: DateTime.now(),
      dueDate: _dueDate,
      attachmentDocUrl: _attachmentCtrl.text.trim().isNotEmpty ? _attachmentCtrl.text.trim() : null,
      assignedClass: targetClass,
      assignedStudentIds: _targetType == 1 ? _selectedStudentIds.toList() : [],
    );

    appState.createAssignment(newAssignment);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Dərs tapşırığı uğurla yaradıldı və şagirdlərə göndərildi!',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final students = appState.students;
    final allDistinctClasses = appState.allDistinctClasses;
    final teacherClaimedClasses = appState.currentTeacherClasses;
    final otherClasses = allDistinctClasses.where((c) => !teacherClaimedClasses.contains(c)).toList();
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

    // Filter students for individual selection
    final filteredStudents = students.where((s) {
      final matchesClass = _studentFilterClass == 'Hamısı' || s.className == _studentFilterClass;
      final q = _studentSearchQuery.toLowerCase().trim();
      final matchesSearch = q.isEmpty ||
          s.fullName.toLowerCase().contains(q) ||
          s.studentNumber.toLowerCase().contains(q);
      return matchesClass && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Yeni Dərs Tapşırığı Təyin Et'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_rounded),
            tooltip: 'Tapşırığı Göndər',
            onPressed: () => _submitAssignment(appState),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Core Info Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(5),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.assignment_rounded, color: AppColors.primary, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Tapşırıq Məlumatları',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title
                  TextField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Tapşırıq Başlığı *',
                      hintText: 'Məs: Kvadratik tənliklərin Viyet teoremi ilə həlli',
                      prefixIcon: Icon(Icons.title_rounded, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Subject
                  TextField(
                    controller: _subjectCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Fənn *',
                      hintText: 'Məs: Riyaziyyat, Fizika',
                      prefixIcon: Icon(Icons.book_rounded, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Quick Subject Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _commonSubjects.map((subj) {
                        final isSelected = _subjectCtrl.text.trim().toLowerCase() == subj.toLowerCase();
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ActionChip(
                            label: Text(subj),
                            backgroundColor: isSelected ? AppColors.primary.withAlpha(20) : AppColors.background,
                            side: BorderSide(color: isSelected ? AppColors.primary : AppColors.cardBorder),
                            labelStyle: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? AppColors.primary : AppColors.textPrimary,
                            ),
                            onPressed: () {
                              setState(() {
                                _subjectCtrl.text = subj;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Instructions
                  TextField(
                    controller: _instructionsCtrl,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Ətraflı Təlimat & Məsələ Nömrələri *',
                      hintText: 'Şagirdin nə etməli olduğunu, dəftərdə yazılacaq məsələləri və qaydaları aydın izah edin...',
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Optional Reference / Link
                  TextField(
                    controller: _attachmentCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Resurs / Dərslik Linki (Könüllü)',
                      hintText: 'Məs: https://idrakliseyi.edu.az/derslik.pdf və ya Səhifə 45-48',
                      prefixIcon: Icon(Icons.link_rounded, color: AppColors.primaryAccent),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 2. Due Date Selector Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.event_available_rounded, color: AppColors.goldDark, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Son Təhvil Tarixi və Saatı',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                      StatusBadge(
                        label: dateFormat.format(_dueDate),
                        color: AppColors.primary,
                        fontSize: 11,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Quick Date Selectors
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _setQuickDueDate(const Duration(days: 1)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            side: const BorderSide(color: AppColors.cardBorder),
                          ),
                          child: const Text('Sabah', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _setQuickDueDate(const Duration(days: 2)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            side: const BorderSide(color: AppColors.cardBorder),
                          ),
                          child: const Text('2 gün sonra', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _setQuickDueDate(const Duration(days: 7)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            side: const BorderSide(color: AppColors.cardBorder),
                          ),
                          child: const Text('1 həftə', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Detailed picker button
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: AppColors.cardBorder),
                    ),
                    tileColor: AppColors.background,
                    leading: const Icon(Icons.calendar_today_rounded, color: AppColors.primaryAccent),
                    title: const Text('Xüsusi Gün və Saat Seç', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      dateFormat.format(_dueDate),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.primary),
                    ),
                    trailing: const Icon(Icons.edit_calendar_rounded, color: AppColors.primaryAccent),
                    onTap: _pickDueDate,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 3. Target Audience Card (Class vs Specific Students)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.people_alt_rounded, color: AppColors.primaryAccent, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Tapşırıq Kimə Təyin Olunur?',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Segmented Target Switch
                  Row(
                    children: [
                      Expanded(
                        child: _buildTargetToggle(0, '🏫 Sinif Üzrə'),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTargetToggle(1, '👤 Fərdi Şagirdlər'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (_targetType == 0) ...[
                    // A) TEACHER CLAIMED CLASSES (Sahipliyi olduğu siniflər)
                    if (teacherClaimedClasses.isNotEmpty) ...[
                      Row(
                        children: const [
                          Icon(Icons.star_rounded, color: AppColors.gold, size: 18),
                          SizedBox(width: 6),
                          Text(
                            'Sahipliyinizdə Olan Siniflər:',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: teacherClaimedClasses.map((c) {
                          final isSelected = _selectedClass == c;
                          final classCount = appState.getStudentsForClass(c).length;
                          return ChoiceChip(
                            avatar: Icon(
                              Icons.verified_rounded,
                              size: 16,
                              color: isSelected ? Colors.white : AppColors.goldDark,
                            ),
                            label: Text('$c ($classCount şagird)'),
                            selected: isSelected,
                            onSelected: (val) {
                              if (val) setState(() => _selectedClass = c);
                            },
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            backgroundColor: AppColors.gold.withAlpha(25),
                            side: BorderSide(
                              color: isSelected ? AppColors.primary : AppColors.gold.withAlpha(100),
                              width: 1.2,
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),
                      const Divider(),
                      const SizedBox(height: 10),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryAccent.withAlpha(15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.primaryAccent.withAlpha(40)),
                        ),
                        child: Row(
                          children: const [
                            Icon(Icons.info_outline_rounded, color: AppColors.primaryAccent, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Hələlik sinif sahiplənməmisiniz. Aşağıdakı məktəb siniflərindən birini seçə bilərsiniz:',
                                style: TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // B) ALL SCHOOL CLASSES / OTHERS
                    const Text(
                      'Digər Siniflər və Məktəb:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        // All Classes Option
                        ChoiceChip(
                          avatar: Icon(
                            Icons.public_rounded,
                            size: 16,
                            color: _selectedClass == 'Hamısı' ? Colors.white : AppColors.primaryAccent,
                          ),
                          label: const Text('Bütün Siniflər (Hamısı)'),
                          selected: _selectedClass == 'Hamısı',
                          onSelected: (val) {
                            if (val) setState(() => _selectedClass = 'Hamısı');
                          },
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: _selectedClass == 'Hamısı' ? Colors.white : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          backgroundColor: AppColors.background,
                          side: BorderSide(color: _selectedClass == 'Hamısı' ? AppColors.primary : AppColors.cardBorder),
                        ),

                        // Other school classes
                        ...otherClasses.map((c) {
                          final isSelected = _selectedClass == c;
                          final classCount = appState.getStudentsForClass(c).length;
                          return ChoiceChip(
                            label: Text('$c ($classCount)'),
                            selected: isSelected,
                            onSelected: (val) {
                              if (val) setState(() => _selectedClass = c);
                            },
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 12,
                            ),
                            backgroundColor: AppColors.background,
                            side: BorderSide(color: isSelected ? AppColors.primary : AppColors.cardBorder),
                          );
                        }),

                        // Custom class chip
                        ChoiceChip(
                          avatar: Icon(
                            Icons.add_circle_outline_rounded,
                            size: 16,
                            color: _selectedClass == 'Digər' ? Colors.white : AppColors.textSecondary,
                          ),
                          label: const Text('Digər Sinif'),
                          selected: _selectedClass == 'Digər',
                          onSelected: (val) {
                            if (val) setState(() => _selectedClass = 'Digər');
                          },
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: _selectedClass == 'Digər' ? Colors.white : AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          backgroundColor: AppColors.background,
                          side: BorderSide(color: _selectedClass == 'Digər' ? AppColors.primary : AppColors.cardBorder),
                        ),
                      ],
                    ),

                    if (_selectedClass == 'Digər') ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: _customClassCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Xüsusi Sinif Adı *',
                          hintText: 'Məs: 8A, 10C',
                          prefixIcon: Icon(Icons.school_rounded, color: AppColors.primary),
                        ),
                      ),
                    ],

                    // Current Selected Summary Banner
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.success.withAlpha(80)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedClass == 'Hamısı'
                                  ? 'Tapşırıq məktəbin bütün siniflərinə göndəriləcək'
                                  : 'Seçildi: $_selectedClass sinfi (${appState.getStudentsForClass(_selectedClass).length} şagird)',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF15803D),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Individual Student Selector with Filter & Search
                    if (students.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.danger.withAlpha(50)),
                        ),
                        child: const Text(
                          'Sistemdə hələ heç bir şagird qeydiyyatdan keçməyib. Əvvəlcə Admin panelindən şagird hesabı yaradın.',
                          style: TextStyle(color: AppColors.danger, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      )
                    else ...[
                      // Class filter chips for students (highlighting claimed classes)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: ['Hamısı', ...teacherClaimedClasses, ...otherClasses].map((c) {
                            final isSel = _studentFilterClass == c;
                            final isClaimed = teacherClaimedClasses.contains(c);
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: FilterChip(
                                avatar: isClaimed
                                    ? Icon(Icons.star_rounded, size: 14, color: isSel ? Colors.white : AppColors.gold)
                                    : null,
                                label: Text(c == 'Hamısı' ? 'Bütün Şagirdlər' : c),
                                selected: isSel,
                                onSelected: (val) => setState(() => _studentFilterClass = c),
                                selectedColor: AppColors.primary,
                                checkmarkColor: Colors.white,
                                labelStyle: TextStyle(
                                  color: isSel ? Colors.white : AppColors.textPrimary,
                                  fontSize: 11,
                                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                ),
                                backgroundColor: isClaimed ? AppColors.gold.withAlpha(20) : AppColors.background,
                                side: BorderSide(
                                  color: isSel
                                      ? AppColors.primary
                                      : (isClaimed ? AppColors.gold.withAlpha(80) : AppColors.cardBorder),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Search bar
                      TextField(
                        onChanged: (val) => setState(() => _studentSearchQuery = val),
                        decoration: InputDecoration(
                          hintText: 'Şagird axtar...',
                          prefixIcon: const Icon(Icons.search_rounded, size: 18),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Quick Select/Deselect all
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Seçilmiş: ${_selectedStudentIds.length} / ${students.length}',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                          ),
                          Row(
                            children: [
                              TextButton(
                                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                                onPressed: () {
                                  setState(() {
                                    for (final s in filteredStudents) {
                                      _selectedStudentIds.add(s.id);
                                    }
                                  });
                                },
                                child: const Text('Hamısını Seç', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 8),
                              TextButton(
                                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                                onPressed: () {
                                  setState(() {
                                    _selectedStudentIds.clear();
                                  });
                                },
                                child: const Text('Təmizlə', style: TextStyle(fontSize: 11, color: AppColors.danger)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Students List with Checkboxes
                      Container(
                        constraints: const BoxConstraints(maxHeight: 240),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.cardBorder),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: filteredStudents.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: Text('Axtarışa uyğun şagird tapılmadı.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                itemCount: filteredStudents.length,
                                separatorBuilder: (_, index) => const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final st = filteredStudents[index];
                                  final isChecked = _selectedStudentIds.contains(st.id);
                                  return CheckboxListTile(
                                    dense: true,
                                    value: isChecked,
                                    title: Text(st.fullName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                    subtitle: Text('${st.className} • ${st.studentNumber}', style: const TextStyle(fontSize: 11)),
                                    activeColor: AppColors.primary,
                                    onChanged: (val) {
                                      setState(() {
                                        if (val == true) {
                                          _selectedStudentIds.add(st.id);
                                        } else {
                                          _selectedStudentIds.remove(st.id);
                                        }
                                      });
                                    },
                                  );
                                },
                              ),
                      ),
                    ],
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 4,
                  shadowColor: AppColors.primary.withAlpha(100),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => _submitAssignment(appState),
                icon: const Icon(Icons.send_rounded, color: Colors.white),
                label: const Text(
                  'Tapşırığı Təsdiqlə və Şagirdlərə Göndər',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetToggle(int type, String title) {
    final isSelected = _targetType == type;
    return GestureDetector(
      onTap: () => setState(() => _targetType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.cardBorder),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
