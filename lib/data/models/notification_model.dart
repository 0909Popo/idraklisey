enum NotificationCategory {
  general,       // Rəsmi / Ümumi Lisey Elanı
  teacherDirect, // Müəllimdən Valideynə / Şagirdə Fərdi Mesaj
  classBroadcast,// Sinif Üzrə Elan
  academic,      // Dərs / Tapşırıq / Qiymət Bildirişi
  attendance,    // Davamiyyət Xəbərdarlığı
  emergency,     // Təcili / Vacib Bildiriş
}

class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationCategory category;
  final String senderId;
  final String senderName;
  final String? senderPhotoUrl;
  final String senderRole; // 'admin', 'teacher', 'school'
  final String? senderSubject; // e.g. "Riyaziyyat" for teacher
  final String? targetStudentId;
  final String? targetStudentName;
  final String? targetParentId;
  final List<String> targetClasses; // e.g. ['9A', '9B'] or [] for all
  final List<String> targetRoles; // ['student', 'parent', 'teacher'] or [] for all
  final DateTime createdAt;
  final List<String> readByUserIds; // User IDs who marked it read
  final String priority; // 'normal', 'important', 'urgent'

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    this.category = NotificationCategory.general,
    required this.senderId,
    required this.senderName,
    this.senderPhotoUrl,
    required this.senderRole,
    this.senderSubject,
    this.targetStudentId,
    this.targetStudentName,
    this.targetParentId,
    this.targetClasses = const [],
    this.targetRoles = const [],
    DateTime? createdAt,
    this.readByUserIds = const [],
    this.priority = 'normal',
  }) : createdAt = createdAt ?? DateTime.now();

  bool isReadBy(String userId) => readByUserIds.contains(userId);

  AppNotification copyWith({
    String? id,
    String? title,
    String? message,
    NotificationCategory? category,
    String? senderId,
    String? senderName,
    String? senderPhotoUrl,
    String? senderRole,
    String? senderSubject,
    String? targetStudentId,
    String? targetStudentName,
    String? targetParentId,
    List<String>? targetClasses,
    List<String>? targetRoles,
    DateTime? createdAt,
    List<String>? readByUserIds,
    String? priority,
  }) {
    return AppNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      category: category ?? this.category,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderPhotoUrl: senderPhotoUrl ?? this.senderPhotoUrl,
      senderRole: senderRole ?? this.senderRole,
      senderSubject: senderSubject ?? this.senderSubject,
      targetStudentId: targetStudentId ?? this.targetStudentId,
      targetStudentName: targetStudentName ?? this.targetStudentName,
      targetParentId: targetParentId ?? this.targetParentId,
      targetClasses: targetClasses ?? this.targetClasses,
      targetRoles: targetRoles ?? this.targetRoles,
      createdAt: createdAt ?? this.createdAt,
      readByUserIds: readByUserIds ?? this.readByUserIds,
      priority: priority ?? this.priority,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'message': message,
    'category': category.name,
    'senderId': senderId,
    'senderName': senderName,
    'senderPhotoUrl': senderPhotoUrl,
    'senderRole': senderRole,
    'senderSubject': senderSubject,
    'targetStudentId': targetStudentId,
    'targetStudentName': targetStudentName,
    'targetParentId': targetParentId,
    'targetClasses': targetClasses,
    'targetRoles': targetRoles,
    'createdAt': createdAt.toIso8601String(),
    'readByUserIds': readByUserIds,
    'priority': priority,
  };

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      category: NotificationCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => NotificationCategory.general,
      ),
      senderId: json['senderId'] ?? '',
      senderName: json['senderName'] ?? 'İdrak Liseyi',
      senderPhotoUrl: json['senderPhotoUrl'],
      senderRole: json['senderRole'] ?? 'school',
      senderSubject: json['senderSubject'],
      targetStudentId: json['targetStudentId'],
      targetStudentName: json['targetStudentName'],
      targetParentId: json['targetParentId'],
      targetClasses: (json['targetClasses'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      targetRoles: (json['targetRoles'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) ?? DateTime.now() : DateTime.now(),
      readByUserIds: (json['readByUserIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      priority: json['priority'] ?? 'normal',
    );
  }
}
