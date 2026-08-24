import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
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
      senderId: currentUser?.id,
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
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1A1B2E), Color(0xFF1E293B), Color(0xFFD97706)],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -15,
                      bottom: -15,
                      child: Icon(Icons.qr_code_scanner_rounded, size: 130, color: Colors.white.withAlpha(10)),
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
                                  child: const Icon(Icons.build_circle_rounded, size: 22, color: Colors.white),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'İnventar & QR Texniki Ticket',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Avadanlıq nasazlıq müraciətləri',
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

          // ── Content ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Scanner Action Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.cardBorder),
                      boxShadow: AppShadows.sm,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.goldDark.withAlpha(15),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(Icons.qr_code_scanner_rounded, color: AppColors.goldDark, size: 22),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'İnventar QR Skaneri',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryAccent.withAlpha(12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text('İT Dəstək', style: TextStyle(color: AppColors.primaryAccent, fontSize: 10.5, fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Müəllim otağındakı proyektor, kompüter və ya elektron avadanlığın üzərindəki QR kodu skan edərək anında ticket göndərin.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.goldDark,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                            ),
                            onPressed: _startRealScan,
                            icon: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                            label: const Text(
                              'Avadanlıq QR Kodunu Skan Et',
                              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Scanned Equipment Details & Report Form
                  if (_scannedQrCode != null) ...[
                    const SizedBox(height: 16),
                    if (_scannedItem != null) ...[
                      // Known device
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.success.withAlpha(60)),
                        ),
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
                                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF15803D)),
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
                      // Unknown QR
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF9C3).withAlpha(100),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppColors.warning.withAlpha(80)),
                        ),
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
                                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF92400E)),
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

                    const SizedBox(height: 16),

                    // Problem Form
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.cardBorder),
                        boxShadow: AppShadows.sm,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Nasazlıq Şikayətini Rəhbərliyə Göndər', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _problemTitleCtrl,
                            decoration: InputDecoration(
                              labelText: 'Problem Başlığı *',
                              hintText: 'Məs: Proyektor lampası yanmır',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: AppColors.cardBorder),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: AppColors.primaryAccent, width: 1.5),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _problemDescCtrl,
                            maxLines: 3,
                            decoration: InputDecoration(
                              labelText: 'Ətraflı İzah *',
                              hintText: 'Problem haqqında ətraflı məlumatı qeyd edin...',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(color: AppColors.cardBorder),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(color: AppColors.primaryAccent, width: 1.5),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<TicketPriority>(
                            initialValue: _priority,
                            decoration: InputDecoration(
                              labelText: 'Təcililik Dərəcəsi',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            ),
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
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.danger,
                                padding: const EdgeInsets.symmetric(vertical: 13),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                elevation: 0,
                              ),
                              onPressed: () => _submitTicket(appState),
                              icon: const Icon(Icons.report_problem_rounded, color: Colors.white, size: 18),
                              label: const Text('Rəhbərliyə və İT Şöbəsinə Göndər', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Previous Inventory Tickets List Header
                  Text('Məktəb Üzrə Texniki Müraciətlər', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  const SizedBox(height: 10),

                  if (inventoryTickets.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Center(
                        child: Text(
                          'Aktiv texniki müraciət yoxdur.',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                        ),
                      ),
                    )
                  else
                    ...inventoryTickets.map((ticket) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.cardBorder),
                          boxShadow: AppShadows.sm,
                        ),
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
                                Text(ticket.inventoryCode ?? ticket.id, style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
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
          ),
        ],
      ),
    );
  }
}
