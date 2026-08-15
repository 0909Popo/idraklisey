import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_card.dart';
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
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Permission Banner (if admin or teacher with permission)
            if (canManageMenu)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                color: AppColors.gold.withAlpha(30),
                child: Row(
                  children: [
                    const Icon(Icons.admin_panel_settings_rounded, size: 18, color: AppColors.goldDark),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'İdarəetmə aktivdir: Menyunu dəyişə, yeni yemək əlavə edə və silə bilərsiniz.',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.goldDark),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_rounded, color: AppColors.goldDark),
                      tooltip: 'Yemək Əlavə Et',
                      onPressed: () => _showAddMenuItemDialog(context, appState),
                    ),
                  ],
                ),
              ),

            // Days Switcher
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(weeklyMenus.length, (index) {
                    final isSelected = index == _selectedDayIndex;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(weeklyMenus[index].dayName),
                        selected: isSelected,
                        onSelected: (val) {
                          if (val) setState(() => _selectedDayIndex = index);
                        },
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                        backgroundColor: Colors.white,
                        side: BorderSide(color: isSelected ? AppColors.primary : AppColors.cardBorder),
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
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFD97706), Color(0xFFF59E0B), Color(0xFFFBBF24)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gold.withAlpha(70),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentMenu.dayName,
                          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${currentMenu.mealTime} • ${currentMenu.items.length} Çeşid',
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Cəmi Kalori',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 10, fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '${currentMenu.totalCalories} kkal',
                            style: const TextStyle(
                              color: Color(0xFFD97706),
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Food Items
              if (currentMenu.items.isEmpty)
                CustomCard(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.restaurant_menu_rounded, size: 48, color: AppColors.textMuted),
                        const SizedBox(height: 10),
                        const Text(
                          'Bu gün üçün menyu daxil edilməyib.',
                          style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold),
                        ),
                        if (canManageMenu) ...[
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldDark),
                            onPressed: () => _showAddMenuItemDialog(context, appState),
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text('İlk Yeməyi Əlavə Et', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ],
                    ),
                  ),
                )
              else
                ...currentMenu.items.asMap().entries.map(
                  (entry) => _buildMenuItemCard(context, appState, entry.value, entry.key, canManageMenu),
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
    return CustomCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              item.imageUrl,
              width: 80,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, e, s) => Container(
                width: 80,
                height: 80,
                color: const Color(0xFFF1F5F9),
                child: const Icon(Icons.restaurant_rounded, color: AppColors.textMuted),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatusBadge(
                      label: item.category,
                      color: AppColors.primary,
                      fontSize: 10,
                    ),
                    Row(
                      children: [
                        Text(
                          '${item.calories} kkal • ${item.weightGram}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                        ),
                        if (canManage) ...[
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (dCtx) => AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                              child: Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.danger),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (item.allergens.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: item.allergens.map((allergen) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.danger.withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.danger.withAlpha(60)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.warning_amber_rounded, size: 12, color: AppColors.danger),
                            const SizedBox(width: 4),
                            Text(
                              allergen,
                              style: const TextStyle(fontSize: 10, color: AppColors.danger, fontWeight: FontWeight.bold),
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
    final calCtrl = TextEditingController(text: '250');
    final weightCtrl = TextEditingController(text: '200 qr');
    final allergenCtrl = TextEditingController();
    String category = 'Əsas Yemək';

    final categoryImages = {
      'Əsas Yemək': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',
      'Şorba': 'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=400',
      'Salat': 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',
      'Şirniyyat': 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=400',
      'İçki': 'https://images.unsplash.com/photo-1513558161293-cdaf765ed2fd?w=400',
    };

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Menyuya Yeni Yemək Əlavə Et'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Yeməyin Adı *', hintText: 'Məs: Mərci şorbası, Toyuq filesi'),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      initialValue: category,
                      decoration: const InputDecoration(labelText: 'Kateqoriya'),
                      items: ['Əsas Yemək', 'Şorba', 'Salat', 'Şirniyyat', 'İçki'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => setDialogState(() => category = v!),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: calCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Kalori (kkal)'))),
                        const SizedBox(width: 10),
                        Expanded(child: TextField(controller: weightCtrl, decoration: const InputDecoration(labelText: 'Porsiya Çəkisi'))),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: allergenCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Allergenlər (vergüllə ayırın)',
                        hintText: 'Məs: Qlüten, Süd məhsulları, Qoz',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Ləğv et')),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldDark),
                  onPressed: () {
                    if (nameCtrl.text.trim().isNotEmpty) {
                      final allergens = allergenCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                      final newItem = MenuItem(
                        name: nameCtrl.text.trim(),
                        category: category,
                        calories: int.tryParse(calCtrl.text.trim()) ?? 200,
                        weightGram: weightCtrl.text.trim().isEmpty ? '200 qr' : weightCtrl.text.trim(),
                        allergens: allergens,
                        imageUrl: categoryImages[category] ?? 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',
                      );
                      appState.addMenuItemToDay(_selectedDayIndex, newItem);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Yemək menyuya əlavə edildi və buluda yazıldı!'), backgroundColor: AppColors.success),
                      );
                    }
                  },
                  child: const Text('Əlavə Et', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
