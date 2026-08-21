import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_state.dart';
import '../../../data/models/role_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/widgets/glass_card.dart';

/// Yeni Rol Yaratma Dialoqu
class CreateRoleDialog extends StatefulWidget {
  final VoidCallback onRoleCreated;

  const CreateRoleDialog({
    super.key,
    required this.onRoleCreated,
  });

  @override
  State<CreateRoleDialog> createState() => _CreateRoleDialogState();
}

class _CreateRoleDialogState extends State<CreateRoleDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  final Set<String> _selectedPermissions = {};
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createRole() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final appState = Provider.of<AppState>(context, listen: false);
      
      final newRole = Role(
        id: 'role-${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        permissionIds: _selectedPermissions.toList(),
        isDefault: false,
        isDeletable: true,
        createdAt: DateTime.now(),
      );

      await appState.firestoreService.saveRole(newRole);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${newRole.name} rolu yaradıldı'),
            backgroundColor: Colors.green,
          ),
        );
        widget.onRoleCreated();
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rol yaradılarkən xəta: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final permissionsByCategory = DefaultPermissions.byCategory;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          children: [
            // Başlık
            Container(
              padding: EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.lg),
                  topRight: Radius.circular(AppRadius.lg),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.add_circle_outline, color: Colors.white),
                  SizedBox(width: AppSpacing.md),
                  const Expanded(
                    child: Text(
                      'Yeni Rol Yarat',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Form və səlahiyyətlər
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: EdgeInsets.all(AppSpacing.lg),
                  children: [
                    // Rol adı
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Rol Adı *',
                        hintText: 'məs: Mühasib',
                        prefixIcon: const Icon(Icons.badge),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Rol adı daxil edilməlidir';
                        }
                        return null;
                      },
                    ),
                    
                    SizedBox(height: AppSpacing.lg),
                    
                    // Açıqlama
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Açıqlama *',
                        hintText: 'Rolun vəzifələrini qeyd edin',
                        prefixIcon: const Icon(Icons.description),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      maxLines: 2,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Açıqlama daxil edilməlidir';
                        }
                        return null;
                      },
                    ),
                    
                    SizedBox(height: AppSpacing.xl),
                    
                    // Səlahiyyətlər başlığı
                    Row(
                      children: [
                        const Icon(Icons.security, color: AppColors.primary),
                        SizedBox(width: AppSpacing.sm),
                        Text(
                          'Səlahiyyətlər (${_selectedPermissions.length})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: AppSpacing.sm),
                    
                    Text(
                      'Bu rol üçün səlahiyyətləri seçin',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    
                    SizedBox(height: AppSpacing.md),
                    
                    // Səlahiyyətlər (Kateqoriyaya görə)
                    ...permissionsByCategory.entries.map((entry) {
                      final category = entry.key;
                      final permissions = entry.value;
                      
                      return _PermissionCategoryCard(
                        category: category,
                        permissions: permissions,
                        selectedPermissions: _selectedPermissions,
                        onPermissionToggle: (permissionId) {
                          setState(() {
                            if (_selectedPermissions.contains(permissionId)) {
                              _selectedPermissions.remove(permissionId);
                            } else {
                              _selectedPermissions.add(permissionId);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ],
                ),
              ),
            ),

            // Alt düymələr
            Container(
              padding: EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.background,
                border: Border(
                  top: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                      ),
                      child: const Text('Ləğv et'),
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _createRole,
                      icon: _isLoading 
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save),
                      label: Text(_isLoading ? 'Yaradılır...' : 'Rolu Yarat'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kateqoriya üzrə Səlahiyyət Kartı (Animasiyalı və Kompakt)
class _PermissionCategoryCard extends StatefulWidget {
  final String category;
  final List<Permission> permissions;
  final Set<String> selectedPermissions;
  final Function(String) onPermissionToggle;

  const _PermissionCategoryCard({
    required this.category,
    required this.permissions,
    required this.selectedPermissions,
    required this.onPermissionToggle,
  });

  @override
  State<_PermissionCategoryCard> createState() => _PermissionCategoryCardState();
}

class _PermissionCategoryCardState extends State<_PermissionCategoryCard> 
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _heightFactorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _heightFactorAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _selectAll() {
    for (final permission in widget.permissions) {
      if (!widget.selectedPermissions.contains(permission.id)) {
        widget.onPermissionToggle(permission.id);
      }
    }
  }

  void _deselectAll() {
    for (final permission in widget.permissions) {
      if (widget.selectedPermissions.contains(permission.id)) {
        widget.onPermissionToggle(permission.id);
      }
    }
  }

  Color _getCategoryColor() {
    // Kateqoriyaya görə rəng təyin et
    switch (widget.category) {
      case 'Şagird İdarəetməsi':
        return const Color(0xFF3B82F6); // Mavi
      case 'Qiymət İdarəetməsi':
        return const Color(0xFF10B981); // Yaşıl
      case 'Davamiyyət İdarəetməsi':
        return const Color(0xFFF59E0B); // Narıncı
      case 'İstifadəçi İdarəetməsi':
        return const Color(0xFF8B5CF6); // Bənövşəyi
      case 'Sinif İdarəetməsi':
        return const Color(0xFFEC4899); // Çəhrayı
      case 'Dərs Cədvəli':
        return const Color(0xFF6366F1); // İndiqo
      case 'Hesabatlar':
        return const Color(0xFF14B8A6); // Teal
      case 'Səhiyyə':
        return const Color(0xFFEF4444); // Qırmızı
      case 'Kitabxana':
        return const Color(0xFF06B6D4); // Cyan
      case 'Yeməkxana':
        return const Color(0xFFF97316); // Portağal
      case 'İnventar':
        return const Color(0xFF84CC16); // Lime
      case 'Dəstək':
        return const Color(0xFFA855F7); // Purple
      case 'Sistem':
        return const Color(0xFF64748B); // Slate
      case 'Rol İdarəetməsi':
        return const Color(0xFFD97706); // Amber
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = widget.permissions
        .where((p) => widget.selectedPermissions.contains(p.id))
        .length;
    final allSelected = selectedCount == widget.permissions.length;
    final categoryColor = _getCategoryColor();

    return Card(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      elevation: _isExpanded ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: BorderSide(
          color: _isExpanded 
              ? categoryColor.withOpacity(0.3) 
              : Colors.grey.shade200,
          width: _isExpanded ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          // Başlıq (Tıklanabilir)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggleExpand,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppRadius.lg),
                topRight: Radius.circular(AppRadius.lg),
                bottomLeft: _isExpanded ? Radius.zero : Radius.circular(AppRadius.lg),
                bottomRight: _isExpanded ? Radius.zero : Radius.circular(AppRadius.lg),
              ),
              child: Container(
                padding: EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.lg),
                    topRight: Radius.circular(AppRadius.lg),
                    bottomLeft: _isExpanded ? Radius.zero : Radius.circular(AppRadius.lg),
                    bottomRight: _isExpanded ? Radius.zero : Radius.circular(AppRadius.lg),
                  ),
                ),
                child: Row(
                  children: [
                    // Animasiyalı ox ikonu
                    RotationTransition(
                      turns: _rotationAnimation,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: categoryColor,
                        size: 28,
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    
                    // Kateqoriya ikonu
                    Container(
                      padding: EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Icon(
                        _getCategoryIcon(),
                        color: categoryColor,
                        size: 20,
                      ),
                    ),
                    
                    SizedBox(width: AppSpacing.md),
                    
                    // Kateqoriya adı
                    Expanded(
                      child: Text(
                        widget.category,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    
                    // Seçilmiş sayı badge
                    if (selectedCount > 0)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: categoryColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '$selectedCount/${widget.permissions.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          
          // Açılan məzmun (Animasiyalı)
          ClipRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _isExpanded
                  ? Column(
                      children: [
                        // Hamısını seç / Təmizlə düymələri
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            border: Border(
                              bottom: BorderSide(color: Colors.grey.shade200),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: allSelected ? null : _selectAll,
                                  icon: Icon(
                                    Icons.check_circle_outline,
                                    size: 18,
                                    color: allSelected ? Colors.grey : categoryColor,
                                  ),
                                  label: const Text('Hamısını Seç'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: categoryColor,
                                    side: BorderSide(color: categoryColor.withOpacity(0.3)),
                                    padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                                  ),
                                ),
                              ),
                              SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: selectedCount == 0 ? null : _deselectAll,
                                  icon: Icon(
                                    Icons.clear_rounded,
                                    size: 18,
                                    color: selectedCount == 0 ? Colors.grey : Colors.red,
                                  ),
                                  label: const Text('Təmizlə'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: BorderSide(color: Colors.red.withOpacity(0.3)),
                                    padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Səlahiyyət siyahısı
                        ...widget.permissions.map((permission) {
                          final isSelected = widget.selectedPermissions.contains(permission.id);
                          
                          return Material(
                            color: isSelected 
                                ? categoryColor.withOpacity(0.03) 
                                : Colors.transparent,
                            child: InkWell(
                              onTap: () => widget.onPermissionToggle(permission.id),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                  vertical: AppSpacing.sm,
                                ),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Colors.grey.shade100,
                                      width: 0.5,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // Animasiyalı checkbox
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: isSelected 
                                            ? categoryColor 
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: isSelected 
                                              ? categoryColor 
                                              : Colors.grey.shade400,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: isSelected
                                          ? const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 16,
                                            )
                                          : null,
                                    ),
                                    SizedBox(width: AppSpacing.md),
                                    
                                    // Səlahiyyət məlumatı
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            permission.name,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: isSelected 
                                                  ? FontWeight.w600 
                                                  : FontWeight.normal,
                                              color: isSelected 
                                                  ? AppColors.textPrimary 
                                                  : AppColors.textSecondary,
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            permission.description,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.textMuted,
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
                        }).toList(),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon() {
    switch (widget.category) {
      case 'Şagird İdarəetməsi':
        return Icons.school_rounded;
      case 'Qiymət İdarəetməsi':
        return Icons.grade_rounded;
      case 'Davamiyyət İdarəetməsi':
        return Icons.event_available_rounded;
      case 'İstifadəçi İdarəetməsi':
        return Icons.people_rounded;
      case 'Sinif İdarəetməsi':
        return Icons.class_rounded;
      case 'Dərs Cədvəli':
        return Icons.calendar_month_rounded;
      case 'Hesabatlar':
        return Icons.analytics_rounded;
      case 'Səhiyyə':
        return Icons.health_and_safety_rounded;
      case 'Kitabxana':
        return Icons.library_books_rounded;
      case 'Yeməkxana':
        return Icons.restaurant_rounded;
      case 'İnventar':
        return Icons.inventory_rounded;
      case 'Dəstək':
        return Icons.support_agent_rounded;
      case 'Sistem':
        return Icons.settings_rounded;
      case 'Rol İdarəetməsi':
        return Icons.admin_panel_settings_rounded;
      default:
        return Icons.security_rounded;
    }
  }
}
