enum TicketCategory {
  general,      // Ümumi müraciət
  academic,     // Tədris və Qiymətlər
  psychological,// Məktəb Psixoloqu
  finance,      // Mühasibatlıq / Ödənişlər
  inventory,    // İnventar & IT (Proyektor, Kompüter, Lövhə)
  cafeteria,    // Yeməkxana & Qidalanma
}

enum TicketStatus {
  open,        // Gözləmədə
  inProgress,  // Baxılır / İcrada
  resolved,    // Həll olundu
  closed,      // Bağlandı
}

enum TicketPriority {
  low,
  medium,
  high,
  urgent,
}

class TicketMessage {
  final String sender; // "Valideyn", "Müəllim", "İT Dəstək", "Rəhbərlik"
  final String message;
  final DateTime timestamp;
  final bool isFromStaff;

  TicketMessage({
    required this.sender,
    required this.message,
    required this.timestamp,
    required this.isFromStaff,
  });
}

class HelpdeskTicket {
  final String id;
  final String title;
  final TicketCategory category;
  final TicketStatus status;
  final TicketPriority priority;
  final String senderName;
  final String senderRole; // "Valideyn", "Müəllim"
  final String description;
  final DateTime createdAt;
  final String? roomNumber;     // e.g. "Otaq 304"
  final String? inventoryCode;  // e.g. "INV-PRJ-2024-88"
  final String? attachedImage;
  final List<TicketMessage> messages;

  HelpdeskTicket({
    required this.id,
    required this.title,
    required this.category,
    required this.status,
    required this.priority,
    required this.senderName,
    required this.senderRole,
    required this.description,
    required this.createdAt,
    this.roomNumber,
    this.inventoryCode,
    this.attachedImage,
    this.messages = const [],
  });
}
