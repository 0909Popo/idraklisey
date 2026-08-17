import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../providers/app_state.dart';
import '../../../data/models/menu_model.dart';

class CafeteriaMenuScreen extends StatefulWidget {
  const CafeteriaMenuScreen({super.key});

  @override
  State<CafeteriaMenuScreen> createState() => _CafeteriaMenuScreenState();
}

class _CafeteriaMenuScreenState extends State<CafeteriaMenuScreen> {
  int _selectedDayIndex = 0;

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final weeklyMenus = appState.weeklyMenu;
    final currentMenu = _selectedDayIndex < weeklyMenus.length ? weeklyMenus[_selectedDayIndex] : null;

    final currentUser = appState.currentUser;
    final canManageMenu = currentUser?.role == UserRole.admin ||
        (currentUser?.role == UserRole.teacher &&
            (currentUser?.teacherPermissions?.canManageCafeteria ?? false));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Lisey Yeməkxana Menyusu'),
        elevation: 0,
      ),
      floatingActionButton: canManageMenu
          ? FloatingActionButton.extended(
              onPressed: () => _showAddMenuItemDialog(context, appState),
              backgroundColor: AppColors.goldDark,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text('Menyuya Əlavə Et', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Permission Banner (if admin or teacher with permission)
            if (canManageMenu)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: AppColors.goldDark.withAlpha(18),
                child: Row(
                  children: [
                    const Icon(Icons.admin_panel_settings_outlined, size: 16, color: AppColors.goldDark),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'İdarəetmə aktivdir: Menyunu dəyişə, yeni yemək əlavə edə və silə bilərsiniz.',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.goldDark),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.goldDark, size: 18),
                      tooltip: 'Yemək Əlavə Et',
                      onPressed: () => _showAddMenuItemDialog(context, appState),
                    ),
                  ],
                ),
              ),

            // Days Switcher
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(bottom: BorderSide(color: AppColors.cardBorder)),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(weeklyMenus.length, (index) {
                    final isSelected = index == _selectedDayIndex;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: InkWell(
                        onTap: () => setState(() => _selectedDayIndex = index),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryAccent : AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isSelected ? AppColors.primaryAccent : AppColors.cardBorder),
                          ),
                          child: Text(
                            weeklyMenus[index].dayName,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 11.5,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),

            if (currentMenu != null) ...[
              // Daily Summary Card
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFB45309), Color(0xFFD97706)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: AppShadows.sm,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentMenu.dayName,
                          style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: -0.2),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${currentMenu.mealTime} • ${currentMenu.items.length} Çeşid',
                          style: const TextStyle(color: Colors.white70, fontSize: 11.5, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Cəmi Kalori',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 9, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${currentMenu.totalCalories} kkal',
                            style: const TextStyle(
                              color: Color(0xFFD97706),
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Food Items List
              if (currentMenu.items.isEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.restaurant_menu_outlined, size: 44, color: AppColors.textMuted),
                        const SizedBox(height: 10),
                        Text(
                          'Bu gün üçün menyu daxil edilməyib.',
                          style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        if (canManageMenu) ...[
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.goldDark,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () => _showAddMenuItemDialog(context, appState),
                            icon: const Icon(Icons.add, color: Colors.white, size: 16),
                            label: const Text('İlk Yeməyi Əlavə Et', style: TextStyle(color: Colors.white, fontSize: 12)),
                          ),
                        ],
                      ],
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: currentMenu.items.asMap().entries.map(
                      (entry) => _buildMenuItemCard(context, appState, entry.value, entry.key, canManageMenu),
                    ).toList(),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItemCard(
    BuildContext context,
    AppState appState,
    MenuItem item,
    int itemIndex,
    bool canManage,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppShadows.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              item.imageUrl,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (_, e, s) => Container(
                width: 70,
                height: 70,
                color: const Color(0xFFF1F5F9),
                child: Icon(Icons.restaurant_outlined, color: AppColors.textMuted),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatusBadge(
                      label: item.category,
                      color: AppColors.primaryAccent,
                      fontSize: 9.5,
                    ),
                    Row(
                      children: [
                        Text(
                          '${item.calories} kkal • ${item.weightGram}',
                          style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                        ),
                        if (canManage) ...[
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (dCtx) => AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                  title: const Text('Yeməyi Sil'),
                                  content: Text('"${item.name}" menyudan silinsin?'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(dCtx), child: const Text('Ləğv et')),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                                      onPressed: () {
                                        appState.removeMenuItemFromDay(_selectedDayIndex, itemIndex);
                                        Navigator.pop(dCtx);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Yemək menyudan silindi.'), backgroundColor: AppColors.danger),
                                        );
                                      },
                                      child: const Text('Sil', style: TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(2),
                              child: Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.danger),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (item.allergens.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Wrap(
                    spacing: 4,
                    runSpacing: 3,
                    children: item.allergens.map((allergen) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withAlpha(12),
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(color: AppColors.danger.withAlpha(40)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.warning_amber_rounded, size: 10, color: AppColors.danger),
                            const SizedBox(width: 2),
                            Text(
                              allergen,
                              style: const TextStyle(fontSize: 9, color: AppColors.danger, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMenuItemDialog(BuildContext context, AppState appState) {
    final nameCtrl = TextEditingController();
    final calCtrl = TextEditingController(text: '300');
    final weightCtrl = TextEditingController(text: '200g');
    final allergenCtrl = TextEditingController();
    String category = 'Əsas Yemək';
    final categories = ['Şorba', 'Əsas Yemək', 'Qarnir', 'Salat', 'Şirniyyat / İçki'];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: const Text('Menyuya Yeni Yemək Əlavə Et'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Yeməyin Adı *')),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: category,
                      decoration: const InputDecoration(labelText: 'Kateqoriya'),
                      items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => category = val);
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: calCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Kalori (kkal) *'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: weightCtrl,
                            decoration: const InputDecoration(labelText: 'Porsiya (qram) *'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: allergenCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Allergenlər (vergüllə ayırın)',
                        hintText: 'Məs: Qlüten, Süd, Qoz',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Ləğv et')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.goldDark,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (nameCtrl.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Yeməyin adını qeyd edin!')),
                      );
                      return;
                    }
                    final allergens = allergenCtrl.text
                        .split(',')
                        .map((a) => a.trim())
                        .where((a) => a.isNotEmpty)
                        .toList();

                    final newItem = MenuItem(
                      name: nameCtrl.text.trim(),
                      category: category,
                      calories: int.tryParse(calCtrl.text.trim()) ?? 250,
                      weightGram: weightCtrl.text.trim().isNotEmpty ? weightCtrl.text.trim() : '200g',
                      allergens: allergens,
                      imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',
                    );

                    appState.addMenuItemToDay(_selectedDayIndex, newItem);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('"${newItem.name}" menyuya əlavə edildi!'), backgroundColor: AppColors.success),
                    );
                  },
                  child: const Text('Əlavə Et', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
