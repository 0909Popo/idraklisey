import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_state.dart';
import '../../../data/models/role_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/widgets/modern_card.dart';
import '../../../core/widgets/glass_card.dart';
import 'create_role_dialog.dart';
import 'edit_role_dialog.dart';

/// Rol İdarəetmə Ekranı
/// Admin rollar yarada, redaktə edə və səlahiyyətlər təyin edə bilər
class RoleManagementScreen extends StatefulWidget {
  const RoleManagementScreen({super.key});

  @override
  State<RoleManagementScreen> createState() => _RoleManagementScreenState();
}

class _RoleManagementScreenState extends State<RoleManagementScreen> {
  bool _isLoading = true;
  List<Role> _roles = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadRoles();
  }

  Future<void> _loadRoles() async {
    setState(() => _isLoading = true);
    try {
      final appState = Provider.of<AppState>(context, listen: false);
      final roles = await appState.firestoreService.fetchRoles();
      setState(() {
        _roles = roles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Rollar yüklənərkən xəta: $e')),
        );
      }
    }
  }

  List<Role> get _filteredRoles {
    if (_searchQuery.isEmpty) return _roles;
    final query = _searchQuery.toLowerCase();
    return _roles.where((role) {
      return role.name.toLowerCase().contains(query) ||
          role.description.toLowerCase().contains(query);
    }).toList();
  }

  void _showCreateRoleDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateRoleDialog(
        onRoleCreated: () {
          _loadRoles();
        },
      ),
    );
  }

  void _showEditRoleDialog(Role role) {
    showDialog(
      context: context,
      builder: (context) => EditRoleDialog(
        role: role,
        onRoleUpdated: () {
          _loadRoles();
        },
      ),
    );
  }

  Future<void> _deleteRole(Role role) async {
    if (role.isDefault || !role.isDeletable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sistem rolu silinə bilməz!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rolu Sil'),
        content: Text(
          '${role.name} rolunu silmək istədiyinizə əminsiniz?\n\n'
          'Bu rolu istifadə edən istifadəçilər rol təyinatını itirəcək.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Ləğv et'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        final appState = Provider.of<AppState>(context, listen: false);
        await appState.firestoreService.deleteRole(role.id);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${role.name} rolu silindi'),
            backgroundColor: Colors.green,
          ),
        );
        
        _loadRoles();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rol silinərkən xəta: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Rol İdarəetməsi'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRoles,
            tooltip: 'Yenilə',
          ),
        ],
      ),
      body: Column(
        children: [
          // Arama ve Oluştur butonu
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Arama çubuğu
                TextField(
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Rol axtar...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    filled: true,
                    fillColor: AppColors.background,
                  ),
                ),
                SizedBox(height: AppSpacing.md),
                // Yeni rol butonu
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _showCreateRoleDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.add),
                        SizedBox(width: AppSpacing.sm),
                        const Text('Yeni Rol Yarat'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Roller listesi
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredRoles.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.admin_panel_settings_outlined,
                              size: 80,
                              color: AppColors.textSecondary,
                            ),
                            SizedBox(height: AppSpacing.md),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'Hələ rol yaradılmayıb'
                                  : 'Axtarış nəticəsi tapılmadı',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(AppSpacing.md),
                        itemCount: _filteredRoles.length,
                        itemBuilder: (context, index) {
                          final role = _filteredRoles[index];
                          return _RoleCard(
                            role: role,
                            onTap: () => _showEditRoleDialog(role),
                            onDelete: () => _deleteRole(role),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

/// Rol Kartı Widget
class _RoleCard extends StatelessWidget {
  final Role role;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _RoleCard({
    required this.role,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final permissionCount = role.permissionIds.length;
    
    return ModernCard(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // İkon
                  Container(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: role.isDefault
                          ? AppColors.primary.withValues(alpha: 0.1)
                          : AppColors.primaryAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Icon(
                      role.isDefault
                          ? Icons.verified_user
                          : Icons.admin_panel_settings,
                      color: role.isDefault
                          ? AppColors.primary
                          : AppColors.primaryAccent,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  
                  // Rol adı ve açıklama
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                role.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (role.isDefault) ...[
                              SizedBox(width: AppSpacing.sm),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'SİSTEM',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          role.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  // Sil butonu
                  if (role.isDeletable)
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: Colors.red,
                      onPressed: onDelete,
                      tooltip: 'Rolu Sil',
                    ),
                ],
              ),
              
              SizedBox(height: AppSpacing.md),
              
              // Yetki sayısı ve tarih
              Row(
                children: [
                  Icon(
                    Icons.security,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    '$permissionCount Səlahiyyət',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    _formatDate(role.createdAt),
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) return 'Bu gün';
    if (diff.inDays == 1) return 'Dünən';
    if (diff.inDays < 7) return '${diff.inDays} gün əvvəl';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} həftə əvvəl';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} ay əvvəl';
    
    return '${date.day}.${date.month}.${date.year}';
  }
}
