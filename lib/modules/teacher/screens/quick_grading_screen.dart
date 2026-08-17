import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../providers/app_state.dart';
import '../../../data/models/student_model.dart';
import '../../../data/models/grade_model.dart';
import '../../../data/mock_data.dart';

class QuickGradingScreen extends StatefulWidget {
  final StudentProfile? preSelectedStudent;

  const QuickGradingScreen({super.key, this.preSelectedStudent});

  @override
  State<QuickGradingScreen> createState() => _QuickGradingScreenState();
}

class _QuickGradingScreenState extends State<QuickGradingScreen> {
  int _selectedAssessmentSystem = 0; // 0: AZ/RU (100 Bal / 5-lik), 1: IB MYP (1-7 Band & STR)
  StudentProfile? _selectedStudent;
  final TextEditingController _scoreController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();
  bool _isVoiceRecording = false;
  AssessmentType _assessmentType = AssessmentType.ksq;
  String _selectedClassFilter = 'Hamısı'; // 'Hamısı' means all

  @override
  void initState() {
    super.initState();
    _selectedStudent = widget.preSelectedStudent;

    // Default class filter to teacher's first assigned class
    final appState = Provider.of<AppState>(context, listen: false);
    final teacherClasses = appState.currentTeacherClasses;
    if (teacherClasses.isNotEmpty) {
      _selectedClassFilter = teacherClasses.first;
    }
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  void _simulateVoiceToText() {
    setState(() {
      _isVoiceRecording = !_isVoiceRecording;
    });

    if (_isVoiceRecording) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Səs yazılır... Danışın...'),
          backgroundColor: AppColors.primaryAccent,
          duration: Duration(seconds: 2),
        ),
      );

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && _isVoiceRecording) {
          setState(() {
            _isVoiceRecording = false;
            _feedbackController.text = 'Şagird bugünkü dərsdə və qiymətləndirmə tapşırıqlarında çox fəal iştirak etdi, analitik yanaşması əladır.';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Səsli rəy mətnə çevrildi (Voice-to-Text)!'),
              backgroundColor: AppColors.success,
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isIbSystem = _selectedAssessmentSystem == 1;

    final allStudents = appState.students.isNotEmpty ? appState.students : [MockData.currentStudent];

    // Class filtering
    final distinctClasses = allStudents.map((s) => s.className).toSet().toList()..sort();
    final availableStudents = _selectedClassFilter == 'Hamısı'
        ? allStudents
        : allStudents.where((s) => s.className == _selectedClassFilter).toList();

    // If selected student is not in the filtered list, reset
    if (_selectedStudent != null && !availableStudents.any((s) => s.id == _selectedStudent!.id)) {
      _selectedStudent = availableStudents.isNotEmpty ? availableStudents.first : null;
    }
    final activeStudent = _selectedStudent ?? (availableStudents.isNotEmpty ? availableStudents.first : allStudents.first);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Gradient Header ──
          SliverAppBar(
            expandedHeight: 130,
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
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1A1B2E), Color(0xFF4F46E5), Color(0xFF6C5CE7)],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      bottom: -10,
                      child: Icon(Icons.grade_rounded, size: 130, color: Colors.white.withAlpha(8)),
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
                                  child: const Icon(Icons.speed_rounded, size: 22, color: Colors.white),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Sürətli Qiymətləndirmə',
                                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Səsli Rəy & Qiymət Jurnalı',
                                      style: TextStyle(color: Colors.white.withAlpha(178), fontSize: 12, fontWeight: FontWeight.w500),
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

          // ── System Selector (AZ / RU vs IB MYP) ──
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Expanded(child: _buildSystemToggleBtn(0, 'AZ / RU Sistemi (100 Bal / KSQ)')),
                  const SizedBox(width: 8),
                  Expanded(child: _buildSystemToggleBtn(1, 'IB MYP (STR / Band 1-7)')),
                ],
              ),
            ),
          ),

          // ── Class Filter ──
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryAccent.withAlpha(12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.filter_alt_rounded, size: 14, color: AppColors.primaryAccent),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Sinif Filteri:',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryAccent.withAlpha(10),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${availableStudents.length} şagird',
                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.primaryAccent),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildClassFilterChip('Hamısı', allStudents.length),
                        ...distinctClasses.map((cls) {
                          final count = allStudents.where((s) => s.className == cls).length;
                          return _buildClassFilterChip(cls, count);
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Student Picker Label ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Text(
                'Şagirdi Seçin (${availableStudents.length} Şagird):',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
            ),
          ),

          // ── Student Picker Carousel ──
          SliverToBoxAdapter(
            child: availableStudents.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        '$_selectedClassFilter sinifində şagird tapılmadı.',
                        style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                      ),
                    ),
                  )
                : SizedBox(
                    height: 95,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      physics: const BouncingScrollPhysics(),
                      itemCount: availableStudents.length,
                      itemBuilder: (context, index) {
                        final student = availableStudents[index];
                        final isSelected = student.id == activeStudent.id;

                        return GestureDetector(
                          onTap: () => setState(() => _selectedStudent = student),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 80,
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primaryAccent.withAlpha(12) : AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? AppColors.primaryAccent : AppColors.cardBorder,
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [BoxShadow(color: AppColors.primaryAccent.withAlpha(25), blurRadius: 8, offset: const Offset(0, 2))]
                                  : AppShadows.sm,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(1.5),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected ? AppColors.primaryAccent : AppColors.cardBorder,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    radius: 18,
                                    backgroundImage: NetworkImage(student.photoUrl),
                                    onBackgroundImageError: (_, __) {},
                                    child: null,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  student.fullName.split(' ').first,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                    color: isSelected ? AppColors.primaryAccent : AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),

          // ── Selected Student Overview ──
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.cardBorder),
                boxShadow: AppShadows.sm,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primaryAccent.withAlpha(40), width: 1.5),
                    ),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundImage: NetworkImage(activeStudent.photoUrl),
                      onBackgroundImageError: (_, __) {},
                      child: null,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activeStudent.fullName,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.2),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${activeStudent.className} • ${activeStudent.studentNumber}',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(
                    label: activeStudent.gpa > 0 ? 'GPA: ${activeStudent.gpa}' : 'Yeni',
                    color: AppColors.primaryAccent,
                  ),
                ],
              ),
            ),
          ),

          // ── Grading Form ──
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 10, 16, 32),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primaryAccent.withAlpha(40)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryAccent.withAlpha(10),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primaryAccent.withAlpha(12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.edit_note_rounded, size: 16, color: AppColors.primaryAccent),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Qiymətləndirmə Növü & Bal',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Assessment Type Dropdown
                  DropdownButtonFormField<AssessmentType>(
                    initialValue: _assessmentType,
                    decoration: InputDecoration(
                      labelText: 'Qiymətləndirmə Tipi',
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
                    items: AssessmentType.values.map((t) {
                      return DropdownMenuItem(value: t, child: Text(t.displayName));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _assessmentType = val);
                    },
                  ),

                  const SizedBox(height: 14),

                  // Score Input
                  TextField(
                    controller: _scoreController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: isIbSystem ? 'IB Band Qiyməti (1 - 7)' : 'Toplanmış Bal (0 - 100)',
                      hintText: isIbSystem ? 'Məs: 6' : 'Məs: 88.5',
                      prefixIcon: const Icon(Icons.grade_rounded, color: AppColors.primaryAccent),
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

                  const SizedBox(height: 18),

                  // Feedback Header & Voice-to-Text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pedaqoji Rəy & Şərh',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                      ),
                      GestureDetector(
                        onTap: _simulateVoiceToText,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: _isVoiceRecording ? AppColors.danger.withAlpha(12) : AppColors.primaryAccent.withAlpha(10),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _isVoiceRecording ? AppColors.danger.withAlpha(50) : AppColors.primaryAccent.withAlpha(30),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _isVoiceRecording ? Icons.stop_circle_rounded : Icons.mic_rounded,
                                color: _isVoiceRecording ? AppColors.danger : AppColors.primaryAccent,
                                size: 16,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                _isVoiceRecording ? 'Yazılır...' : 'Səslə Rəy',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _isVoiceRecording ? AppColors.danger : AppColors.primaryAccent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: _feedbackController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Şagirdin dərslərdəki fəallığı və tərəqqisi barədə rəy daxil edin...',
                      hintStyle: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
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

                  const SizedBox(height: 22),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryAccent,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      onPressed: () {
                        final rawScoreText = _scoreController.text.trim().replaceAll(',', '.');
                        if (rawScoreText.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Zəhmət olmasa toplanmış balı daxil edin!'),
                              backgroundColor: AppColors.danger,
                            ),
                          );
                          return;
                        }

                        final parsedScore = double.tryParse(rawScoreText);
                        if (parsedScore == null || parsedScore < 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Düzgün rəqəm daxil edin!'),
                              backgroundColor: AppColors.danger,
                            ),
                          );
                          return;
                        }

                        if (isIbSystem) {
                          if (parsedScore < 1 || parsedScore > 7) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('IB MYP Band qiyməti 1 ilə 7 arasında olmalıdır!'),
                                backgroundColor: AppColors.danger,
                              ),
                            );
                            return;
                          }
                        } else {
                          if (parsedScore > 100) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Bal 0 ilə 100 arasında olmalıdır!'),
                                backgroundColor: AppColors.danger,
                              ),
                            );
                            return;
                          }
                        }

                        final score = parsedScore;
                        final teacherSubject = appState.currentUser?.subject ?? 'Fənn';

                        final newGrade = GradeRecord(
                          id: 'gr-${DateTime.now().millisecondsSinceEpoch}',
                          studentId: activeStudent.id,
                          studentName: activeStudent.fullName,
                          subject: '$teacherSubject (${activeStudent.className})',
                          type: _assessmentType,
                          title: '${_assessmentType.displayName} Qiymətləndirməsi',
                          score: score,
                          maxScore: isIbSystem ? 7.0 : 100.0,
                          gradeLetter: isIbSystem
                              ? 'Band ${score.toInt()}'
                              : (score >= 90 ? '5 (Əla)' : (score >= 70 ? '4 (Yaxşı)' : (score >= 50 ? '3 (Kafi)' : '2 (Qeyri-kafi)'))),
                          date: DateTime.now(),
                          teacherFeedback: _feedbackController.text.trim(),
                        );

                        appState.addGrade(newGrade, activeStudent.id);
                        _scoreController.clear();
                        _feedbackController.clear();

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${activeStudent.fullName} üçün qiymət qeydə alındı və GPA yeniləndi!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      icon: const Icon(Icons.save_rounded, color: Colors.white, size: 18),
                      label: const Text(
                        'Qiyməti Rəsmi Jurnala Daxil Et',
                        style: TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w700),
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

  Widget _buildSystemToggleBtn(int index, String label) {
    final isSelected = _selectedAssessmentSystem == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedAssessmentSystem = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryAccent : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primaryAccent : AppColors.cardBorder,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.primaryAccent.withAlpha(30), blurRadius: 8, offset: const Offset(0, 2))]
              : [],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildClassFilterChip(String cls, int count) {
    final isSelected = _selectedClassFilter == cls;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedClassFilter = cls;
            _selectedStudent = null; // Reset student selection on class change
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryAccent : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primaryAccent : AppColors.cardBorder,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? [BoxShadow(color: AppColors.primaryAccent.withAlpha(30), blurRadius: 6, offset: const Offset(0, 2))]
                : [],
          ),
          child: Text(
            '$cls ($count)',
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
