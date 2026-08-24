class MeetParticipant {
  final String userId;
  final String fullName;
  final String role; // 'host', 'teacher', 'student'
  final String? photoUrl;
  final String? className;
  final bool isMuted;
  final bool isMutedByHost;
  final bool isSpeaking;
  final DateTime joinedAt;

  MeetParticipant({
    required this.userId,
    required this.fullName,
    required this.role,
    this.photoUrl,
    this.className,
    this.isMuted = false,
    this.isMutedByHost = false,
    this.isSpeaking = false,
    DateTime? joinedAt,
  }) : joinedAt = joinedAt ?? DateTime.now();

  MeetParticipant copyWith({
    String? userId,
    String? fullName,
    String? role,
    String? photoUrl,
    String? className,
    bool? isMuted,
    bool? isMutedByHost,
    bool? isSpeaking,
    DateTime? joinedAt,
  }) {
    return MeetParticipant(
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      className: className ?? this.className,
      isMuted: isMuted ?? this.isMuted,
      isMutedByHost: isMutedByHost ?? this.isMutedByHost,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'fullName': fullName,
    'role': role,
    'photoUrl': photoUrl,
    'className': className,
    'isMuted': isMuted,
    'isMutedByHost': isMutedByHost,
    'isSpeaking': isSpeaking,
    'joinedAt': joinedAt.toIso8601String(),
  };

  factory MeetParticipant.fromJson(Map<String, dynamic> json) {
    return MeetParticipant(
      userId: json['userId'] ?? '',
      fullName: json['fullName'] ?? '',
      role: json['role'] ?? 'student',
      photoUrl: json['photoUrl'],
      className: json['className'],
      isMuted: json['isMuted'] ?? false,
      isMutedByHost: json['isMutedByHost'] ?? false,
      isSpeaking: json['isSpeaking'] ?? false,
      joinedAt: json['joinedAt'] != null
          ? DateTime.tryParse(json['joinedAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class MeetRoom {
  final String id;
  final String title;
  final String hostId;
  final String hostName;
  final String? hostPhotoUrl;
  final String subject;
  final List<String> targetClasses; // e.g. ['9A', '9B'] or [] for all
  final bool allowTeachers; // Can other teachers join?
  final bool allowStudents; // Can students join?
  final String
  status; // 'live' (Canlı Dərs Gedir), 'scheduled' (Planlaşdırılıb), 'ended' (Başa çatdı)
  final DateTime createdAt;
  final DateTime? scheduledTime;
  final List<MeetParticipant> participants;
  final List<String> materials; // PDF links or slide notes

  MeetRoom({
    required this.id,
    required this.title,
    required this.hostId,
    required this.hostName,
    this.hostPhotoUrl,
    required this.subject,
    this.targetClasses = const [],
    this.allowTeachers = true,
    this.allowStudents = true,
    this.status = 'live',
    DateTime? createdAt,
    this.scheduledTime,
    this.participants = const [],
    this.materials = const [],
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isLive => status == 'live' || status == 'Canlı Dərs Gedir';

  MeetRoom copyWith({
    String? id,
    String? title,
    String? hostId,
    String? hostName,
    String? hostPhotoUrl,
    String? subject,
    List<String>? targetClasses,
    bool? allowTeachers,
    bool? allowStudents,
    String? status,
    DateTime? createdAt,
    DateTime? scheduledTime,
    List<MeetParticipant>? participants,
    List<String>? materials,
  }) {
    return MeetRoom(
      id: id ?? this.id,
      title: title ?? this.title,
      hostId: hostId ?? this.hostId,
      hostName: hostName ?? this.hostName,
      hostPhotoUrl: hostPhotoUrl ?? this.hostPhotoUrl,
      subject: subject ?? this.subject,
      targetClasses: targetClasses ?? this.targetClasses,
      allowTeachers: allowTeachers ?? this.allowTeachers,
      allowStudents: allowStudents ?? this.allowStudents,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      participants: participants ?? this.participants,
      materials: materials ?? this.materials,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'hostId': hostId,
    'hostName': hostName,
    'hostPhotoUrl': hostPhotoUrl,
    'subject': subject,
    'targetClasses': targetClasses,
    'allowTeachers': allowTeachers,
    'allowStudents': allowStudents,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'scheduledTime': scheduledTime?.toIso8601String(),
    'participants': participants.map((p) => p.toJson()).toList(),
    'materials': materials,
  };

  factory MeetRoom.fromJson(Map<String, dynamic> json) {
    return MeetRoom(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      hostId: json['hostId'] ?? '',
      hostName: json['hostName'] ?? '',
      hostPhotoUrl: json['hostPhotoUrl'],
      subject: json['subject'] ?? '',
      targetClasses:
          (json['targetClasses'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      allowTeachers: json['allowTeachers'] ?? true,
      allowStudents: json['allowStudents'] ?? true,
      status: json['status'] ?? 'live',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      scheduledTime: json['scheduledTime'] != null
          ? DateTime.tryParse(json['scheduledTime'])
          : null,
      participants:
          (json['participants'] as List<dynamic>?)
              ?.map((p) => MeetParticipant.fromJson(p))
              .toList() ??
          [],
      materials:
          (json['materials'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

// Backward compatibility alias for legacy mock data / screens
typedef OnlineLesson = MeetRoom;
