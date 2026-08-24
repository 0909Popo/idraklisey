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

/// Şagird qeydiyyatı — 3 səhifəli addım-addım forma:
/// 1) Şagird kimliyi  2) Təhsil və əlaqə  3) Valideyn.
/// Şagirdin ünvanı daxil edildikdə valideynin ünvanı avtomatik eyniləşir.
class StudentRegistrationScreen extends StatefulWidget {
  const StudentRegistrationScreen({super.key});

  @override
  State<StudentRegistrationScreen> createState() => _StudentRegistrationScreenState();
}

class _StudentRegistrationScreenState extends State<StudentRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _fatherNameCtrl = TextEditingController();
  final _finCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _allergiesCtrl = TextEditingController();
  final _studentPassCtrl = TextEditingController(text: '123456');
  final _parentNameCtrl = TextEditingController();
  final _parentFinCtrl = TextEditingController();
  final _parentPhoneCtrl = TextEditingController();
  final _parentAddressCtrl = TextEditingController();
  final _parentPassCtrl = TextEditingController(text: '123456');

  static const _stepTitles = ['Şagird Kimliyi', 'Təhsil və Əlaqə', 'Valideyn'];
  static const _empty2 = 'Məlumat yoxdur';

  static const _bloodGroups = [
    'A(I) Rh+', 'A(II) Rh+', 'B(III) Rh+', 'AB(IV) Rh+',
    'A(II) Rh-', 'B(III) Rh-', 'AB(IV) Rh-',
    'O(I) Rh+', 'O(I) Rh-',
  ];

  int _step = 0;
  String _gender = 'Kişi';
  DateTime? _birthDate;
  DateTime? _parentBirthDate;
  String? _selectedClass;
  String _bloodGroup = 'A(II) Rh+';
  String? _photoUrl;
  bool _saving = false;
  bool _parentAddressEdited = false; // valideyn ünvanı əl ilə dəyişilibsə avto-sync dayanır
  bool _useExistingParent = false;
  AppUser? _selectedParent;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _fatherNameCtrl.dispose();
    _finCtrl.dispose();
    _addressCtrl.dispose();
    _allergiesCtrl.dispose();
    _studentPassCtrl.dispose();
    _parentNameCtrl.dispose();
    _parentFinCtrl.dispose();
    _parentPhoneCtrl.dispose();
    _parentAddressCtrl.dispose();
    _parentPassCtrl.dispose();
    super.dispose();
  }

  String _fullStudentName() => '${_firstNameCtrl.text.trim()} ${_lastNameCtrl.text.trim()}'.trim();

  /// Şagird ünvanı dəyişəndə valideyn ünvanını avtomatik eyniləşdir
  /// (yalnız valideyn onu əl ilə dəyişməyibsə — mantıqen eyni yerdə yaşayırlar).
  void _syncParentAddress(String studentAddress) {
    if (!_parentAddressEdited) {
      _parentAddressCtrl.text = studentAddress;
    }
  }

  MapEntry<String, String> _previewEmails(AppState appState) {
    final existing = appState.users
        .map((u) => (u.email ?? '').toLowerCase())
        .where((e) => e.isNotEmpty)
        .toList();
    final name = _fullStudentName();
    final studentEmail = _firstNameCtrl.text.trim().isEmpty || _lastNameCtrl.text.trim().isEmpty
        ? ''
        : EmailGenerator.generateStudentEmail(
            name,
            EmailGenerator.getYearFromFIN(_finCtrl.text.trim()),
            existingEmails: existing,
          );
    final parentEmail = _parentNameCtrl.text.trim().isEmpty
        ? ''
        : EmailGenerator.generateParentEmail(
            _parentNameCtrl.text.trim(),
            existingEmails: [...existing, if (studentEmail.isNotEmpty) studentEmail],
          );
    return MapEntry(studentEmail, parentEmail);
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 15),
      firstDate: DateTime(now.year - 25),
      lastDate: DateTime(now.year - 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppColors.primaryAccent),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _pickParentBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _parentBirthDate ?? DateTime(now.year - 40),
      firstDate: DateTime(now.year - 85),
      lastDate: DateTime(now.year - 18),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppColors.gold),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _parentBirthDate = picked);
  }

  Future<void> _nextOrSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_step == _stepTitles.length - 1 && _useExistingParent && _selectedParent == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mövcud valideyn hesabı seçilməlidir'), backgroundColor: AppColors.danger),
      );
      return;
    }
    if (_step < _stepTitles.length - 1) {
      setState(() => _step++);
      return;
    }
    await _submit();
  }

  Future<void> _submit() async {
    final appState = context.read<AppState>();
    final allergies = _allergiesCtrl.text
        .split(',')
        .map((a) => a.trim())
        .where((a) => a.isNotEmpty)
        .toList();

    setState(() => _saving = true);
    final accounts = appState.registerStudentWithParent(
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      fatherName: _fatherNameCtrl.text.trim(),
      gender: _gender,
      birthDate: _birthDate,
      finCode: _finCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      className: _selectedClass!,
      bloodGroup: _bloodGroup,
      allergies: allergies,
      studentPassword: _studentPassCtrl.text.trim(),
      existingParent: _useExistingParent ? _selectedParent : null,
      parentName: _parentNameCtrl.text.trim(),
      parentFinCode: _parentFinCtrl.text.trim(),
      parentBirthDate: _parentBirthDate,
      parentPhone: _parentPhoneCtrl.text.trim(),
      parentAddress: _parentAddressCtrl.text.trim(),
      parentPassword: _parentPassCtrl.text.trim(),
      studentPhotoUrl: _photoUrl,
    );
    setState(() => _saving = false);

    if (!mounted) return;
    final student = accounts['student']!;
    final parent = accounts['parent']!;
    await showCredentialsResultDialog(
      context: context,
      title: _useExistingParent ? 'Şagird Mövcud Valideynə Bağlandı' : 'Şagird və Valideyn Hesabları Yaradıldı',
      sections: [
        CredentialsSection(title: 'Şagird Hesabı', rows: [
          MapEntry('Ad Soyad', student.fullName),
          MapEntry('Sinif', _selectedClass!),
          MapEntry('E-poçt (Login)', student.email ?? ''),
          MapEntry('FIN kod', student.finCode ?? ''),
          MapEntry('İdrak kodu', student.idrakCode),
          MapEntry('Şifrə', student.password),
        ]),
        CredentialsSection(title: 'Valideyn', rows: [
          MapEntry('Ad Soyad', parent.fullName),
          if (_useExistingParent) ...[
            MapEntry('E-poçt (Login)', parent.email ?? ''),
            MapEntry('Mövcud hesab', 'Yeni şagird bu hesaba bağlandı'),
          ] else ...[
            MapEntry('E-poçt (Login)', parent.email ?? ''),
            MapEntry('FIN kod', parent.finCode ?? ''),
            MapEntry('İstifadəçi adı', parent.username),
            MapEntry('İdrak kodu', parent.idrakCode),
            MapEntry('Şifrə', parent.password),
          ],
        ]),
      ],
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final classes = appState.allDistinctClasses;
    if (_selectedClass == null && classes.isNotEmpty) {
      _selectedClass = classes.first;
    }
    final previews = _previewEmails(appState);
    final dateFormat = DateFormat('dd.MM.yyyy');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Şagird Qeydiyyatı (${_step + 1}/3): ${_stepTitles[_step]}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15.5),
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

            // ════ ADDIM 1: ŞAGIRD KİMLİYİ ════
            if (_step == 0) ...[
              _buildSection(
                icon: Icons.school_rounded,
                title: 'Şəxsi Məlumatlar',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: _buildText(_firstNameCtrl, 'Ad *', 'Elmir', icon: Icons.person_rounded, validator: (v) => (v ?? '').trim().isEmpty ? 'Ad tələb olunur' : null)),
                        const SizedBox(width: 10),
                        Expanded(child: _buildText(_lastNameCtrl, 'Soyad *', 'Quliyev', icon: Icons.person_outline_rounded, validator: (v) => (v ?? '').trim().isEmpty ? 'Soyad tələb olunur' : null)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildText(_fatherNameCtrl, 'Ata adı', 'İlham', icon: Icons.person_pin_rounded),
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
                      onTap: _pickBirthDate,
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
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _buildSection(
                icon: Icons.photo_camera_front_rounded,
                title: 'Şagirdin Şəkli',
                child: Center(
                  child: ProfilePhotoPicker(
                    initialPhotoUrl: _photoUrl,
                    onPhotoUploaded: (url) => setState(() => _photoUrl = url),
                    folder: 'idrak/profiles/students',
                  ),
                ),
              ),
            ],

            // ════ ADDIM 2: TƏHSİL VƏ ƏLAQƏ ════
            if (_step == 1) ...[
              _buildSection(
                icon: Icons.class_rounded,
                title: 'Təhsil və Səhiyyə',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedClass,
                      decoration: _inputDeco(icon: Icons.class_rounded).copyWith(labelText: 'Sinif *'),
                      items: [
                        for (final cls in classes) DropdownMenuItem(value: cls, child: Text(cls, style: const TextStyle(fontSize: 13))),
                      ],
                      onChanged: (v) => setState(() => _selectedClass = v),
                      validator: (v) => v == null || v.isEmpty ? 'Sinif seçilməlidir' : null,
                    ),
                    const SizedBox(height: 14),
                    DropdownButtonFormField<String>(
                      value: _bloodGroup,
                      decoration: _inputDeco(icon: Icons.bloodtype_rounded).copyWith(labelText: 'Qan Qrupu'),
                      items: [
                        for (final bg in _bloodGroups) DropdownMenuItem(value: bg, child: Text(bg, style: const TextStyle(fontSize: 13))),
                      ],
                      onChanged: (v) => setState(() => _bloodGroup = v!),
                    ),
                    const SizedBox(height: 14),
                    _buildText(_allergiesCtrl, 'Alergiyalar (vergüllə ayırın)', 'Fıstıq, toz', icon: Icons.healing_rounded, maxLines: 2),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _buildSection(
                icon: Icons.home_rounded,
                title: 'Yaşadığı Ünvan',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildText(
                      _addressCtrl,
                      'Ünvan',
                      'Bakı, Nəsimi ray., ...',
                      icon: Icons.home_rounded,
                      maxLines: 2,
                      onFieldChanged: _syncParentAddress,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Bu ünvan avtomatik valideyn ünvanına da tətbiq olunacaq (3-cü addımda dəyişmək mümkündür).',
                      style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 14),
                    Text('Avtomatik E-poçt (@idrak.edu.az)', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    _buildEmailBox(
                      email: previews.key,
                      placeholder: 'ad.soyad.s2025@idrak.edu.az (ad və FIN daxil edildikdə yaranır)',
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Şagird e-poçt VEYA FIN kod ilə giriş edə biləcək.',
                      style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ],

            // ════ ADDIM 3: VALİDEYN ════
            if (_step == 2) ...[
              _buildSection(
                icon: Icons.family_restroom_rounded,
                title: 'Valideyn Məlumatları',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Yeni / Mövcud valideyn seçimi (Övladlar modeli)
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _useExistingParent = false),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: !_useExistingParent ? AppColors.primaryAccent.withAlpha(15) : AppColors.background,
                                borderRadius: BorderRadius.circular(13),
                                border: Border.all(color: !_useExistingParent ? AppColors.primaryAccent : AppColors.cardBorder, width: !_useExistingParent ? 1.5 : 1),
                              ),
                              child: Center(
                                child: Text('Yeni Valideyn', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: !_useExistingParent ? AppColors.primaryAccent : AppColors.textSecondary)),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _useExistingParent = true),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _useExistingParent ? AppColors.gold.withAlpha(15) : AppColors.background,
                                borderRadius: BorderRadius.circular(13),
                                border: Border.all(color: _useExistingParent ? AppColors.goldDark : AppColors.cardBorder, width: _useExistingParent ? 1.5 : 1),
                              ),
                              child: Center(
                                child: Text('Mövcud Valideyn', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: _useExistingParent ? AppColors.goldDark : AppColors.textSecondary)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (_useExistingParent) ...[
                      const SizedBox(height: 14),
                      Text('Valideyn Hesabı Seç *', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _selectedParent?.id,
                        decoration: _inputDeco(icon: Icons.family_restroom_rounded, accent: AppColors.goldDark).copyWith(hintText: 'Valideyn seçin'),
                        items: [
                          for (final p in appState.users.where((u) => u.role == UserRole.parent))
                            DropdownMenuItem(
                              value: p.id,
                              child: Text(
                                '${p.fullName} (${p.linkedStudentIds.length + (p.linkedStudentId != null && !p.linkedStudentIds.contains(p.linkedStudentId) ? 1 : 0)} övlad)',
                                style: const TextStyle(fontSize: 12.5),
                              ),
                            ),
                        ],
                        onChanged: (v) => setState(() {
                          _selectedParent = appState.users.where((u) => u.id == v).isEmpty ? null : appState.users.firstWhere((u) => u.id == v);
                        }),
                      ),
                      if (_selectedParent != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withAlpha(8),
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(color: AppColors.gold.withAlpha(35)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Seçilmiş valideyn: ${_selectedParent!.fullName}', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                              const SizedBox(height: 3),
                              Text('Mail: ${_selectedParent!.email ?? _empty2}', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                              Text('Telefon: ${_selectedParent!.phone.isEmpty ? _empty2 : _selectedParent!.phone}', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                              const SizedBox(height: 4),
                              Text('Yeni şagird bu hesaba bağlanacaq — ayrıca valideyn hesabı yaradılmır.', style: TextStyle(fontSize: 10.5, color: AppColors.goldDark, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      _buildText(
                        _studentPassCtrl,
                        'Şagird Şifrəsi *',
                        'Ən azı 4 simvol',
                        icon: Icons.lock_outline_rounded,
                        obscure: true,
                        validator: (v) => (v ?? '').trim().length < 4 ? 'Ən azı 4 simvol' : null,
                      ),
                    ] else ...[
                      _buildText(_parentNameCtrl, 'Ad Soyad *', 'Vəli Quliyev', icon: Icons.person_rounded, validator: (v) => (v ?? '').trim().isEmpty ? 'Valideyn adı tələb olunur' : null),
                    const SizedBox(height: 14),
                    _buildText(
                      _parentFinCtrl,
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
                    Text('Doğum Tarixi *', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 6),
                    _buildDateField(
                      date: _parentBirthDate,
                      hint: 'Seçilməyib',
                      icon: Icons.cake_rounded,
                      onTap: _pickParentBirthDate,
                      accent: AppColors.goldDark,
                    ),
                    const SizedBox(height: 14),
                    _buildText(_parentPhoneCtrl, 'Telefon *', '+994 50 000-00-00', icon: Icons.phone_rounded, keyboard: TextInputType.phone, validator: (v) => (v ?? '').trim().isEmpty ? 'Telefon tələb olunur' : null),
                    const SizedBox(height: 14),
                    _buildText(
                      _parentAddressCtrl,
                      'Ünvan',
                      'Bakı, ...',
                      icon: Icons.home_work_rounded,
                      maxLines: 2,
                      onFieldChanged: (_) => _parentAddressEdited = true,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.sync_rounded, size: 13, color: _parentAddressEdited ? AppColors.textMuted : AppColors.gold),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _parentAddressEdited
                                ? 'Ünvan əl ilə dəyişdirilib.'
                                : 'Şagirdin ünvanından avtomatik köçürülüb — fərqlidirsə dəyişin.',
                            style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Valideyn avtomatik maili
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withAlpha(10),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.gold.withAlpha(40)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.alternate_email_rounded, size: 17, color: AppColors.goldDark),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              previews.value.isNotEmpty ? previews.value : 'valideyn.mail@idrak.edu.az (ad daxil edildikdə yaranır)',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: previews.value.isNotEmpty ? AppColors.textPrimary : AppColors.textMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Valideyn hesabı avtomatik olaraq bu şagirdə bağlanacaq.',
                      style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _buildText(
                            _studentPassCtrl,
                            'Şagird Şifrəsi *',
                            'Ən azı 4 simvol',
                            icon: Icons.lock_outline_rounded,
                            obscure: true,
                            validator: (v) => (v ?? '').trim().length < 4 ? 'Ən azı 4 simvol' : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildText(
                            _parentPassCtrl,
                            'Valideyn Şifrəsi *',
                            'Ən azı 4 simvol',
                            icon: Icons.lock_reset_rounded,
                            obscure: true,
                            validator: (v) => (v ?? '').trim().length < 4 ? 'Ən azı 4 simvol' : null,
                          ),
                        ),
                      ],
                    ),
                    ],
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
                              _step == _stepTitles.length - 1 ? Icons.school_rounded : Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                      label: Text(
                        _saving ? 'Qeydiyyat edilir...' : (_step == _stepTitles.length - 1 ? 'Şagirdi Qeydiyyata Al' : 'İrəli'),
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

  Widget _buildEmailBox({required String email, required String placeholder}) {
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
              email.isNotEmpty ? email : placeholder,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: email.isNotEmpty ? AppColors.textPrimary : AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({required DateTime? date, required String hint, required IconData icon, required VoidCallback onTap, Color? accent}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: _inputDeco(icon: icon, accent: accent).copyWith(
          suffixIcon: Icon(Icons.calendar_month_rounded, color: accent ?? AppColors.primaryAccent, size: 20),
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
    final rows = <MapEntry<String, String>>[
      MapEntry('Şagird', _fullStudentName()),
      if (_fatherNameCtrl.text.trim().isNotEmpty) MapEntry('Ata adı', _fatherNameCtrl.text.trim()),
      MapEntry('Sinif', _selectedClass ?? '-'),
      if (_birthDate != null) MapEntry('Doğum tarixi', dateFormat.format(_birthDate!)),
      MapEntry('FIN', _finCtrl.text),
      if (_bloodGroup != 'A(II) Rh+') MapEntry('Qan qrupu', _bloodGroup),
      MapEntry('Valideyn', _parentNameCtrl.text.trim()),
      if (_parentBirthDate != null) MapEntry('Valideyn doğum tarixi', dateFormat.format(_parentBirthDate!)),
      if (_parentPhoneCtrl.text.trim().isNotEmpty) MapEntry('Valideyn telefonu', _parentPhoneCtrl.text.trim()),
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
                  width: 140,
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
              Expanded(
                child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.3)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  InputDecoration _inputDeco({required IconData icon, String? labelText, Color? accent}) {
    final color = accent ?? AppColors.primaryAccent;
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
      filled: true,
      fillColor: AppColors.background,
      prefixIcon: Icon(icon, color: color, size: 20),
      contentPadding: const EdgeInsets.symmetric(vertical: 13, horizontal: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.cardBorder)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColors.cardBorder)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: 1.5),
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
    ValueChanged<String>? onFieldChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      inputFormatters: inputFormatters,
      validator: validator,
      obscureText: obscure,
      maxLines: obscure ? 1 : maxLines,
      onChanged: (v) {
        onFieldChanged?.call(v);
        setState(() {});
      },
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
}
