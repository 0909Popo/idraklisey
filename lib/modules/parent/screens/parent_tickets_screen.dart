import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../providers/app_state.dart';
import '../../../data/models/ticket_model.dart';

class ParentTicketsScreen extends StatefulWidget {
  const ParentTicketsScreen({super.key});

  @override
  State<ParentTicketsScreen> createState() => _ParentTicketsScreenState();
}

class _ParentTicketsScreenState extends State<ParentTicketsScreen> {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final parentTickets = appState.tickets.where((t) => t.senderRole == 'Valideyn').toList();
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Elektron Müraciətlər (Helpdesk)'),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateTicketDialog(context),
        backgroundColor: AppColors.primaryAccent,
        icon: const Icon(Icons.add_comment_outlined, color: Colors.white),
        label: const Text('Yeni Müraciət', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: parentTickets.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 56, color: AppColors.textMuted),
                  const SizedBox(height: 12),
                  Text('Hələ ki, heç bir müraciətiniz yoxdur.', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                ],
              ),
            )
          : ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
              itemCount: parentTickets.length,
              itemBuilder: (context, index) {
                final ticket = parentTickets[index];
                return _buildTicketCard(context, ticket, dateFormat);
              },
            ),
    );
  }

  Widget _buildTicketCard(BuildContext context, HelpdeskTicket ticket, DateFormat dateFormat) {
    Color statusColor;
    String statusLabel;
    switch (ticket.status) {
      case TicketStatus.open:
        statusColor = AppColors.warning;
        statusLabel = 'Gözləmədə';
        break;
      case TicketStatus.inProgress:
        statusColor = AppColors.primaryAccent;
        statusLabel = 'Baxılır / İcrada';
        break;
      case TicketStatus.resolved:
        statusColor = AppColors.success;
        statusLabel = 'Həll Olundu';
        break;
      case TicketStatus.closed:
        statusColor = AppColors.textMuted;
        statusLabel = 'Bağlandı';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: AppShadows.sm,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showTicketDetailsModal(context, ticket),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryAccent.withAlpha(15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            ticket.id,
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryAccent,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _getCategoryName(ticket.category),
                          style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    StatusBadge(
                      label: statusLabel,
                      color: statusColor,
                      fontSize: 10,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  ticket.title,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ticket.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 10),
                Divider(color: AppColors.cardBorder, height: 1),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dateFormat.format(ticket.createdAt),
                      style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.forum_outlined, size: 14, color: AppColors.primaryAccent),
                        const SizedBox(width: 4),
                        Text(
                          '${ticket.messages.length} Cavab',
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.primaryAccent),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getCategoryName(TicketCategory category) {
    switch (category) {
      case TicketCategory.general:
        return 'Ümumi Rəhbərlik';
      case TicketCategory.academic:
        return 'Tədris & Müəllim';
      case TicketCategory.psychological:
        return 'Məktəb Psixoloqu';
      case TicketCategory.finance:
        return 'Mühasibatlıq';
      case TicketCategory.inventory:
        return 'İT & Avadanlıq';
      case TicketCategory.cafeteria:
        return 'Yeməkxana & Qidalanma';
    }
  }

  void _showTicketDetailsModal(BuildContext context, HelpdeskTicket ticket) {
    final messageController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final appState = Provider.of<AppState>(context);
            final currentTicket = appState.tickets.firstWhere((t) => t.id == ticket.id, orElse: () => ticket);

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                height: MediaQuery.of(context).size.height * 0.75,
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentTicket.id,
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                            ),
                            Text(
                              currentTicket.title,
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Divider(color: AppColors.cardBorder),

                    // Resolved QR equipment info
                    if (currentTicket.inventoryCode != null &&
                        currentTicket.inventoryCode!.isNotEmpty) ...[
                      Builder(
                        builder: (context) {
                          final item = appState.findInventoryItemByQr(
                            currentTicket.inventoryCode!,
                          );
                          return Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(top: 6),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: item != null
                                  ? AppColors.success.withAlpha(15)
                                  : AppColors.warning.withAlpha(15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: item != null
                                    ? AppColors.success.withAlpha(50)
                                    : AppColors.warning.withAlpha(50),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      item != null
                                          ? Icons.precision_manufacturing_outlined
                                          : Icons.help_outline_rounded,
                                      color: item != null ? AppColors.success : AppColors.warning,
                                      size: 15,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'QR ilə aşkarlanan avadanlıq',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                        color: item != null ? const Color(0xFF065F46) : const Color(0xFF92400E),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                if (item != null) ...[
                                  Text(item.name, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                                  Text('${item.category} • ${item.room}', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                                  if (item.serialNumber.isNotEmpty)
                                    Text('Seriya №: ${item.serialNumber}', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                                ] else
                                  Text(
                                    'Bu QR reyestrdə qeydiyyatda deyil.',
                                    style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                    Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: currentTicket.messages.length,
                        itemBuilder: (context, index) {
                          final msg = currentTicket.messages[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: msg.isFromStaff ? AppColors.primaryAccent.withAlpha(12) : AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: msg.isFromStaff ? AppColors.primaryAccent.withAlpha(30) : AppColors.cardBorder,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      msg.sender,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.bold,
                                        color: msg.isFromStaff ? AppColors.primaryAccent : AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      DateFormat('HH:mm').format(msg.timestamp),
                                      style: TextStyle(fontSize: 9.5, color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  msg.message,
                                  style: TextStyle(fontSize: 12.5, color: AppColors.textPrimary),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: messageController,
                            decoration: const InputDecoration(
                              hintText: 'Cavabınızı yazın...',
                              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: () {
                            if (messageController.text.trim().isNotEmpty) {
                              appState.addTicketMessage(
                                currentTicket.id,
                                TicketMessage(
                                  sender: 'Rəşad Qasımov (Valideyn)',
                                  message: messageController.text.trim(),
                                  timestamp: DateTime.now(),
                                  isFromStaff: false,
                                ),
                              );
                              messageController.clear();
                              setModalState(() {});
                            }
                          },
                          icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                          style: IconButton.styleFrom(backgroundColor: AppColors.primaryAccent),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showCreateTicketDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    TicketCategory selectedCat = TicketCategory.general;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Yeni Müraciət Yarat',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<TicketCategory>(
                    initialValue: selectedCat,
                    decoration: const InputDecoration(labelText: 'Müraciət Şöbəsi / Kateqoriya'),
                    items: TicketCategory.values.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text(_getCategoryName(cat)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedCat = val);
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: titleCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Mövzu Başlığı',
                      hintText: 'Məs: Dərslik və ya qiymətləndirmə haqqında',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: descCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Ətraflı İzah',
                      hintText: 'Müraciətinizi tam şəkildə qeyd edin...',
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () {
                        if (titleCtrl.text.isNotEmpty && descCtrl.text.isNotEmpty) {
                          final newTicket = HelpdeskTicket(
                            id: 'TCK-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                            title: titleCtrl.text.trim(),
                            category: selectedCat,
                            status: TicketStatus.open,
                            priority: TicketPriority.medium,
                            senderName: 'Rəşad Qasımov',
                            senderRole: 'Valideyn',
                            description: descCtrl.text.trim(),
                            createdAt: DateTime.now(),
                            messages: [
                              TicketMessage(
                                sender: 'Rəşad Qasımov',
                                message: descCtrl.text.trim(),
                                timestamp: DateTime.now(),
                                isFromStaff: false,
                              ),
                            ],
                          );
                          Provider.of<AppState>(context, listen: false).addTicket(newTicket);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Müraciətiniz uğurla göndərildi!'), backgroundColor: AppColors.success),
                          );
                        }
                      },
                      child: const Text('Müraciəti Göndər', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
