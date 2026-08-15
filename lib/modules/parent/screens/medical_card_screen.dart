import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/section_header.dart';
import '../../../providers/app_state.dart';
import '../../../data/models/medical_model.dart';

class MedicalCardScreen extends StatelessWidget {
  const MedicalCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final student = appState.student;
    final med = appState.getMedicalCardForStudent(student.id);
    final dateFormat = DateFormat('dd.MM.yyyy');

    final currentUser = appState.currentUser;
    final canManageMedical = currentUser?.role == UserRole.admin ||
        (currentUser?.role == UserRole.teacher &&
            (currentUser?.teacherPermissions?.canManageMedical ?? false));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('${student.fullName} • Tibbi Kart'),
      ),
      floatingActionButton: canManageMedical
          ? FloatingActionButton.extended(
              onPressed: () => _showAddAllergyDialog(context, appState),
              backgroundColor: AppColors.danger,
              icon: const Icon(Icons.add_alert_rounded, color: Colors.white),
              label: const Text('Allergiya Əlavə Et', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Permission Banner (if teacher has permission)
            if (canManageMedical)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: AppColors.danger.withAlpha(20),
                child: Row(
                  children: const [
                    Icon(Icons.medical_services_rounded, size: 16, color: AppColors.danger),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Admin icazəsi aktivdir: Şagirdin tibbi və allergiya qeydlərini birbaşa daxil edə bilərsiniz.',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.danger),
                      ),
                    ),
                  ],
                ),
              ),

            // Top Medical Passport Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF991B1B), Color(0xFFDC2626), Color(0xFFEF4444)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withAlpha(80),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(40),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'İdrak Liseyi Tibb Mərkəzi',
                                style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                student.fullName,
                                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'TƏSDİQLƏNİB',
                          style: TextStyle(
                            color: Color(0xFFDC2626),
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  const Divider(color: Colors.white30, height: 1),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildPassportInfo(
                        'Qan Qrupu',
                        (med.bloodGroup.isNotEmpty && !med.bloodGroup.toLowerCase().contains('yoxdur') && !med.bloodGroup.toLowerCase().contains('məlumat'))
                            ? med.bloodGroup
                            : 'Qeyd yoxdur',
                      ),
                      _buildPassportInfo('Boy / Çəki', med.heightCm > 0 ? '${med.heightCm.toInt()} sm / ${med.weightKg.toInt()} kq' : 'Qeyd yoxdur'),
                      _buildPassportInfo('BMI İndeksi', med.bmi > 0 ? med.bmiDisplay : 'Hesablanmayıb'),
                    ],
                  ),
                  if (med.bmi > 0) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'BMI: ${med.bmiCategory}',
                        style: TextStyle(color: med.bmiColor, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  if (med.bmiWarning != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(220),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        med.bmiWarning!,
                        style: TextStyle(color: med.bmiColor, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Critical Allergies Section
            const SectionHeader(
              title: 'Allergiya Xəbərdarlıqları',
              subtitle: 'Yeməkxana və ilk tibbi yardım üçün xüsusi diqqət',
            ),

            if (med.allergies.isNotEmpty)
              ...med.allergies.map((allergy) => _buildAllergyCard(allergy))
            else
              CustomCard(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: const [
                    Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Qeydə alınmış allergiya və ya qida həssaslığı yoxdur.',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 10),

            // Chronic Conditions
            const SectionHeader(
              title: 'Xroniki Keçirdiyi Xəstəliklər & Göstərişlər',
              subtitle: 'Həkim təlimatları və daimi qeydlər',
            ),

            if (med.chronicConditions.isNotEmpty)
              CustomCard(
                child: Column(
                  children: med.chronicConditions.map((cond) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle_outline_rounded, color: AppColors.primaryAccent, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              cond,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              )
            else
              CustomCard(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: const [
                    Icon(Icons.health_and_safety_outlined, color: AppColors.primary, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Xroniki xəstəlik və ya daimi diaqnoz qeydi yoxdur.',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 10),

            // Vaccine History Table
            const SectionHeader(
              title: 'Peyvənd Tarixçəsi Cədvəli',
              subtitle: 'Dövlət peyvənd təqviminə uyğun rəsmi qeydlər',
            ),

            CustomCard(
              padding: const EdgeInsets.all(0),
              child: Column(
                children: [
                  // Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(15),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: const Row(
                      children: [
                        Expanded(flex: 3, child: Text('Peyvənd Növü', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary))),
                        Expanded(flex: 2, child: Text('Tarix', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary))),
                        Expanded(flex: 2, child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary))),
                      ],
                    ),
                  ),

                  // Table Rows
                  if (med.vaccineHistory.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: Text('Peyvənd qeydi daxil edilməyib.', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: med.vaccineHistory.length,
                      separatorBuilder: (_, _) => const Divider(color: AppColors.cardBorder, height: 1),
                      itemBuilder: (context, index) {
                        final item = med.vaccineHistory[index];
                        final isDone = item.status == 'Tamamlandı';
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.name,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                                    ),
                                    Text(
                                      item.doctor,
                                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  dateFormat.format(item.date),
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: StatusBadge(
                                  label: item.status,
                                  color: isDone ? AppColors.success : AppColors.warning,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                  if (canManageMedical) ...[
                    const Divider(color: AppColors.cardBorder, height: 1),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: () => _showAddVaccineDialog(context, appState, student.id),
                          icon: const Icon(Icons.vaccines_rounded, size: 16, color: AppColors.primary),
                          label: const Text('+ Peyvənd / Vaksina Qeydi Əlavə Et', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 14),

            // 👨‍👩‍👧 Parent Notes Section (Multiple notes)
            SectionHeader(
              title: 'Valideyn Qeydləri',
              subtitle: 'Övladınızın səhhəti, pəhrizi və xüsusi həssaslığı barədə qeydlər',
              trailing: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.goldDark,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => _showAddParentNoteDialog(context, appState, student.id),
                icon: const Icon(Icons.note_add_rounded, size: 16, color: Colors.white),
                label: const Text('Qeyd Yaz', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ),

            if (med.parentNotes.isNotEmpty)
              ...med.parentNotes.map((note) => CustomCard(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.all(12),
                backgroundColor: const Color(0xFFFFFBEB),
                border: Border.all(color: AppColors.goldLight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.family_restroom_rounded, size: 16, color: AppColors.goldDark),
                            const SizedBox(width: 6),
                            Text(
                              note.parentName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.goldDark),
                            ),
                          ],
                        ),
                        Text(
                          dateFormat.format(note.date),
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      note.note,
                      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.3),
                    ),
                  ],
                ),
              ))
            else
              CustomCard(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: const [
                    Icon(Icons.info_outline_rounded, size: 18, color: AppColors.textMuted),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Valideyn tərəfindən hələlik heç bir qeyd daxil edilməyib. Yuxarıdakı "Qeyd Yaz" düyməsindən istifadə edə bilərsiniz.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 14),

            // Emergency Contact & Lyceum Doctor Note
            CustomCard(
              backgroundColor: const Color(0xFFF0FDF4),
              border: Border.all(color: AppColors.success.withAlpha(80)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.local_hospital_rounded, color: AppColors.success, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Məktəb Həkiminin Rəsmi Qeydi',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.success),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    med.lyceumDoctorNotes.isNotEmpty ? med.lyceumDoctorNotes : 'Məktəb həkimi tərəfindən xüsusi qeyd daxil edilməyib.',
                    style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: AppColors.cardBorder),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Təcili Əlaqə Şəxsi:', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                          Text(med.emergencyContactName.isNotEmpty ? med.emergencyContactName : student.parentName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                        ],
                      ),
                      Text(
                        med.emergencyContactPhone.isNotEmpty ? med.emergencyContactPhone : student.parentPhone,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primaryAccent),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPassportInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _buildAllergyCard(AllergyItem allergy) {
    Color severityColor = allergy.severity == 'Kritik'
        ? AppColors.danger
        : allergy.severity == 'Yüksək dərəcə'
            ? Colors.deepOrange
            : AppColors.warning;

    return CustomCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.all(14),
      border: Border.all(color: severityColor.withAlpha(60), width: 1.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: severityColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    allergy.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              StatusBadge(
                label: allergy.severity,
                color: severityColor,
                fontSize: 10,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Reaksiya: ${allergy.reaction}',
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'İlk Yardım: ${allergy.firstAid}',
              style: TextStyle(fontSize: 12, color: severityColor, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddAllergyDialog(BuildContext context, AppState appState) {
    final nameCtrl = TextEditingController();
    final reactionCtrl = TextEditingController();
    final firstAidCtrl = TextEditingController();
    String severity = 'Yüksək dərəcə';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Yeni Allergiya Xəbərdarlığı Əlavə Et'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Allergiya Adı (Məs: Çiyələk)')),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: severity,
                      decoration: const InputDecoration(labelText: 'Təhlükə Dərəcəsi'),
                      items: ['Orta dərəcə', 'Yüksək dərəcə', 'Kritik'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (v) => setDialogState(() => severity = v!),
                    ),
                    const SizedBox(height: 10),
                    TextField(controller: reactionCtrl, decoration: const InputDecoration(labelText: 'Reaksiya Təsiri (Məs: Səpgi)')),
                    const SizedBox(height: 10),
                    TextField(controller: firstAidCtrl, decoration: const InputDecoration(labelText: 'İlk Yardım Təlimatı')),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Ləğv et')),
                ElevatedButton(
                  onPressed: () {
                    if (nameCtrl.text.isNotEmpty) {
                      final newAllergy = AllergyItem(
                        name: nameCtrl.text.trim(),
                        severity: severity,
                        reaction: reactionCtrl.text.trim().isEmpty ? 'Allergik reaksiya' : reactionCtrl.text.trim(),
                        firstAid: firstAidCtrl.text.trim().isEmpty ? 'Tibb otağına məlumat verin' : firstAidCtrl.text.trim(),
                      );
                      appState.addAllergy(newAllergy);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Allergiya tibbi karta əlavə edildi!'), backgroundColor: AppColors.success),
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

  void _showAddVaccineDialog(BuildContext context, AppState appState, String studentId) {
    final nameCtrl = TextEditingController(text: 'QPM (Qızılca, Parotit, Məxmərək)');
    final doctorCtrl = TextEditingController(text: 'Dr. Əliyeva N. (Məktəb Tibb Mərkəzi)');
    String status = 'Tamamlandı';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Peyvənd / Vaksina Qeydi Əlavə Et'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Peyvənd Növü (Məs: Hepatit B, QPM) *'),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: status,
                      decoration: const InputDecoration(labelText: 'Vuruluş Statusu'),
                      items: ['Tamamlandı', 'Növbəti doza gözlənilir', 'Müddəti çatıb'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (v) => setDialogState(() => status = v!),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: doctorCtrl,
                      decoration: const InputDecoration(labelText: 'Həkim / Tibb Müəssisəsi'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Ləğv et')),
                ElevatedButton(
                  onPressed: () {
                    if (nameCtrl.text.trim().isNotEmpty) {
                      final newVaccine = VaccineRecord(
                        name: nameCtrl.text.trim(),
                        date: DateTime.now(),
                        status: status,
                        doctor: doctorCtrl.text.trim().isNotEmpty ? doctorCtrl.text.trim() : 'Məktəb Tibb Otağı',
                      );
                      appState.addVaccineRecordToStudent(studentId, newVaccine);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Peyvənd qeydi yeniləndi və yadda saxlanıldı!'), backgroundColor: AppColors.success),
                      );
                    }
                  },
                  child: const Text('Yadda Saxla'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddParentNoteDialog(BuildContext context, AppState appState, String studentId) {
    final noteCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.edit_note_rounded, color: AppColors.goldDark),
              SizedBox(width: 8),
              Text('Valideyn Tibbi Qeydi'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Övladınızın səhhəti, içdiyi dərmanlar, xüsusi pəhriz və ya həkim təlimatlarını bura yaza bilərsiniz. Məktəb həkimi və müəllimlər bu qeydi görəcək.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Qeydiniz *',
                  hintText: 'Məsələn: Günorta yeməyində süd məhsulları verilməsin, həkim pəhrizi var...',
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Ləğv et')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldDark),
              onPressed: () {
                if (noteCtrl.text.trim().isNotEmpty) {
                  appState.addParentMedicalNote(studentId, noteCtrl.text.trim());
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Tibbi qeydiniz uğurla əlavə edildi!'), backgroundColor: AppColors.success),
                  );
                }
              },
              child: const Text('Qeyd Et', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
