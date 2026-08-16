import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/profile_photo_picker.dart';
import '../../../providers/app_state.dart';
import '../../../data/models/user_model.dart';

class CreateAccountDialog extends StatefulWidget {
  const CreateAccountDialog({super.key});

  @override
  State<CreateAccountDialog> createState() => _CreateAccountDialogState();
}

class _CreateAccountDialogState extends State<CreateAccountDialog> {
  int _selectedType = 0; // 0: Müəllim (Teacher), 1: Şagird + Valideyn (Student + Parent)

  // Teacher Form Controllers
  final _teacherNameCtrl = TextEditingController();
  final _teacherSubjectCtrl = TextEditingController();
  final _teacherRoomCtrl = TextEditingController();
  final _teacherPhoneCtrl = TextEditingController();
  final _teacherPassCtrl = TextEditingController(text: '123456');
  bool _permCafeteria = false;
  bool _permMedical = false;
  bool _permInventory = true;

  // Photo URLs from Cloudinary
  String? _teacherPhotoUrl;
  String? _studentPhotoUrl;

  // Student & Parent Form Controllers
  final _studentNameCtrl = TextEditingController();
  final _studentClassCtrl = TextEditingController(text: '9B');
  final _studentBloodCtrl = TextEditingController(text: 'A(II) Rh+');
  final _studentAllergiesCtrl = TextEditingController();
  final _studentPassCtrl = TextEditingController(text: '123456');

  final _parentNameCtrl = TextEditingController();
  final _parentPhoneCtrl = TextEditingController();
  final _parentPassCtrl = TextEditingController(text: '123456');

  @override
  void dispose() {
    _teacherNameCtrl.dispose();
    _teacherSubjectCtrl.dispose();
    _teacherRoomCtrl.dispose();
    _teacherPhoneCtrl.dispose();
    _teacherPassCtrl.dispose();
    _studentNameCtrl.dispose();
    _studentClassCtrl.dispose();
    _studentBloodCtrl.dispose();
    _studentAllergiesCtrl.dispose();
    _studentPassCtrl.dispose();
    _parentNameCtrl.dispose();
    _parentPhoneCtrl.dispose();
    _parentPassCtrl.dispose();
    super.dispose();
  }

  void _submitTeacher(AppState appState) {
    if (_teacherNameCtrl.text.isEmpty || _teacherSubjectCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zəhmət olmasa Müəllimin adını və fənnini daxil edin!')),
      );
      return;
    }

    final newTeacher = appState.createTeacherAccount(
      fullName: _teacherNameCtrl.text.trim(),
      subject: _teacherSubjectCtrl.text.trim(),
      roomNumber: _teacherRoomCtrl.text.trim().isEmpty ? 'Otaq 201' : _teacherRoomCtrl.text.trim(),
      phone: _teacherPhoneCtrl.text.trim(),
      password: _teacherPassCtrl.text.trim(),
      photoUrl: _teacherPhotoUrl,
      permissions: TeacherPermissions(
        canManageCafeteria: _permCafeteria,
        canManageMedical: _permMedical,
        canManageInventory: _permInventory,
      ),
    );

    Navigator.pop(context);
    _showCredentialsDialog(
      title: 'Müəllim Hesabı Yaradıldı',
      items: [
        _CredItem(label: 'Müəllim Adı', value: newTeacher.fullName),
        _CredItem(label: 'İdrak Kodu', value: newTeacher.idrakCode),
        _CredItem(label: 'İstifadəçi Adı (Login)', value: newTeacher.username),
        _CredItem(label: 'Şifrə', value: newTeacher.password),
        _CredItem(
          label: 'Verilən İcazələr',
          value: '${_permCafeteria ? "✅ Yeməkxana " : ""}${_permMedical ? "✅ Tibbi Kart " : ""}${_permInventory ? "✅ İnventar" : ""}',
        ),
      ],
    );
  }

  void _submitStudentAndParent(AppState appState) {
    if (_studentNameCtrl.text.isEmpty || _parentNameCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zəhmət olmasa Şagird və Valideyn adını qeyd edin!')),
      );
      return;
    }

    final allergies = _studentAllergiesCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    final result = appState.createStudentAndParentAccount(
      studentName: _studentNameCtrl.text.trim(),
      className: _studentClassCtrl.text.trim(),
      bloodGroup: _studentBloodCtrl.text.trim(),
      allergies: allergies,
      studentPassword: _studentPassCtrl.text.trim(),
      parentName: _parentNameCtrl.text.trim(),
      parentPhone: _parentPhoneCtrl.text.trim(),
      parentPassword: _parentPassCtrl.text.trim(),
      studentPhotoUrl: _studentPhotoUrl,
    );

    final student = result['student']!;
    final parent = result['parent']!;

    Navigator.pop(context);
    _showCredentialsDialog(
      title: 'Şagird və Əlaqəli Valideyn Hesabı Yaradıldı',
      items: [
        _CredItem(label: '🎓 Şagird Adı', value: student.fullName),
        _CredItem(label: 'Şagird İdrak Kodu', value: student.idrakCode),
        _CredItem(label: 'Şagird Logini', value: student.username),
        _CredItem(label: 'Şagird Şifrəsi', value: student.password),
        _CredItem(label: '----------------', value: '----------------'),
        _CredItem(label: '👨‍👩‍👧 Əlaqəli Valideyn', value: parent.fullName),
        _CredItem(label: 'Valideyn İdrak Kodu', value: parent.idrakCode),
        _CredItem(label: 'Valideyn Logini', value: parent.username),
        _CredItem(label: 'Valideyn Şifrəsi', value: parent.password),
      ],
    );
  }

  void _showCredentialsDialog({required String title, required List<_CredItem> items}) {
    showDialog(
      context: context,
      builder: (ctx) {
        final shareText = items.map((i) => '${i.label}: ${i.value}').join('\n');
        return Dialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.verified_rounded, color: AppColors.success, size: 28),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    children: items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 110,
                              child: Text(
                                item.label,
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: SelectableText(
                                item.value,
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: shareText));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Giriş məlumatları buferə kopyalandı!')),
                          );
                        },
                        icon: const Icon(Icons.copy_rounded, size: 16),
                        label: const Text('Kopyala'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Bağla'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Yeni İstifadəçi Hesabı Yarat',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Role Switcher
          Row(
            children: [
              Expanded(
                child: _buildTypeToggle(0, '👨‍🏫 Müəllim Hesabı'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildTypeToggle(1, '🎓 Şagird + Valideyn'),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Divider(color: AppColors.cardBorder),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: _selectedType == 0
                  ? _buildTeacherForm(appState)
                  : _buildStudentAndParentForm(appState),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeToggle(int index, String title) {
    final isSelected = _selectedType == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.cardBorder),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildTeacherForm(AppState appState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Müəllim Məlumatları',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primary),
        ),
        const SizedBox(height: 14),

        // Profile Photo Picker
        Center(
          child: ProfilePhotoPicker(
            initialPhotoUrl: _teacherPhotoUrl,
            onPhotoUploaded: (url) => setState(() => _teacherPhotoUrl = url),
            folder: 'idrak/profiles/teachers',
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Profil fotosu əlavə edin (ixtiyari)',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _teacherNameCtrl,
          decoration: const InputDecoration(labelText: 'Ad və Soyad *', hintText: 'Məs: Elvin Rəhimov'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _teacherSubjectCtrl,
          decoration: const InputDecoration(labelText: 'Tədris Etdiyi Fənn *', hintText: 'Məs: Fizika (IB HL)'),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _teacherRoomCtrl,
                decoration: const InputDecoration(labelText: 'Otaq / Laboratoriya', hintText: 'Məs: Otaq 304'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _teacherPhoneCtrl,
                decoration: const InputDecoration(labelText: 'Əlaqə Telefonu', hintText: '+994 50 111 22 33'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _teacherPassCtrl,
          decoration: const InputDecoration(labelText: 'İlkin Şifrə', hintText: '123456'),
        ),

        const SizedBox(height: 16),
        Text(
          'Admin Tərəfindən Verilən Xüsusi İcazələr (Yetkilər):',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),

        // 1. Cafeteria Permission Switch
        SwitchListTile(
          title: const Text('Kantin / Yeməkxana Menyusunu İdarə Etmək', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          subtitle: const Text('Müəllim həftəlik menyunu və yemək tərkiblərini redaktə edə bilər', style: TextStyle(fontSize: 11)),
          value: _permCafeteria,
          activeThumbColor: AppColors.gold,
          onChanged: (val) => setState(() => _permCafeteria = val),
        ),

        // 2. Medical Card Permission Switch
        SwitchListTile(
          title: const Text('Şagirdin Tibbi Qeydlərini & Allergiyalarını Yeniləmək', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          subtitle: const Text('Şagirdin xəstəlik tarixçəsinə və tibbi vərəqəsinə qeydlər əlavə edə bilər', style: TextStyle(fontSize: 11)),
          value: _permMedical,
          activeThumbColor: AppColors.danger,
          onChanged: (val) => setState(() => _permMedical = val),
        ),

        // 3. Inventory QR Ticket Permission Switch
        SwitchListTile(
          title: const Text('Otaq İnventar Nasazlıq Ticketləri Göndərmək', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
          subtitle: const Text('Proyektor və kompüter QR kodlarını skan edib şikayət göndərə bilər', style: TextStyle(fontSize: 11)),
          value: _permInventory,
          activeThumbColor: AppColors.primaryAccent,
          onChanged: (val) => setState(() => _permInventory = val),
        ),

        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _submitTeacher(appState),
            icon: const Icon(Icons.person_add_alt_1_rounded),
            label: const Text('Müəllim Hesabını Təsdiqlə və Yarat'),
          ),
        ),
      ],
    );
  }

  Widget _buildStudentAndParentForm(AppState appState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Student Info
        const Text(
          '🎓 Şagird Məlumatları',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primary),
        ),
        const SizedBox(height: 14),

        // Student Profile Photo Picker
        Center(
          child: ProfilePhotoPicker(
            initialPhotoUrl: _studentPhotoUrl,
            onPhotoUploaded: (url) => setState(() => _studentPhotoUrl = url),
            folder: 'idrak/profiles/students',
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Şagirdin profil fotosunu çəkin və ya seçin',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _studentNameCtrl,
          decoration: const InputDecoration(labelText: 'Şagirdin Ad və Soyadı *', hintText: 'Məs: Elmir Quliyev'),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _studentClassCtrl,
                decoration: const InputDecoration(labelText: 'Sinfi *', hintText: 'Məs: 9B'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _studentBloodCtrl,
                decoration: const InputDecoration(labelText: 'Qan Qrupu', hintText: 'A(II) Rh+'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _studentAllergiesCtrl,
          decoration: const InputDecoration(labelText: 'Allergiyalar (Vergüllə ayırın)', hintText: 'Məs: Qlüten, Fındıq'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _studentPassCtrl,
          decoration: const InputDecoration(labelText: 'Şagird Şifrəsi', hintText: '123456'),
        ),

        const SizedBox(height: 20),
        Divider(color: AppColors.cardBorder),
        const SizedBox(height: 10),

        // Parent Info (Linked automatically)
        const Text(
          '👨‍👩‍👧 Əlaqəli Valideyn Məlumatları',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.goldDark),
        ),
        const SizedBox(height: 4),
        Text(
          'Valideyn hesabı avtomatik olaraq bu şagirdə bağlanacaq və yalnız onun məlumatlarını görəcək.',
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _parentNameCtrl,
          decoration: const InputDecoration(labelText: 'Valideynin Ad və Soyadı *', hintText: 'Məs: Vüqar Quliyev'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _parentPhoneCtrl,
          decoration: const InputDecoration(labelText: 'Valideyn Əlaqə Nömrəsi', hintText: '+994 50 222 33 44'),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _parentPassCtrl,
          decoration: const InputDecoration(labelText: 'Valideyn Şifrəsi', hintText: '123456'),
        ),

        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => _submitStudentAndParent(appState),
            icon: const Icon(Icons.group_add_rounded),
            label: const Text('Şagird və Valideyn Hesabını Birlikdə Yarat'),
          ),
        ),
      ],
    );
  }
}

class _CredItem {
  final String label;
  final String value;
  _CredItem({required this.label, required this.value});
}
