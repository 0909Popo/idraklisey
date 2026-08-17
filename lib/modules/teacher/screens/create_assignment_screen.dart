import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
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
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryAccent,
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
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Gradient Header ──
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.primary,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.check_rounded, size: 18, color: Colors.white),
                  ),
                  tooltip: 'Tapşırığı Göndər',
                  onPressed: () => _submitAssignment(appState),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1A1B2E), Color(0xFF312E81), Color(0xFF6C5CE7)],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -15,
                      bottom: -15,
                      child: Icon(Icons.note_add_rounded, size: 130, color: Colors.white.withAlpha(10)),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 44, 20, 16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withAlpha(20),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.add_task_rounded, size: 22, color: Colors.white),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Yeni Dərs Tapşırığı',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Tapşırıq təlimatları & Son tarix',
                                      style: TextStyle(
                                        color: Colors.white.withAlpha(180),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Form Body ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Core Info Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.cardBorder),
                      boxShadow: AppShadows.sm,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primaryAccent.withAlpha(15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.description_rounded, color: AppColors.primaryAccent, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Tapşırıq Məlumatları',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Title
                        TextField(
                          controller: _titleCtrl,
                          decoration: InputDecoration(
                            labelText: 'Tapşırıq Başlığı *',
                            hintText: 'Məs: Kvadratik tənliklərin Viyet teoremi ilə həlli',
                            prefixIcon: const Icon(Icons.title_rounded, color: AppColors.primaryAccent, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: AppColors.cardBorder),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.primaryAccent, width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Subject
                        TextField(
                          controller: _subjectCtrl,
                          decoration: InputDecoration(
                            labelText: 'Fənn *',
                            hintText: 'Məs: Riyaziyyat, Fizika',
                            prefixIcon: const Icon(Icons.menu_book_rounded, color: AppColors.primaryAccent, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: AppColors.cardBorder),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.primaryAccent, width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Quick Subject Chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            children: _commonSubjects.map((subj) {
                              final isSelected = _subjectCtrl.text.trim().toLowerCase() == subj.toLowerCase();
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _subjectCtrl.text = subj;
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.primaryAccent : AppColors.background,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected ? AppColors.primaryAccent : AppColors.cardBorder,
                                      ),
                                    ),
                                    child: Text(
                                      subj,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                        color: isSelected ? Colors.white : AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
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
                          decoration: InputDecoration(
                            labelText: 'Ətraflı Təlimat & Məsələ Nömrələri *',
                            hintText: 'Şagirdin nə etməli olduğunu, dəftərdə yazılacaq məsələləri və qaydaları aydın izah edin...',
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: AppColors.cardBorder),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.primaryAccent, width: 1.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Optional Reference / Link
                        TextField(
                          controller: _attachmentCtrl,
                          decoration: InputDecoration(
                            labelText: 'Resurs / Dərslik Linki (Könüllü)',
                            hintText: 'Məs: https://idrakliseyi.edu.az/derslik.pdf və ya Səhifə 45-48',
                            prefixIcon: const Icon(Icons.link_rounded, color: AppColors.primaryAccent, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(color: AppColors.cardBorder),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.primaryAccent, width: 1.5),
                            ),
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
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.cardBorder),
                      boxShadow: AppShadows.sm,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppColors.gold.withAlpha(15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.event_available_rounded, color: AppColors.goldDark, size: 18),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Son Təhvil Tarixi',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                                ),
                              ],
                            ),
                            StatusBadge(
                              label: dateFormat.format(_dueDate),
                              color: AppColors.primaryAccent,
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
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  side: BorderSide(color: AppColors.cardBorder),
                                ),
                                child: const Text('Sabah', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _setQuickDueDate(const Duration(days: 2)),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  side: BorderSide(color: AppColors.cardBorder),
                                ),
                                child: const Text('2 gün sonra', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _setQuickDueDate(const Duration(days: 7)),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  side: BorderSide(color: AppColors.cardBorder),
                                ),
                                child: const Text('1 həftə', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Detailed picker button
                        ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(color: AppColors.cardBorder),
                          ),
                          tileColor: AppColors.background,
                          leading: const Icon(Icons.calendar_today_rounded, color: AppColors.primaryAccent, size: 20),
                          title: const Text('Xüsusi Gün və Saat Seç', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          subtitle: Text(
                            dateFormat.format(_dueDate),
                            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.primaryAccent),
                          ),
                          trailing: const Icon(Icons.edit_calendar_rounded, color: AppColors.primaryAccent, size: 18),
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
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.cardBorder),
                      boxShadow: AppShadows.sm,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.primaryAccent.withAlpha(15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.people_alt_rounded, color: AppColors.primaryAccent, size: 18),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Tapşırıq Kimə Təyin Olunur?',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

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
                          // A) TEACHER CLAIMED CLASSES
                          if (teacherClaimedClasses.isNotEmpty) ...[
                            Row(
                              children: [
                                const Icon(Icons.star_rounded, color: AppColors.gold, size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  'Sahipliyinizdə Olan Siniflər:',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: teacherClaimedClasses.map((c) {
                                final isSelected = _selectedClass == c;
                                final classCount = appState.getStudentsForClass(c).length;
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedClass = c),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.primaryAccent : AppColors.gold.withAlpha(20),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected ? AppColors.primaryAccent : AppColors.gold.withAlpha(80),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.verified_rounded,
                                          size: 15,
                                          color: isSelected ? Colors.white : AppColors.goldDark,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          '$c ($classCount şagird)',
                                          style: TextStyle(
                                            color: isSelected ? Colors.white : AppColors.textPrimary,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 14),
                            Divider(color: AppColors.cardBorder),
                            const SizedBox(height: 10),
                          ] else ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: AppColors.primaryAccent.withAlpha(12),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.primaryAccent.withAlpha(30)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.info_outline_rounded, color: AppColors.primaryAccent, size: 18),
                                  const SizedBox(width: 8),
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
                          Text(
                            'Digər Siniflər və Məktəb:',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              // All Classes Option
                              GestureDetector(
                                onTap: () => setState(() => _selectedClass = 'Hamısı'),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _selectedClass == 'Hamısı' ? AppColors.primaryAccent : AppColors.background,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: _selectedClass == 'Hamısı' ? AppColors.primaryAccent : AppColors.cardBorder,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.public_rounded,
                                        size: 15,
                                        color: _selectedClass == 'Hamısı' ? Colors.white : AppColors.primaryAccent,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Bütün Siniflər (Hamısı)',
                                        style: TextStyle(
                                          color: _selectedClass == 'Hamısı' ? Colors.white : AppColors.textPrimary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Other school classes
                              ...otherClasses.map((c) {
                                final isSelected = _selectedClass == c;
                                final classCount = appState.getStudentsForClass(c).length;
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedClass = c),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.primaryAccent : AppColors.background,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected ? AppColors.primaryAccent : AppColors.cardBorder,
                                      ),
                                    ),
                                    child: Text(
                                      '$c ($classCount)',
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : AppColors.textPrimary,
                                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                );
                              }),

                              // Custom class chip
                              GestureDetector(
                                onTap: () => setState(() => _selectedClass = 'Digər'),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _selectedClass == 'Digər' ? AppColors.primaryAccent : AppColors.background,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: _selectedClass == 'Digər' ? AppColors.primaryAccent : AppColors.cardBorder,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.add_circle_outline_rounded,
                                        size: 15,
                                        color: _selectedClass == 'Digər' ? Colors.white : AppColors.textSecondary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Digər Sinif',
                                        style: TextStyle(
                                          color: _selectedClass == 'Digər' ? Colors.white : AppColors.textPrimary,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          if (_selectedClass == 'Digər') ...[
                            const SizedBox(height: 12),
                            TextField(
                              controller: _customClassCtrl,
                              decoration: InputDecoration(
                                labelText: 'Xüsusi Sinif Adı *',
                                hintText: 'Məs: 8A, 10C',
                                prefixIcon: const Icon(Icons.school_rounded, color: AppColors.primaryAccent, size: 20),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                            ),
                          ],

                          // Current Selected Summary Banner
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0FDF4),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.success.withAlpha(60)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _selectedClass == 'Hamısı'
                                        ? 'Tapşırıq məktəbin bütün siniflərinə göndəriləcək'
                                        : 'Seçildi: $_selectedClass sinfi (${appState.getStudentsForClass(_selectedClass).length} şagird)',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
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
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.danger.withAlpha(40)),
                              ),
                              child: const Text(
                                'Sistemdə hələ heç bir şagird qeydiyyatdan keçməyib. Əvvəlcə Admin panelindən şagird hesabı yaradın.',
                                style: TextStyle(color: AppColors.danger, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            )
                          else ...[
                            // Class filter chips for students
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              child: Row(
                                children: ['Hamısı', ...teacherClaimedClasses, ...otherClasses].map((c) {
                                  final isSel = _studentFilterClass == c;
                                  final isClaimed = teacherClaimedClasses.contains(c);
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: GestureDetector(
                                      onTap: () => setState(() => _studentFilterClass = c),
                                      child: AnimatedContainer(
                                        duration: const Duration(milliseconds: 200),
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: isSel ? AppColors.primaryAccent : (isClaimed ? AppColors.gold.withAlpha(20) : AppColors.background),
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: isSel ? AppColors.primaryAccent : (isClaimed ? AppColors.gold.withAlpha(80) : AppColors.cardBorder),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (isClaimed) ...[
                                              Icon(Icons.star_rounded, size: 14, color: isSel ? Colors.white : AppColors.gold),
                                              const SizedBox(width: 4),
                                            ],
                                            Text(
                                              c == 'Hamısı' ? 'Bütün Şagirdlər' : c,
                                              style: TextStyle(
                                                color: isSel ? Colors.white : AppColors.textPrimary,
                                                fontSize: 11,
                                                fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Search bar
                            TextField(
                              onChanged: (val) => setState(() => _studentSearchQuery = val),
                              decoration: InputDecoration(
                                hintText: 'Şagird axtar...',
                                prefixIcon: const Icon(Icons.search_rounded, size: 18, color: AppColors.primaryAccent),
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(color: AppColors.cardBorder),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: AppColors.primaryAccent, width: 1.5),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Quick Select/Deselect all
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Seçilmiş: ${_selectedStudentIds.length} / ${students.length}',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primaryAccent),
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
                                      child: const Text('Hamısını Seç', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                                    ),
                                    const SizedBox(width: 8),
                                    TextButton(
                                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                                      onPressed: () {
                                        setState(() {
                                          _selectedStudentIds.clear();
                                        });
                                      },
                                      child: const Text('Təmizlə', style: TextStyle(fontSize: 11, color: AppColors.danger, fontWeight: FontWeight.w700)),
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
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: filteredStudents.isEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Center(
                                        child: Text('Axtarışa uyğun şagird tapılmadı.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                      ),
                                    )
                                  : ListView.separated(
                                      shrinkWrap: true,
                                      physics: const BouncingScrollPhysics(),
                                      itemCount: filteredStudents.length,
                                      separatorBuilder: (_, index) => Divider(height: 1, color: AppColors.cardBorder),
                                      itemBuilder: (context, index) {
                                        final st = filteredStudents[index];
                                        final isChecked = _selectedStudentIds.contains(st.id);
                                        return CheckboxListTile(
                                          dense: true,
                                          value: isChecked,
                                          title: Text(st.fullName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                                          subtitle: Text('${st.className} • ${st.studentNumber}', style: const TextStyle(fontSize: 11)),
                                          activeColor: AppColors.primaryAccent,
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
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: () => _submitAssignment(appState),
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                      label: const Text(
                        'Tapşırığı Təsdiqlə və Şagirdlərə Göndər',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetToggle(int type, String title) {
    final isSelected = _targetType == type;
    return GestureDetector(
      onTap: () => setState(() => _targetType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryAccent : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primaryAccent : AppColors.cardBorder,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.primaryAccent.withAlpha(25), blurRadius: 8, offset: const Offset(0, 2))]
              : [],
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }
}
