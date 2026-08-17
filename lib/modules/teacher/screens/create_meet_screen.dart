import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../providers/app_state.dart';
import '../../shared/screens/voice_room_screen.dart';

class CreateMeetScreen extends StatefulWidget {
  const CreateMeetScreen({super.key});

  @override
  State<CreateMeetScreen> createState() => _CreateMeetScreenState();
}

class _CreateMeetScreenState extends State<CreateMeetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subjectController = TextEditingController();

  final List<String> _availableClasses = [
    '9A', '9B', '10A', '10B', '11A', '11B', '8A', '8B', '7A', '7B', '6A', '6B', '5A', '5B'
  ];
  final Set<String> _selectedClasses = {};

  bool _allowAllClasses = false;
  bool _allowTeachers = true;
  bool _allowStudents = true;
  bool _isLiveNow = true;
  DateTime? _scheduledTime;
  bool _isCreating = false;

  final List<String> _quickSubjects = [
    'Riyaziyyat', 'Fizika', 'Kimya', 'Biologiya', 'Azərbaycan dili', 'İngilis dili', 'Tarix', 'İnformatika'
  ];

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    final user = appState.currentUser;
    if (user?.subject != null && user!.subject!.isNotEmpty) {
      _subjectController.text = user.subject!;
    } else {
      _subjectController.text = 'Riyaziyyat';
    }
    if (user?.assignedClasses.isNotEmpty == true) {
      _selectedClasses.addAll(user!.assignedClasses);
    } else {
      _selectedClasses.add('9B');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  Future<void> _pickScheduleTime() async {
    final now = DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
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
    if (pickedDate == null || !mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime == null || !mounted) return;

    setState(() {
      _scheduledTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      _isLiveNow = false;
    });
  }

  Future<void> _submitCreate() async {
    if (!_formKey.currentState!.validate()) return;
    if (_allowStudents && !_allowAllClasses && _selectedClasses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Zəhmət olmasa ən azı bir sinif seçin və ya "Bütün Siniflər"i aktiv edin.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final room = await appState.createMeetRoom(
        title: _titleController.text.trim(),
        subject: _subjectController.text.trim(),
        targetClasses: _allowAllClasses ? [] : _selectedClasses.toList(),
        allowTeachers: _allowTeachers,
        allowStudents: _allowStudents,
        scheduledTime: _isLiveNow ? null : _scheduledTime,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${room.title}" görüş otağı uğurla yaradıldı!'),
          backgroundColor: AppColors.success,
        ),
      );

      // Navigate directly to the voice room
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => VoiceRoomScreen(room: room),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Xəta baş verdi: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1A1B2E), Color(0xFF0D9488), Color(0xFF14B8A6)],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -15,
                      bottom: -15,
                      child: Icon(Icons.video_call_rounded, size: 130, color: Colors.white.withAlpha(10)),
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
                                  child: const Icon(Icons.mic_external_on_rounded, size: 22, color: Colors.white),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Meet İdrak Otaq',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Real-vaxt interaktiv səsli dərslər',
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Input Card
                    Container(
                      padding: const EdgeInsets.all(18),
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
                                  color: AppColors.primaryAccent.withAlpha(12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.title_rounded, color: AppColors.primaryAccent, size: 16),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Görüşün Mövzusu / Başlığı *',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _titleController,
                            decoration: InputDecoration(
                              hintText: 'məs: Riyaziyyat: Triqonometriya Canlı Müzakirə',
                              hintStyle: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                              prefixIcon: const Icon(Icons.subtitles_rounded, color: AppColors.primaryAccent, size: 20),
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
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Mövzunu qeyd edin' : null,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Subject Input & Quick Selection Card
                    Container(
                      padding: const EdgeInsets.all(18),
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
                                  color: AppColors.primaryAccent.withAlpha(12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.menu_book_rounded, color: AppColors.primaryAccent, size: 16),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Fənn / Kateqoriya *',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _subjectController,
                            decoration: InputDecoration(
                              hintText: 'Fənni daxil edin',
                              hintStyle: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                              prefixIcon: const Icon(Icons.category_rounded, color: AppColors.primaryAccent, size: 20),
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
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'Fənni qeyd edin' : null,
                          ),
                          const SizedBox(height: 12),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Row(
                              children: _quickSubjects.map((sub) {
                                final isSelected = _subjectController.text.trim() == sub;
                                return Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: GestureDetector(
                                    onTap: () => setState(() => _subjectController.text = sub),
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
                                        sub,
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
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Participation & Target Permissions Card
                    Container(
                      padding: const EdgeInsets.all(18),
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
                                  color: AppColors.primaryAccent.withAlpha(12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.security_rounded, color: AppColors.primaryAccent, size: 16),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'İştirakçılar və Giriş İcazələri',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Allow Teachers Toggle
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Digər Müəllimlər Qoşula Bilsin', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                            subtitle: Text('Kafedra və lisey müəllimlərinin dəvətsiz girişi', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            value: _allowTeachers,
                            activeThumbColor: AppColors.primaryAccent,
                            onChanged: (v) => setState(() => _allowTeachers = v),
                          ),

                          Divider(height: 1, color: AppColors.cardBorder),

                          // Allow Students Toggle
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Şagirdlər Qoşula Bilsin', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                            subtitle: Text('Təyin olunmuş siniflərin şagirdlərinə açıq olsun', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            value: _allowStudents,
                            activeThumbColor: AppColors.primaryAccent,
                            onChanged: (v) => setState(() => _allowStudents = v),
                          ),

                          if (_allowStudents) ...[
                            const SizedBox(height: 12),
                            Text(
                              'Hansı Siniflər Qoşula Bilər?',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5, color: AppColors.textPrimary),
                            ),
                            const SizedBox(height: 8),

                            CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Bütün Siniflər (Ümumi Dərs / Seminar)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                              value: _allowAllClasses,
                              activeColor: AppColors.primaryAccent,
                              onChanged: (v) {
                                setState(() {
                                  _allowAllClasses = v ?? false;
                                });
                              },
                            ),

                            if (!_allowAllClasses) ...[
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _availableClasses.map((cls) {
                                  final isSel = _selectedClasses.contains(cls);
                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        if (isSel) {
                                          _selectedClasses.remove(cls);
                                        } else {
                                          _selectedClasses.add(cls);
                                        }
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                      decoration: BoxDecoration(
                                        color: isSel ? AppColors.primaryAccent : AppColors.background,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: isSel ? AppColors.primaryAccent : AppColors.cardBorder,
                                        ),
                                      ),
                                      child: Text(
                                        cls,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: isSel ? Colors.white : AppColors.textPrimary,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Timing: Live Now vs Scheduled Card
                    Container(
                      padding: const EdgeInsets.all(18),
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
                                  color: AppColors.primaryAccent.withAlpha(12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.schedule_rounded, color: AppColors.primaryAccent, size: 16),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Görüşün Vaxtı',
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: AppColors.textPrimary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() => _isLiveNow = true),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: _isLiveNow ? AppColors.success.withAlpha(15) : AppColors.background,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: _isLiveNow ? AppColors.success : AppColors.cardBorder,
                                        width: _isLiveNow ? 1.5 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.play_circle_fill_rounded, color: _isLiveNow ? AppColors.success : AppColors.textSecondary, size: 18),
                                        const SizedBox(width: 6),
                                        Text(
                                          'İndi Canlı Başlat',
                                          style: TextStyle(
                                            color: _isLiveNow ? AppColors.success : AppColors.textPrimary,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: GestureDetector(
                                  onTap: _pickScheduleTime,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: !_isLiveNow ? AppColors.primaryAccent.withAlpha(15) : AppColors.background,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: !_isLiveNow ? AppColors.primaryAccent : AppColors.cardBorder,
                                        width: !_isLiveNow ? 1.5 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.calendar_today_rounded, color: !_isLiveNow ? AppColors.primaryAccent : AppColors.textSecondary, size: 16),
                                        const SizedBox(width: 6),
                                        Text(
                                          _scheduledTime != null
                                              ? '${_scheduledTime!.hour.toString().padLeft(2, '0')}:${_scheduledTime!.minute.toString().padLeft(2, '0')}'
                                              : 'Planlaşdır',
                                          style: TextStyle(
                                            color: !_isLiveNow ? AppColors.primaryAccent : AppColors.textPrimary,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D9488),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        onPressed: _isCreating ? null : _submitCreate,
                        icon: _isCreating
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.video_call_rounded, color: Colors.white, size: 22),
                        label: Text(
                          _isCreating ? 'Otaq Hazırlanır...' : (_isLiveNow ? 'Canlı Otağı Başlat & Daxil Ol' : 'Planlaşdırılmış Dərsi Yadda Saxla'),
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
