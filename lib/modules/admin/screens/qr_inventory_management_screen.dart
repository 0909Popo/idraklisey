import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../providers/app_state.dart';
import '../../../data/models/inventory_model.dart';
import '../../../data/models/ticket_model.dart';
import '../../shared/screens/qr_scanner_screen.dart';

class QrInventoryManagementScreen extends StatefulWidget {
  const QrInventoryManagementScreen({super.key});

  @override
  State<QrInventoryManagementScreen> createState() => _QrInventoryManagementScreenState();
}

class _QrInventoryManagementScreenState extends State<QrInventoryManagementScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Proyektor':
        return Icons.videocam_rounded;
      case 'Smart Lövhə':
        return Icons.dashboard_rounded;
      case 'Kompyuter':
        return Icons.computer_rounded;
      case 'Noutbuk':
        return Icons.laptop_rounded;
      case 'Printer / Skaner':
        return Icons.print_rounded;
      case 'Səs Sistemi':
        return Icons.speaker_rounded;
      case 'Laboratoriya Avadanlığı':
        return Icons.science_rounded;
      case 'Mebel':
        return Icons.chair_rounded;
      default:
        return Icons.devices_rounded;
    }
  }

  Future<void> _openItemForm({InventoryItem? existing}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _InventoryItemFormSheet(existing: existing),
    );
  }

  Future<void> _confirmDelete(InventoryItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Avadanlığı sil', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text('"${item.name}" reyestrdən silinsin? Bu əməliyyat geri qaytarıla bilməz.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Ləğv Et')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await Provider.of<AppState>(context, listen: false).deleteInventoryItem(item.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Avadanlıq reyestrdən silindi.'), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  void _showQrDialog(InventoryItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(item.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
                boxShadow: AppShadows.sm,
              ),
              child: QrImageView(
                data: item.qrCode,
                version: QrVersions.auto,
                size: 200,
                eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Color(0xFF0F2552)),
                dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Color(0xFF0F2552)),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                item.qrCode,
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.goldLight),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Bu QR-ni çap edib avadanlığın üzərinə yapışdırın. Müəllim skan etdikdə sistem avadanlığı avtomatik tanıyacaq.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary, height: 1.4),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('Bağla', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final items = appState.inventoryItems;

    final filtered = items.where((i) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return i.name.toLowerCase().contains(q) ||
          i.room.toLowerCase().contains(q) ||
          i.qrCode.toLowerCase().contains(q) ||
          i.category.toLowerCase().contains(q);
    }).toList();

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
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryAccent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
                  ),
                  tooltip: 'Yeni Avadanlıq',
                  onPressed: () => _openItemForm(),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0D9488)],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -15,
                      bottom: -15,
                      child: Icon(Icons.inventory_2_rounded, size: 130, color: Colors.white.withAlpha(10)),
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
                                  child: const Icon(Icons.qr_code_2_rounded, size: 22, color: Colors.white),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'QR İnventar Reyestri',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${items.length} qeydiyyatlı avadanlıq',
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

          // ── Search & Filter ──
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                  boxShadow: AppShadows.sm,
                ),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _searchQuery = v.trim()),
                  decoration: InputDecoration(
                    hintText: 'Axtarış (ad, otaq, QR kodu, kateqoriya)...',
                    hintStyle: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.surface,
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryAccent, size: 20),
                    contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: AppColors.primaryAccent, width: 1.5),
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ),

          // ── Items List ──
          if (filtered.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primaryAccent.withAlpha(8),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.inventory_2_rounded, size: 44, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      items.isEmpty ? 'Reyestr boşdur. İlk avadanlığı əlavə edin.' : 'Nəticə tapılmadı.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = filtered[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.cardBorder),
                        boxShadow: AppShadows.sm,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryAccent.withAlpha(15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.primaryAccent.withAlpha(30)),
                                ),
                                child: Icon(_categoryIcon(item.category), color: AppColors.primaryAccent, size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.name, style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                                    const SizedBox(height: 2),
                                    Text('${item.category} • ${item.room}', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                                  ],
                                ),
                              ),
                              StatusBadge(
                                label: item.isActive ? 'AKTİV' : 'SİLİNİB',
                                color: item.isActive ? AppColors.success : AppColors.textMuted,
                                fontSize: 9,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F172A),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              item.qrCode,
                              style: const TextStyle(color: AppColors.goldLight, fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton.icon(
                                onPressed: () => _showQrDialog(item),
                                icon: const Icon(Icons.qr_code_rounded, size: 16, color: AppColors.primaryAccent),
                                label: const Text('QR Göstər', style: TextStyle(color: AppColors.primaryAccent, fontSize: 12, fontWeight: FontWeight.w700)),
                              ),
                              TextButton.icon(
                                onPressed: () => _openItemForm(existing: item),
                                icon: const Icon(Icons.edit_rounded, size: 16, color: AppColors.warning),
                                label: const Text('Redaktə', style: TextStyle(color: AppColors.warning, fontSize: 12, fontWeight: FontWeight.w700)),
                              ),
                              TextButton.icon(
                                onPressed: () => _confirmDelete(item),
                                icon: const Icon(Icons.delete_rounded, size: 16, color: AppColors.danger),
                                label: const Text('Sil', style: TextStyle(color: AppColors.danger, fontSize: 12, fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                  childCount: filtered.length,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryAccent,
        foregroundColor: Colors.white,
        onPressed: () => _openItemForm(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Yeni Avadanlıq', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }
}

/// Bottom sheet form used for both registering and editing an inventory item.
class _InventoryItemFormSheet extends StatefulWidget {
  final InventoryItem? existing;
  const _InventoryItemFormSheet({this.existing});

  @override
  State<_InventoryItemFormSheet> createState() => _InventoryItemFormSheetState();
}

class _InventoryItemFormSheetState extends State<_InventoryItemFormSheet> {
  late final TextEditingController _qrCtrl;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _roomCtrl;
  late final TextEditingController _serialCtrl;
  late final TextEditingController _notesCtrl;
  late final TextEditingController _problemCtrl;
  late String _category;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _qrCtrl = TextEditingController(text: e?.qrCode ?? '');
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _roomCtrl = TextEditingController(text: e?.room ?? '');
    _serialCtrl = TextEditingController(text: e?.serialNumber ?? '');
    _notesCtrl = TextEditingController(text: e?.notes ?? '');
    _problemCtrl = TextEditingController();
    _category = e?.category ?? inventoryCategories.first;
  }

  @override
  void dispose() {
    _qrCtrl.dispose();
    _nameCtrl.dispose();
    _roomCtrl.dispose();
    _serialCtrl.dispose();
    _notesCtrl.dispose();
    _problemCtrl.dispose();
    super.dispose();
  }

  Future<void> _scanQr() async {
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const QrScannerScreen()),
    );
    if (code != null && code.isNotEmpty && mounted) {
      setState(() => _qrCtrl.text = code);
    }
  }

  void _save() {
    final appState = Provider.of<AppState>(context, listen: false);

    if (_nameCtrl.text.trim().isEmpty || _roomCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Avadanlıq adı və otaq mütləqdir!')),
      );
      return;
    }

    final qrCode = _qrCtrl.text.trim().isNotEmpty
        ? _qrCtrl.text.trim()
        : 'IDRAK-INV-${DateTime.now().millisecondsSinceEpoch}';

    final duplicate = appState.inventoryItems.any(
      (i) => i.qrCode.trim() == qrCode && i.id != widget.existing?.id,
    );
    if (duplicate) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bu QR kodu artıq digər avadanlığa bağlıdır!'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    if (widget.existing != null) {
      appState.updateInventoryItem(
        widget.existing!.copyWith(
          qrCode: qrCode,
          name: _nameCtrl.text.trim(),
          category: _category,
          room: _roomCtrl.text.trim(),
          serialNumber: _serialCtrl.text.trim(),
          notes: _notesCtrl.text.trim(),
        ),
      );
    } else {
      final newItem = InventoryItem(
        id: 'INV-${DateTime.now().millisecondsSinceEpoch}',
        qrCode: qrCode,
        name: _nameCtrl.text.trim(),
        category: _category,
        room: _roomCtrl.text.trim(),
        serialNumber: _serialCtrl.text.trim(),
        notes: _notesCtrl.text.trim(),
        isActive: true,
        createdAt: DateTime.now(),
      );
      appState.addInventoryItem(newItem);

      // Problem qeydi daxil edilibsə avtomatik helpdesk bileti yaranır
      // (QR-suz / problemli məhsul daxil etmə axını)
      final problem = _problemCtrl.text.trim();
      if (problem.isNotEmpty) {
        final user = appState.currentUser;
        appState.addTicket(HelpdeskTicket(
          id: 'INV-TK-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
          title: '${_nameCtrl.text.trim()} — problem qeydi',
          category: TicketCategory.inventory,
          status: TicketStatus.open,
          priority: TicketPriority.medium,
          senderName: user?.fullName ?? 'İnzibatçı',
          senderRole: 'İşçi',
          senderId: user?.id,
          roomNumber: _roomCtrl.text.trim(),
          inventoryCode: qrCode,
          description: problem,
          createdAt: DateTime.now(),
          messages: [
            TicketMessage(
              sender: user?.fullName ?? 'İnzibatçı',
              message: problem,
              timestamp: DateTime.now(),
              isFromStaff: false,
            ),
          ],
        ));
      }
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              widget.existing != null ? 'Avadanlığı Redaktə Et' : 'Yeni Avadanlıq Qeydiyyata Al',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.3),
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _qrCtrl,
              decoration: InputDecoration(
                labelText: 'QR Kodu *',
                hintText: 'Skan edin, daxil edin və ya boş buraxın',
                prefixIcon: const Icon(Icons.qr_code_rounded, color: AppColors.primaryAccent),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.camera_alt_rounded, color: AppColors.primaryAccent),
                  tooltip: 'Kamera ilə skan et',
                  onPressed: _scanQr,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: 'Avadanlıq Adı *',
                hintText: 'Məs: Epson EB-S41 Proyektor',
                prefixIcon: const Icon(Icons.devices_rounded, color: AppColors.primaryAccent),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: InputDecoration(
                labelText: 'Kateqoriya',
                prefixIcon: const Icon(Icons.category_rounded, color: AppColors.primaryAccent),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
              items: inventoryCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _category = v);
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _roomCtrl,
              decoration: InputDecoration(
                labelText: 'Yerləşdiyi Otaq *',
                hintText: 'Məs: Otaq 302 (Riyaziyyat Korpusu)',
                prefixIcon: const Icon(Icons.meeting_room_rounded, color: AppColors.primaryAccent),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _serialCtrl,
              decoration: InputDecoration(
                labelText: 'Seriya Nömrəsi',
                hintText: 'Məs: SN-EP-88421',
                prefixIcon: const Icon(Icons.pin_rounded, color: AppColors.primaryAccent),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: 'Qeydlər',
                hintText: 'Alınma tarixi, vəziyyəti və s.',
                prefixIcon: const Icon(Icons.notes_rounded, color: AppColors.primaryAccent),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            // Problem qeydi — doldurulsa avtomatik helpdesk bileti yaranır
            // (QR-suz / problemli məhsul daxil etmə axını)
            if (widget.existing == null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.gold.withAlpha(10),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.gold.withAlpha(35)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.report_problem_rounded, size: 15, color: AppColors.goldDark),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        'QR-suz və ya problemli məhsül? Problem qeydini doldurun — müraciət dərhal Helpdesk-ə düşəcək.',
                        style: TextStyle(fontSize: 10.5, color: AppColors.goldDark, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _problemCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Problem Qeydi (Helpdesk-ə göndərilir)',
                  hintText: 'Məs: Proyektor işləmir, kabellər yararsızdır...',
                  prefixIcon: const Icon(Icons.build_circle_rounded, color: AppColors.goldDark),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryAccent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: _save,
                icon: const Icon(Icons.save_rounded, color: Colors.white),
                label: Text(
                  widget.existing != null ? 'Dəyişikliyi Yadda Saxla' : 'Qeydiyyata Al',
                  style: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
