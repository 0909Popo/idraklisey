import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_card.dart';
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
      appBar: AppBar(
        title: const Text('Yeni Görüş / Dərs Yarat'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Banner
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0D9488)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(20),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.mic_external_on_rounded, color: AppColors.goldLight, size: 28),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Meet İdrak Səsli Otaq',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Gecikməsiz real-vaxt səsli interaktiv dərs və toplantı',
                            style: TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Title Input
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Görüşün Mövzusu / Başlığı *',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'məs: Riyaziyyat: Triqonometriya Canlı Müzakirə',
                        prefixIcon: const Icon(Icons.title_rounded, color: AppColors.primary),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Mövzunu qeyd edin' : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Subject Input & Quick Selection
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fənn / Kateqoriya *',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _subjectController,
                      decoration: InputDecoration(
                        hintText: 'Fənni daxil edin',
                        prefixIcon: const Icon(Icons.menu_book_rounded, color: AppColors.primary),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Fənni qeyd edin' : null,
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _quickSubjects.map((sub) {
                        final isSelected = _subjectController.text.trim() == sub;
                        return ChoiceChip(
                          label: Text(sub, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : AppColors.textPrimary)),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          onSelected: (_) {
                            setState(() {
                              _subjectController.text = sub;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Participation & Target Permissions
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.security_rounded, color: AppColors.primaryAccent, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'İştirakçılar və Giriş İcazələri',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Allow Teachers Toggle
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Digər Müəllimlər Qoşula Bilsin', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: const Text('Kafedra və lisey müəllimlərinin dəvətsiz girişi', style: TextStyle(fontSize: 11)),
                      value: _allowTeachers,
                      activeThumbColor: AppColors.primary,
                      onChanged: (v) => setState(() => _allowTeachers = v),
                    ),

                    const Divider(height: 1),

                    // Allow Students Toggle
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Şagirdlər Qoşula Bilsin', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      subtitle: const Text('Təyin olunmuş siniflərin şagirdlərinə açıq olsun', style: TextStyle(fontSize: 11)),
                      value: _allowStudents,
                      activeThumbColor: AppColors.primary,
                      onChanged: (v) => setState(() => _allowStudents = v),
                    ),

                    if (_allowStudents) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Hansı Siniflər Qoşula Bilər?',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),

                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Bütün Siniflər (Ümumi Dərs / Seminar)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                        value: _allowAllClasses,
                        activeColor: AppColors.primary,
                        onChanged: (v) {
                          setState(() {
                            _allowAllClasses = v ?? false;
                          });
                        },
                      ),

                      if (!_allowAllClasses) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _availableClasses.map((cls) {
                            final isSel = _selectedClasses.contains(cls);
                            return FilterChip(
                              label: Text(
                                cls,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSel ? Colors.white : AppColors.textPrimary,
                                ),
                              ),
                              selected: isSel,
                              selectedColor: AppColors.primaryAccent,
                              checkmarkColor: Colors.white,
                              onSelected: (sel) {
                                setState(() {
                                  if (sel) {
                                    _selectedClasses.add(cls);
                                  } else {
                                    _selectedClasses.remove(cls);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Timing: Live Now vs Scheduled
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Görüşün Vaxtı',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: _isLiveNow ? AppColors.success.withAlpha(20) : null,
                              side: BorderSide(color: _isLiveNow ? AppColors.success : AppColors.cardBorder, width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: () => setState(() => _isLiveNow = true),
                            icon: const Icon(Icons.play_circle_fill_rounded, color: AppColors.success),
                            label: Text('İndi Canlı Başlat', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: !_isLiveNow ? AppColors.primary.withAlpha(20) : null,
                              side: BorderSide(color: !_isLiveNow ? AppColors.primary : AppColors.cardBorder, width: 2),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            onPressed: _pickScheduleTime,
                            icon: const Icon(Icons.calendar_today_rounded, color: AppColors.primary),
                            label: Text(
                              _scheduledTime != null ? '${_scheduledTime!.hour.toString().padLeft(2, '0')}:${_scheduledTime!.minute.toString().padLeft(2, '0')}' : 'Planlaşdır',
                              style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
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
                height: 52,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _isCreating ? null : _submitCreate,
                  icon: _isCreating
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.video_call_rounded, color: Colors.white, size: 24),
                  label: Text(
                    _isCreating ? 'Otaq Hazırlanır...' : (_isLiveNow ? 'Canlı Otağı Başlat & Daxil Ol' : 'Planlaşdırılmış Dərsi Yadda Saxla'),
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
