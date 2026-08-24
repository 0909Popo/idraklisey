import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../providers/app_state.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/role_model.dart';
import '../widgets/edit_employee_sheet.dart';
import 'create_employee_screen.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  UserRole? _filterRole;
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    // Yalnız işçilər: şagird və valideyn hesabları Şagird İdarəsindədir
    final staff = appState.users
        .where((u) => u.role != UserRole.student && u.role != UserRole.parent)
        .toList();
    final dateFormat = DateFormat('dd.MM.yyyy');

    final filtered = staff.where((u) {
      final matchesRole = _filterRole == null || u.role == _filterRole;
      final q = _searchCtrl.text.toLowerCase().trim();
      final matchesSearch = q.isEmpty ||
          u.fullName.toLowerCase().contains(q) ||
          u.username.toLowerCase().contains(q) ||
          (u.email ?? '').toLowerCase().contains(q) ||
          (u.finCode ?? '').toLowerCase().contains(q) ||
          u.idrakCode.toLowerCase().contains(q);
      return matchesRole && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Gradient Header ──
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
                  tooltip: 'Yeni İşçi Hesabı Yarat',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CreateEmployeeScreen()),
                    );
                  },
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0D9488)],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -15,
                      bottom: -15,
                      child: Icon(Icons.manage_accounts_rounded, size: 130, color: Colors.white.withAlpha(10)),
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
                                  child: const Icon(Icons.people_alt_rounded, size: 22, color: Colors.white),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'İstifadəçi Hesabları',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${staff.length} işçi hesabı',
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

          // ── Search & Filter Controls ──
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
                        hintText: 'Ad, İdrak kodu və ya istifadəçi adı axtar...',
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
                        _buildRoleFilterChip('Hamısı (${staff.length})', null),
                        _buildRoleFilterChip('Müəllimlər', UserRole.teacher),
                        _buildRoleFilterChip('İnzibatçı və İşçilər', UserRole.admin),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Users List ──
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
                    Text('Axtarışa uyğun istifadəçi tapılmadı.', style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final user = filtered[index];
                    return _buildUserCard(context, appState, user, dateFormat);
                  },
                  childCount: filtered.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRoleFilterChip(String label, UserRole? role) {
    final isSelected = _filterRole == role;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _filterRole = role),
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
            boxShadow: isSelected
                ? [BoxShadow(color: AppColors.primaryAccent.withAlpha(30), blurRadius: 6, offset: const Offset(0, 2))]
                : [],
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

  Widget _buildUserCard(BuildContext context, AppState appState, AppUser user, DateFormat dateFormat) {
    Color roleColor;
    switch (user.role) {
      case UserRole.admin:
        roleColor = Colors.red;
        break;
      case UserRole.teacher:
        roleColor = const Color(0xFF0D9488);
        break;
      case UserRole.student:
        roleColor = AppColors.primaryAccent;
        break;
      case UserRole.parent:
        roleColor = AppColors.goldDark;
        break;
    }

    final assignedRole = appState.getRoleById(user.assignedRoleId);
    final badgeLabel = assignedRole?.name ?? user.role.displayName.split(' ').first;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: () => _showStaffDetails(context, appState, user, assignedRole, dateFormat),
          borderRadius: BorderRadius.circular(18),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.cardBorder),
              boxShadow: AppShadows.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: roleColor.withAlpha(15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: roleColor.withAlpha(30)),
                      ),
                      child: Icon(user.role.icon, color: roleColor, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  user.fullName,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                              StatusBadge(
                                label: badgeLabel,
                                color: roleColor,
                                fontSize: 10,
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          if (user.email != null && user.email!.isNotEmpty) ...[
                            Text(
                              user.email!,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11.5, color: AppColors.primaryAccent, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                          ],
                          Text(
                            'İdrak Kodu: ${user.idrakCode}${user.finCode != null ? ' • FIN: ${user.finCode}' : ''}',
                            style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                          ),
                          if (user.role == UserRole.teacher && user.subject != null) ...[
                            const SizedBox(height: 3),
                            Text(
                              'Fənn: ${user.subject} (${user.roomNumber ?? "Otaq təyin olunmayıb"})',
                              style: const TextStyle(fontSize: 11.5, color: AppColors.primaryAccent, fontWeight: FontWeight.w600),
                            ),
                          ],
                          if (user.role == UserRole.parent && user.linkedStudentId != null) ...[
                            const SizedBox(height: 3),
                            Text(
                              'Əlaqəli Şagird ID: ${user.linkedStudentId}',
                              style: const TextStyle(fontSize: 11.5, color: AppColors.goldDark, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),

                // Teacher Permissions Panel (if Teacher)
                if (user.role == UserRole.teacher && user.teacherPermissions != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Müəllimə Verilmiş Admin Yetkiləri:',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                            ),
                            GestureDetector(
                              onTap: () => _showEditPermissionsDialog(context, appState, user),
                              child: const Text('Dəyiş', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primaryAccent)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            _buildPermChip('Yeməkxana Menyu', user.teacherPermissions!.canManageCafeteria, AppColors.gold),
                            _buildPermChip('Tibbi Qeydlər', user.teacherPermissions!.canManageMedical, AppColors.danger),
                            _buildPermChip('İnventar QR', user.teacherPermissions!.canManageInventory, AppColors.primaryAccent),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 10),
                Divider(color: AppColors.cardBorder, height: 1),
                const SizedBox(height: 8),

                // Footer: Status toggle & Credentials view
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          user.isActive ? Icons.check_circle_rounded : Icons.cancel_rounded,
                          size: 14,
                          color: user.isActive ? AppColors.success : AppColors.danger,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          user.isActive ? 'Aktiv Hesab' : 'Deaktiv Edilib',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: user.isActive ? AppColors.success : AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Şifrə: ${user.password}',
                          style: TextStyle(fontSize: 11, fontFamily: 'monospace', color: AppColors.textMuted),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: () => appState.toggleUserStatus(user.id),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: (user.isActive ? AppColors.danger : AppColors.success).withAlpha(12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              user.isActive ? 'Deaktiv et' : 'Aktivləşdir',
                              style: TextStyle(
                                fontSize: 11,
                                color: user.isActive ? AppColors.danger : AppColors.success,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
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
      ),
    );
  }

  /// İşçinin tam profili: bütün HR məlumatları, rol, səlahiyyətlər, hesab
  void _showStaffDetails(BuildContext context, AppState appState, AppUser user, Role? assignedRole, DateFormat dateFormat) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isTeacher = user.role == UserRole.teacher;
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.86,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
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
                    Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: AppColors.cardBorder),
                            image: user.photoUrl != null
                                ? DecorationImage(
                                    image: NetworkImage(user.photoUrl!),
                                    fit: BoxFit.cover,
                                    onError: (_, __) {},
                                  )
                                : null,
                            color: AppColors.background,
                          ),
                          child: user.photoUrl == null
                              ? Icon(user.role.icon, color: AppColors.primaryAccent, size: 26)
                              : null,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.fullName,
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.4),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  StatusBadge(
                                    label: user.role == UserRole.teacher ? 'Müəllim' : (assignedRole?.name ?? 'İnzibatçı'),
                                    color: user.role == UserRole.teacher ? const Color(0xFF0D9488) : Colors.red,
                                    fontSize: 10.5,
                                  ),
                                  const SizedBox(width: 6),
                                  StatusBadge(
                                    label: user.isActive ? 'Aktiv' : 'Deaktiv',
                                    color: user.isActive ? AppColors.success : AppColors.danger,
                                    fontSize: 10,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Redaktə düyməsi (edit_users səlahiyyəti olanlara)
                        if (appState.hasPermission('edit_users'))
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(ctx);
                              showEditEmployeeSheet(context, user);
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
                        gradient: isTeacher
                            ? const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF134E4A), Color(0xFF0D9488), Color(0xFF14B8A6)],
                              )
                            : const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF7F1D1D), Color(0xFFB91C1C), Color(0xFFEF4444)],
                              ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: AppShadows.md,
                      ),
                      child: Column(
                        children: [
                          if (isTeacher) ...[
                            Row(
                              children: [
                                Expanded(child: _heroFact(Icons.menu_book_rounded, 'Fənn', _dv(user.subject))),
                                Expanded(child: _heroFact(Icons.meeting_room_rounded, 'Otaq', _dv(user.roomNumber))),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _heroFact(
                                    Icons.school_rounded,
                                    'Siniflər (${user.assignedClasses.length})',
                                    user.assignedClasses.isEmpty ? 'Yoxdur' : user.assignedClasses.join(', '),
                                  ),
                                ),
                              ],
                            ),
                          ] else ...[
                            Row(
                              children: [
                                Expanded(child: _heroFact(Icons.admin_panel_settings_rounded, 'Rol', assignedRole?.name ?? 'İnzibatçı')),
                                Expanded(child: _heroFact(Icons.work_rounded, 'Vəzifə', _dv(user.position))),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(child: _heroFact(Icons.phone_rounded, 'Telefon', user.phone.isEmpty ? _empty : user.phone)),
                                Expanded(child: _heroFact(Icons.alternate_email_rounded, 'E-poçt (Login)', _dv(user.email))),
                              ],
                            ),
                          ],
                          if (isTeacher) ...[
                            Divider(color: Colors.white.withAlpha(40), height: 22),
                            Row(
                              children: [
                                Expanded(child: _heroFact(Icons.phone_rounded, 'Telefon', user.phone.isEmpty ? _empty : user.phone)),
                                Expanded(child: _heroFact(Icons.cake_rounded, 'Doğum', user.birthDate != null ? dateFormat.format(user.birthDate!) : _empty)),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    _buildStaffInfoBox(
                      icon: Icons.badge_rounded,
                      title: 'Şəxsi Məlumatlar',
                      color: AppColors.primaryAccent,
                      rows: [
                        MapEntry('Ad / Soyad', user.fullName),
                        MapEntry('Ata adı', _dv(user.fatherName)),
                        MapEntry('Cins', _dv(user.gender)),
                        MapEntry('Doğum Tarixi', user.birthDate != null ? dateFormat.format(user.birthDate!) : _empty),
                        MapEntry('FIN Kod', _dv(user.finCode)),
                        MapEntry('Vətəndaşlıq', _dv(user.citizenship)),
                        MapEntry('ŞV Seriyası', _dv(user.idCardSerial)),
                        MapEntry('Ünvan', _dv(user.address)),
                        MapEntry('Telefon', user.phone.isEmpty ? _empty : user.phone),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildStaffInfoBox(
                      icon: Icons.payments_rounded,
                      title: 'İş Müqaviləsi və Əmək Haqqı',
                      color: AppColors.goldDark,
                      rows: [
                        MapEntry('Vəzifə adı', _dv(user.position)),
                        MapEntry('Təhsil Dərəcəsi', _dv(user.educationLevel)),
                        MapEntry('Bank', _dv(user.bankName)),
                        MapEntry('Əmək haqqı (gross)', user.salary != null ? '${_fmtSalary(user.salary!)} AZN' : _empty),
                        MapEntry('İşə qəbul', user.hireDate != null ? dateFormat.format(user.hireDate!) : _empty),
                        MapEntry('Müqavilə başlanğıc', user.contractStart != null ? dateFormat.format(user.contractStart!) : _empty),
                        MapEntry('Müqavilə bitmə', user.contractEnd != null ? dateFormat.format(user.contractEnd!) : 'Müddətsiz'),
                      ],
                    ),
                    const SizedBox(height: 14),
                    if (user.role == UserRole.teacher) ...[
                      _buildStaffInfoBox(
                        icon: Icons.work_rounded,
                        title: 'Müəllim Məlumatları',
                        color: const Color(0xFF0D9488),
                        rows: [
                          MapEntry('Fənn', _dv(user.subject)),
                          MapEntry('Otaq', _dv(user.roomNumber)),
                          MapEntry('Təyin Olunan Siniflər', user.assignedClasses.isEmpty ? 'Yoxdur' : user.assignedClasses.join(', ')),
                        ],
                      ),
                      const SizedBox(height: 14),
                    ] else ...[
                      _buildStaffInfoBox(
                        icon: Icons.admin_panel_settings_rounded,
                        title: 'Rol və Səlahiyyətlər',
                        color: Colors.red,
                        rows: [
                          MapEntry('Rol', assignedRole?.name ?? 'Təyin olunmayıb'),
                          MapEntry('Səlahiyyət sayı', '${assignedRole?.permissionIds.length ?? 0}'),
                        ],
                      ),
                      const SizedBox(height: 14),
                    ],
                    _buildStaffInfoBox(
                      icon: Icons.key_rounded,
                      title: 'Hesab Məlumatları',
                      color: AppColors.primaryAccent,
                      rows: [
                        MapEntry('E-poçt (Login)', _dv(user.email)),
                        MapEntry('İstifadəçi adı', user.username),
                        MapEntry('İdrak kodu', user.idrakCode),
                        MapEntry('Şifrə', user.password),
                        MapEntry('Qeydiyyat', dateFormat.format(user.createdAt)),
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

  /// Detal görüntüsündə boş sahələr üçün fallback mətn
  static const _empty = 'Daxil edilməyib';
  String _dv(String? v) => (v == null || v.trim().isEmpty) ? _empty : v;

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

  String _fmtSalary(double s) =>
      s == s.roundToDouble() ? s.toStringAsFixed(0) : s.toStringAsFixed(2);

  Widget _buildStaffInfoBox({
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
                  width: 130,
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

  Widget _buildPermChip(String label, bool isEnabled, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isEnabled ? color.withAlpha(15) : AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isEnabled ? color.withAlpha(50) : AppColors.cardBorder),
      ),
      child: Text(
        '${isEnabled ? "✓" : "✗"} $label',
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: isEnabled ? color : AppColors.textMuted,
        ),
      ),
    );
  }

  void _showEditPermissionsDialog(BuildContext context, AppState appState, AppUser user) {
    bool pCaf = user.teacherPermissions?.canManageCafeteria ?? false;
    bool pMed = user.teacherPermissions?.canManageMedical ?? false;
    bool pInv = user.teacherPermissions?.canManageInventory ?? true;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
              title: Text('${user.fullName} üçün Yetkilər', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: const Text('Yeməkxana Menyu İdarəsi', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    value: pCaf,
                    activeThumbColor: AppColors.gold,
                    onChanged: (v) => setDialogState(() => pCaf = v),
                  ),
                  SwitchListTile(
                    title: const Text('Tibbi Kart & Allergiya Qeydləri', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    value: pMed,
                    activeThumbColor: AppColors.danger,
                    onChanged: (v) => setDialogState(() => pMed = v),
                  ),
                  SwitchListTile(
                    title: const Text('İnventar & QR Ticket Göndərmə', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    value: pInv,
                    activeThumbColor: AppColors.primaryAccent,
                    onChanged: (v) => setDialogState(() => pInv = v),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Ləğv et'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    appState.updateTeacherPermissions(
                      user.id,
                      TeacherPermissions(
                        canManageCafeteria: pCaf,
                        canManageMedical: pMed,
                        canManageInventory: pInv,
                      ),
                    );
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Müəllim yetkiləri uğurla yeniləndi!'), backgroundColor: AppColors.success),
                    );
                  },
                  child: const Text('Yadda Saxla', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
