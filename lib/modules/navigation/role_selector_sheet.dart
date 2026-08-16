import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/idrak_logo.dart';
import '../../providers/app_state.dart';

class RoleSelectorSheet extends StatelessWidget {
  const RoleSelectorSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final currentRole = appState.currentRole;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.cardBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const IdrakLogo(size: 38, showText: true),
          const SizedBox(height: 14),
          Text(
            'İstifadəçi Hesabı və Paneli',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            'Tətbiqdəki 4 rol arasında sürətli keçid edin:',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),

          // 0. Admin Role Card
          _buildRoleOption(
            context: context,
            role: UserRole.admin,
            title: 'Məktəb İnzibatçısı (Admin Paneli)',
            description: 'Hesab yaratma, şifrə təyini, müəllim yetkiləri (Kantin/Tibb/İnventar) və ümumi idarəetmə',
            icon: Icons.admin_panel_settings_rounded,
            isSelected: currentRole == UserRole.admin,
            accentColor: Colors.red,
            onTap: () {
              appState.switchUserRoleForTesting(UserRole.admin);
              Navigator.pop(context);
            },
          ),

          const SizedBox(height: 8),

          // 1. Teacher Role Card
          _buildRoleOption(
            context: context,
            role: UserRole.teacher,
            title: 'Müəllim Paneli (Teacher Hub)',
            description: 'Tinder-Style Smart Davamiyyət (Q, İ, G), Səsli Rəy Qiymətləndirmə, QR İnventar Ticket',
            icon: Icons.psychology_rounded,
            isSelected: currentRole == UserRole.teacher,
            accentColor: const Color(0xFF0D9488),
            onTap: () {
              appState.switchUserRoleForTesting(UserRole.teacher);
              Navigator.pop(context);
            },
          ),

          const SizedBox(height: 8),

          // 2. Student Role Card
          _buildRoleOption(
            context: context,
            role: UserRole.student,
            title: 'Şagird Paneli (Student App)',
            description: 'Digital ID Kimlik, Kamera ilə Tapşırıq Təhvili, Meet İdrak Dərs Otağı, E-Kitabxana, Yeməkxana Menyu',
            icon: Icons.school_rounded,
            isSelected: currentRole == UserRole.student,
            accentColor: AppColors.primaryAccent,
            onTap: () {
              appState.switchUserRoleForTesting(UserRole.student);
              Navigator.pop(context);
            },
          ),

          const SizedBox(height: 8),

          // 3. Parent Role Card
          _buildRoleOption(
            context: context,
            role: UserRole.parent,
            title: 'Valideyn Paneli (Parent Dashboard)',
            description: 'Həftəlik Matris Gündəlik, İnteraktiv Qrafiklər, Davamiyyət Təqvimi, Tibbi Kart, Helpdesk',
            icon: Icons.family_restroom_rounded,
            isSelected: currentRole == UserRole.parent,
            accentColor: AppColors.goldDark,
            onTap: () {
              appState.switchUserRoleForTesting(UserRole.parent);
              Navigator.pop(context);
            },
          ),

          const SizedBox(height: 14),

          // Logout Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.danger),
              ),
              onPressed: () {
                Navigator.pop(context);
                appState.logout();
              },
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('Hesabdan Çıxış Et'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleOption({
    required BuildContext context,
    required UserRole role,
    required String title,
    required String description,
    required IconData icon,
    required bool isSelected,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected ? accentColor.withAlpha(15) : AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? accentColor : AppColors.cardBorder,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected ? accentColor : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: isSelected ? accentColor : AppColors.cardBorder),
                  ),
                  child: Icon(
                    icon,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? accentColor : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle_rounded, color: accentColor, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
