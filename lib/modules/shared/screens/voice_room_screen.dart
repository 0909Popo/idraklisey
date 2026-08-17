import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/app_state.dart';
import '../../../data/models/meet_model.dart';
import '../../../services/agora_service.dart';
import '../../../services/agora_token_service.dart';

class VoiceRoomScreen extends StatefulWidget {
  final MeetRoom room;

  const VoiceRoomScreen({super.key, required this.room});

  @override
  State<VoiceRoomScreen> createState() => _VoiceRoomScreenState();
}

class _VoiceRoomScreenState extends State<VoiceRoomScreen>
    with SingleTickerProviderStateMixin {
  final AgoraService _agoraService = AgoraService();
  final AgoraTokenService _agoraTokenService = AgoraTokenService();

  late Timer _durationTimer;
  int _secondsElapsed = 0;
  bool _isLocalMuted = false;
  bool _isSpeakerOn = true;
  bool _isHandRaised = false;
  bool _isJoining = true;
  bool _hasJoinedRoom = false;
  String? _connectionError;
  late AppState _appState;

  StreamSubscription? _userJoinedSub;
  StreamSubscription? _userLeftSub;
  StreamSubscription? _userMuteSub;
  StreamSubscription? _volumeSub;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) setState(() => _secondsElapsed++);
    });

    _appState = Provider.of<AppState>(context, listen: false);
    _appState.addListener(_syncForcedMuteState);
    _subscribeToAgoraEvents();
    _initAndJoinVoice();
  }

  void _subscribeToAgoraEvents() {
    _userMuteSub ??= _agoraService.onUserMuteAudio.listen((_) {
      if (mounted) setState(() {});
    });
    _userJoinedSub ??= _agoraService.onUserJoined.listen((remoteUid) {
      debugPrint('✓ Agora user joined: $remoteUid');
      if (mounted) setState(() {});
    });
    _userLeftSub ??= _agoraService.onUserOffline.listen((remoteUid) {
      debugPrint('✓ Agora user left: $remoteUid');
      if (mounted) setState(() {});
    });
  }

  Future<void> _initAndJoinVoice() async {
    final appState = _appState;
    final currentUserId = appState.currentUser?.id ?? appState.student.id;
    final myUid = agoraUidForUser(currentUserId);

    try {
      final token = await _agoraTokenService.getToken(
        roomId: widget.room.id,
        channelName: widget.room.channelName,
        uid: myUid,
      );
      final joined = await _agoraService.joinChannel(
        channelName: widget.room.channelName,
        uid: myUid,
        token: token,
      );
      if (!joined) throw StateError('Agora bağlantısı kurulamadı.');

      _hasJoinedRoom = true;
      unawaited(_registerMeetPresence(appState));
      _volumeSub = _agoraService.onVolumeIndication.listen((speakers) {
        if (!mounted) return;
        final room = appState.meetRooms.firstWhere(
          (item) => item.id == widget.room.id,
          orElse: () => widget.room,
        );
        for (final speaker in speakers) {
          final participant = room.participants
              .where((item) => item.agoraUid == speaker.uid)
              .firstOrNull;
          if (participant != null) {
            appState.updateParticipantSpeaking(
              widget.room.id,
              participant.userId,
              (speaker.volume ?? 0) > 10,
            );
          }
        }
      });
    } catch (error) {
      _connectionError = error.toString().replaceFirst('Bad state: ', '');
      debugPrint('Meet connection error: $error');
    } finally {
      if (mounted) setState(() => _isJoining = false);
    }
  }

  Future<void> _registerMeetPresence(AppState appState) async {
    for (var attempt = 0; attempt < 5; attempt++) {
      try {
        await appState
            .joinMeetRoom(widget.room.id)
            .timeout(const Duration(seconds: 20));
        debugPrint('✓ Meet presence registered successfully');
        return;
      } catch (error) {
        debugPrint(
          'Meet presence attempt ${attempt + 1}/5 failed; retrying: $error',
        );
        if (attempt < 4) {
          await Future<void>.delayed(Duration(seconds: 3 * (attempt + 1)));
        }
      }
    }
    debugPrint('⚠️ Meet presence registration failed after 5 attempts');
  }

  Future<void> _syncForcedMuteState() async {
    if (!_hasJoinedRoom) return;
    final userId = _appState.currentUser?.id ?? _appState.student.id;
    final room = _appState.meetRooms.firstWhere(
      (item) => item.id == widget.room.id,
      orElse: () => widget.room,
    );
    final participant = room.participants
        .where((item) => item.userId == userId)
        .firstOrNull;
    if (participant == null || participant.isMutedByHost == _isLocalMuted) {
      return;
    }

    final muted = await _agoraService.setLocalMute(participant.isMutedByHost);
    if (mounted) setState(() => _isLocalMuted = muted);
  }

  @override
  void dispose() {
    _durationTimer.cancel();
    _pulseController.dispose();
    _userJoinedSub?.cancel();
    _userLeftSub?.cancel();
    _userMuteSub?.cancel();
    _volumeSub?.cancel();
    _appState.removeListener(_syncForcedMuteState);

    if (_hasJoinedRoom) {
      _appState.leaveMeetRoom(widget.room.id);
    }
    _agoraService.leaveChannel();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _toggleMute() async {
    final appState = _appState;
    final userId = appState.currentUser?.id ?? appState.student.id;
    final room = appState.meetRooms.firstWhere(
      (item) => item.id == widget.room.id,
      orElse: () => widget.room,
    );
    final me = room.participants
        .where((participant) => participant.userId == userId)
        .firstOrNull;
    if (me?.isMutedByHost ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Müəllim mikrofonunuzu müvəqqəti bağlayıb.'),
        ),
      );
      return;
    }
    final newMuteState = await _agoraService.toggleLocalMute();
    await appState.toggleMyMuteInRoom(widget.room.id);
    setState(() {
      _isLocalMuted = newMuteState;
    });
  }

  Future<void> _toggleSpeaker() async {
    final newState = await _agoraService.toggleSpeaker();
    setState(() {
      _isSpeakerOn = newState;
    });
  }

  void _leaveRoom() async {
    if (_hasJoinedRoom) {
      await _appState.leaveMeetRoom(widget.room.id);
      _hasJoinedRoom = false;
    }
    await _agoraService.leaveChannel();
    if (mounted) Navigator.pop(context);
  }

  void _showParticipantOptions(
    MeetParticipant participant,
    bool isHost,
    String hostId,
  ) {
    if (!isHost) return;
    final appState = Provider.of<AppState>(context, listen: false);
    final isTargetHost = participant.userId == hostId;

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E293B),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              CircleAvatar(
                radius: 28,
                backgroundImage: NetworkImage(
                  participant.photoUrl ??
                      'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200',
                ),
                child: const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                participant.fullName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${participant.role == 'host' ? 'Host (Müəllim)' : (participant.role == 'teacher' ? 'Müəllim' : 'Şagird')} • ${participant.className ?? 'İdrak'}',
                style: const TextStyle(
                  color: AppColors.goldLight,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 20),

              if (!isTargetHost) ...[
                ListTile(
                  leading: Icon(
                    participant.isMuted
                        ? Icons.mic_rounded
                        : Icons.mic_off_rounded,
                    color: participant.isMuted
                        ? AppColors.success
                        : AppColors.danger,
                  ),
                  title: Text(
                    participant.isMuted
                        ? 'Səsini Aç (Unmute)'
                        : 'Səsini Susdur (Mute)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    participant.isMuted
                        ? 'Şagirdin danışmasına icazə ver'
                        : 'Şagirdin mikrofonunu məcburi bağla',
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final newMute = !participant.isMuted;
                    await _agoraService.muteRemoteParticipant(
                      participant.agoraUid,
                      newMute,
                    );
                    await appState.setParticipantMuteByHost(
                      widget.room.id,
                      participant.userId,
                      newMute,
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${participant.fullName} ${newMute ? 'susduruldu' : 'səsi açıldı'}',
                          ),
                          backgroundColor: newMute
                              ? AppColors.danger
                              : AppColors.success,
                        ),
                      );
                    }
                  },
                ),
                const Divider(color: Colors.white12),
                ListTile(
                  leading: const Icon(
                    Icons.person_remove_rounded,
                    color: AppColors.danger,
                  ),
                  title: const Text(
                    'Otaqdan Çıxar',
                    style: TextStyle(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text(
                    'İştirakçını bu toplantıdan uzaqlaşdır',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await appState.setParticipantMuteByHost(
                      widget.room.id,
                      participant.userId,
                      true,
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${participant.fullName} otaqdan uzaqlaşdırıldı',
                          ),
                          backgroundColor: AppColors.danger,
                        ),
                      );
                    }
                  },
                ),
              ] else ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Bu istifadəçi otağın təşkilatçısıdır (Host).',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _showMuteAllDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Row(
            children: [
              Icon(Icons.volume_off_rounded, color: AppColors.danger),
              SizedBox(width: 8),
              Text(
                'Hamını Susdur?',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            'Bütün şagird və iştirakçıların mikrofonları bağlanacaq. Yalnız siz danışa biləcəksiniz.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Ləğv et', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                final appState = Provider.of<AppState>(context, listen: false);
                await _agoraService.muteAllRemoteParticipants(true);
                await appState.muteAllInRoom(widget.room.id, true);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bütün iştirakçılar susduruldu'),
                      backgroundColor: AppColors.danger,
                    ),
                  );
                }
              },
              child: const Text('Hamısını Susdur', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showEndMeetingDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Row(
            children: [
              Icon(Icons.call_end_rounded, color: AppColors.danger),
              SizedBox(width: 8),
              Text(
                'Toplantını Bitir?',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            'Bu görüş bütün iştirakçılar üçün sonlandırılacaq və otaq bağlanacaq.',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Ləğv et', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                Navigator.pop(ctx);
                final appState = Provider.of<AppState>(context, listen: false);
                await appState.endMeetRoom(widget.room.id);
                await _agoraService.leaveChannel();
                if (mounted) Navigator.pop(context);
              },
              child: const Text('Toplantını Bitir', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  List<MeetParticipant> _participantsForDisplay(
    MeetRoom room,
    AppState appState,
    String currentUserId,
  ) {
    final byAgoraUid = <int, MeetParticipant>{
      for (final participant in room.participants)
        participant.agoraUid: participant,
    };

    final currentUser = appState.currentUser;
    final localUid = agoraUidForUser(currentUserId);
    byAgoraUid.putIfAbsent(
      localUid,
      () => MeetParticipant(
        userId: currentUserId,
        fullName: currentUser?.fullName ?? appState.student.fullName,
        role: room.hostId == currentUserId
            ? 'host'
            : (currentUser?.role == UserRole.teacher ? 'teacher' : 'student'),
        photoUrl: currentUser?.photoUrl ?? appState.student.photoUrl,
        className: currentUser?.className ?? appState.student.className,
        agoraUid: localUid,
      ),
    );

    for (final remoteUid in _agoraService.remoteUids) {
      byAgoraUid.putIfAbsent(remoteUid, () {
        final isRemoteHost = remoteUid == agoraUidForUser(room.hostId);
        return MeetParticipant(
          userId: isRemoteHost ? room.hostId : 'agora-$remoteUid',
          fullName: isRemoteHost ? room.hostName : 'Bağlı iştirakçı',
          role: isRemoteHost ? 'host' : 'student',
          photoUrl: isRemoteHost ? room.hostPhotoUrl : null,
          agoraUid: remoteUid,
        );
      });
    }

    return byAgoraUid.values.toList()..sort((a, b) {
      final aIsHost = a.userId == room.hostId;
      final bIsHost = b.userId == room.hostId;
      if (aIsHost != bIsHost) return aIsHost ? -1 : 1;
      return a.joinedAt.compareTo(b.joinedAt);
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final currentUserId = appState.currentUser?.id ?? appState.student.id;

    final currentRoom = appState.meetRooms.firstWhere(
      (r) => r.id == widget.room.id,
      orElse: () => widget.room,
    );

    final isHost = currentRoom.hostId == currentUserId;
    final participants = _participantsForDisplay(
      currentRoom,
      appState,
      currentUserId,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF070B16),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white),
          ),
          onPressed: _leaveRoom,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              currentRoom.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: -0.2),
            ),
            Row(
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  '${currentRoom.subject} • ${_formatDuration(_secondsElapsed)} • ${participants.length} İştirakçı',
                  style: const TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (isHost) ...[
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.volume_off_rounded, color: AppColors.goldLight, size: 18),
              ),
              tooltip: 'Hamını Susdur',
              onPressed: _showMuteAllDialog,
            ),
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.danger.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.power_settings_new_rounded, color: AppColors.danger, size: 18),
              ),
              tooltip: 'Toplantını Bitir',
              onPressed: _showEndMeetingDialog,
            ),
          ],
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          if (_isJoining || _connectionError != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: _connectionError == null
                  ? AppColors.primaryAccent.withAlpha(45)
                  : AppColors.danger.withAlpha(45),
              child: Row(
                children: [
                  if (_connectionError == null)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  else
                    const Icon(Icons.error_outline_rounded, color: Colors.white, size: 16),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _connectionError ?? 'Səsli otağa qoşulursunuz…',
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),

          // Host Alert Banner
          if (isHost)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.gold.withAlpha(20),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.gold.withAlpha(50)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.admin_panel_settings_rounded, color: AppColors.goldLight, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Siz Hostsuz. İştirakçının üzərinə toxunaraq səsini aça və ya bağlaya bilərsiniz.',
                      style: TextStyle(
                        color: AppColors.goldLight,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Target classes tag info
          if (currentRoom.targetClasses.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.groups_rounded, color: Colors.white54, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'İcazəli Siniflər: ${currentRoom.targetClasses.join(', ')}',
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            ),

          // Participants Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: GridView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: participants.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.95,
                ),
                itemBuilder: (context, index) {
                  final p = participants[index];
                  final isMe = p.userId == currentUserId;
                  final isParticipantHost = p.userId == currentRoom.hostId;
                  final isParticipantSpeaking = p.isSpeaking;

                  return GestureDetector(
                    onTap: () => _showParticipantOptions(p, isHost, currentRoom.hostId),
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        final glow = isParticipantSpeaking ? (_pulseController.value * 8 + 4) : 0.0;
                        return Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B).withAlpha(180),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isParticipantSpeaking
                                  ? AppColors.success
                                  : (isParticipantHost ? AppColors.gold : Colors.white12),
                              width: isParticipantSpeaking ? 2 : (isParticipantHost ? 1.5 : 1),
                            ),
                            boxShadow: isParticipantSpeaking
                                ? [
                                    BoxShadow(
                                      color: AppColors.success.withAlpha(100),
                                      blurRadius: glow,
                                      spreadRadius: 2,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Avatar
                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        if (isParticipantSpeaking)
                                          Container(
                                            width: 68,
                                            height: 68,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: AppColors.success.withAlpha(120),
                                                width: 3,
                                              ),
                                            ),
                                          ),
                                        CircleAvatar(
                                          radius: 28,
                                          backgroundImage: NetworkImage(
                                            p.photoUrl ??
                                                'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200',
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),

                                    // Full Name
                                    Text(
                                      isMe ? '${p.fullName} (Siz)' : p.fullName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.5,
                                        fontWeight: isMe ? FontWeight.w900 : FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 4),

                                    // Role Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isParticipantHost
                                            ? AppColors.gold.withAlpha(30)
                                            : (p.role == 'teacher'
                                                ? AppColors.primaryAccent.withAlpha(30)
                                                : Colors.white.withAlpha(15)),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        isParticipantHost
                                            ? '👑 Host'
                                            : (p.role == 'teacher' ? '👨‍🏫 Müəllim' : (p.className ?? '🎓 Şagird')),
                                        style: TextStyle(
                                          color: isParticipantHost
                                              ? AppColors.goldLight
                                              : (p.role == 'teacher' ? AppColors.primaryAccent : Colors.white70),
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Mic Status Icon
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: p.isMuted ? AppColors.danger : AppColors.success.withAlpha(40),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: p.isMuted ? AppColors.danger : AppColors.success,
                                    ),
                                  ),
                                  child: Icon(
                                    p.isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ),
                              ),

                              // Hand Raised indicator
                              if (isMe && _isHandRaised)
                                Positioned(
                                  top: 10,
                                  left: 10,
                                  child: Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: const BoxDecoration(
                                      color: AppColors.gold,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.front_hand_rounded,
                                      color: Color(0xFF0F172A),
                                      size: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),

          // Bottom Control Dock
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(color: Colors.white.withAlpha(15)),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 20,
                  offset: Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // 1. Mic Mute / Unmute Button (Primary Large)
                  GestureDetector(
                    onTap: _toggleMute,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isLocalMuted ? AppColors.danger : AppColors.success,
                            boxShadow: [
                              BoxShadow(
                                color: (_isLocalMuted ? AppColors.danger : AppColors.success).withAlpha(100),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Icon(
                            _isLocalMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _isLocalMuted ? 'Səssiz' : 'Danışırsınız',
                          style: TextStyle(
                            color: _isLocalMuted ? Colors.white60 : AppColors.success,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 2. Speakerphone Toggle
                  GestureDetector(
                    onTap: _toggleSpeaker,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withAlpha(15),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Icon(
                            _isSpeakerOn ? Icons.volume_up_rounded : Icons.phone_in_talk_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _isSpeakerOn ? 'Dinamik' : 'Dəstək',
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),

                  // 3. Raise Hand Button
                  GestureDetector(
                    onTap: () {
                      setState(() => _isHandRaised = !_isHandRaised);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _isHandRaised ? 'Əl qaldırdınız ✋' : 'Əlinizi endirdiniz',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isHandRaised ? AppColors.gold.withAlpha(40) : Colors.white.withAlpha(15),
                            border: Border.all(
                              color: _isHandRaised ? AppColors.gold : Colors.white24,
                            ),
                          ),
                          child: Icon(
                            Icons.front_hand_rounded,
                            color: _isHandRaised ? AppColors.goldLight : Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _isHandRaised ? 'Əl aktiv' : 'Əl qaldır',
                          style: TextStyle(
                            color: _isHandRaised ? AppColors.goldLight : Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 4. Leave Meeting (Red Button)
                  GestureDetector(
                    onTap: _leaveRoom,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.danger.withAlpha(25),
                            border: Border.all(color: AppColors.danger.withAlpha(60)),
                          ),
                          child: const Icon(
                            Icons.call_end_rounded,
                            color: AppColors.danger,
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Çıxış',
                          style: TextStyle(
                            color: AppColors.danger,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
