import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/app_state.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/models/student_model.dart';

class SendNotificationDialog extends StatefulWidget {
  final StudentProfile? directStudent; // Optional: If sending direct note to a specific student/parent
  final String? initialClass; // Optional: default class

  const SendNotificationDialog({
    super.key,
    this.directStudent,
    this.initialClass,
  });

  @override
  State<SendNotificationDialog> createState() => _SendNotificationDialogState();
}

class _SendNotificationDialogState extends State<SendNotificationDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();

  String _adminTargetGroup = 'all'; // 'all', 'teachers', 'students', 'parents', 'custom_classes'
  final Set<String> _selectedClasses = {};
  String _teacherRecipientType = 'parent_and_student'; // 'parent', 'student', 'parent_and_student'
  String _selectedClassForTeacher = '';
  String _priority = 'normal'; // 'normal', 'important', 'urgent'
  bool _isSending = false;

  final List<String> _allClasses = ['9A', '9B', '10A', '10B', '11A', '11B', '8A', '8B', '7A', '7B', '6A', '6B', '5A', '5B'];

  final List<String> _quickTemplates = [
    'Dərsə gecikmə və davamiyyət xəbərdarlığı',
    'Ev tapşırıqlarının təhvili haqqında qeyd',
    'Dərsdə yüksək fəallıq və əla nəticə',
    'Yaxınlaşan KSQ / BSQ imtahanı haqqında',
    'Fərdi valideyn məsləhətləşməsi tələb olunur',
  ];

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    final user = appState.currentUser;

    if (widget.directStudent != null) {
      _titleController.text = 'Şagird haqqında məlumat: ${widget.directStudent!.fullName}';
    } else if (user?.role == UserRole.teacher) {
      _titleController.text = '${user?.subject ?? "Fənn"} Dərsi Üzrə Qeyd';
      if (user?.assignedClasses.isNotEmpty == true) {
        _selectedClassForTeacher = widget.initialClass ?? user!.assignedClasses.first;
      } else {
        _selectedClassForTeacher = '9B';
      }
    } else {
      _titleController.text = 'İdrak Liseyi Rəsmi Elanı';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitSend() async {
    if (!_formKey.currentState!.validate()) return;
    final appState = Provider.of<AppState>(context, listen: false);
    final user = appState.currentUser;

    setState(() => _isSending = true);

    try {
      if (widget.directStudent != null) {
        // Direct Teacher -> Student / Parent
        final std = widget.directStudent!;
        List<String> targetRoles = [];
        if (_teacherRecipientType == 'parent') targetRoles = ['parent'];
        if (_teacherRecipientType == 'student') targetRoles = ['student'];
        if (_teacherRecipientType == 'parent_and_student') targetRoles = ['parent', 'student'];

        await appState.sendNotification(
          title: _titleController.text.trim(),
          message: _messageController.text.trim(),
          category: NotificationCategory.teacherDirect,
          targetStudentId: std.id,
          targetStudentName: std.fullName,
          targetParentId: null, // Will match parent by linked student
          targetClasses: [std.className],
          targetRoles: targetRoles,
          priority: _priority,
        );
      } else if (user?.role == UserRole.teacher) {
        // Teacher class broadcast
        List<String> targetRoles = [];
        if (_teacherRecipientType == 'parent') targetRoles = ['parent'];
        if (_teacherRecipientType == 'student') targetRoles = ['student'];
        if (_teacherRecipientType == 'parent_and_student') targetRoles = ['parent', 'student'];

        await appState.sendNotification(
          title: _titleController.text.trim(),
          message: _messageController.text.trim(),
          category: NotificationCategory.classBroadcast,
          targetClasses: [_selectedClassForTeacher],
          targetRoles: targetRoles,
          priority: _priority,
        );
      } else {
        // Admin broadcast
        List<String> targetRoles = [];
        List<String> targetClasses = [];

        if (_adminTargetGroup == 'all') {
          targetRoles = []; // All
          targetClasses = [];
        } else if (_adminTargetGroup == 'teachers') {
          targetRoles = ['teacher'];
        } else if (_adminTargetGroup == 'students') {
          targetRoles = ['student'];
        } else if (_adminTargetGroup == 'parents') {
          targetRoles = ['parent'];
        } else if (_adminTargetGroup == 'custom_classes') {
          targetClasses = _selectedClasses.toList();
          targetRoles = ['student', 'parent'];
        }

        await appState.sendNotification(
          title: _titleController.text.trim(),
          message: _messageController.text.trim(),
          category: _priority == 'urgent' ? NotificationCategory.emergency : NotificationCategory.general,
          targetClasses: targetClasses,
          targetRoles: targetRoles,
          priority: _priority,
        );
      }

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bildiriş uğurla göndərildi!'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xəta baş verdi: $e'), backgroundColor: AppColors.danger),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser;
    final isDirectStudent = widget.directStudent != null;
    final isTeacher = user?.role == UserRole.teacher;

    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 680),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF0F172A),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withAlpha(30),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded, color: AppColors.goldLight, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isDirectStudent
                              ? 'Valideyn ilə Əlaqə & Bildiriş'
                              : (isTeacher ? 'Sinifə Bildiriş Göndər' : 'Rəsmi Lisey Bildirişi Göndər'),
                          style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          isDirectStudent
                              ? '${widget.directStudent!.fullName} • ${widget.directStudent!.className}'
                              : (isTeacher ? '${user?.fullName} • ${user?.subject ?? "Müəllim"}' : 'İnzibatçı / Rəhbərlik Paneli'),
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Form Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Direct Student Banner
                      if (isDirectStudent) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                onBackgroundImageError: (e, s) {},
                                backgroundImage: NetworkImage(widget.directStudent!.photoUrl),
                                child: null, // No overlay icon
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.directStudent!.fullName,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                    Text(
                                      'Valideyn: ${widget.directStudent!.parentName} (${widget.directStudent!.parentPhone})',
                                      style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Target Selection (Teacher or Admin)
                      if (!isDirectStudent && isTeacher) ...[
                        const Text('Hansı Sinifə Göndərilsin?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 8,
                          children: (user?.assignedClasses.isNotEmpty == true ? user!.assignedClasses : _allClasses.take(4).toList()).map((cls) {
                            final isSel = _selectedClassForTeacher == cls;
                            return ChoiceChip(
                              label: Text(cls, style: TextStyle(color: isSel ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.bold)),
                              selected: isSel,
                              selectedColor: AppColors.primary,
                              onSelected: (_) => setState(() => _selectedClassForTeacher = cls),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 14),
                      ],

                      if (!isDirectStudent && !isTeacher) ...[
                        // Admin target selection
                        const Text('Kimlərə Göndərilsin?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            ChoiceChip(
                              label: const Text('🌍 Hamıya (Bütün Lisey)'),
                              selected: _adminTargetGroup == 'all',
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(color: _adminTargetGroup == 'all' ? Colors.white : AppColors.textPrimary, fontSize: 11),
                              onSelected: (_) => setState(() => _adminTargetGroup = 'all'),
                            ),
                            ChoiceChip(
                              label: const Text('👨‍🏫 Müəllimlərə'),
                              selected: _adminTargetGroup == 'teachers',
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(color: _adminTargetGroup == 'teachers' ? Colors.white : AppColors.textPrimary, fontSize: 11),
                              onSelected: (_) => setState(() => _adminTargetGroup = 'teachers'),
                            ),
                            ChoiceChip(
                              label: const Text('🎓 Şagirdlərə'),
                              selected: _adminTargetGroup == 'students',
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(color: _adminTargetGroup == 'students' ? Colors.white : AppColors.textPrimary, fontSize: 11),
                              onSelected: (_) => setState(() => _adminTargetGroup = 'students'),
                            ),
                            ChoiceChip(
                              label: const Text('👨‍👩‍👧 Valideynlərə'),
                              selected: _adminTargetGroup == 'parents',
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(color: _adminTargetGroup == 'parents' ? Colors.white : AppColors.textPrimary, fontSize: 11),
                              onSelected: (_) => setState(() => _adminTargetGroup = 'parents'),
                            ),
                            ChoiceChip(
                              label: const Text('🏫 Xüsusi Siniflər'),
                              selected: _adminTargetGroup == 'custom_classes',
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(color: _adminTargetGroup == 'custom_classes' ? Colors.white : AppColors.textPrimary, fontSize: 11),
                              onSelected: (_) => setState(() => _adminTargetGroup = 'custom_classes'),
                            ),
                          ],
                        ),
                        if (_adminTargetGroup == 'custom_classes') ...[
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: _allClasses.map((cls) {
                              final isSel = _selectedClasses.contains(cls);
                              return FilterChip(
                                label: Text(cls, style: TextStyle(color: isSel ? Colors.white : AppColors.textPrimary, fontSize: 11)),
                                selected: isSel,
                                selectedColor: AppColors.primaryAccent,
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
                        const SizedBox(height: 14),
                      ],

                      // Recipient Role Selection for Teacher
                      if (isTeacher || isDirectStudent) ...[
                        const Text('Qəbul Edən Tərəf:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            ChoiceChip(
                              label: const Text('👨‍👩‍👧 Valideyn', style: TextStyle(fontSize: 11)),
                              selected: _teacherRecipientType == 'parent',
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(color: _teacherRecipientType == 'parent' ? Colors.white : AppColors.textPrimary),
                              onSelected: (_) => setState(() => _teacherRecipientType = 'parent'),
                            ),
                            ChoiceChip(
                              label: const Text('🎓 Şagird', style: TextStyle(fontSize: 11)),
                              selected: _teacherRecipientType == 'student',
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(color: _teacherRecipientType == 'student' ? Colors.white : AppColors.textPrimary),
                              onSelected: (_) => setState(() => _teacherRecipientType = 'student'),
                            ),
                            ChoiceChip(
                              label: const Text('👥 Hər İkisi', style: TextStyle(fontSize: 11)),
                              selected: _teacherRecipientType == 'parent_and_student',
                              selectedColor: AppColors.primary,
                              labelStyle: TextStyle(color: _teacherRecipientType == 'parent_and_student' ? Colors.white : AppColors.textPrimary),
                              onSelected: (_) => setState(() => _teacherRecipientType = 'parent_and_student'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Title Input
                      const Text('Başlıq / Mövzu *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _titleController,
                        decoration: InputDecoration(
                          hintText: 'məs: Riyaziyyat dərsi üzrə həftəlik rəy',
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Başlığı qeyd edin' : null,
                      ),

                      const SizedBox(height: 14),

                      // Quick Templates
                      Text('Sürətli Şablonlar:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 34,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _quickTemplates.length,
                          separatorBuilder: (c, i) => const SizedBox(width: 6),
                          itemBuilder: (ctx, idx) {
                            return ActionChip(
                              label: Text(_quickTemplates[idx], style: const TextStyle(fontSize: 10)),
                              backgroundColor: AppColors.primary.withAlpha(15),
                              onPressed: () {
                                setState(() {
                                  _titleController.text = _quickTemplates[idx];
                                  if (_messageController.text.isEmpty) {
                                    _messageController.text = 'Hörmətli valideyn, ${_quickTemplates[idx].toLowerCase()} ilə əlaqədar diqqət yetirməyinizi xahiş edirik.';
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Message Body
                      const Text('Bildiriş Mətni *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _messageController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Valideynə və ya şagirdə çatdırmaq istədiyiniz mesajı ətraflı yazın...',
                          filled: true,
                          fillColor: AppColors.background,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Mesaj mətnini yazın' : null,
                      ),

                      const SizedBox(height: 14),

                      // Priority
                      const Text('Dərəcə / Vaciblik:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          ChoiceChip(
                            label: const Text('Adi (Normal)'),
                            selected: _priority == 'normal',
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(color: _priority == 'normal' ? Colors.white : AppColors.textPrimary, fontSize: 11),
                            onSelected: (_) => setState(() => _priority = 'normal'),
                          ),
                          ChoiceChip(
                            label: const Text('⚠️ Vacib'),
                            selected: _priority == 'important',
                            selectedColor: AppColors.goldDark,
                            labelStyle: TextStyle(color: _priority == 'important' ? Colors.white : AppColors.textPrimary, fontSize: 11),
                            onSelected: (_) => setState(() => _priority = 'important'),
                          ),
                          ChoiceChip(
                            label: const Text('🚨 Təcili'),
                            selected: _priority == 'urgent',
                            selectedColor: AppColors.danger,
                            labelStyle: TextStyle(color: _priority == 'urgent' ? Colors.white : AppColors.textPrimary, fontSize: 11),
                            onSelected: (_) => setState(() => _priority = 'urgent'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Submit Button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _isSending ? null : _submitSend,
                  icon: _isSending
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.send_rounded, color: Colors.white),
                  label: Text(
                    _isSending ? 'Göndərilir...' : 'Bildirişi Göndər',
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
