import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
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
        elevation: 0,
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
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Permission Banner (if teacher has permission)
            if (canManageMedical)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: AppColors.danger.withAlpha(15),
                child: Row(
                  children: const [
                    Icon(Icons.medical_services_outlined, size: 16, color: AppColors.danger),
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
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF991B1B), Color(0xFFDC2626)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppShadows.sm,
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
                              color: Colors.white.withAlpha(30),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'İdrak Liseyi Tibb Mərkəzi',
                                style: TextStyle(color: Colors.white70, fontSize: 10.5, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                student.fullName,
                                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'TƏSDİQLƏNİB',
                          style: TextStyle(
                            color: Color(0xFFDC2626),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Divider(color: Colors.white.withAlpha(35), height: 1),
                  const SizedBox(height: 12),
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
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'BMI: ${med.bmiCategory}',
                        style: TextStyle(color: med.bmiColor, fontSize: 10.5, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                  if (med.bmiWarning != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(220),
                        borderRadius: BorderRadius.circular(8),
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
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Qeydə alınmış allergiya və ya qida həssaslığı yoxdur.',
                      style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
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
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: med.chronicConditions.map((cond) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline_rounded, color: AppColors.primaryAccent, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              cond,
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              )
            else
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.health_and_safety_outlined, color: AppColors.primaryAccent, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Xroniki xəstəlik və ya daimi diaqnoz qeydi yoxdur.',
                      style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 10),

            // 🆕 PARENT MEDICAL NOTES SECTION
            const SectionHeader(
              title: 'Valideyn Tibbi Qeydləri',
              subtitle: 'Valideyn tərəfindən bildiriş və xəbərdarlıqlar',
            ),

            if (med.parentNotes.isNotEmpty)
              ...med.parentNotes.map((note) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primaryAccent.withAlpha(50)),
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
                            color: AppColors.primaryAccent.withAlpha(15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.message_outlined, color: AppColors.primaryAccent, size: 14),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            note.parentName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: AppColors.primaryAccent),
                          ),
                        ),
                        Text(
                          dateFormat.format(note.date),
                          style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      note.note,
                      style: TextStyle(fontSize: 12.5, color: AppColors.textPrimary, height: 1.4),
                    ),
                  ],
                ),
              ))
            else
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppColors.primaryAccent, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Valideyn tərəfindən tibbi qeyd və ya xəbərdarlıq daxil edilməyib.',
                        style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),

            // Veli nota ekleme butonu
            if (appState.currentUser?.role == UserRole.parent)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddParentNoteDialog(context, appState),
                    icon: const Icon(Icons.add_comment_outlined, size: 18),
                    label: const Text('Yeni Tibbi Qeyd Əlavə Et'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 10),

            // Vaccine History Table
            const SectionHeader(
              title: 'Peyvənd Tarixçəsi Cədvəli',
              subtitle: 'Dövlət peyvənd təqviminə uyğun rəsmi qeydlər',
            ),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
                boxShadow: AppShadows.sm,
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryAccent.withAlpha(12),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: const Row(
                      children: [
                        Expanded(flex: 3, child: Text('Peyvənd Növü', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: AppColors.primaryAccent))),
                        Expanded(flex: 2, child: Text('Tarix', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: AppColors.primaryAccent))),
                        Expanded(flex: 2, child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: AppColors.primaryAccent))),
                      ],
                    ),
                  ),

                  if (med.vaccineHistory.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Text('Peyvənd qeydi daxil edilməyib.', style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: med.vaccineHistory.length,
                      separatorBuilder: (_, _) => Divider(color: AppColors.cardBorder, height: 1),
                      itemBuilder: (context, index) {
                        final item = med.vaccineHistory[index];
                        final isDone = item.status == 'Tamamlandı';
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Text(
                                  item.name,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textPrimary),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  dateFormat.format(item.date),
                                  style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
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
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w500)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
      ],
    );
  }

  Widget _buildAllergyCard(AllergyItem allergy) {
    final severityColor = allergy.severity == 'Kritik'
        ? AppColors.danger
        : allergy.severity == 'Yüksək dərəcə'
            ? Colors.orange
            : AppColors.warning;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: severityColor.withAlpha(50), width: 1.2),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: severityColor, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    allergy.name,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              StatusBadge(
                label: allergy.severity,
                color: severityColor,
                fontSize: 9.5,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Reaksiya: ${allergy.reaction}',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'İlk Yardım: ${allergy.firstAid}',
              style: TextStyle(fontSize: 11, color: severityColor, fontWeight: FontWeight.w600),
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

  void _showAddParentNoteDialog(BuildContext context, AppState appState) {
    final noteCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.medical_information_outlined, color: AppColors.primaryAccent, size: 24),
              SizedBox(width: 8),
              Expanded(child: Text('Tibbi Qeyd Əlavə Et')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Övladınızın sağlığı ilə bağlı məktəb həkimi və müəllimlərinə bildirmək istədiyiniz məlumat:',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: noteCtrl,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Tibbi Qeyd və ya Xəbərdarlıq',
                  hintText: 'Məsələn: Uşaq bu həftə zökəm olub, dərslərdə çox gərginləşməməlidir.',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Ləğv et'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                if (noteCtrl.text.trim().isNotEmpty) {
                  appState.addParentMedicalNote(
                    appState.student.id,
                    noteCtrl.text.trim(),
                  );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tibbi qeyd uğurla əlavə edildi! Məktəb həkimi və müəllimlər görə biləcək.'),
                      backgroundColor: AppColors.success,
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Əlavə Et'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryAccent,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }
}
