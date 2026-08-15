import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';

class AgoraService {
  static final AgoraService _instance = AgoraService._internal();
  factory AgoraService() => _instance;
  AgoraService._internal();

  // Agora App ID - Can be replaced with production App ID
  static String agoraAppId = '00000000000000000000000000000000'; // Default placeholder

  RtcEngine? _engine;
  bool _isInitialized = false;
  bool _isJoined = false;
  bool _isMuted = false;
  bool _isSpeakerOn = true;

  // Stream controllers for Agora events
  final _onUserJoinedController = StreamController<int>.broadcast();
  final _onUserOfflineController = StreamController<int>.broadcast();
  final _onUserMuteAudioController = StreamController<Map<String, dynamic>>.broadcast();
  final _onVolumeIndicationController = StreamController<List<AudioVolumeInfo>>.broadcast();
  final _onConnectionStateChangedController = StreamController<ConnectionStateType>.broadcast();

  Stream<int> get onUserJoined => _onUserJoinedController.stream;
  Stream<int> get onUserOffline => _onUserOfflineController.stream;
  Stream<Map<String, dynamic>> get onUserMuteAudio => _onUserMuteAudioController.stream;
  Stream<List<AudioVolumeInfo>> get onVolumeIndication => _onVolumeIndicationController.stream;
  Stream<ConnectionStateType> get onConnectionStateChanged => _onConnectionStateChangedController.stream;

  bool get isJoined => _isJoined;
  bool get isMuted => _isMuted;
  bool get isSpeakerOn => _isSpeakerOn;

  /// Initialize Agora Engine
  Future<bool> initAgora({String? customAppId}) async {
    final appId = customAppId ?? agoraAppId;
    if (_isInitialized && _engine != null) return true;

    try {
      // 1. Request microphone permission
      final micStatus = await Permission.microphone.request();
      if (!micStatus.isGranted && !kIsWeb) {
        debugPrint('[AgoraService] Microphone permission not granted');
      }

      // 2. Create engine
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ));

      // 3. Register Event Handlers
      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
            debugPrint('[AgoraService] onJoinChannelSuccess: channel=${connection.channelId}, uid=${connection.localUid}');
            _isJoined = true;
          },
          onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
            debugPrint('[AgoraService] onUserJoined: remoteUid=$remoteUid');
            _onUserJoinedController.add(remoteUid);
          },
          onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
            debugPrint('[AgoraService] onUserOffline: remoteUid=$remoteUid, reason=$reason');
            _onUserOfflineController.add(remoteUid);
          },
          onUserMuteAudio: (RtcConnection connection, int remoteUid, bool muted) {
            debugPrint('[AgoraService] onUserMuteAudio: remoteUid=$remoteUid, muted=$muted');
            _onUserMuteAudioController.add({'uid': remoteUid, 'muted': muted});
          },
          onAudioVolumeIndication: (RtcConnection connection, List<AudioVolumeInfo> speakers, int speakerNumber, int totalVolume) {
            _onVolumeIndicationController.add(speakers);
          },
          onConnectionStateChanged: (RtcConnection connection, ConnectionStateType state, ConnectionChangedReasonType reason) {
            debugPrint('[AgoraService] onConnectionStateChanged: state=$state, reason=$reason');
            _onConnectionStateChangedController.add(state);
          },
          onError: (ErrorCodeType err, String msg) {
            debugPrint('[AgoraService] onError: err=$err, msg=$msg');
          },
        ),
      );

      // 4. Enable Audio & Volume Indication
      await _engine!.enableAudio();
      await _engine!.enableAudioVolumeIndication(
        interval: 250,
        smooth: 3,
        reportVad: true,
      );
      await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
      await _engine!.setDefaultAudioRouteToSpeakerphone(true);

      _isInitialized = true;
      debugPrint('[AgoraService] Agora initialized successfully');
      return true;
    } catch (e) {
      debugPrint('[AgoraService] Initialization error (running in fallback mode): $e');
      _isInitialized = false;
      return false;
    }
  }

  /// Join a Voice Channel
  Future<bool> joinChannel({
    required String channelName,
    required int uid,
    String? token,
  }) async {
    try {
      if (!_isInitialized) {
        await initAgora();
      }

      if (_engine != null) {
        await _engine!.joinChannel(
          token: token ?? '',
          channelId: channelName,
          uid: uid,
          options: const ChannelMediaOptions(
            clientRoleType: ClientRoleType.clientRoleBroadcaster,
            channelProfile: ChannelProfileType.channelProfileCommunication,
            publishMicrophoneTrack: true,
            autoSubscribeAudio: true,
          ),
        );
      }
      _isJoined = true;
      _isMuted = false;
      return true;
    } catch (e) {
      debugPrint('[AgoraService] Join channel error: $e');
      _isJoined = true; // Still mark joined for UI state
      return false;
    }
  }

  /// Toggle Local Microphone Mute
  Future<bool> toggleLocalMute() async {
    return setLocalMute(!_isMuted);
  }

  /// Set Local Microphone Mute
  Future<bool> setLocalMute(bool muted) async {
    _isMuted = muted;
    try {
      if (_engine != null) {
        await _engine!.muteLocalAudioStream(muted);
      }
    } catch (e) {
      debugPrint('[AgoraService] muteLocalAudioStream error: $e');
    }
    return _isMuted;
  }

  /// Mute or Unmute a Specific Remote Participant (Host Control)
  Future<void> muteRemoteParticipant(int remoteUid, bool mute) async {
    try {
      if (_engine != null) {
        await _engine!.muteRemoteAudioStream(uid: remoteUid, mute: mute);
      }
    } catch (e) {
      debugPrint('[AgoraService] muteRemoteAudioStream error: $e');
    }
  }

  /// Mute All Remote Participants (Host Control)
  Future<void> muteAllRemoteParticipants(bool mute) async {
    try {
      if (_engine != null) {
        await _engine!.muteAllRemoteAudioStreams(mute);
      }
    } catch (e) {
      debugPrint('[AgoraService] muteAllRemoteAudioStreams error: $e');
    }
  }

  /// Toggle Loudspeaker / Earpiece
  Future<bool> toggleSpeaker() async {
    _isSpeakerOn = !_isSpeakerOn;
    try {
      if (_engine != null) {
        await _engine!.setEnableSpeakerphone(_isSpeakerOn);
      }
    } catch (e) {
      debugPrint('[AgoraService] setEnableSpeakerphone error: $e');
    }
    return _isSpeakerOn;
  }

  /// Leave Channel
  Future<void> leaveChannel() async {
    try {
      if (_engine != null && _isJoined) {
        await _engine!.leaveChannel();
      }
    } catch (e) {
      debugPrint('[AgoraService] leaveChannel error: $e');
    } finally {
      _isJoined = false;
      _isMuted = false;
    }
  }

  /// Dispose
  Future<void> dispose() async {
    await leaveChannel();
    try {
      if (_engine != null) {
        await _engine!.release();
        _engine = null;
        _isInitialized = false;
      }
    } catch (e) {
      debugPrint('[AgoraService] dispose error: $e');
    }
  }
}
