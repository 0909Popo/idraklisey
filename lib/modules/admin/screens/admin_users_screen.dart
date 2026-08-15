import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_card.dart';
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
      appBar: AppBar(
        title: const Text('İstifadəçi Hesabları & Yetkilər'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_rounded),
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
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Ad, İdrak kodu və ya istifadəçi adı axtar...',
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
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

          // User Cards List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final user = filtered[index];
                return _buildUserCard(context, appState, user, dateFormat);
              },
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
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => _filterRole = role),
        selectedColor: AppColors.primary,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textPrimary,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: Colors.white,
        side: BorderSide(color: isSelected ? AppColors.primary : AppColors.cardBorder),
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

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: roleColor.withAlpha(25),
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
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
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
                    const SizedBox(height: 2),
                    Text(
                      'İdrak Kodu: ${user.idrakCode} • Login: ${user.username}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                    ),
                    if (user.role == UserRole.teacher && user.subject != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Fənn: ${user.subject} (${user.roomNumber ?? "Otaq təyin olunmayıb"})',
                        style: const TextStyle(fontSize: 12, color: AppColors.primary),
                      ),
                    ],
                    if (user.role == UserRole.parent && user.linkedStudentId != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Əlaqəli Şagird ID: ${user.linkedStudentId}',
                        style: const TextStyle(fontSize: 12, color: AppColors.goldDark, fontWeight: FontWeight.bold),
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Müəllimə Verilmiş Admin Yetkiləri:',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      GestureDetector(
                        onTap: () => _showEditPermissionsDialog(context, appState, user),
                        child: const Text('Dəyiş', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryAccent)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
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
          const Divider(color: AppColors.cardBorder, height: 1),
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
                      fontWeight: FontWeight.bold,
                      color: user.isActive ? AppColors.success : AppColors.danger,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    'Şifrə: ${user.password}',
                    style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: AppColors.textMuted),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(40, 24)),
                    onPressed: () => appState.toggleUserStatus(user.id),
                    child: Text(
                      user.isActive ? 'Deaktiv et' : 'Aktivləşdir',
                      style: TextStyle(
                        fontSize: 11,
                        color: user.isActive ? AppColors.danger : AppColors.success,
                        fontWeight: FontWeight.bold,
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isEnabled ? color.withAlpha(20) : Colors.black12,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: isEnabled ? color : Colors.transparent),
      ),
      child: Text(
        '${isEnabled ? "✓" : "✗"} $label',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text('${user.fullName} üçün Yetkilər'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: const Text('Yeməkxana Menyu İdarəsi', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    value: pCaf,
                    activeThumbColor: AppColors.gold,
                    onChanged: (v) => setDialogState(() => pCaf = v),
                  ),
                  SwitchListTile(
                    title: const Text('Tibbi Kart & Allergiya Qeydləri', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    value: pMed,
                    activeThumbColor: AppColors.danger,
                    onChanged: (v) => setDialogState(() => pMed = v),
                  ),
                  SwitchListTile(
                    title: const Text('İnventar & QR Ticket Göndərmə', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
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
                      const SnackBar(content: Text('Müəllim yetkiləri uğurla yeniləndi!')),
                    );
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
}
