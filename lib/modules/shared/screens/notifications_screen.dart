import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../providers/app_state.dart';
import '../../../data/models/notification_model.dart';
import '../dialogs/send_notification_dialog.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  String _selectedFilter = 'all';

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'İndicə';
    if (diff.inMinutes < 60) return '${diff.inMinutes} dəq əvvəl';
    if (diff.inHours < 24) return '${diff.inHours} saat əvvəl';
    if (diff.inDays == 1) return 'Dünən ${DateFormat('HH:mm').format(dt)}';
    if (diff.inDays < 7) return '${diff.inDays} gün əvvəl';
    return DateFormat('dd.MM.yyyy HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser;
    final userId = user?.id ?? '';
    final isTeacherOrAdmin = user?.role == UserRole.teacher || user?.role == UserRole.admin;
    final allNotifs = appState.notificationsForCurrentUser;

    // Apply Filter
    final filteredNotifs = allNotifs.where((n) {
      if (_selectedFilter == 'unread') {
        return !n.isReadBy(userId);
      }
      if (_selectedFilter == 'teacher') {
        return n.category == NotificationCategory.teacherDirect || n.senderRole == 'teacher';
      }
      if (_selectedFilter == 'general') {
        return n.category == NotificationCategory.general || n.category == NotificationCategory.emergency;
      }
      return true;
    }).toList();

    final unreadCount = appState.unreadNotificationCount;

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
              if (unreadCount > 0)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.goldLight,
                      backgroundColor: Colors.white.withAlpha(15),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: const Icon(Icons.done_all_rounded, size: 16),
                    label: const Text('Hamısını Oxu', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                    onPressed: () async {
                      await appState.markAllNotificationsAsRead();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Bütün bildirişlər oxundu işarələndi'), duration: Duration(seconds: 1)),
                        );
                      }
                    },
                  ),
                ),
              if (isTeacherOrAdmin)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryAccent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.add_comment_rounded, size: 18, color: Colors.white),
                    ),
                    tooltip: 'Yeni Bildiriş Göndər',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => const SendNotificationDialog(),
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
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF6366F1)],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -15,
                      bottom: -15,
                      child: Icon(Icons.notifications_rounded, size: 130, color: Colors.white.withAlpha(10)),
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
                                  child: const Icon(Icons.notifications_active_rounded, size: 22, color: Colors.white),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Bildirişlər & Elanlar',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      unreadCount > 0 ? '$unreadCount oxunmamış bildirişiniz var' : 'Bütün bildirişlər oxunub',
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

          // ── Filter Chips Bar ──
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildFilterChip('all', 'Hamısı (${allNotifs.length})'),
                    const SizedBox(width: 8),
                    _buildFilterChip('unread', 'Oxunmamışlar ($unreadCount)', isHighlighted: unreadCount > 0),
                    const SizedBox(width: 8),
                    _buildFilterChip('teacher', '👨‍🏫 Müəllim Mesajları'),
                    const SizedBox(width: 8),
                    _buildFilterChip('general', '📢 Rəsmi Elanlar'),
                  ],
                ),
              ),
            ),
          ),

          // ── Notifications List ──
          if (filteredNotifs.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.primaryAccent.withAlpha(10),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.notifications_none_rounded, size: 48, color: AppColors.primaryAccent),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Bildiriş tapılmadı',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Məktəb rəhbərliyindən və ya müəllimlərinizdən gələn bütün bildirişlər burada toplanacaq.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final notif = filteredNotifs[index];
                    final isRead = notif.isReadBy(userId);

                    return Dismissible(
                      key: Key(notif.id),
                      direction: isTeacherOrAdmin ? DismissDirection.endToStart : DismissDirection.none,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: AppColors.danger,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(Icons.delete_rounded, color: Colors.white),
                      ),
                      onDismissed: (_) {
                        appState.deleteNotification(notif.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Bildiriş silindi')),
                        );
                      },
                      child: _buildNotificationCard(context, notif, isRead, appState),
                    );
                  },
                  childCount: filteredNotifs.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: isTeacherOrAdmin
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primaryAccent,
              icon: const Icon(Icons.send_rounded, color: Colors.white),
              label: const Text('Bildiriş Göndər', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => const SendNotificationDialog(),
                );
              },
            )
          : null,
    );
  }

  Widget _buildFilterChip(String key, String label, {bool isHighlighted = false}) {
    final isSelected = _selectedFilter == key;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? (isHighlighted ? AppColors.danger : AppColors.primaryAccent)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? (isHighlighted ? AppColors.danger : AppColors.primaryAccent)
                : AppColors.cardBorder,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: (isHighlighted ? AppColors.danger : AppColors.primaryAccent).withAlpha(30), blurRadius: 6, offset: const Offset(0, 2))]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isHighlighted ? AppColors.danger : AppColors.textPrimary),
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, AppNotification notif, bool isRead, AppState appState) {
    final isTeacherSender = notif.senderRole == 'teacher';
    final isUrgent = notif.priority == 'urgent';

    return GestureDetector(
      onTap: () {
        if (!isRead) {
          appState.markNotificationAsRead(notif.id);
        }
        _showNotificationDetailDialog(context, notif);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isRead ? AppColors.surface : const Color(0xFFEEF2FF),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isUrgent
                ? AppColors.danger
                : (isRead ? AppColors.cardBorder : AppColors.primaryAccent.withAlpha(100)),
            width: isRead ? 1 : 1.5,
          ),
          boxShadow: AppShadows.sm,
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Sender Info & Time
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (notif.senderPhotoUrl != null)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primaryAccent.withAlpha(30)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: Image.network(
                          notif.senderPhotoUrl!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.person_rounded, size: 22, color: AppColors.primaryAccent),
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isTeacherSender ? const Color(0xFF7C3AED).withAlpha(15) : AppColors.primaryAccent.withAlpha(15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isTeacherSender ? Icons.psychology_rounded : Icons.school_rounded,
                        color: isTeacherSender ? const Color(0xFF7C3AED) : AppColors.primaryAccent,
                        size: 22,
                      ),
                    ),
                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                notif.senderName,
                                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textPrimary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (!isRead) ...[
                              const SizedBox(width: 6),
                              Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(color: AppColors.primaryAccent, shape: BoxShape.circle),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          isTeacherSender
                              ? 'Müəllim • ${notif.senderSubject ?? "Fənn"}'
                              : 'İdrak Liseyi Rəhbərliyi',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),

                  // Priority / Category Badge
                  if (isUrgent)
                    const StatusBadge(label: '🚨 TƏCİLİ', color: AppColors.danger, fontSize: 9)
                  else if (notif.category == NotificationCategory.teacherDirect)
                    const StatusBadge(label: '👨‍👩‍👧 Qeyd', color: Color(0xFF0D9488), fontSize: 9)
                  else
                    StatusBadge(label: '📢 Elan', color: AppColors.primaryAccent, fontSize: 9),
                ],
              ),

              const SizedBox(height: 10),

              // Title
              Text(
                notif.title,
                style: TextStyle(
                  fontWeight: isRead ? FontWeight.w700 : FontWeight.w900,
                  fontSize: 13.5,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 3),

              // Body Preview
              Text(
                notif.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.3),
              ),

              const SizedBox(height: 10),

              // Target Class & Time Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (notif.targetClasses.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryAccent.withAlpha(12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Sinif: ${notif.targetClasses.join(", ")}',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryAccent),
                          ),
                        ),
                      if (notif.targetStudentName != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D9488).withAlpha(12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Şagird: ${notif.targetStudentName}',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0D9488)),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    _formatTimeAgo(notif.createdAt),
                    style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotificationDetailDialog(BuildContext context, AppNotification notif) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with sender
              Row(
                children: [
                  if (notif.senderPhotoUrl != null)
                    CircleAvatar(
                      radius: 22,
                      backgroundImage: NetworkImage(notif.senderPhotoUrl!),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryAccent.withAlpha(15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.school_rounded, color: AppColors.primaryAccent, size: 22),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notif.senderName,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                        ),
                        Text(
                          notif.senderSubject != null
                              ? 'Müəllim • ${notif.senderSubject}'
                              : 'İdrak Liseyi Rəsmi Bildirişi',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),
              Divider(height: 1, color: AppColors.cardBorder),
              const SizedBox(height: 14),

              Text(
                notif.title,
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                notif.message,
                style: TextStyle(fontSize: 12.5, color: AppColors.textPrimary, height: 1.4),
              ),

              const SizedBox(height: 16),
              Text(
                DateFormat('dd MMMM yyyy, HH:mm').format(notif.createdAt),
                style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Bağla', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
