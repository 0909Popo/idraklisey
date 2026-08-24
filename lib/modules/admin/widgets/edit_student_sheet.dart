import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/student_model.dart';
import '../../../data/models/user_model.dart';
import '../../../providers/app_state.dart';

/// Şagird + veli məlumatlarının redaktəsi (admin / edit_students).
/// Eyni anda 3 qeyd yenilənir: StudentProfile, şagird hesabı, veli hesabı.
Future<void> showEditStudentSheet(BuildContext context, StudentProfile student) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _EditStudentForm(student: student),
  );
}

class _EditStudentForm extends StatefulWidget {
  final StudentProfile student;
  const _EditStudentForm({required this.student});

  @override
  State<_EditStudentForm> createState() => _EditStudentFormState();
}

class _EditStudentFormState extends State<_EditStudentForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _fatherName;
  late final TextEditingController _fin;
  late final TextEditingController _address;
  late final TextEditingController _allergies;
  late final TextEditingController _studentPass;
  late final TextEditingController _parentName;
  late final TextEditingController _parentFin;
  late final TextEditingController _parentPhone;
  late final TextEditingController _parentAddress;
  late final TextEditingController _parentPass;

  static const _bloodGroups = [
    'A(I) Rh+', 'A(II) Rh+', 'B(III) Rh+', 'AB(IV) Rh+',
    'A(II) Rh-', 'B(III) Rh-', 'AB(IV) Rh-',
    'O(I) Rh+', 'O(I) Rh-', 'Məlumat yoxdur',
  ];

  late String _gender;
  DateTime? _birthDate;
  DateTime? _parentBirthDate;
  late String? _selectedClass;
  late String _bloodGroup;
  bool _saving = false;

  AppUser? _studentUser;
  AppUser? _parentUser;

  @override
  void initState() {
    super.initState();
    final s = widget.student;
    final nameParts = s.fullName.split(' ');
    _firstName = TextEditingController(text: s.firstName ?? nameParts.first);
    _lastName =
        TextEditingController(text: s.lastName ?? nameParts.skip(1).join(' '));
    _fatherName = TextEditingController(text: s.fatherName ?? '');
    _fin = TextEditingController(text: s.finCode ?? '');
    _address = TextEditingController(text: s.address ?? '');
    _allergies = TextEditingController(text: (s.allergies ?? []).join(', '));
    _parentName = TextEditingController(text: s.parentName);
    _parentPhone = TextEditingController(text: s.parentPhone);
    _parentAddress = TextEditingController(text: s.parentAddress ?? '');
    _gender = s.gender ?? 'Kişi';
    _birthDate = s.birthDate;
    _selectedClass = s.className;
    _bloodGroup = _bloodGroups.contains(s.bloodGroup) ? s.bloodGroup! : 'Məlumat yoxdur';

    final appState = context.read<AppState>();
    for (final u in appState.users) {
      if (u.id == 'usr-${s.id}') _studentUser = u;
      if (u.role == UserRole.parent &&
          (u.linkedStudentId == s.id || u.linkedStudentIds.contains(s.id))) {
        _parentUser = u;
      }
    }
    _studentPass = TextEditingController(text: _studentUser?.password ?? '123456');
    _parentPass = TextEditingController(text: _parentUser?.password ?? '123456');
    _parentFin = TextEditingController(text: _parentUser?.finCode ?? '');
    _parentBirthDate = _parentUser?.birthDate;
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _fatherName.dispose();
    _fin.dispose();
    _address.dispose();
    _allergies.dispose();
    _studentPass.dispose();
    _parentName.dispose();
    _parentFin.dispose();
    _parentPhone.dispose();
    _parentAddress.dispose();
    _parentPass.dispose();
    super.dispose();
  }

  Future<void> _pick(DateTime? current, int minAge, int maxAge, ValueChanged<DateTime> onPicked) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime(now.year - minAge),
      firstDate: DateTime(now.year - maxAge),
      lastDate: DateTime(now.year - minAge + 10),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(primary: AppColors.primaryAccent),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => onPicked(picked));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final appState = context.read<AppState>();
    setState(() => _saving = true);

    final first = _firstName.text.trim();
    final last = _lastName.text.trim();
    final fullName = '$first $last'.trim();
    final bloodGroup = _bloodGroup == 'Məlumat yoxdur' ? null : _bloodGroup;
    final allergies = _allergies.text
        .split(',')
        .map((a) => a.trim())
        .where((a) => a.isNotEmpty)
        .toList();

    // 1. Şagird profili
    appState.updateStudentRecord(widget.student.copyWith(
      fullName: fullName,
      firstName: first,
      lastName: last,
      fatherName: _fatherName.text.trim(),
      gender: _gender,
      birthDate: _birthDate,
      finCode: _fin.text.trim(),
      address: _address.text.trim(),
      className: _selectedClass ?? widget.student.className,
      bloodGroup: bloodGroup,
      allergies: allergies,
      parentName: _parentName.text.trim(),
      parentPhone: _parentPhone.text.trim(),
      parentAddress: _parentAddress.text.trim(),
    ));

    // 2. Şagird hesabı
    if (_studentUser != null) {
      appState.updateUserAccount(_studentUser!.copyWith(
        fullName: fullName,
        firstName: first,
        lastName: last,
        fatherName: _fatherName.text.trim(),
        gender: _gender,
        birthDate: _birthDate,
        finCode: _fin.text.trim(),
        address: _address.text.trim(),
        className: _selectedClass,
        phone: _parentPhone.text.trim(),
        password: _studentPass.text.trim(),
      ));
    }

    // 3. Veli hesabı
    if (_parentUser != null) {
      appState.updateUserAccount(_parentUser!.copyWith(
        fullName: _parentName.text.trim(),
        finCode: _parentFin.text.trim(),
        birthDate: _parentBirthDate,
        phone: _parentPhone.text.trim(),
        address: _parentAddress.text.trim(),
        password: _parentPass.text.trim(),
      ));
    }

    setState(() => _saving = false);
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Şagird və valideyn məlumatları yeniləndi'), backgroundColor: AppColors.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final classes = appState.allDistinctClasses;
    final dateFormat = DateFormat('dd.MM.yyyy');

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 42,
                height: 4.5,
                decoration: BoxDecoration(color: AppColors.cardBorder, borderRadius: BorderRadius.circular(10)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 16, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Redaktə: ${widget.student.fullName}',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.3),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: AppColors.textMuted, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  children: [
                    _sectionTitle('Şagird', AppColors.primaryAccent),
                    _label('Ad *'),
                    _field(_firstName, 'Ad', validator: _req),
                    _label('Soyad *'),
                    _field(_lastName, 'Soyad', validator: _req),
                    _label('Ata adı'),
                    _field(_fatherName, 'Ata adı'),
                    _label('Cins'),
                    Row(
                      children: [
                        _chip('Kişi', _gender == 'Kişi', () => setState(() => _gender = 'Kişi')),
                        const SizedBox(width: 8),
                        _chip('Qadın', _gender == 'Qadın', () => setState(() => _gender = 'Qadın')),
                      ],
                    ),
                    _label('Doğum Tarixi'),
                    _dateField(_birthDate, dateFormat, () => _pick(_birthDate, 15, 25, (d) => _birthDate = d)),
                    _label('FIN Kod'),
                    _field(
                      _fin,
                      '1234567',
                      keyboard: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(7)],
                      validator: (v) {
                        final val = (v ?? '').trim();
                        if (val.isNotEmpty && !RegExp(r'^\d{7}$').hasMatch(val)) return '7 rəqəm olmalıdır';
                        if (val.isNotEmpty && appState.users.any((u) => (u.finCode ?? '') == val && u.id != _studentUser?.id)) {
                          return 'Bu FIN başqa hesabda istifadə olunur';
                        }
                        return null;
                      },
                    ),
                    _label('Ünvan'),
                    _field(_address, 'Ünvan'),
                    _label('Sinif'),
                    DropdownButtonFormField<String>(
                      value: classes.contains(_selectedClass) ? _selectedClass : null,
                      decoration: _deco(Icons.class_rounded),
                      items: [
                        for (final cls in classes) DropdownMenuItem(value: cls, child: Text(cls, style: const TextStyle(fontSize: 13))),
                      ],
                      onChanged: (v) => setState(() => _selectedClass = v),
                      validator: (v) => v == null ? 'Sinif seçin' : null,
                    ),
                    _label('Qan Qrupu'),
                    DropdownButtonFormField<String>(
                      value: _bloodGroup,
                      decoration: _deco(Icons.bloodtype_rounded),
                      items: [
                        for (final bg in _bloodGroups) DropdownMenuItem(value: bg, child: Text(bg, style: const TextStyle(fontSize: 13))),
                      ],
                      onChanged: (v) => setState(() => _bloodGroup = v!),
                    ),
                    _label('Alergiyalar (vergüllə)'),
                    _field(_allergies, 'Fıstıq, toz'),
                    _label('Şagird şifrəsi'),
                    _field(_studentPass, 'Şifrə', validator: (v) => (v ?? '').trim().length < 4 ? 'Ən azı 4 simvol' : null),
                    const SizedBox(height: 14),
                    _sectionTitle('Valideyn', AppColors.goldDark),
                    _label('Ad Soyad *'),
                    _field(_parentName, 'Vəli Quliyev', validator: _req),
                    _label('FIN Kod'),
                    _field(
                      _parentFin,
                      '1234567',
                      keyboard: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(7)],
                      validator: (v) {
                        final val = (v ?? '').trim();
                        if (val.isNotEmpty && !RegExp(r'^\d{7}$').hasMatch(val)) return '7 rəqəm olmalıdır';
                        if (val.isNotEmpty && appState.users.any((u) => (u.finCode ?? '') == val && u.id != _parentUser?.id)) {
                          return 'Bu FIN başqa hesabda istifadə olunur';
                        }
                        return null;
                      },
                    ),
                    _label('Doğum Tarixi'),
                    _dateField(_parentBirthDate, dateFormat, () => _pick(_parentBirthDate, 40, 85, (d) => _parentBirthDate = d)),
                    _label('Telefon *'),
                    _field(_parentPhone, '+994 ...', keyboard: TextInputType.phone, validator: _req),
                    _label('Ünvan'),
                    _field(_parentAddress, 'Ünvan'),
                    _label('Valideyn şifrəsi'),
                    _field(_parentPass, 'Şifrə', validator: (v) => (v ?? '').trim().length < 4 ? 'Ən azı 4 simvol' : null),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _saving ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        icon: _saving
                            ? const SizedBox(width: 17, height: 17, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2))
                            : const Icon(Icons.save_rounded, color: Colors.white, size: 19),
                        label: const Text('Yadda Saxla', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _req(String? v) => (v ?? '').trim().isEmpty ? 'Tələb olunur' : null;

  Widget _sectionTitle(String text, Color color) => Row(
        children: [
          Container(width: 4, height: 16, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: color, letterSpacing: 0.2)),
        ],
      );

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 5),
        child: Text(text, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
      );

  InputDecoration _deco(IconData icon) => InputDecoration(
        filled: true,
        fillColor: AppColors.background,
        prefixIcon: Icon(icon, color: AppColors.primaryAccent, size: 19),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: AppColors.cardBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: BorderSide(color: AppColors.cardBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: const BorderSide(color: AppColors.primaryAccent, width: 1.4)),
        errorStyle: const TextStyle(fontSize: 10),
      );

  Widget _field(
    TextEditingController controller,
    String hint, {
    String? Function(String?)? validator,
    TextInputType? keyboard,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboard,
      inputFormatters: inputFormatters,
      onChanged: (_) => setState(() {}),
      decoration: _deco(Icons.edit_rounded).copyWith(hintText: hint, hintStyle: TextStyle(fontSize: 12, color: AppColors.textMuted)),
      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
    );
  }

  Widget _dateField(DateTime? date, DateFormat fmt, VoidCallback onTap) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(13),
        child: InputDecorator(
          decoration: _deco(Icons.calendar_month_rounded).copyWith(
            suffixIcon: const Icon(Icons.arrow_drop_down_rounded, color: AppColors.primaryAccent),
          ),
          child: Text(
            date != null ? fmt.format(date) : 'Seçilməyib',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: date != null ? AppColors.textPrimary : AppColors.textMuted,
            ),
          ),
        ),
      );

  Widget _chip(String label, bool selected, VoidCallback onTap) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: selected ? AppColors.primaryAccent.withAlpha(15) : AppColors.background,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: selected ? AppColors.primaryAccent : AppColors.cardBorder, width: selected ? 1.5 : 1),
            ),
            child: Center(
              child: Text(label, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: selected ? AppColors.primaryAccent : AppColors.textSecondary)),
            ),
          ),
        ),
      );
}
