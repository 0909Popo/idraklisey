import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/utils/email_generator.dart';
import '../../../core/widgets/profile_photo_picker.dart';
import '../../../data/models/user_model.dart';
import '../../../providers/app_state.dart';
import '../widgets/credentials_result_dialog.dart';

/// Detallı işçi yaradılması — 4 səhifəli addım-addım forma:
/// 1) Kimlik  2) Əlaqə  3) İş və vəzifə  4) Hesab.
/// Yalnız cari səhifənin sahələri validasiya olunur.
class CreateEmployeeScreen extends StatefulWidget {
  const CreateEmployeeScreen({super.key});

  @override
  State<CreateEmployeeScreen> createState() => _CreateEmployeeScreenState();
}

class _CreateEmployeeScreenState extends State<CreateEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _fatherNameCtrl = TextEditingController();
  final _finCtrl = TextEditingController();
  final _idCardCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _positionCtrl = TextEditingController();
  final _salaryCtrl = TextEditingController();
  final _bankCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _roomCtrl = TextEditingController();
  final _passCtrl = TextEditingController(text: '123456');

  static const _citizenships = ['Azərbaycan', 'Türkiyə', 'Rusiya', 'Gürcüstan', 'Ukrayna', 'İran', 'Digər'];
  static const _educationLevels = ['Orta təhsil', 'Orta ixtisas', 'Bakalavr', 'Magistr', 'PhD / Doktorantura'];

  static const _stepTitles = ['Kimlik', 'Əlaqə', 'İş və Vəzifə', 'Hesab'];

  int _step = 0;
  String _gender = 'Kişi';
  String _citizenship = 'Azərbaycan';
  String _educationLevel = 'Bakalavr';
  DateTime? _birthDate;
  DateTime? _hireDate;
  DateTime? _contractStart;
  DateTime? _contractEnd;
  bool _isTeacher = true;
  String? _selectedRoleId;
  String? _photoUrl;
  bool _saving = false;
  final Set<String> _assignedClasses = {};
  bool _permCafeteria = false;
  bool _permMedical = false;
  bool _permInventory = true;

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppState>();
    if (appState.roles.isEmpty) {
      appState.loadRoles();
    }
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _fatherNameCtrl.dispose();
    _finCtrl.dispose();
    _idCardCtrl.dispose();
    _addressCtrl.dispose();
    _phoneCtrl.dispose();
    _positionCtrl.dispose();
    _salaryCtrl.dispose();
    _bankCtrl.dispose();
    _subjectCtrl.dispose();
    _roomCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  String? _previewEmail(AppState appState) {
    final first = _firstNameCtrl.text.trim();
    final last = _lastNameCtrl.text.trim();
    if (first.isEmpty || last.isEmpty) return '';
    final existing = appState.users
        .map((u) => (u.email ?? '').toLowerCase())
        .where((e) => e.isNotEmpty)
        .toList();
    return EmailGenerator.generateStaffEmail('$first $last', existingEmails: existing);
  }

  Future<void> _pickDate(DateTime? current, int minYearsAgo, int maxYearsAgo, ValueChanged<DateTime> onPicked) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime(now.year - minYearsAgo),
      firstDate: DateTime(now.year - maxYearsAgo),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppColors.primaryAccent),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => onPicked(picked));
  }

  Future<void> _nextOrSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_step < _stepTitles.length - 1) {
      setState(() => _step++);
      return;
    }
    await _submit();
  }

  Future<void> _submit() async {
    final appState = context.read<AppState>();
    setState(() => _saving = true);
    final role = _isTeacher ? null : appState.getRoleById(_selectedRoleId);

    final user = appState.createEmployeeAccount(
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      fatherName: _fatherNameCtrl.text.trim(),
      gender: _gender,
      birthDate: _birthDate,
      finCode: _finCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      citizenship: _citizenship,
      idCardSerial: _idCardCtrl.text.trim(),
      educationLevel: _educationLevel,
      bankName: _bankCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      password: _passCtrl.text.trim(),
      photoUrl: _photoUrl,
      isTeacher: _isTeacher,
      position: _positionCtrl.text.trim(),
      hireDate: _hireDate,
      salary: double.tryParse(_salaryCtrl.text.trim().replaceAll(',', '.')),
      contractStart: _contractStart,
      contractEnd: _contractEnd,
      subject: _isTeacher ? _subjectCtrl.text.trim() : null,
      roomNumber: _isTeacher ? _roomCtrl.text.trim() : null,
      assignedClasses: _assignedClasses.toList(),
      teacherPermissions: _isTeacher
          ? TeacherPermissions(
              canManageCafeteria: _permCafeteria,
              canManageMedical: _permMedical,
              canManageInventory: _permInventory,
            )
          : null,
      assignedRoleId: _isTeacher ? null : _selectedRoleId,
    );
    setState(() => _saving = false);

    if (!mounted) return;
    await showCredentialsResultDialog(
      context: context,
      title: 'İşçi Hesabı Yaradıldı',
      sections: [
        CredentialsSection(title: 'Hesab Məlumatları', rows: [
          MapEntry('Ad Soyad', user.fullName),
          MapEntry('Vəzifə', _isTeacher ? 'Müəllim' : (role?.name ?? 'İşçi')),
          if (user.position != null && user.position!.isNotEmpty) MapEntry('Vəzifə adı', user.position!),
          MapEntry('E-poçt (Login)', user.email ?? ''),
          MapEntry('İstifadəçi adı', user.username),
          MapEntry('FIN kod', user.finCode ?? ''),
          MapEntry('İdrak kodu', user.idrakCode),
          MapEntry('Şifrə', user.password),
        ]),
      ],
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final classes = appState.allDistinctClasses;
    final emailPreview = _previewEmail(appState);
    final dateFormat = DateFormat('dd.MM.yyyy');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Yeni İşçi (${_step + 1}/4): ${_stepTitles[_step]}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          onPressed: () {
            if (_step > 0) {
              setState(() => _step--);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(
            value: (_step + 1) / _stepTitles.length,
            minHeight: 6,
            backgroundColor: Colors.white.withAlpha(30),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryAccent),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            // ── Addım göstəricisi ──
            Row(
              children: [
                for (var i = 0; i < _stepTitles.length; i++) ...[
                  if (i > 0)
                    Expanded(child: Container(height: 3, color: i <= _step ? AppColors.primaryAccent : AppColors.cardBorder)),
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: i <= _step ? AppColors.primaryAccent : AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: i <= _step ? AppColors.primaryAccent : AppColors.cardBorder),
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                          color: i <= _step ? Colors.white : AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _stepTitles[_step],
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ════ ADDIM 1: KİMLİK ════
            if (_step == 0) ...[
              _buildSection(
                icon: Icons.badge_rounded,
                title: 'Şəxsi Məlumatlar',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildText(_firstNameCtrl, 'Ad *', 'Ayşə', icon: Icons.person_rounded, validator: (v) => (v ?? '').trim().isEmpty ? 'Ad tələb olunur' : null)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildText(_lastNameCtrl, 'Soyad *', 'Məmmədova', icon: Icons.person_outline_rounded, validator: (v) => (v ?? '').trim().isEmpty ? 'Soyad tələb olunur' : null)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildText(_fatherNameCtrl, 'Ata adı', 'Eldar', icon: Icons.person_pin_rounded),
                    const SizedBox(height: 14),
                    Text('Cins', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _buildGenderChip('Kişi', Icons.man_rounded),
                        const SizedBox(width: 8),
                        _buildGenderChip('Qadın', Icons.woman_rounded),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text('Doğum Tarixi', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    _buildDateField(
                      date: _birthDate,
                      hint: 'Seçilməyib',
                      icon: Icons.cake_rounded,
                      onTap: () => _pickDate(_birthDate, 30, 75, (d) => _birthDate = d),
                    ),
                    const SizedBox(height: 14),
                    _buildText(
                      _finCtrl,
                      'FIN Kod *',
                      '1234567',
                      icon: Icons.pin_rounded,
                      keyboard: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(7)],
                      validator: (v) {
                        final val = (v ?? '').trim();
                        if (val.isEmpty) return 'FIN kod tələb olunur';
                        if (!RegExp(r'^\d{7}$').hasMatch(val)) return 'FIN kod 7 rəqəmdən ibarət olmalıdır';
                        if (appState.users.any((u) => (u.finCode ?? '') == val)) return 'Bu FIN kod artıq qeydiyyatdadır';
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: _citizenship,
                      decoration: _inputDeco(icon: Icons.flag_rounded).copyWith(labelText: 'Vətəndaşlıq'),
                      items: [
                        for (final c in _citizenships) DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13))),
                      ],
                      onChanged: (v) => setState(() => _citizenship = v!),
                    ),
                    const SizedBox(height: 14),
                    _buildText(
                      _idCardCtrl,
                      'ŞV Seriyası',
                      'AA1234567',
                      icon: Icons.badge_rounded,
                      keyboard: TextInputType.text,
                      inputFormatters: [LengthLimitingTextInputFormatter(12)],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _buildSection(
                icon: Icons.photo_camera_front_rounded,
                title: 'Profil Şəkli',
                child: Center(
                  child: ProfilePhotoPicker(
                    initialPhotoUrl: _photoUrl,
                    onPhotoUploaded: (url) => setState(() => _photoUrl = url),
                    folder: 'idrak/profiles/teachers',
                  ),
                ),
              ),
            ],

            // ════ ADDIM 2: ƏLAQƏ ════
            if (_step == 1) ...[
              _buildSection(
                icon: Icons.contact_mail_rounded,
                title: 'Əlaqə Məlumatları',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildText(_phoneCtrl, 'Telefon', '+994 50 000-00-00', icon: Icons.phone_rounded, keyboard: TextInputType.phone),
                    const SizedBox(height: 14),
                    _buildText(_addressCtrl, 'Yaşadığı Ünvan', 'Bakı, Nərimanov ray., ...', icon: Icons.home_rounded, maxLines: 2),
                    const SizedBox(height: 14),
                    Text('Avtomatik E-poçt (@idrak.edu.az)', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    _buildEmailPreview(emailPreview),
                    const SizedBox(height: 6),
                    Text(
                      'İstifadəçi e-poçt VEYA FIN kod ilə giriş edə biləcək.',
                      style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],

            // ════ ADDIM 3: İŞ VƏ VƏZİFƏ ════
            if (_step == 2) ...[
              _buildSection(
                icon: Icons.work_rounded,
                title: 'Vəzifə və Rol',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildTypeChip(true, 'Müəllim', Icons.psychology_rounded),
                        const SizedBox(width: 8),
                        _buildTypeChip(false, 'Digər İşçi', Icons.badge_rounded),
                      ],
                    ),
                    if (_isTeacher) ...[
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(child: _buildText(_subjectCtrl, 'Fənn *', 'Riyaziyyat', icon: Icons.menu_book_rounded, validator: (v) => (v ?? '').trim().isEmpty ? 'Fənn tələb olunur' : null)),
                          const SizedBox(width: 10),
                          Expanded(child: _buildText(_roomCtrl, 'Otaq', 'Otaq 201', icon: Icons.meeting_room_rounded)),
                        ],
                      ),
                      if (classes.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Text('Təyin Olunan Siniflər', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final cls in classes)
                              FilterChip(
                                label: Text(cls, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                selected: _assignedClasses.contains(cls),
                                onSelected: (v) => setState(() => v ? _assignedClasses.add(cls) : _assignedClasses.remove(cls)),
                                selectedColor: AppColors.primaryAccent.withAlpha(30),
                                checkmarkColor: AppColors.primaryAccent,
                                backgroundColor: AppColors.background,
                                side: BorderSide(
                                  color: _assignedClasses.contains(cls) ? AppColors.primaryAccent : AppColors.cardBorder,
                                ),
                              ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 14),
                      Text('Müəllimə Verilən Yetkilər', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      _buildPermSwitch('Yeməkxana Menyu İdarəsi', _permCafeteria, (v) => setState(() => _permCafeteria = v), AppColors.gold),
                      _buildPermSwitch('Tibbi Qeydlər İdarəsi', _permMedical, (v) => setState(() => _permMedical = v), AppColors.danger),
                      _buildPermSwitch('İnventar & QR Ticketlər', _permInventory, (v) => setState(() => _permInventory = v), AppColors.primaryAccent),
                    ] else ...[
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        value: _selectedRoleId,
                        decoration: _inputDeco(icon: Icons.admin_panel_settings_rounded).copyWith(labelText: 'Rol *'),
                        items: [
                          for (final r in appState.roles)
                            DropdownMenuItem(value: r.id, child: Text('${r.name} (${r.permissionIds.length} səlahiyyət)', style: const TextStyle(fontSize: 13))),
                        ],
                        onChanged: (v) => setState(() => _selectedRoleId = v),
                        validator: (v) => v == null ? 'Rol seçilməlidir' : null,
                      ),
                      if (_selectedRoleId != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          appState.getRoleById(_selectedRoleId)?.description ?? '',
                          style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _buildSection(
                icon: Icons.payments_rounded,
                title: 'İş Müqaviləsi və Əmək Haqqı',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildText(_positionCtrl, 'Vəzifə adı', 'Məs: İT üzrə mütəxəssis', icon: Icons.work_history_rounded),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: _educationLevel,
                      decoration: _inputDeco(icon: Icons.school_rounded).copyWith(labelText: 'Təhsil Dərəcəsi'),
                      items: [
                        for (final e in _educationLevels) DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13))),
                      ],
                      onChanged: (v) => setState(() => _educationLevel = v!),
                    ),
                    const SizedBox(height: 14),
                    _buildText(
                      _bankCtrl,
                      'Bank Adı',
                      'Məs: Kapital Bank',
                      icon: Icons.account_balance_rounded,
                    ),
                    const SizedBox(height: 14),
                    _buildText(
                      _salaryCtrl,
                      'Əmək haqqı (AZN, gross)',
                      'Məs: 1500',
                      icon: Icons.payments_rounded,
                      keyboard: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                    ),
                    const SizedBox(height: 14),
                    Text('İşə Qəbul Tarixi', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    _buildDateField(
                      date: _hireDate,
                      hint: 'Seçilməyib',
                      icon: Icons.event_available_rounded,
                      onTap: () => _pickDate(_hireDate, 1, 50, (d) => _hireDate = d),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Müqavilə Başlanğıc', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                              const SizedBox(height: 6),
                              _buildDateField(
                                date: _contractStart,
                                hint: 'Seçilməyib',
                                icon: Icons.start_rounded,
                                onTap: () => _pickDate(_contractStart, 1, 50, (d) => _contractStart = d),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Müqavilə Bitmə', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                              const SizedBox(height: 6),
                              _buildDateField(
                                date: _contractEnd,
                                hint: 'Müddətsiz',
                                icon: Icons.event_busy_rounded,
                                onTap: () => _pickDate(_contractEnd, 1, 50, (d) => _contractEnd = d),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            // ════ ADDIM 4: HESAB ════
            if (_step == 3) ...[
              _buildSection(
                icon: Icons.key_rounded,
                title: 'Hesab Məlumatları',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildEmailPreview(emailPreview),
                    const SizedBox(height: 6),
                    Text(
                      'İstifadəçi e-poçt VEYA FIN kod ilə giriş edə biləcək.',
                      style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 14),
                    _buildText(
                      _passCtrl,
                      'Şifrə *',
                      'Ən azı 4 simvol',
                      icon: Icons.lock_outline_rounded,
                      obscure: true,
                      validator: (v) => (v ?? '').trim().length < 4 ? 'Şifrə ən azı 4 simvol olmalıdır' : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _buildSummaryCard(dateFormat),
            ],

            const SizedBox(height: 22),
            Row(
              children: [
                if (_step > 0)
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: () => setState(() => _step--),
                        icon: const Icon(Icons.arrow_back_rounded, size: 19),
                        label: const Text('Geri'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          side: BorderSide(color: AppColors.cardBorder),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ),
                if (_step > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _saving ? null : _nextOrSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryAccent,
                        disabledBackgroundColor: AppColors.primaryAccent.withAlpha(100),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      icon: _saving
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2))
                          : Icon(
                              _step == _stepTitles.length - 1 ? Icons.person_add_rounded : Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                      label: Text(
                        _saving
                            ? 'Yaradılır...'
                            : (_step == _stepTitles.length - 1 ? 'İşçini Yarat' : 'İrəli'),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14.5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailPreview(String? emailPreview) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryAccent.withAlpha(8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryAccent.withAlpha(40)),
      ),
      child: Row(
        children: [
          const Icon(Icons.alternate_email_rounded, size: 17, color: AppColors.primaryAccent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              (emailPreview ?? '').isNotEmpty ? emailPreview! : 'ad.soyad@idrak.edu.az (ad daxil edildikdə yaranır)',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: (emailPreview ?? '').isNotEmpty ? AppColors.textPrimary : AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({required DateTime? date, required String hint, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: _inputDeco(icon: icon).copyWith(
          suffixIcon: const Icon(Icons.calendar_month_rounded, color: AppColors.primaryAccent, size: 20),
        ),
        child: Text(
          date != null ? DateFormat('dd.MM.yyyy').format(date) : hint,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: date != null ? AppColors.textPrimary : AppColors.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(DateFormat dateFormat) {
    final salary = double.tryParse(_salaryCtrl.text.trim().replaceAll(',', '.'));
    final rows = <MapEntry<String, String>>[
      MapEntry('Ad Soyad', '${_firstNameCtrl.text} ${_lastNameCtrl.text}'.trim()),
      if (_fatherNameCtrl.text.trim().isNotEmpty) MapEntry('Ata adı', _fatherNameCtrl.text.trim()),
      MapEntry('Cins', _gender),
      if (_birthDate != null) MapEntry('Doğum tarixi', dateFormat.format(_birthDate!)),
      MapEntry('FIN', _finCtrl.text),
      if (_phoneCtrl.text.trim().isNotEmpty) MapEntry('Telefon', _phoneCtrl.text.trim()),
      MapEntry('Vəzifə', _isTeacher ? 'Müəllim${_subjectCtrl.text.trim().isNotEmpty ? ' — ${_subjectCtrl.text.trim()}' : ''}' : 'Digər işçi'),
      if (_positionCtrl.text.trim().isNotEmpty) MapEntry('Vəzifə adı', _positionCtrl.text.trim()),
      if (salary != null) MapEntry('Əmək haqqı', '${_salaryCtrl.text.trim()} AZN'),
      if (_hireDate != null) MapEntry('İşə qəbul', dateFormat.format(_hireDate!)),
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(color: AppColors.gold.withAlpha(15), borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.fact_check_rounded, size: 17, color: AppColors.goldDark),
              ),
              const SizedBox(width: 10),
              Text('Yekun Yoxlama', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.3)),
            ],
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            Row(
              children: [
                SizedBox(
                  width: 110,
                  child: Text(rows[i].key, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                ),
                Expanded(
                  child: Text(
                    rows[i].value,
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSection({required IconData icon, required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.primaryAccent.withAlpha(12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 17, color: AppColors.primaryAccent),
              ),
              const SizedBox(width: 10),
              Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.3)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  InputDecoration _inputDeco({required IconData icon, String? labelText}) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
      filled: true,
      fillColor: AppColors.background,
      prefixIcon: Icon(icon, color: AppColors.primaryAccent, size: 20),
      contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.cardBorder)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.cardBorder)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primaryAccent, width: 1.5),
      ),
      errorStyle: const TextStyle(fontSize: 10.5),
    );
  }

  Widget _buildText(
    TextEditingController controller,
    String label,
    String hint, {
    required IconData icon,
    TextInputType? keyboard,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    bool obscure = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      inputFormatters: inputFormatters,
      validator: validator,
      obscureText: obscure,
      maxLines: obscure ? 1 : maxLines,
      onChanged: (_) => setState(() {}),
      decoration: _inputDeco(icon: icon, labelText: label).copyWith(hintText: hint, hintStyle: TextStyle(fontSize: 12.5, color: AppColors.textMuted)),
      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
    );
  }

  Widget _buildGenderChip(String value, IconData icon) {
    final selected = _gender == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _gender = value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryAccent.withAlpha(15) : AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected ? AppColors.primaryAccent : AppColors.cardBorder, width: selected ? 1.5 : 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: selected ? AppColors.primaryAccent : AppColors.textMuted),
              const SizedBox(width: 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: selected ? AppColors.primaryAccent : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip(bool isTeacher, String label, IconData icon) {
    final selected = _isTeacher == isTeacher;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isTeacher = isTeacher),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryAccent.withAlpha(15) : AppColors.background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: selected ? AppColors.primaryAccent : AppColors.cardBorder, width: selected ? 1.5 : 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: selected ? AppColors.primaryAccent : AppColors.textMuted),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: selected ? AppColors.primaryAccent : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermSwitch(String label, bool value, ValueChanged<bool> onChanged, Color color) {
    return SwitchListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(label, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
      value: value,
      activeThumbColor: color,
      onChanged: onChanged,
    );
  }
}
