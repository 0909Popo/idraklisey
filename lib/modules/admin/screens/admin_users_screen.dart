import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../providers/app_state.dart';
import '../../../data/models/user_model.dart';
import 'create_account_dialog.dart';

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
    final users = appState.users;
    final dateFormat = DateFormat('dd.MM.yyyy');

    final filtered = users.where((u) {
      final matchesRole = _filterRole == null || u.role == _filterRole;
      final q = _searchCtrl.text.toLowerCase().trim();
      final matchesSearch = q.isEmpty ||
          u.fullName.toLowerCase().contains(q) ||
          u.username.toLowerCase().contains(q) ||
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
                  tooltip: 'Yeni Hesab Yarat',
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const CreateAccountDialog(),
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
                                      '${users.length} qeydiyyatlı hesab & yetkilər',
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
                        _buildRoleFilterChip('Hamısı (${users.length})', null),
                        _buildRoleFilterChip('Müəllimlər', UserRole.teacher),
                        _buildRoleFilterChip('Şagirdlər', UserRole.student),
                        _buildRoleFilterChip('Valideynlər', UserRole.parent),
                        _buildRoleFilterChip('İnzibatçılar', UserRole.admin),
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

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
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
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        StatusBadge(
                          label: user.role.displayName.split(' ').first,
                          color: roleColor,
                          fontSize: 10,
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'İdrak Kodu: ${user.idrakCode} • Login: ${user.username}',
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
