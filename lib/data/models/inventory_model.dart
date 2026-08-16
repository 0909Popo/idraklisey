/// A piece of school equipment registered in the QR inventory registry.
///
/// Admin registers items here (attaching a unique [qrCode] printed as a QR
/// sticker on the device). When a teacher scans that QR, the app resolves it
/// back to this record so the fault ticket carries the device identity.
class InventoryItem {
  final String id;
  final String qrCode;
  final String name;
  final String category;
  final String room;
  final String serialNumber;
  final String notes;
  final bool isActive;
  final DateTime createdAt;

  const InventoryItem({
    required this.id,
    required this.qrCode,
    required this.name,
    required this.category,
    required this.room,
    this.serialNumber = '',
    this.notes = '',
    this.isActive = true,
    required this.createdAt,
  });

  InventoryItem copyWith({
    String? id,
    String? qrCode,
    String? name,
    String? category,
    String? room,
    String? serialNumber,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      qrCode: qrCode ?? this.qrCode,
      name: name ?? this.name,
      category: category ?? this.category,
      room: room ?? this.room,
      serialNumber: serialNumber ?? this.serialNumber,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Standard equipment categories offered in the admin registration form.
const List<String> inventoryCategories = [
  'Proyektor',
  'Smart Lövhə',
  'Kompyuter',
  'Noutbuk',
  'Printer / Skaner',
  'Səs Sistemi',
  'Laboratoriya Avadanlığı',
  'Mebel',
  'Digər',
];
