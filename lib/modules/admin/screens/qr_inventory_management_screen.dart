import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../providers/app_state.dart';
import '../../../data/models/inventory_model.dart';
import '../../shared/screens/qr_scanner_screen.dart';

/// Admin registry of QR-tagged school equipment.
///
/// Admin registers each device with a unique QR code (scanned from the real
/// sticker via camera, entered manually, or auto-generated), then prints the
/// QR from this screen and sticks it on the device. When a teacher scans that
/// QR, the fault ticket automatically references this record.
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
        title: const Text('Avadanlığı sil'),
        content: Text('"${item.name}" reyestrdən silinsin? Bu əməliyyat geri qaytarıla bilməz.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Ləğv Et')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil', style: TextStyle(color: AppColors.danger)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(item.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: QrImageView(
                data: item.qrCode,
                version: QrVersions.auto,
                size: 200,
                eyeStyle: const QrEyeStyle(eyeShape: QrEyeShape.square, color: Color(0xFF0F2552)),
                dataModuleStyle: const QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: Color(0xFF0F2552)),
              ),
            ),
            const SizedBox(height: 12),
            Text(item.qrCode, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'monospace', fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(
              'Bu QR-ni çap edib avadanlığın üzərinə yapışdırın. Müəllim skan etdikdə sistem avadanlığı avtomatik tanıyacaq.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: AppColors.textSecondary, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Bağla')),
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
      appBar: AppBar(
        title: const Text('QR İnventar Reyestri'),
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        onPressed: () => _openItemForm(),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Yeni Avadanlıq'),
      ),
      body: Column(
        children: [
          // Info header
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0F2552)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.qr_code_rounded, color: AppColors.goldLight, size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Reyestrdə ${items.length} avadanlıq qeydiyyatdadır',
                        style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Avadanlığı qeydiyyata al, QR-ni çap edib cihaza yapışdır. Müəllim skan etdikdə sistem avadanlığı avtomatik tanıyır və ticket-də göstərir.',
                  style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                ),
              ],
            ),
          ),

          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v.trim()),
              decoration: InputDecoration(
                labelText: 'Axtarış (ad, otaq, QR kodu, kateqoriya)',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
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
          const SizedBox(height: 8),

          // Items list
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_rounded, size: 48, color: AppColors.textMuted.withAlpha(120)),
                        const SizedBox(height: 12),
                        Text(
                          items.isEmpty ? 'Reyestr boşdur. İlk avadanlığı əlavə edin.' : 'Nəticə tapılmadı.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 90, top: 4),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return CustomCard(
                        onTap: () => _openItemForm(existing: item),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryAccent.withAlpha(25),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(_categoryIcon(item.category), color: AppColors.primaryAccent, size: 22),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                                      const SizedBox(height: 2),
                                      Text('${item.category} • ${item.room}', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
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
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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
                                  icon: const Icon(Icons.qr_code_rounded, size: 18, color: AppColors.primary),
                                  label: const Text('QR Göstər', style: TextStyle(color: AppColors.primary, fontSize: 12)),
                                ),
                                TextButton.icon(
                                  onPressed: () => _openItemForm(existing: item),
                                  icon: const Icon(Icons.edit_rounded, size: 18, color: AppColors.warning),
                                  label: const Text('Redaktə', style: TextStyle(color: AppColors.warning, fontSize: 12)),
                                ),
                                TextButton.icon(
                                  onPressed: () => _confirmDelete(item),
                                  icon: const Icon(Icons.delete_rounded, size: 18, color: AppColors.danger),
                                  label: const Text('Sil', style: TextStyle(color: AppColors.danger, fontSize: 12)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
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
    _category = e?.category ?? inventoryCategories.first;
  }

  @override
  void dispose() {
    _qrCtrl.dispose();
    _nameCtrl.dispose();
    _roomCtrl.dispose();
    _serialCtrl.dispose();
    _notesCtrl.dispose();
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

    // QR boş buraxılırsa avtomatik unikal kod yaradılır
    final qrCode = _qrCtrl.text.trim().isNotEmpty
        ? _qrCtrl.text.trim()
        : 'IDRAK-INV-${DateTime.now().millisecondsSinceEpoch}';

    // Eyni QR artıq başqa avadanlıqdadır?
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
      appState.addInventoryItem(
        InventoryItem(
          id: 'INV-${DateTime.now().millisecondsSinceEpoch}',
          qrCode: qrCode,
          name: _nameCtrl.text.trim(),
          category: _category,
          room: _roomCtrl.text.trim(),
          serialNumber: _serialCtrl.text.trim(),
          notes: _notesCtrl.text.trim(),
          isActive: true,
          createdAt: DateTime.now(),
        ),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.existing != null ? 'Avadanlığı Redaktə Et' : 'Yeni Avadanlıq Qeydiyyata Al',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),

            // QR code — scan with camera, enter manually, or auto-generate
            TextFormField(
              controller: _qrCtrl,
              decoration: InputDecoration(
                labelText: 'QR Kodu *',
                hintText: 'Skan edin, daxil edin və ya boş buraxın (avtomatik yaranar)',
                prefixIcon: const Icon(Icons.qr_code_rounded, color: AppColors.primary),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                  tooltip: 'Kamera ilə skan et',
                  onPressed: _scanQr,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Avadanlıq Adı *',
                hintText: 'Məs: Epson EB-S41 Proyektor',
                prefixIcon: Icon(Icons.devices_rounded, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Kateqoriya',
                prefixIcon: Icon(Icons.category_rounded, color: AppColors.primary),
              ),
              items: inventoryCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _category = v);
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _roomCtrl,
              decoration: const InputDecoration(
                labelText: 'Yerləşdiyi Otaq *',
                hintText: 'Məs: Otaq 302 (Riyaziyyat Korpusu)',
                prefixIcon: Icon(Icons.meeting_room_rounded, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _serialCtrl,
              decoration: const InputDecoration(
                labelText: 'Seriya Nömrəsi',
                hintText: 'Məs: SN-EP-88421',
                prefixIcon: Icon(Icons.pin_rounded, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Qeydlər',
                hintText: 'Alınma tarixi, vəziyyəti və s.',
                prefixIcon: Icon(Icons.notes_rounded, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _save,
                icon: const Icon(Icons.save_rounded),
                label: Text(widget.existing != null ? 'Dəyişikliyi Yadda Saxla' : 'Qeydiyyata Al'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
