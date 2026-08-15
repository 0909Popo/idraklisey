import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../providers/app_state.dart';
import '../../../data/models/ticket_model.dart';

class QrInventoryTicketScreen extends StatefulWidget {
  const QrInventoryTicketScreen({super.key});

  @override
  State<QrInventoryTicketScreen> createState() => _QrInventoryTicketScreenState();
}

class _QrInventoryTicketScreenState extends State<QrInventoryTicketScreen> {
  String? _scannedQrCode;
  String? _detectedRoom;
  String? _detectedEquipment;
  final TextEditingController _problemTitleCtrl = TextEditingController();
  final TextEditingController _problemDescCtrl = TextEditingController();
  TicketPriority _priority = TicketPriority.urgent;
  bool _isScanning = false;

  @override
  void dispose() {
    _problemTitleCtrl.dispose();
    _problemDescCtrl.dispose();
    super.dispose();
  }

  void _simulateQrScan() {
    setState(() => _isScanning = true);

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _isScanning = false;
          _scannedQrCode = 'IDRAK-INV-ROOM302-PROJ-882';
          _detectedRoom = 'Otaq 302 (Riyaziyyat Korpusu)';
          _detectedEquipment = 'Epson HD Proyektor & Smart Lövhə (INV-PRJ-2023-302)';
          // Do not auto-fill problem text - teacher enters custom description from scratch!
          _problemTitleCtrl.clear();
          _problemDescCtrl.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Avadanlıq QR Kodu uğurla skan edildi! İndi nasazlıq haqqında məlumatı qeyd edin.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final currentUser = appState.currentUser;
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
                      onPressed: _isScanning ? null : _simulateQrScan,
                      icon: _isScanning
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.camera_alt_rounded),
                      label: Text(_isScanning ? 'Kamera Açılır...' : 'Avadanlıq QR Kodunu Skan Et'),
                    ),
                  ),
                ],
              ),
            ),

            // Scanned Equipment Details & Report Form
            if (_scannedQrCode != null) ...[
              CustomCard(
                backgroundColor: const Color(0xFFFEF2F2),
                border: Border.all(color: AppColors.danger.withAlpha(60)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.precision_manufacturing_rounded, color: AppColors.danger, size: 20),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Aşkar Edilmiş Avadanlıq:',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                        StatusBadge(
                          label: 'QR Təsdiqləndi',
                          color: AppColors.danger,
                          fontSize: 9,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(_detectedEquipment!, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary)),
                    Text(_detectedRoom!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),

              // Problem Form
              CustomCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Nasazlıq Şikayətini Rəhbərliyə Göndər', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
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
                        onPressed: () {
                          if (_problemTitleCtrl.text.isNotEmpty && _problemDescCtrl.text.isNotEmpty) {
                            final newTicket = HelpdeskTicket(
                              id: 'INV-TK-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                              title: _problemTitleCtrl.text.trim(),
                              category: TicketCategory.inventory,
                              status: TicketStatus.open,
                              priority: _priority,
                              senderName: '${currentUser?.fullName ?? "Müəllim"} (${currentUser?.subject ?? "Tədris"})',
                              senderRole: 'Müəllim',
                              roomNumber: _detectedRoom,
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
                            _problemTitleCtrl.clear();
                            _problemDescCtrl.clear();
                            setState(() => _scannedQrCode = null);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('İnventar nasazlıq müraciəti rəhbərliyə və IT şöbəsinə çatdırıldı!'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Zəhmət olmasa problem başlığını və izahını qeyd edin!')),
                            );
                          }
                        },
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
              child: const Text('Məktəb Üzrə Texniki Müraciətlər', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
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
                        Text(ticket.inventoryCode ?? ticket.id, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(ticket.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text(ticket.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
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
