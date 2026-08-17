import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/app_state.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/timetable_model.dart';

class CreateTimetableEntryScreen extends StatefulWidget {
  const CreateTimetableEntryScreen({super.key});

  @override
  State<CreateTimetableEntryScreen> createState() => _CreateTimetableEntryScreenState();
}

class _CreateTimetableEntryScreenState extends State<CreateTimetableEntryScreen> with SingleTickerProviderStateMixin {
  int _currentStep = 0;
  AppUser? _selectedTeacher;
  String? _selectedClass;
  String? _selectedDay;
  String? _selectedPeriod;
  final TextEditingController _roomCtrl = TextEditingController();

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  final List<String> _days = [
    'Bazar ertəsi',
    'Çərşənbə axşamı',
    'Çərşənbə',
    'Cümə axşamı',
    'Cümə',
  ];

  final Map<String, String> _lessonPeriods = {
    '1-ci dərs': '08:00 - 08:45',
    '2-ci dərs': '08:55 - 09:40',
    '3-cü dərs': '09:50 - 10:35',
    '4-cü dərs': '10:45 - 11:30',
    '5-ci dərs': '11:40 - 12:25',
    '6-cı dərs': '12:35 - 13:20',
    '7-ci dərs': '13:30 - 14:15',
    '8-ci dərs': '14:25 - 15:10',
  };

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _roomCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final teachers = appState.users.where((u) => u.role == UserRole.teacher).toList();
    final classes = appState.allDistinctClasses;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF0F172A),
              const Color(0xFF1E293B),
              AppColors.primary,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Modern Header
              _buildModernHeader(),

              // Progress Stepper
              _buildProgressStepper(),

              // Content
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    margin: const EdgeInsets.only(top: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    ),
                    child: _buildStepContent(appState, teachers, classes),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withAlpha(25),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '✨ Yeni Dərs Əlavə Et',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Addım ${_currentStep + 1}/5',
                  style: TextStyle(
                    color: Colors.white.withAlpha(180),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStepper() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(5, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < 4 ? 8 : 0),
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: isCompleted || isActive
                    ? AppColors.goldLight
                    : Colors.white.withAlpha(40),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent(AppState appState, List<AppUser> teachers, List<String> classes) {
    switch (_currentStep) {
      case 0:
        return _buildTeacherSelection(teachers);
      case 1:
        return _buildClassSelection(classes);
      case 2:
        return _buildDaySelection();
      case 3:
        return _buildPeriodSelection();
      case 4:
        return _buildRoomAndConfirm(appState);
      default:
        return const SizedBox();
    }
  }

  // ========== ADDIM 1: MÜƏLLİM SEÇİMİ ==========
  Widget _buildTeacherSelection(List<AppUser> teachers) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.person_search_rounded, color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Müəllimi Seçin',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                    Text(
                      'Bu dərsi tədris edəcək müəllim',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (teachers.isEmpty)
            _buildEmptyState('Müəllim yoxdur', 'Əvvəlcə İstifadəçi İdarəsindən müəllim yaradın.')
          else
            ...teachers.map((teacher) => _buildTeacherCard(teacher)),
        ],
      ),
    );
  }

  Widget _buildTeacherCard(AppUser teacher) {
    final isSelected = _selectedTeacher?.id == teacher.id;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                colors: [AppColors.primary, AppColors.primaryAccent],
              )
            : null,
        color: isSelected ? null : AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? Colors.transparent : AppColors.cardBorder,
          width: 2,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppColors.primary.withAlpha(80),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedTeacher = teacher;
              _currentStep = 1;
            });
            _animController.reset();
            _animController.forward();
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: isSelected ? Colors.white.withAlpha(30) : AppColors.primary.withAlpha(30),
                  backgroundImage: teacher.photoUrl != null ? NetworkImage(teacher.photoUrl!) : null,
                  child: teacher.photoUrl == null
                      ? Icon(
                          Icons.person_rounded,
                          size: 28,
                          color: isSelected ? Colors.white : AppColors.primary,
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        teacher.fullName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withAlpha(30)
                              : AppColors.goldDark.withAlpha(25),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          teacher.subject ?? 'Fənn yoxdur',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : AppColors.goldDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 28)
                else
                  Icon(Icons.circle_outlined, color: AppColors.textMuted, size: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ========== ADDIM 2: SİNİF SEÇİMİ ==========
  Widget _buildClassSelection(List<String> classes) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.class_rounded, color: AppColors.primaryAccent, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Sinif Seçin',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                    Text(
                      'Hansı sinfə dərs təyin edilsin',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (classes.isEmpty)
            _buildEmptyState('Sinif yoxdur', 'Əvvəlcə Sinif İdarəsindən sinif yaradın.')
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: classes.map((cls) => _buildClassChip(cls)).toList(),
            ),
          const SizedBox(height: 16),
          _buildBackButton(),
        ],
      ),
    );
  }

  Widget _buildClassChip(String className) {
    final isSelected = _selectedClass == className;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedClass = className;
          _currentStep = 2;
        });
        _animController.reset();
        _animController.forward();
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [AppColors.primaryAccent, const Color(0xFF3B82F6)],
                )
              : null,
          color: isSelected ? null : AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.cardBorder,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryAccent.withAlpha(80),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          className,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  // ========== ADDIM 3: GÜN SEÇİMİ ==========
  Widget _buildDaySelection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.goldDark.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.calendar_today_rounded, color: AppColors.goldDark, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gün Seçin',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                    Text(
                      'Dərsin hansı gündə olacağını seçin',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ..._days.map((day) => _buildDayCard(day)),
          const SizedBox(height: 16),
          _buildBackButton(),
        ],
      ),
    );
  }

  Widget _buildDayCard(String day) {
    final isSelected = _selectedDay == day;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                colors: [AppColors.goldDark, AppColors.gold],
              )
            : null,
        color: isSelected ? null : AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? Colors.transparent : AppColors.cardBorder,
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedDay = day;
              _currentStep = 3;
            });
            _animController.reset();
            _animController.forward();
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Icon(
                  Icons.event_rounded,
                  color: isSelected ? Colors.white : AppColors.goldDark,
                  size: 28,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 26),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ========== ADDIM 4: DƏRS SAATİ SEÇİMİ ==========
  Widget _buildPeriodSelection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.schedule_rounded, color: AppColors.success, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Dərs Saatı Seçin',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                    Text(
                      'Neçənci dərs olacağını seçin',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ..._lessonPeriods.entries.map((entry) => _buildPeriodCard(entry.key, entry.value)),
          const SizedBox(height: 16),
          _buildBackButton(),
        ],
      ),
    );
  }

  Widget _buildPeriodCard(String period, String time) {
    final isSelected = _selectedPeriod == period;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: isSelected
            ? LinearGradient(
                colors: [AppColors.success, const Color(0xFF059669)],
              )
            : null,
        color: isSelected ? null : AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? Colors.transparent : AppColors.cardBorder,
          width: 2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedPeriod = period;
              _currentStep = 4;
            });
            _animController.reset();
            _animController.forward();
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withAlpha(30)
                        : AppColors.success.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.access_time_rounded,
                    color: isSelected ? Colors.white : AppColors.success,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        period,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white.withAlpha(200) : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle_rounded, color: Colors.white, size: 26),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ========== ADDIM 5: OTAQ VƏ TƏSDİQ ==========
  Widget _buildRoomAndConfirm(AppState appState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.meeting_room_rounded, color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Otaq & Təsdiq',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                    ),
                    Text(
                      'Son məlumatlar və təsdiq',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Otaq Input
          TextField(
            controller: _roomCtrl,
            decoration: InputDecoration(
              labelText: 'Otaq / Sinif Nömrəsi',
              hintText: 'məs: 301, Lab-A, 2B',
              prefixIcon: const Icon(Icons.door_front_door_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: AppColors.background,
            ),
          ),

          const SizedBox(height: 24),

          // Xülasə
          _buildSummaryCard(),

          const SizedBox(height: 24),

          // Təsdiq Düyməsi
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 8,
                shadowColor: AppColors.primary.withAlpha(100),
              ),
              onPressed: () => _createTimetableEntry(context, appState),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white, size: 24),
                  SizedBox(width: 10),
                  Text(
                    'Dərsi Əlavə Et',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),
          _buildBackButton(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withAlpha(15),
            AppColors.primaryAccent.withAlpha(10),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.summarize_rounded, color: AppColors.primary, size: 22),
              SizedBox(width: 8),
              Text(
                'Xülasə',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('👤 Müəllim', _selectedTeacher?.fullName ?? '-'),
          _buildSummaryRow('📚 Fənn', _selectedTeacher?.subject ?? '-'),
          _buildSummaryRow('🎓 Sinif', _selectedClass ?? '-'),
          _buildSummaryRow('📅 Gün', _selectedDay ?? '-'),
          _buildSummaryRow('🕐 Saat', _selectedPeriod != null ? '$_selectedPeriod (${_lessonPeriods[_selectedPeriod]})' : '-'),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return TextButton.icon(
      onPressed: () {
        setState(() {
          if (_currentStep > 0) {
            _currentStep--;
            _animController.reset();
            _animController.forward();
          }
        });
      },
      icon: const Icon(Icons.arrow_back_rounded),
      label: const Text('Geri'),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.inbox_rounded, size: 64, color: AppColors.textMuted),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  void _createTimetableEntry(BuildContext context, AppState appState) {
    // Validasiya
    if (_selectedTeacher == null || _selectedClass == null || _selectedDay == null || _selectedPeriod == null) {
      _showModernError(context, 'Bütün məlumatları doldurun!', 'Zəhmət olmasa bütün addımları tamamlayın.');
      return;
    }

    if (_roomCtrl.text.trim().isEmpty) {
      _showModernError(context, 'Otaq nömrəsi lazımdır!', 'Otaq və ya sinif nömrəsini daxil edin.');
      return;
    }

    final timeRange = _lessonPeriods[_selectedPeriod]!;

    // KONFLIKT YOXLAMASI
    final conflictResult = appState.checkTimetableConflict(
      className: _selectedClass!,
      day: _selectedDay!,
      time: timeRange,
      teacherId: _selectedTeacher!.id,
    );

    if (conflictResult != null) {
      _showModernConflict(context, conflictResult);
      return;
    }

    // Dərsi əlavə et
    final newLesson = LessonSlot(
      period: _selectedPeriod!,
      time: timeRange,
      subject: _selectedTeacher!.subject ?? 'Dərs',
      teacher: _selectedTeacher!.fullName,
      room: _roomCtrl.text.trim(),
      teacherId: _selectedTeacher!.id,
      teacherPhotoUrl: _selectedTeacher!.photoUrl,
    );

    appState.addLessonToClassTimetable(
      className: _selectedClass!,
      day: _selectedDay!,
      lesson: newLesson,
    );

    // Uğur animasiyası
    _showModernSuccess(context);
  }

  void _showModernError(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, AppColors.danger.withAlpha(10)],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.danger.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 48),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Bağla', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showModernConflict(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, AppColors.warning.withAlpha(10)],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 56),
              ),
              const SizedBox(height: 20),
              const Text(
                '⚠️ Cədvəl Konflikti',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withAlpha(15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.warning.withAlpha(60)),
                ),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14, height: 1.5),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(ctx),
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                label: const Text('Geri Qayıt', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showModernSuccess(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, AppColors.success.withAlpha(10)],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.success.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 64),
              ),
              const SizedBox(height: 24),
              const Text(
                '🎉 Dərs Uğurla Əlavə Edildi!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              Text(
                'Dərs cədvəli yeniləndi və şagirdlər üçün görünəcək.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.done_all_rounded, color: Colors.white),
                label: const Text('Tamamdır', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
