import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/app_state.dart';
import '../../../data/models/timetable_model.dart';
import 'smart_attendance_screen.dart';

class ManageTimetableScreen extends StatefulWidget {
  const ManageTimetableScreen({super.key});

  @override
  State<ManageTimetableScreen> createState() => _ManageTimetableScreenState();
}

class _ManageTimetableScreenState extends State<ManageTimetableScreen> {
  String _selectedClass = '9B';
  int _selectedDayIndex = 0;

  final List<String> _daysList = [
    'Bazar ertəsi',
    'Çərşənbə axşamı',
    'Çərşənbə',
    'Cümə axşamı',
    'Cümə',
  ];

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    final teacherClasses = appState.currentTeacherClasses;
    if (teacherClasses.isNotEmpty) {
      _selectedClass = teacherClasses.first;
    } else if (appState.allDistinctClasses.isNotEmpty) {
      _selectedClass = appState.allDistinctClasses.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final distinctClasses = appState.allDistinctClasses;
    final timetable = appState.getClassTimetable(_selectedClass);
    final currentDayTimetable = timetable.firstWhere(
      (d) => d.dayName == _daysList[_selectedDayIndex],
      orElse: () => DayTimetable(dayName: _daysList[_selectedDayIndex], shortDay: '', lessons: []),
    );

    final isMyClaimedClass = appState.currentTeacherClasses.contains(_selectedClass);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Dərs Cədvəli İdarəsi & Siniflər'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_business_rounded),
            tooltip: 'Sinif Sahiplən',
            onPressed: () => _showClaimClassDialog(context, appState),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddLessonDialog(context, appState),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Dərs Əlavə Et', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Class Switcher & Claim Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tədris Olunan Sinif:',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      onPressed: () => _showClaimClassDialog(context, appState),
                      icon: const Icon(Icons.class_rounded, size: 16),
                      label: const Text('Sinif Əlavə Et / Sahiplən', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: distinctClasses.map((cls) {
                      final isSelected = _selectedClass == cls;
                      final isClaimed = appState.currentTeacherClasses.contains(cls);
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          avatar: isClaimed ? const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.gold) : null,
                          label: Text(cls),
                          selected: isSelected,
                          onSelected: (val) {
                            if (val) setState(() => _selectedClass = cls);
                          },
                          selectedColor: AppColors.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                          backgroundColor: Colors.white,
                          side: BorderSide(color: isSelected ? AppColors.primary : AppColors.cardBorder),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Ownership Status Banner
          if (isMyClaimedClass)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              color: AppColors.success.withAlpha(20),
              child: Row(
                children: [
                  const Icon(Icons.verified_rounded, color: AppColors.success, size: 16),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'Bu sinifdə tədris edirsiniz: Cədvələ dərs əlavə etdikdə şagird və valideynlərdə dərhal görünəcək.',
                      style: TextStyle(fontSize: 11, color: AppColors.success, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),

          // Days Tabs
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_daysList.length, (index) {
                  final isSelected = _selectedDayIndex == index;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(_daysList[index]),
                      selected: isSelected,
                      onSelected: (val) {
                        if (val) setState(() => _selectedDayIndex = index);
                      },
                      selectedColor: AppColors.primaryAccent,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                      backgroundColor: AppColors.background,
                      side: BorderSide(color: isSelected ? AppColors.primaryAccent : AppColors.cardBorder),
                    ),
                  );
                }),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Lessons List for selected day
          Expanded(
            child: currentDayTimetable.lessons.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.event_note_rounded, size: 56, color: AppColors.textMuted),
                          const SizedBox(height: 12),
                          Text(
                            '$_selectedClass sinfi üçün ${_daysList[_selectedDayIndex]} gününə dərs əlavə edilməyib.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Aşağıdakı "+ Dərs Əlavə Et" düyməsinə basaraq dərsin saatını, otağını və fənnini qeyd edin.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 4, bottom: 80),
                    itemCount: currentDayTimetable.lessons.length,
                    itemBuilder: (context, index) {
                      final slot = currentDayTimetable.lessons[index];
                      return _buildLessonSlotCard(context, appState, slot, index);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonSlotCard(BuildContext context, AppState appState, LessonSlot slot, int index) {
    final currentUser = appState.currentUser;
    final currentTeacherName = currentUser?.fullName.trim().toLowerCase() ?? '';
    final isAdmin = currentUser?.role == UserRole.admin;

    // Check if this lesson slot belongs to the currently logged in teacher
    final slotTeacherClean = slot.teacher.trim().toLowerCase();
    final isMyLesson = isAdmin || (
      currentTeacherName.isNotEmpty && (
        slotTeacherClean == currentTeacherName ||
        slotTeacherClean.contains(currentTeacherName) ||
        currentTeacherName.contains(slotTeacherClean)
      )
    );

    final isLocked = appState.isAttendanceLocked(_selectedClass, slot.subject);

    final color = slot.subjectColor;
    final icon = slot.subjectIcon;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isLocked ? const Color(0xFFF8FAFC) : (isMyLesson ? Colors.white : const Color(0xFFFAFAFA)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLocked ? AppColors.cardBorder : (isMyLesson ? color : AppColors.cardBorder),
          width: isMyLesson ? 1.8 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isMyLesson ? color.withAlpha(30) : Colors.black.withAlpha(6),
            blurRadius: isMyLesson ? 10 : 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            if (!isMyLesson) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.lock_rounded, color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Bu dərs "${slot.teacher}" tərəfindən tədris olunur. Davamiyyət qeydiyyatı yalnız fənnin öz müəlliminə aiddir.',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 3),
                ),
              );
              return;
            }

            if (isLocked) {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  title: const Row(
                    children: [
                      Icon(Icons.lock_clock_rounded, color: AppColors.danger),
                      SizedBox(width: 8),
                      Text('Davamiyyət Kilidlənib', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  content: Text(
                    'Bu dərsin (${slot.subject} - $_selectedClass) davamiyyəti artıq təsdiqlənib və 5 dəqiqə keçdiyi üçün rəsmi olaraq kilidlənib.\n\nDəyişiklik yalnız Məktəb İnzibatçısı (Admin) tərəfindən edilə bilər.',
                    style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4),
                  ),
                  actions: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Anladım'),
                    ),
                  ],
                ),
              );
              return;
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SmartAttendanceScreen(
                  targetClass: _selectedClass,
                  targetSubject: slot.subject,
                  targetTime: slot.time,
                ),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left Accent Strip
                  Container(
                    width: 6,
                    color: isLocked ? AppColors.textMuted : color,
                  ),

                  // Card Content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Row: Period, Time, Subject Tag & Action Badge
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: color.withAlpha(20),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      slot.period,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: color,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.schedule_rounded, size: 13, color: AppColors.textSecondary),
                                      const SizedBox(width: 4),
                                      Text(
                                        slot.time,
                                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              if (isLocked)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.textMuted.withAlpha(40),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.textMuted),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.lock_rounded, color: AppColors.textPrimary, size: 11),
                                      SizedBox(width: 4),
                                      Text(
                                        'Kilidli (5 dəq)',
                                        style: TextStyle(color: AppColors.textPrimary, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                )
                              else if (isMyLesson)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.star_rounded, color: AppColors.goldLight, size: 12),
                                      SizedBox(width: 4),
                                      Text(
                                        'Sizin Dərs',
                                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    slot.room,
                                    style: const TextStyle(fontSize: 10, color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                                  ),
                                ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Main Info Row: Icon, Subject Title, Teacher, Room, and Delete Action
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: color.withAlpha(20),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(icon, color: color, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      slot.subject,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                        color: isMyLesson ? AppColors.textPrimary : AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Row(
                                      children: [
                                        Icon(
                                          isMyLesson ? Icons.verified_user_rounded : Icons.person_outline_rounded,
                                          size: 13,
                                          color: isMyLesson ? color : AppColors.textSecondary,
                                        ),
                                        const SizedBox(width: 4),
                                        Expanded(
                                          child: Text(
                                            isMyLesson ? 'SİZ (${slot.teacher})' : slot.teacher,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: isMyLesson ? FontWeight.bold : FontWeight.w500,
                                              color: isMyLesson ? color : AppColors.textSecondary,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          slot.room,
                                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              if (isMyLesson)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 20),
                                  tooltip: 'Dərsi Sil',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    appState.deleteLessonSlotFromClass(
                                      className: _selectedClass,
                                      dayName: _daysList[_selectedDayIndex],
                                      slotIndex: index,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Dərs cədvəldən silindi!'), duration: Duration(seconds: 1)),
                                    );
                                  },
                                ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Bottom Attendance Helper
                          if (isMyLesson && !isLocked)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FDF4),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.success.withAlpha(60)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: const [
                                  Row(
                                    children: [
                                      Icon(Icons.swipe_rounded, color: AppColors.success, size: 14),
                                      SizedBox(width: 6),
                                      Text(
                                        'Davamiyyət qeydiyyatına başlamaq üçün toxunun',
                                        style: TextStyle(color: Color(0xFF15803D), fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF15803D), size: 10),
                                ],
                              ),
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
      ),
    );
  }

  void _showAddLessonDialog(BuildContext context, AppState appState) {
    final periodCtrl = TextEditingController(text: '${appState.getClassTimetable(_selectedClass)[_selectedDayIndex].lessons.length + 1}-ci dərs');
    final timeCtrl = TextEditingController(text: '08:30 - 09:15');
    final subjectCtrl = TextEditingController(text: appState.currentUser?.subject ?? 'Riyaziyyat');
    final roomCtrl = TextEditingController(text: appState.currentUser?.roomNumber ?? 'Otaq 302');
    final teacherCtrl = TextEditingController(text: appState.currentUser?.fullName ?? 'Müəllim');
    String dayName = _daysList[_selectedDayIndex];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text('$_selectedClass Sinfi üçün Dərs Əlavə Et'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: dayName,
                      decoration: const InputDecoration(labelText: 'Tədris Günü'),
                      items: _daysList.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                      onChanged: (v) => setDialogState(() => dayName = v!),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: periodCtrl, decoration: const InputDecoration(labelText: 'Dərs Saatı (Period)'))),
                        const SizedBox(width: 10),
                        Expanded(child: TextField(controller: timeCtrl, decoration: const InputDecoration(labelText: 'Dərsin Vaxtı'))),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(controller: subjectCtrl, decoration: const InputDecoration(labelText: 'Fənn *')),
                    const SizedBox(height: 10),
                    TextField(
                      controller: teacherCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Müəllimin Adı *',
                        helperText: 'Davamiyyəti yalnız bu müəllim apara biləcək',
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(controller: roomCtrl, decoration: const InputDecoration(labelText: 'Otaq / Laboratoriya *')),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Ləğv et')),
                ElevatedButton(
                  onPressed: () {
                    if (subjectCtrl.text.isNotEmpty && teacherCtrl.text.isNotEmpty) {
                      appState.addLessonSlotToClass(
                        className: _selectedClass,
                        dayName: dayName,
                        period: periodCtrl.text.trim(),
                        time: timeCtrl.text.trim(),
                        subject: subjectCtrl.text.trim(),
                        teacherName: teacherCtrl.text.trim(),
                        room: roomCtrl.text.trim(),
                      );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Dərs cədvələ əlavə edildi və Firebase-də saxlanıldı!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  },
                  child: const Text('Əlavə Et'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showClaimClassDialog(BuildContext context, AppState appState) {
    final newClassCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final teacherClasses = appState.currentTeacherClasses;

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Tədris Etdiyim Siniflər'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tədris etdiyiniz sinifləri seçin və ya yeni sinif əlavə edin. Bir sinfi bir neçə müəllim sahiplənə bilər.',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 14),

                    // Available Classes Checkboxes
                    ...appState.allDistinctClasses.map((cls) {
                      final isClaimed = teacherClasses.contains(cls);
                      return CheckboxListTile(
                        value: isClaimed,
                        title: Text(cls, style: const TextStyle(fontWeight: FontWeight.bold)),
                        activeColor: AppColors.primary,
                        onChanged: (val) {
                          if (val == true) {
                            appState.claimClassForTeacher(cls);
                          } else {
                            appState.unclaimClassForTeacher(cls);
                          }
                          setDialogState(() {});
                        },
                      );
                    }),

                    const SizedBox(height: 10),
                    const Divider(),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: newClassCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Yeni Sinif Adı',
                              hintText: 'Məs: 10A, 11B',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: () {
                            if (newClassCtrl.text.trim().isNotEmpty) {
                              final name = newClassCtrl.text.trim();
                              appState.claimClassForTeacher(name);
                              newClassCtrl.clear();
                              setDialogState(() {});
                            }
                          },
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Bağla'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
