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

class _QrScannerScreenState extends State<QrScannerScreen> with SingleTickerProviderStateMixin {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: const [BarcodeFormat.qrCode],
  );

  late AnimationController _pulseController;
  late Animation<double> _scanAnimation;
  bool _torchOn = false;
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    _scanAnimation = Tween<double>(begin: 0.0, end: 260.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
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
      body: Stack(
        children: [
          // Camera scanner
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error) {
              final denied = error.errorCode == MobileScannerErrorCode.permissionDenied;
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B).withAlpha(220),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withAlpha(20)),
                    ),
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
                          style: const TextStyle(color: Colors.white70, fontSize: 13.5, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Custom Viewfinder with laser & corner brackets
          Center(
            child: SizedBox(
              width: 260,
              height: 260,
              child: Stack(
                children: [
                  // Outer subtle box
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white.withAlpha(40), width: 1.5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),

                  // 4 Corner Brackets
                  ..._buildCorners(),

                  // Animated Scanning Laser
                  AnimatedBuilder(
                    animation: _scanAnimation,
                    builder: (context, _) {
                      return Positioned(
                        top: _scanAnimation.value,
                        left: 10,
                        right: 10,
                        child: Container(
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.transparent, AppColors.primaryAccent, Colors.transparent],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryAccent.withAlpha(200),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Top Header Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(120),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withAlpha(20)),
                        ),
                        child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white),
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(140),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withAlpha(20)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.qr_code_scanner_rounded, size: 16, color: AppColors.goldLight),
                          SizedBox(width: 8),
                          Text(
                            'QR Kodu Skan Et',
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 44), // balance
                  ],
                ),
              ),
            ),
          ),

          // Bottom Controls: Torch & Hint
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(150),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withAlpha(20)),
                  ),
                  child: const Text(
                    'Avadanlıqdakı QR kodu çərçivəyə tutun',
                    style: TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () async {
                    await _controller.toggleTorch();
                    if (mounted) setState(() => _torchOn = !_torchOn);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _torchOn ? AppColors.goldLight : Colors.white.withAlpha(25),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _torchOn ? AppColors.gold : Colors.white.withAlpha(40),
                        width: 1.5,
                      ),
                      boxShadow: _torchOn
                          ? [BoxShadow(color: AppColors.goldLight.withAlpha(120), blurRadius: 16, spreadRadius: 2)]
                          : [],
                    ),
                    child: Icon(
                      _torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                      color: _torchOn ? const Color(0xFF0F172A) : Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCorners() {
    const double length = 24;
    const double thickness = 3.5;
    const color = AppColors.primaryAccent;

    return [
      // Top Left
      Positioned(top: 0, left: 0, child: Container(width: length, height: thickness, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)))),
      Positioned(top: 0, left: 0, child: Container(width: thickness, height: length, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)))),

      // Top Right
      Positioned(top: 0, right: 0, child: Container(width: length, height: thickness, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)))),
      Positioned(top: 0, right: 0, child: Container(width: thickness, height: length, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)))),

      // Bottom Left
      Positioned(bottom: 0, left: 0, child: Container(width: length, height: thickness, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)))),
      Positioned(bottom: 0, left: 0, child: Container(width: thickness, height: length, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)))),

      // Bottom Right
      Positioned(bottom: 0, right: 0, child: Container(width: length, height: thickness, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)))),
      Positioned(bottom: 0, right: 0, child: Container(width: thickness, height: length, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)))),
    ];
  }
}
