import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../providers/app_state.dart';
import '../../../data/models/ticket_model.dart';
import '../../../data/models/inventory_model.dart';
import '../../../data/models/notification_model.dart';
import '../../shared/screens/qr_scanner_screen.dart';

class QrInventoryTicketScreen extends StatefulWidget {
  const QrInventoryTicketScreen({super.key});

  @override
  State<QrInventoryTicketScreen> createState() => _QrInventoryTicketScreenState();
}

class _QrInventoryTicketScreenState extends State<QrInventoryTicketScreen> {
  String? _scannedQrCode;
  InventoryItem? _scannedItem; // Resolved equipment from the registry (null = unknown QR)
  final TextEditingController _problemTitleCtrl = TextEditingController();
  final TextEditingController _problemDescCtrl = TextEditingController();
  TicketPriority _priority = TicketPriority.urgent;

  @override
  void dispose() {
    _problemTitleCtrl.dispose();
    _problemDescCtrl.dispose();
    super.dispose();
  }

  /// Opens the real camera scanner and resolves the scanned QR payload
  /// against the admin-managed inventory registry.
  Future<void> _startRealScan() async {
    final appState = Provider.of<AppState>(context, listen: false);

    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const QrScannerScreen()),
    );

    if (code == null || code.isEmpty) return;

    final item = appState.findInventoryItemByQr(code);

    setState(() {
      _scannedQrCode = code;
      _scannedItem = item;
      // Do not auto-fill problem text - teacher enters custom description from scratch!
      _problemTitleCtrl.clear();
      _problemDescCtrl.clear();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            item != null
                ? 'QR tanındı: ${item.name}. İndi nasazlıq haqqında məlumatı qeyd edin.'
                : 'QR oxundu, amma bu avadanlıq reyestrdə qeydiyyatda deyil. Yenə də müraciət göndərə bilərsiniz.',
          ),
          backgroundColor: item != null ? AppColors.success : AppColors.warning,
        ),
      );
    }
  }

  void _submitTicket(AppState appState) {
    if (_problemTitleCtrl.text.trim().isEmpty || _problemDescCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Zəhmət olmasa problem başlığını və izahını qeyd edin!')),
      );
      return;
    }

    final currentUser = appState.currentUser;
    final item = _scannedItem;

    final newTicket = HelpdeskTicket(
      id: 'INV-TK-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
      title: _problemTitleCtrl.text.trim(),
      category: TicketCategory.inventory,
      status: TicketStatus.open,
      priority: _priority,
      senderName: '${currentUser?.fullName ?? "Müəllim"} (${currentUser?.subject ?? "Tədris"})',
      senderRole: 'Müəllim',
      roomNumber: item?.room,
      inventoryCode: _scannedQrCode,
      description: _problemDescCtrl.text.trim(),
      createdAt: DateTime.now(),
      messages: [
        TicketMessage(
          sender: currentUser?.fullName ?? 'Müəllim',
          message: _problemDescCtrl.text.trim(),
          timestamp: DateTime.now(),
          isFromStaff: false,
        ),
      ],
    );

    appState.addTicket(newTicket);

    // Real in-app notification for the admin: which device + the problem
    // exactly as the teacher described it.
    final deviceLabel = item != null
        ? '${item.name} (${item.room})'
        : 'Qeydiyyatsız avadanlıq [QR: $_scannedQrCode]';
    appState.sendNotification(
      title: '📡 Texniki Müraciət: ${item?.name ?? "Qeydiyyatsız QR"}',
      message:
          '$deviceLabel — ${newTicket.title}. Göndərən: ${currentUser?.fullName ?? "Müəllim"}. İzah: ${_problemDescCtrl.text.trim()}',
      category: _priority == TicketPriority.urgent
          ? NotificationCategory.emergency
          : NotificationCategory.general,
      priority: _priority == TicketPriority.urgent ? 'high' : 'normal',
    );

    _problemTitleCtrl.clear();
    _problemDescCtrl.clear();
    setState(() {
      _scannedQrCode = null;
      _scannedItem = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('İnventar nasazlıq müraciəti rəhbərliyə və IT şöbəsinə çatdırıldı!'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final inventoryTickets = appState.tickets.where((t) => t.category == TicketCategory.inventory).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('İnventar & QR Texniki Ticket'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Scanner Action Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF334155)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(50),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.qr_code_scanner_rounded, color: AppColors.goldLight, size: 28),
                          SizedBox(width: 10),
                          Text(
                            'İnventar QR Skaneri',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryAccent.withAlpha(40),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('İT Dəstək', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Müəllim otağındakı proyektor, kompüter və ya elektron avadanlığın üzərindəki QR kodu skan edərək anında ticket göndərin.',
                    style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.3),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldDark),
                      onPressed: _startRealScan,
                      icon: const Icon(Icons.camera_alt_rounded),
                      label: const Text('Avadanlıq QR Kodunu Skan Et'),
                    ),
                  ),
                ],
              ),
            ),

            // Scanned Equipment Details & Report Form
            if (_scannedQrCode != null) ...[
              if (_scannedItem != null) ...[
                // Known device — green confirmation card
                CustomCard(
                  backgroundColor: AppColors.success.withAlpha(22),
                  border: Border.all(color: AppColors.success.withAlpha(60)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.precision_manufacturing_rounded, color: AppColors.success, size: 20),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Aşkar Edilmiş Avadanlıq:',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                          StatusBadge(
                            label: 'QR Təsdiqləndi',
                            color: AppColors.success,
                            fontSize: 9,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(_scannedItem!.name, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary)),
                      const SizedBox(height: 2),
                      Text(_scannedItem!.room, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      if (_scannedItem!.serialNumber.isNotEmpty)
                        Text('Seriya №: ${_scannedItem!.serialNumber}', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      const SizedBox(height: 4),
                      Text('QR: $_scannedQrCode', style: TextStyle(fontSize: 10, color: AppColors.textMuted, fontFamily: 'monospace')),
                    ],
                  ),
                ),
              ] else ...[
                // Unknown QR — amber warning, still allowed to report
                CustomCard(
                  backgroundColor: AppColors.warning.withAlpha(25),
                  border: Border.all(color: AppColors.warning.withAlpha(70)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.help_outline_rounded, color: AppColors.warning, size: 20),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'Bu QR reyestrdə qeydiyyatda deyil',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF92400E)),
                            ),
                          ),
                          StatusBadge(
                            label: 'Bilinmir',
                            color: AppColors.warning,
                            fontSize: 9,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Bu avadanlıq admin tərəfindən qeydiyyata alınmayıb. Müraciəti yenə də göndərə bilərsiniz — İT şöbəsi QR koduna görə cihazı müəyyən edəcək.',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                      ),
                      const SizedBox(height: 4),
                      Text('QR: $_scannedQrCode', style: TextStyle(fontSize: 10, color: AppColors.textMuted, fontFamily: 'monospace')),
                    ],
                  ),
                ),
              ],

              // Problem Form
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Nasazlıq Şikayətini Rəhbərliyə Göndər', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _problemTitleCtrl,
                      decoration: const InputDecoration(labelText: 'Problem Başlığı *', hintText: 'Məs: Proyektor lampası yanmır'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _problemDescCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Ətraflı İzah *', hintText: 'Problem haqqında ətraflı məlumatı qeyd edin...'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<TicketPriority>(
                      initialValue: _priority,
                      decoration: const InputDecoration(labelText: 'Təcililik Dərəcəsi'),
                      items: TicketPriority.values.map((p) {
                        return DropdownMenuItem(
                          value: p,
                          child: Text(p == TicketPriority.urgent ? '🚨 Təcili (Dərs Prosesinə Mane Olur)' : 'Normal Baxış'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _priority = val);
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
                        onPressed: () => _submitTicket(appState),
                        icon: const Icon(Icons.report_problem_rounded),
                        label: const Text('Rəhbərliyə və İT Şöbəsinə Göndər'),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 14),

            // Previous Inventory Tickets List
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Məktəb Üzrə Texniki Müraciətlər', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            ),
            const SizedBox(height: 8),

            ...inventoryTickets.map((ticket) {
              return CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        StatusBadge(
                          label: ticket.priority == TicketPriority.urgent ? 'TƏCİLİ' : 'NORMAL',
                          color: ticket.priority == TicketPriority.urgent ? AppColors.danger : AppColors.warning,
                        ),
                        Text(ticket.inventoryCode ?? ticket.id, style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(ticket.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text(ticket.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
