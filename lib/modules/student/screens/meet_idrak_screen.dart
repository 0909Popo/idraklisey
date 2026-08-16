import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../providers/app_state.dart';
import '../../../data/models/meet_model.dart';
import '../../shared/screens/voice_room_screen.dart';
import '../../teacher/screens/create_meet_screen.dart';

class MeetIdrakScreen extends StatelessWidget {
  const MeetIdrakScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final user = appState.currentUser;
    final isTeacherOrAdmin = user?.role == UserRole.teacher || user?.role == UserRole.admin;
    final rooms = appState.getMeetRoomsForCurrentUser();
    final timeFormat = DateFormat('HH:mm');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Meet İdrak • Canlı Səsli Dərslər'),
        actions: [
          if (isTeacherOrAdmin)
            IconButton(
              icon: const Icon(Icons.add_call, color: AppColors.goldLight),
              tooltip: 'Yeni Görüş Yarat',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateMeetScreen()),
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meet Idrak Hero Banner
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF065F46)],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.gold.withAlpha(60)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF065F46).withAlpha(80),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.mic_external_on_rounded, color: AppColors.goldLight, size: 28),
                          SizedBox(width: 10),
                          Text(
                            'MEET İDRAK',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.success.withAlpha(30),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.success),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.circle, color: AppColors.success, size: 8),
                            SizedBox(width: 5),
                            Text('Canlı Şəbəkə', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Gecikməsiz real-vaxt səsli dərslər, sinif müzakirələri və interaktiv virtual otaqlar.',
                    style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.3),
                  ),

                  if (isTeacherOrAdmin) ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CreateMeetScreen()),
                          );
                        },
                        icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 20),
                        label: const Text(
                          'Yeni Səsli Toplantı Başlat',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Aktiv & Planlaşdırılmış Dərslər',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                  ),
                  Text(
                    '${rooms.length} Otaq',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryAccent),
                  ),
                ],
              ),
            ),

            if (rooms.isEmpty)
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.voice_over_off_rounded, size: 56, color: AppColors.textMuted),
                      const SizedBox(height: 16),
                      Text(
                        'Hal-hazırda aktiv dərs və ya toplantı yoxdur',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isTeacherOrAdmin
                            ? 'Yuxarıdakı düyməyə basaraq sinifiniz üçün yeni canlı səsli görüş başlada bilərsiniz.'
                            : 'Müəlliminiz dərs başlatdıqda burada görünəcək və dərhal qoşula biləcəksiniz.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...rooms.map((room) => _buildRoomCard(context, room, timeFormat, isTeacherOrAdmin)),
          ],
        ),
      ),
      floatingActionButton: isTeacherOrAdmin
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.mic_rounded, color: Colors.white),
              label: const Text('Görüş Yarat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateMeetScreen()),
                );
              },
            )
          : null,
    );
  }

  Widget _buildRoomCard(BuildContext context, MeetRoom room, DateFormat timeFormat, bool isTeacherOrAdmin) {
    final isLive = room.isLive;
    final currentUserId = Provider.of<AppState>(context, listen: false).currentUser?.id ?? '';
    final isHost = room.hostId == currentUserId;

    return CustomCard(
      border: isLive ? Border.all(color: AppColors.success, width: 2) : Border.all(color: AppColors.cardBorder),
      backgroundColor: isLive ? const Color(0xFFF0FDF4) : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusBadge(
                label: room.subject,
                color: AppColors.primary,
              ),
              if (isLive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.danger.withAlpha(80),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.circle, color: Colors.white, size: 8),
                      SizedBox(width: 5),
                      Text(
                        'CANLI SƏSLİ OTAQ',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                )
              else
                Text(
                  room.status,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            room.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundImage: NetworkImage(
                  room.hostPhotoUrl ?? 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400',
                ),
                child: null, // No overlay icon
              ),
              const SizedBox(width: 8),
              Text(
                'Təşkilatçı: ${room.hostName}',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.people_alt_rounded, size: 16, color: AppColors.primaryAccent),
              const SizedBox(width: 6),
              Text(
                '${room.participants.length} İştirakçı içəridədir',
                style: const TextStyle(fontSize: 12, color: AppColors.primaryAccent, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          if (room.targetClasses.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              children: room.targetClasses.map((cls) {
                return Chip(
                  label: Text('Sinif $cls', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  backgroundColor: AppColors.primary.withAlpha(15),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 14),
          Divider(color: AppColors.cardBorder, height: 1),
          const SizedBox(height: 10),

          // Action Row
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLive ? AppColors.success : AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VoiceRoomScreen(room: room),
                      ),
                    );
                  },
                  icon: Icon(isLive ? Icons.mic_rounded : Icons.headset_mic_rounded, color: Colors.white),
                  label: Text(
                    isLive ? 'Dərsə Canlı Qoşul (Səsli)' : 'Otağa Daxil Ol',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),

              if (isHost || isTeacherOrAdmin) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger),
                  tooltip: 'Otağı Sil',
                  onPressed: () async {
                    final appState = Provider.of<AppState>(context, listen: false);
                    await appState.deleteMeetRoom(room.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Toplantı otağı silindi'), backgroundColor: AppColors.danger),
                      );
                    }
                  },
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
