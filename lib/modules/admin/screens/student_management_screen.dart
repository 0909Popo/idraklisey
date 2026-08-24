import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/models/student_model.dart';
import '../../../data/models/user_model.dart';
import '../../../providers/app_state.dart';
import '../widgets/edit_student_sheet.dart';
import 'student_registration_screen.dart';

/// Şagird İdarəsi: bütün şagirdlərin siyahısı, axtarış, sinif filtri və
/// üzərinə basıldıqda tam profil (şəxsi məlumatlar + veli məlumatları).
class StudentManagementScreen extends StatefulWidget {
  const StudentManagementScreen({super.key});

  @override
  State<StudentManagementScreen> createState() => _StudentManagementScreenState();
}

class _StudentManagementScreenState extends State<StudentManagementScreen> {
  final _searchCtrl = TextEditingController();
  String? _filterClass;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final students = appState.students;
    final classes = appState.allDistinctClasses;
    final dateFormat = DateFormat('dd.MM.yyyy');

    final q = _searchCtrl.text.toLowerCase().trim();
    final filtered = students.where((s) {
      final matchesClass = _filterClass == null || s.className.toLowerCase() == _filterClass!.toLowerCase();
      final matchesSearch = q.isEmpty ||
          s.fullName.toLowerCase().contains(q) ||
          s.studentNumber.toLowerCase().contains(q) ||
          (s.finCode ?? '').toLowerCase().contains(q) ||
          (s.email ?? '').toLowerCase().contains(q);
      return matchesClass && matchesSearch;
    }).toList()
      ..sort((a, b) => a.fullName.compareTo(b.fullName));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
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
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.person_add_rounded, size: 18, color: Colors.white),
                  ),
                  tooltip: 'Yeni Şagird Qeydiyyatı',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StudentRegistrationScreen()),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF6C5CE7)],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -15,
                      bottom: -15,
                      child: Icon(Icons.school_rounded, size: 130, color: Colors.white.withAlpha(10)),
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
                                  child: const Icon(Icons.school_rounded, size: 22, color: Colors.white),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Şagird İdarəsi',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${students.length} qeydiyyatda olan şagird',
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

          // Axtarış + sinif filtri
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder),
                      boxShadow: AppShadows.sm,
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Ad, FIN, e-poçt və ya İdrak kodu ilə axtar...',
                        hintStyle: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                        filled: true,
                        fillColor: AppColors.surface,
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryAccent, size: 20),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: AppColors.primaryAccent, width: 1.5),
                        ),
                        suffixIcon: _searchCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildClassChip('Hamısı (${students.length})', null),
                        for (final cls in classes) _buildClassChip(cls, cls),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (filtered.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primaryAccent.withAlpha(8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.person_search_rounded, size: 44, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 14),
                    Text('Axtarışa uyğun şagird tapılmadı.', style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildStudentCard(context, filtered[index], dateFormat),
                  childCount: filtered.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildClassChip(String label, String? cls) {
    final isSelected = _filterClass == cls;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _filterClass = cls),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryAccent : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.primaryAccent : AppColors.cardBorder,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentCard(BuildContext context, StudentProfile student, DateFormat dateFormat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: () => _showStudentDetails(context, student, dateFormat),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.cardBorder),
              boxShadow: AppShadows.sm,
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder),
                    image: DecorationImage(
                      image: NetworkImage(student.photoUrl),
                      fit: BoxFit.cover,
                      onError: (_, __) {},
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              student.fullName,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.2),
                            ),
                          ),
                          StatusBadge(label: student.className, color: AppColors.primaryAccent, fontSize: 10),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'ID: ${student.studentNumber}${student.finCode != null ? ' • FIN: ${student.finCode}' : ''}',
                        style: TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                      ),
                      if (student.email != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          student.email!,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 10.5, color: AppColors.primaryAccent, fontWeight: FontWeight.w600),
                        ),
                      ],
                      const SizedBox(height: 2),
                      Text(
                        'Valideyn: ${student.parentName}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: AppColors.goldDark, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showStudentDetails(BuildContext context, StudentProfile student, DateFormat dateFormat) {
    // Valideyn hesabını tap (FIN kodu oradan götürülür) — Övladlar modelinə görə
    // həm linkedStudentId, həm də linkedStudentIds siyahısı yoxlanılır
    final appState = context.read<AppState>();
    AppUser? parentUser;
    for (final u in appState.users) {
      if (u.role == UserRole.parent &&
          (u.linkedStudentId == student.id || u.linkedStudentIds.contains(student.id))) {
        parentUser = u;
        break;
      }
    }

    // Eyni valideynin digər övladları (qardaş-bacı)
    final siblingIds = <String>{
      if (parentUser?.linkedStudentId != null) parentUser!.linkedStudentId!,
      ...?parentUser?.linkedStudentIds,
    }.where((id) => id != student.id).toSet();
    final siblings = appState.students.where((s) => siblingIds.contains(s.id)).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.86,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              // Tutacaq
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 42,
                height: 4.5,
                decoration: BoxDecoration(color: AppColors.cardBorder, borderRadius: BorderRadius.circular(10)),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
                  children: [
                    // Başlıq
                    Row(
                      children: [
                        Container(
                          width: 66,
                          height: 66,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.cardBorder),
                            image: DecorationImage(
                              image: NetworkImage(student.photoUrl),
                              fit: BoxFit.cover,
                              onError: (_, __) {},
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student.fullName,
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.4),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  StatusBadge(label: student.className, color: AppColors.primaryAccent, fontSize: 10.5),
                                  const SizedBox(width: 6),
                                  StatusBadge(label: 'ID: ${student.studentNumber}', color: AppColors.textSecondary, fontSize: 10),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Redaktə düyməsi (edit_students səlahiyyəti olanlara)
                        if (appState.hasPermission('edit_students'))
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(ctx);
                              showEditStudentSheet(context, student);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.primaryAccent.withAlpha(15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.primaryAccent.withAlpha(40)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.edit_rounded, size: 15, color: AppColors.primaryAccent),
                                  const SizedBox(width: 5),
                                  Text('Redaktə', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primaryAccent)),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ═══ ƏSAS MƏLUMATLAR (dönər, ən vacib faktlar) ═══
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF1A1B2E), Color(0xFF4437CA), Color(0xFF6C5CE7)],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: AppShadows.md,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: _heroFact(Icons.school_rounded, 'Sinif', student.className)),
                              Expanded(child: _heroFact(Icons.pin_rounded, 'FIN Kod', _dv(student.finCode))),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(child: _heroFact(Icons.bloodtype_rounded, 'Qan Qrupu', _dv(student.bloodGroup))),
                              Expanded(child: _heroFact(Icons.cake_rounded, 'Doğum', student.birthDate != null ? dateFormat.format(student.birthDate!) : _empty)),
                            ],
                          ),
                          Divider(color: Colors.white.withAlpha(40), height: 22),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(color: Colors.white.withAlpha(25), shape: BoxShape.circle),
                                child: const Icon(Icons.family_restroom_rounded, size: 15, color: Colors.white),
                              ),
                              const SizedBox(width: 9),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      student.parentName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900),
                                    ),
                                    Text(
                                      'Valideyn • ${student.parentPhone}',
                                      style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 10.5, fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Şəxsi məlumatlar (bütün sahələr həmişə görünür)
                    _buildDetailBox(
                      icon: Icons.badge_rounded,
                      title: 'Şəxsi Məlumatlar',
                      color: AppColors.primaryAccent,
                      rows: [
                        MapEntry('Ad / Soyad', student.fullName),
                        MapEntry('Ata adı', _dv(student.fatherName)),
                        MapEntry('Cins', _dv(student.gender)),
                        MapEntry('Doğum Tarixi', student.birthDate != null ? dateFormat.format(student.birthDate!) : _empty),
                        MapEntry('FIN Kod', _dv(student.finCode)),
                        MapEntry('Ünvan', _dv(student.address)),
                        MapEntry('E-poçt (Login)', _dv(student.email)),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Veli (bütün sahələr həmişə görünür)
                    _buildDetailBox(
                      icon: Icons.family_restroom_rounded,
                      title: 'Valideyn Məlumatları',
                      color: AppColors.goldDark,
                      rows: [
                        MapEntry('Ad Soyad', student.parentName),
                        MapEntry('Telefon', student.parentPhone),
                        MapEntry('FIN Kod', _dv(parentUser?.finCode)),
                        MapEntry('Doğum Tarixi', parentUser?.birthDate != null ? dateFormat.format(parentUser!.birthDate!) : _empty),
                        MapEntry('E-poçt (Login)', _dv(student.parentEmail)),
                        MapEntry('Ünvan', _dv(student.parentAddress)),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Digər övladlar (qardaş-bacı) — Övladlar modeli
                    if (siblings.isNotEmpty)
                      _buildDetailBox(
                        icon: Icons.diversity_3_rounded,
                        title: 'Digər Övladlar (${siblings.length})',
                        color: AppColors.success,
                        rows: [
                          for (final s in siblings)
                            MapEntry(s.fullName, '${s.className} • ${s.studentNumber}'),
                        ],
                      ),
                    if (siblings.isNotEmpty) const SizedBox(height: 14),

                    // Səhiyyə + akademik
                    _buildDetailBox(
                      icon: Icons.favorite_rounded,
                      title: 'Səhiyyə və Akademik',
                      color: AppColors.danger,
                      rows: [
                        MapEntry('Qan Qrupu', _dv(student.bloodGroup)),
                        MapEntry('Alergiyalar', (student.allergies?.isEmpty ?? true) ? 'Yoxdur' : student.allergies!.join(', ')),
                        MapEntry('GPA', student.gpa.toStringAsFixed(1)),
                        MapEntry('Davamiyyət', '${student.attendanceRate}%'),
                        MapEntry('Təhsil İli', student.academicYear),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Detal kartının ən üstündəki vurğulu əsas fakt
  Widget _heroFact(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(color: Colors.white.withAlpha(22), shape: BoxShape.circle),
          child: Icon(icon, size: 15, color: Colors.white),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.white.withAlpha(170), fontSize: 9.5, fontWeight: FontWeight.w700, letterSpacing: 0.3)),
              const SizedBox(height: 1),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Detal görüntüsündə boş sahələr üçün fallback mətn
  static const _empty = 'Daxil edilməyib';
  String _dv(String? v) => (v == null || v.trim().isEmpty) ? _empty : v;

  Widget _buildDetailBox({
    required IconData icon,
    required String title,
    required Color color,
    required List<MapEntry<String, String>> rows,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(color: color.withAlpha(15), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 10),
              Text(title, style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.2)),
            ],
          ),
          const SizedBox(height: 12),
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) Divider(color: AppColors.cardBorder.withAlpha(60), height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 120,
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
}
