import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/user_model.dart';
import '../../../providers/app_state.dart';

/// İşçi hesabının bütün məlumatlarının redaktəsi (admin / edit_users).
Future<void> showEditEmployeeSheet(BuildContext context, AppUser user) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _EditEmployeeForm(user: user),
  );
}

class _EditEmployeeForm extends StatefulWidget {
  final AppUser user;
  const _EditEmployeeForm({required this.user});

  @override
  State<_EditEmployeeForm> createState() => _EditEmployeeFormState();
}

class _EditEmployeeFormState extends State<_EditEmployeeForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _fatherName;
  late final TextEditingController _fin;
  late final TextEditingController _idCard;
  late final TextEditingController _address;
  late final TextEditingController _phone;
  late final TextEditingController _position;
  late final TextEditingController _salary;
  late final TextEditingController _bank;
  late final TextEditingController _subject;
  late final TextEditingController _room;
  late final TextEditingController _pass;

  late String _gender;
  String _citizenship = 'Azərbaycan';
  String _educationLevel = 'Bakalavr';
  DateTime? _birthDate;
  DateTime? _hireDate;
  DateTime? _contractStart;
  DateTime? _contractEnd;
  String? _selectedRoleId;
  bool _saving = false;
  final Set<String> _assignedClasses = {};

  @override
  void initState() {
    super.initState();
    final u = widget.user;
    final nameParts = u.fullName.split(' ');
    _firstName = TextEditingController(text: u.firstName ?? nameParts.first);
    _lastName =
        TextEditingController(text: u.lastName ?? nameParts.skip(1).join(' '));
    _fatherName = TextEditingController(text: u.fatherName ?? '');
    _fin = TextEditingController(text: u.finCode ?? '');
    _idCard = TextEditingController(text: u.idCardSerial ?? '');
    _address = TextEditingController(text: u.address ?? '');
    _phone = TextEditingController(text: u.phone);
    _position = TextEditingController(text: u.position ?? '');
    _salary = TextEditingController(text: u.salary?.toString() ?? '');
    _bank = TextEditingController(text: u.bankName ?? '');
    _subject = TextEditingController(text: u.subject ?? '');
    _room = TextEditingController(text: u.roomNumber ?? '');
    _pass = TextEditingController(text: u.password);
    _gender = u.gender ?? 'Kişi';
    _citizenship = u.citizenship ?? 'Azərbaycan';
    _educationLevel = u.educationLevel ?? 'Bakalavr';
    _birthDate = u.birthDate;
    _hireDate = u.hireDate;
    _contractStart = u.contractStart;
    _contractEnd = u.contractEnd;
    _selectedRoleId = u.assignedRoleId;
    _assignedClasses.addAll(u.assignedClasses);
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _fatherName.dispose();
    _fin.dispose();
    _idCard.dispose();
    _address.dispose();
    _phone.dispose();
    _position.dispose();
    _salary.dispose();
    _bank.dispose();
    _subject.dispose();
    _room.dispose();
    _pass.dispose();
    super.dispose();
  }

  bool get _isTeacher => widget.user.role == UserRole.teacher;

  Future<void> _pick(DateTime? current, ValueChanged<DateTime> onPicked) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime(now.year - 30),
      firstDate: DateTime(now.year - 75),
      lastDate: DateTime(now.year + 5),
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
    appState.updateUserAccount(widget.user.copyWith(
      firstName: first,
      lastName: last,
      fullName: '$first $last'.trim(),
      fatherName: _fatherName.text.trim(),
      gender: _gender,
      birthDate: _birthDate,
      finCode: _fin.text.trim(),
      address: _address.text.trim(),
      citizenship: _citizenship,
      idCardSerial: _idCard.text.trim(),
      educationLevel: _educationLevel,
      bankName: _bank.text.trim(),
      phone: _phone.text.trim(),
      position: _position.text.trim(),
      hireDate: _hireDate,
      salary: double.tryParse(_salary.text.trim().replaceAll(',', '.')),
      contractStart: _contractStart,
      contractEnd: _contractEnd,
      subject: _isTeacher ? _subject.text.trim() : null,
      roomNumber: _isTeacher ? _room.text.trim() : null,
      assignedClasses: _isTeacher ? _assignedClasses.toList() : const [],
      password: _pass.text.trim(),
      assignedRoleId: _isTeacher ? null : _selectedRoleId,
    ));
    setState(() => _saving = false);
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('İşçi məlumatları yeniləndi'), backgroundColor: AppColors.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
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
                        'Redaktə: ${widget.user.fullName}',
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
                    _dateField(_birthDate, dateFormat, () => _pick(_birthDate, (d) => _birthDate = d)),
                    _label('FIN Kod'),
                    _field(
                      _fin,
                      '1234567',
                      keyboard: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(7)],
                      validator: (v) {
                        final val = (v ?? '').trim();
                        if (val.isNotEmpty && !RegExp(r'^\d{7}$').hasMatch(val)) return '7 rəqəm olmalıdır';
                        if (val.isNotEmpty && appState.users.any((u) => (u.finCode ?? '') == val && u.id != widget.user.id)) {
                          return 'Bu FIN başqa hesabda istifadə olunur';
                        }
                        return null;
                      },
                    ),
                    _label('Vətəndaşlıq'),
                    DropdownButtonFormField<String>(
                      value: _citizenship,
                      decoration: _deco(Icons.flag_rounded),
                      items: const [
                        DropdownMenuItem(value: 'Azərbaycan', child: Text('Azərbaycan', style: TextStyle(fontSize: 13))),
                        DropdownMenuItem(value: 'Türkiyə', child: Text('Türkiyə', style: TextStyle(fontSize: 13))),
                        DropdownMenuItem(value: 'Rusiya', child: Text('Rusiya', style: TextStyle(fontSize: 13))),
                        DropdownMenuItem(value: 'Gürcüstan', child: Text('Gürcüstan', style: TextStyle(fontSize: 13))),
                        DropdownMenuItem(value: 'Ukrayna', child: Text('Ukrayna', style: TextStyle(fontSize: 13))),
                        DropdownMenuItem(value: 'Digər', child: Text('Digər', style: TextStyle(fontSize: 13))),
                      ],
                      onChanged: (v) => setState(() => _citizenship = v!),
                    ),
                    _label('ŞV Seriyası'),
                    _field(_idCard, 'AA1234567', inputFormatters: [LengthLimitingTextInputFormatter(12)]),
                    _label('Ünvan'),
                    _field(_address, 'Ünvan'),
                    _label('Telefon'),
                    _field(_phone, '+994 ...', keyboard: TextInputType.phone),
                    if (_isTeacher) ...[
                      _label('Fənn'),
                      _field(_subject, 'Fənn'),
                      _label('Otaq'),
                      _field(_room, 'Otaq 201'),
                      _label('Təyin Olunan Siniflər'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final cls in appState.allDistinctClasses)
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
                    ] else ...[
                      _label('Rol'),
                      DropdownButtonFormField<String>(
                        value: _selectedRoleId,
                        decoration: _deco(Icons.admin_panel_settings_rounded),
                        items: [
                          for (final r in appState.roles)
                            DropdownMenuItem(value: r.id, child: Text('${r.name} (${r.permissionIds.length})', style: const TextStyle(fontSize: 13))),
                        ],
                        onChanged: (v) => setState(() => _selectedRoleId = v),
                      ),
                    ],
                    _label('Vəzifə adı'),
                    _field(_position, 'Məs: İT üzrə mütəxəssis'),
                    _label('Təhsil Dərəcəsi'),
                    DropdownButtonFormField<String>(
                      value: _educationLevel,
                      decoration: _deco(Icons.school_rounded),
                      items: const [
                        DropdownMenuItem(value: 'Orta təhsil', child: Text('Orta təhsil', style: TextStyle(fontSize: 13))),
                        DropdownMenuItem(value: 'Orta ixtisas', child: Text('Orta ixtisas', style: TextStyle(fontSize: 13))),
                        DropdownMenuItem(value: 'Bakalavr', child: Text('Bakalavr', style: TextStyle(fontSize: 13))),
                        DropdownMenuItem(value: 'Magistr', child: Text('Magistr', style: TextStyle(fontSize: 13))),
                        DropdownMenuItem(value: 'PhD / Doktorantura', child: Text('PhD / Doktorantura', style: TextStyle(fontSize: 13))),
                      ],
                      onChanged: (v) => setState(() => _educationLevel = v!),
                    ),
                    _label('Bank Adı'),
                    _field(_bank, 'Məs: Kapital Bank'),
                    _label('Əmək haqqı (AZN)'),
                    _field(
                      _salary,
                      '1500',
                      keyboard: const TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))],
                    ),
                    _label('İşə Qəbul Tarixi'),
                    _dateField(_hireDate, dateFormat, () => _pick(_hireDate, (d) => _hireDate = d)),
                    _label('Müqavilə Başlanğıc'),
                    _dateField(_contractStart, dateFormat, () => _pick(_contractStart, (d) => _contractStart = d)),
                    _label('Müqavilə Bitmə'),
                    _dateField(_contractEnd, dateFormat, () => _pick(_contractEnd, (d) => _contractEnd = d)),
                    _label('Şifrə *'),
                    _field(_pass, 'Şifrə', validator: (v) => (v ?? '').trim().length < 4 ? 'Ən azı 4 simvol' : null),
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
