import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
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
      duration: const Duration(milliseconds: 400),
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
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
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
                    color: AppColors.background,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: _buildStepContent(appState, teachers, classes),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withAlpha(15),
              padding: const EdgeInsets.all(8),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Yeni Dərs Əlavə Et',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Addım ${_currentStep + 1} / 5',
                  style: TextStyle(
                    color: Colors.white.withAlpha(180),
                    fontSize: 12,
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
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: EdgeInsets.only(right: index < 4 ? 6 : 0),
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: isCompleted || isActive
                    ? AppColors.goldLight
                    : Colors.white.withAlpha(30),
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
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent.withAlpha(15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.person_search_rounded, color: AppColors.primaryAccent, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Müəllimi Seçin',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                    ),
                    Text(
                      'Bu dərsi tədris edəcək müəllim',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
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
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryAccent.withAlpha(12) : AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected ? AppColors.primaryAccent : AppColors.cardBorder,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [BoxShadow(color: AppColors.primaryAccent.withAlpha(30), blurRadius: 10, offset: const Offset(0, 2))]
            : AppShadows.sm,
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
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.primaryAccent.withAlpha(30)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Container(
                      width: 50,
                      height: 50,
                      color: AppColors.primaryAccent.withAlpha(12),
                      child: teacher.photoUrl != null
                          ? Image.network(
                              teacher.photoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.person_rounded, size: 24, color: AppColors.primaryAccent),
                            )
                          : const Icon(Icons.person_rounded, size: 24, color: AppColors.primaryAccent),
                    ),
                  ),
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
                          color: isSelected ? AppColors.primaryAccent : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.goldDark.withAlpha(15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          teacher.subject ?? 'Fənn yoxdur',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.goldDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle_rounded, color: AppColors.primaryAccent, size: 24)
                else
                  Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 22),
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
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent.withAlpha(15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.class_rounded, color: AppColors.primaryAccent, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sinif Seçin',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                    ),
                    Text(
                      'Hansı sinfə dərs təyin edilsin',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (classes.isEmpty)
            _buildEmptyState('Sinif yoxdur', 'Əvvəlcə Sinif İdarəsindən sinif yaradın.')
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: classes.map((cls) => _buildClassChip(cls)).toList(),
            ),
          const SizedBox(height: 20),
          _buildBackButton(),
        ],
      ),
    );
  }

  Widget _buildClassChip(String className) {
    final isSelected = _selectedClass == className;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedClass = className;
          _currentStep = 2;
        });
        _animController.reset();
        _animController.forward();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryAccent : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryAccent : AppColors.cardBorder,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: AppColors.primaryAccent.withAlpha(30), blurRadius: 8, offset: const Offset(0, 2))]
              : AppShadows.sm,
        ),
        child: Text(
          className,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  // ========== ADDIM 3: GÜN SEÇİMİ ==========
  Widget _buildDaySelection() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.goldDark.withAlpha(15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.calendar_today_rounded, color: AppColors.goldDark, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gün Seçin',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                    ),
                    Text(
                      'Dərsin hansı gündə olacağını seçin',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ..._days.map((day) => _buildDayCard(day)),
          const SizedBox(height: 20),
          _buildBackButton(),
        ],
      ),
    );
  }

  Widget _buildDayCard(String day) {
    final isSelected = _selectedDay == day;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.goldDark.withAlpha(12) : AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected ? AppColors.goldDark : AppColors.cardBorder,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [BoxShadow(color: AppColors.goldDark.withAlpha(25), blurRadius: 8, offset: const Offset(0, 2))]
            : AppShadows.sm,
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
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.goldDark.withAlpha(15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.event_rounded, color: AppColors.goldDark, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    day,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? AppColors.goldDark : AppColors.textPrimary,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle_rounded, color: AppColors.goldDark, size: 24)
                else
                  Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 22),
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
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.success.withAlpha(15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.schedule_rounded, color: AppColors.success, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Dərs Saatı Seçin',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                    ),
                    Text(
                      'Neçənci dərs olacağını seçin',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ..._lessonPeriods.entries.map((entry) => _buildPeriodCard(entry.key, entry.value)),
          const SizedBox(height: 20),
          _buildBackButton(),
        ],
      ),
    );
  }

  Widget _buildPeriodCard(String period, String time) {
    final isSelected = _selectedPeriod == period;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.success.withAlpha(12) : AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected ? AppColors.success : AppColors.cardBorder,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [BoxShadow(color: AppColors.success.withAlpha(25), blurRadius: 8, offset: const Offset(0, 2))]
            : AppShadows.sm,
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
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha(15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.access_time_rounded, color: AppColors.success, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        period,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? AppColors.success : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? AppColors.success : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 24)
                else
                  Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 22),
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
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent.withAlpha(15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.meeting_room_rounded, color: AppColors.primaryAccent, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Otaq & Təsdiq',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                    ),
                    Text(
                      'Son məlumatlar və təsdiq',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Otaq Input
          TextField(
            controller: _roomCtrl,
            decoration: InputDecoration(
              labelText: 'Otaq / Sinif Nömrəsi',
              hintText: 'məs: 301, Lab-A, 2B',
              prefixIcon: const Icon(Icons.door_front_door_rounded, color: AppColors.primaryAccent),
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

          const SizedBox(height: 20),

          // Xülasə
          _buildSummaryCard(),

          const SizedBox(height: 24),

          // Təsdiq Düyməsi
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              onPressed: () => _createTimetableEntry(context, appState),
              icon: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              label: const Text(
                'Dərsi Əlavə Et',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),
          _buildBackButton(),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.primaryAccent.withAlpha(40)),
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
                  color: AppColors.primaryAccent.withAlpha(12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.summarize_rounded, color: AppColors.primaryAccent, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                'Xülasə',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
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
                fontSize: 13,
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
      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 14),
      label: const Text('Geri Qayıt', style: TextStyle(fontWeight: FontWeight.w700)),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(Icons.inbox_rounded, size: 54, color: AppColors.textMuted),
            const SizedBox(height: 14),
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  void _createTimetableEntry(BuildContext context, AppState appState) {
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

    _showModernSuccess(context);
  }

  void _showModernError(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        content: Text(message, style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Bağla', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showModernConflict(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('⚠️ Cədvəl Konflikti', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        content: Text(message, style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4)),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Geri Qayıt', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showModernSuccess(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('🎉 Dərs Uğurla Əlavə Edildi!', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        content: Text(
          'Dərs cədvəli yeniləndi və şagirdlər üçün görünəcək.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Tamamdır', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
