import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/theme/app_colors.dart';

/// Full-screen real camera QR scanner.
///
/// Opens the device camera, scans a QR code and returns its raw payload
/// string via `Navigator.pop(context, code)`. Used by both the teacher
/// fault-reporting flow and the admin inventory registration flow.
class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.qrCode],
  );

  bool _torchOn = false;
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    if (capture.barcodes.isEmpty) return;
    final code = capture.barcodes.first.rawValue;
    if (code == null || code.trim().isEmpty) return;

    _handled = true;
    Navigator.of(context).pop(code.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('QR Kodu Skan Et'),
        backgroundColor: const Color(0xFF070D1B),
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error) {
              final denied = error.errorCode == MobileScannerErrorCode.permissionDenied;
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        denied ? Icons.no_photography_rounded : Icons.error_outline_rounded,
                        color: AppColors.goldLight,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        denied
                            ? 'Kamera icazəsi verilməyib.\nTətbiq parametrlərindən kamera icazəsini verin və yenidən cəhd edin.'
                            : 'Kamera açıla bilmədi: ${error.errorCode.name}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Scan window frame
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.goldLight.withAlpha(180), width: 3),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),

          // Hint text
          Positioned(
            top: 40,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(120),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Avadanlıqdakı QR kodu çərçivəyə tutun',
                  style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),

          // Torch toggle
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                backgroundColor: Colors.white.withAlpha(30),
                foregroundColor: Colors.white,
                onPressed: () async {
                  await _controller.toggleTorch();
                  if (mounted) setState(() => _torchOn = !_torchOn);
                },
                child: Icon(_torchOn ? Icons.flash_off_rounded : Icons.flash_on_rounded),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
