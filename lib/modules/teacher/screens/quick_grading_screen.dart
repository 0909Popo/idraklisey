import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_card.dart';
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
      appBar: AppBar(
        title: const Text('Sürətli Qiymətləndirmə & Səsli Rəy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // System Selector (AZ / RU vs IB MYP)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: _buildSystemToggleBtn(0, 'AZ / RU Sistemi (100 Bal / KSQ)'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildSystemToggleBtn(1, 'IB MYP (STR / Band 1-7)'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Class Filter Chips
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.filter_alt_rounded, size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      const Text(
                        'Sinif Filteri:',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const Spacer(),
                      Text(
                        '${availableStudents.length} şagird',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
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

            const SizedBox(height: 12),

            // Student Picker Carousel
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Şagirdi Seçin (${availableStudents.length} Şagird):',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 8),

            if (availableStudents.isEmpty)
              Padding(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    '$_selectedClassFilter sinifində şagird tapılmadı.',
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                ),
              )
            else
              SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: availableStudents.length,
                  itemBuilder: (context, index) {
                    final student = availableStudents[index];
                    final isSelected = student.id == activeStudent.id;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedStudent = student),
                      child: Container(
                        width: 80,
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary.withAlpha(20) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : AppColors.cardBorder,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundImage: NetworkImage(student.photoUrl),
                              onBackgroundImageError: (_, _) {},
                              child: const Icon(Icons.person, size: 18),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              student.fullName.split(' ').first,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? AppColors.primary : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 16),

            // Selected Student Overview Card
            CustomCard(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage(activeStudent.photoUrl),
                    onBackgroundImageError: (_, _) {},
                    child: const Icon(Icons.person),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activeStudent.fullName,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                        Text(
                          '${activeStudent.className} • ${activeStudent.studentNumber}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
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

            const SizedBox(height: 8),

            // Grading Form Card
            CustomCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Qiymətləndirmə Növü & Bal Daxil Etmə',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),

                  // Assessment Type Dropdown
                  DropdownButtonFormField<AssessmentType>(
                    initialValue: _assessmentType,
                    decoration: const InputDecoration(labelText: 'Qiymətləndirmə Tipi'),
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
                      prefixIcon: const Icon(Icons.grade_rounded, color: AppColors.primary),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Feedback Header & Voice-to-Text Trigger
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Pedaqoji Rəy & Şərh',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      TextButton.icon(
                        onPressed: _simulateVoiceToText,
                        icon: Icon(
                          _isVoiceRecording ? Icons.stop_circle_rounded : Icons.mic_rounded,
                          color: _isVoiceRecording ? Colors.red : AppColors.primary,
                          size: 18,
                        ),
                        label: Text(
                          _isVoiceRecording ? 'Yazılır...' : 'Səslə Rəy Yaz',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: _isVoiceRecording ? Colors.red : AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  TextField(
                    controller: _feedbackController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Şagirdin dərslərdəki fəallığı və tərəqqisi barədə rəy daxil edin...',
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Save Grade Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
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
                      icon: const Icon(Icons.save_rounded),
                      label: const Text('Qiyməti Rəsmi Jurnala Daxil Et'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemToggleBtn(int index, String label) {
    final isSelected = _selectedAssessmentSystem == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedAssessmentSystem = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.cardBorder),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
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
      child: ChoiceChip(
        label: Text('$cls ($count)'),
        selected: isSelected,
        selectedColor: AppColors.primary,
        backgroundColor: const Color(0xFFF1F5F9),
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
          fontSize: 12,
        ),
        onSelected: (_) {
          setState(() {
            _selectedClassFilter = cls;
            _selectedStudent = null; // Reset student selection on class change
          });
        },
      ),
    );
  }
}
