import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
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
        elevation: 0,
        actions: [
          if (isTeacherOrAdmin)
            IconButton(
              icon: const Icon(Icons.add_call, color: AppColors.primaryAccent),
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
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Meet Idrak Hero Banner
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withAlpha(25)),
                boxShadow: AppShadows.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.mic_external_on_rounded, color: AppColors.primaryAccent, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'MEET İDRAK',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.success.withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.success.withAlpha(80)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.circle, color: AppColors.success, size: 6),
                            SizedBox(width: 4),
                            Text('Canlı', style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Gecikməsiz real-vaxt səsli dərslər, sinif müzakirələri və interaktiv virtual otaqlar.',
                    style: TextStyle(color: Colors.white70, fontSize: 11.5, height: 1.35),
                  ),

                  if (isTeacherOrAdmin) ...[
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CreateMeetScreen()),
                          );
                        },
                        icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.white, size: 16),
                        label: const Text(
                          'Yeni Səsli Toplantı Başlat',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.5),
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
                    style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: -0.2),
                  ),
                  Text(
                    '${rooms.length} Otaq',
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppColors.primaryAccent),
                  ),
                ],
              ),
            ),

            if (rooms.isEmpty)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.voice_over_off_rounded, size: 44, color: AppColors.textMuted),
                      const SizedBox(height: 12),
                      Text(
                        'Hal-hazırda aktiv dərs və ya toplantı yoxdur',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isTeacherOrAdmin
                            ? 'Yuxarıdakı düyməyə basaraq sinifiniz üçün yeni canlı səsli görüş başlada bilərsiniz.'
                            : 'Müəlliminiz dərs başlatdıqda burada görünəcək.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
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
              backgroundColor: AppColors.primaryAccent,
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLive ? AppColors.success.withAlpha(80) : AppColors.cardBorder,
          width: isLive ? 1.5 : 1,
        ),
        boxShadow: AppShadows.sm,
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatusBadge(
                  label: room.subject,
                  color: AppColors.primaryAccent,
                  fontSize: 9.5,
                ),
                if (isLive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: AppColors.danger,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.circle, color: Colors.white, size: 6),
                        SizedBox(width: 4),
                        Text(
                          'CANLI',
                          style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  )
                else
                  Text(
                    room.status,
                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              room.title,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                CircleAvatar(
                  radius: 10,
                  backgroundImage: NetworkImage(
                    room.hostPhotoUrl ?? 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400',
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  'Təşkilatçı: ${room.hostName}',
                  style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                const Icon(Icons.people_alt_outlined, size: 13, color: AppColors.primaryAccent),
                const SizedBox(width: 4),
                Text(
                  '${room.participants.length} İştirakçı içəridədir',
                  style: const TextStyle(fontSize: 10.5, color: AppColors.primaryAccent, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            if (room.targetClasses.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 5,
                children: room.targetClasses.map((cls) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: AppColors.primaryAccent.withAlpha(12),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: AppColors.primaryAccent.withAlpha(30)),
                    ),
                    child: Text('Sinif $cls', style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppColors.primaryAccent)),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 10),
            Divider(color: AppColors.cardBorder, height: 1),
            const SizedBox(height: 8),

            // Action Row
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLive ? AppColors.success : AppColors.primaryAccent,
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VoiceRoomScreen(room: room),
                        ),
                      );
                    },
                    icon: Icon(isLive ? Icons.mic_rounded : Icons.headset_mic_outlined, color: Colors.white, size: 16),
                    label: Text(
                      isLive ? 'Dərsə Canlı Qoşul' : 'Otağa Daxil Ol',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),

                if (isHost || isTeacherOrAdmin) ...[
                  const SizedBox(width: 6),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 18),
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
      ),
    );
  }
}
