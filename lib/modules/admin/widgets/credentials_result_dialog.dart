import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';

/// Hesab yaradıldıqdan sonra giriş məlumatlarını göstərən dialoq.
/// [sections] — başlıq + (etiket, dəyər) cütləri.
Future<void> showCredentialsResultDialog({
  required BuildContext context,
  required String title,
  required List<CredentialsSection> sections,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.success.withAlpha(15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.verified_rounded, color: AppColors.success, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final section in sections) ...[
                        if (sections.length > 1) ...[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8, top: 4),
                            child: Text(
                              section.title,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primaryAccent,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (var i = 0; i < section.rows.length; i++) ...[
                                if (i > 0) const SizedBox(height: 10),
                                _buildRow(section.rows[i].key, section.rows[i].value),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        final buffer = StringBuffer();
                        for (final section in sections) {
                          if (sections.length > 1) buffer.writeln('=== ${section.title} ===');
                          for (final row in section.rows) {
                            buffer.writeln('${row.key}: ${row.value}');
                          }
                        }
                        Clipboard.setData(ClipboardData(text: buffer.toString()));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Giriş məlumatları kopyalandı'),
                            backgroundColor: AppColors.success,
                            duration: Duration(seconds: 1),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded, size: 17),
                      label: const Text('Kopyala'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryAccent,
                        side: const BorderSide(color: AppColors.primaryAccent),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryAccent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      child: const Text('Bağla', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildRow(String label, String value) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.2),
      ),
      const SizedBox(height: 2),
      SelectableText(
        value,
        style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
      ),
    ],
  );
}

class CredentialsSection {
  final String title;
  final List<MapEntry<String, String>> rows;

  const CredentialsSection({required this.title, required this.rows});
}
