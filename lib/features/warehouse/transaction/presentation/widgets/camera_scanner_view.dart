import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barcode/shared/theme/theme.dart';
import 'package:barcode/shared/widgets/widgets.dart';

/// Komponen Viewfinder Kamera Scanner Interaktif dengan animasi laser,
/// kontrol lampu senter (torch), dan opsi input barcode manual.
class CameraScannerView extends StatefulWidget {
  const CameraScannerView({
    super.key,
    required this.onBarcodeScanned,
    this.title = 'Arahkan Kamera ke Barcode / Plat Mesin',
    this.subtitle = 'Pastikan barcode atau nomor seri berada dalam kotak pemindai',
    this.isScanningPaused = false,
  });

  final void Function(String barcode) onBarcodeScanned;
  final String title;
  final String subtitle;
  final bool isScanningPaused;

  @override
  State<CameraScannerView> createState() => _CameraScannerViewState();
}

class _CameraScannerViewState extends State<CameraScannerView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _laserController;
  late final Animation<double> _laserAnimation;

  bool _isTorchOn = false;
  bool _isCoolingDown = false;
  Timer? _cooldownTimer;

  final TextEditingController _manualInputController = TextEditingController();

  // Daftar barcode mesin industri siap uji cepat
  final List<Map<String, String>> _quickBarcodes = const [
    {
      'code': 'BC-MZK-8501',
      'label': 'Mazak VCS 430A (Jepang)',
    },
    {
      'code': 'BC-MZK-8502',
      'label': 'Mazak QT 250MSY (Jepang)',
    },
    {
      'code': 'BC-OKM-3001',
      'label': 'Okuma Genos L3000-e',
    },
    {
      'code': 'BC-FNC-2101',
      'label': 'FANUC Robodrill BBT30',
    },
    {
      'code': 'BC-DMG-5001',
      'label': 'DMG MORI DMU 50 (Jerman)',
    },
    {
      'code': 'BC-DOO-2601',
      'label': 'Doosan Puma GT 2600',
    },
  ];

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _laserAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _laserController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _laserController.dispose();
    _manualInputController.dispose();
    super.dispose();
  }

  void _triggerScan(String barcode) {
    if (_isCoolingDown || widget.isScanningPaused) return;

    setState(() => _isCoolingDown = true);
    HapticFeedback.mediumImpact();
    widget.onBarcodeScanned(barcode);

    // Mencegah duplicate scan bertubi-tubi
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() => _isCoolingDown = false);
      }
    });
  }

  void _showManualInputDialog() {
    _manualInputController.clear();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final colorScheme = ctx.colorScheme;
        final isDark = ctx.isDarkMode;

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Input Barcode / SN Manual',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Masukkan kode barcode atau nomor seri mesin jika stiker barcode kotor atau rusak.',
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Nomor Barcode / Serial Number',
                  hintText: 'Contoh: BC-MZK-8501 atau SN-2026-99',
                  controller: _manualInputController,
                  prefixIcon: const Icon(Icons.qr_code),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        text: 'Batal',
                        type: AppButtonType.outlined,
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        text: 'Verifikasi',
                        type: AppButtonType.primary,
                        onPressed: () {
                          final code = _manualInputController.text.trim();
                          if (code.isNotEmpty) {
                            Navigator.pop(ctx);
                            _triggerScan(code);
                          }
                        },
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = context.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background feed kamera simulasi real-time
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF10141A),
                      const Color(0xFF1E2630),
                      if (_isTorchOn) const Color(0xFF333E4D) else const Color(0xFF0D1117),
                    ],
                  ),
                ),
                child: const Opacity(
                  opacity: 0.15,
                  child: GridPaper(
                    color: Colors.cyanAccent,
                    divisions: 2,
                    subdivisions: 2,
                  ),
                ),
              ),
            ),
          ),

          // Viewfinder Cutout Frame
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Top Scanner HUD
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24, width: 0.8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _isCoolingDown
                              ? Colors.amber
                              : widget.isScanningPaused
                                  ? Colors.red
                                  : Colors.greenAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isCoolingDown
                            ? 'MEMPROSES KODE...'
                            : widget.isScanningPaused
                                ? 'SCANNER DIJEDA'
                                : 'SCANNER AKTIF',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Kotak Viewfinder
                SizedBox(
                  width: 250,
                  height: 250,
                  child: Stack(
                    children: [
                      // Sudut-sudut Viewfinder (Corners)
                      const _ScannerCorner(alignment: Alignment.topLeft),
                      const _ScannerCorner(alignment: Alignment.topRight),
                      const _ScannerCorner(alignment: Alignment.bottomLeft),
                      const _ScannerCorner(alignment: Alignment.bottomRight),

                      // Laser Merah Bergerak Vertikal
                      if (!widget.isScanningPaused)
                        AnimatedBuilder(
                          animation: _laserAnimation,
                          builder: (context, child) {
                            return Positioned(
                              top: _laserAnimation.value * 230 + 10,
                              left: 12,
                              right: 12,
                              child: Container(
                                height: 3,
                                decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.redAccent.withValues(alpha: 0.8),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                      // Watermark ikon barcode di tengah kotak
                      Center(
                        child: Icon(
                          Icons.qr_code_2_rounded,
                          size: 72,
                          color: Colors.white.withValues(alpha: 0.12),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          // Tombol Kontrol Flashlight & Input Manual
          Positioned(
            top: 14,
            right: 14,
            child: Row(
              children: [
                _ScannerIconButton(
                  icon: _isTorchOn ? Icons.flash_on : Icons.flash_off,
                  isActive: _isTorchOn,
                  tooltip: 'Lampu Senter',
                  onTap: () {
                    setState(() => _isTorchOn = !_isTorchOn);
                  },
                ),
                const SizedBox(width: 8),
                _ScannerIconButton(
                  icon: Icons.keyboard_alt_outlined,
                  isActive: false,
                  tooltip: 'Ketik Barcode Manual',
                  onTap: _showManualInputDialog,
                ),
              ],
            ),
          ),

          // Bar Cepat Simulasi Scan Barcode (Untuk Testing Cepat & Demo Langsung)
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pilih Barcode Uji Cepat:',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    InkWell(
                      onTap: _showManualInputDialog,
                      child: Text(
                        'Input Manual >',
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _quickBarcodes.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ActionChip(
                          visualDensity: VisualDensity.compact,
                          backgroundColor: isDark
                              ? const Color(0xFF263238)
                              : Colors.white.withValues(alpha: 0.9),
                          avatar: const Icon(
                            Icons.barcode_reader,
                            size: 14,
                            color: Colors.blueAccent,
                          ),
                          label: Text(
                            item['code']!,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () => _triggerScan(item['code']!),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerCorner extends StatelessWidget {
  const _ScannerCorner({required this.alignment});

  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    const double length = 26;
    const double thickness = 3.5;
    const Color cornerColor = Color(0xFF00E5FF);

    final isTop = alignment.y < 0;
    final isLeft = alignment.x < 0;

    return Align(
      alignment: alignment,
      child: SizedBox(
        width: length,
        height: length,
        child: CustomPaint(
          painter: _CornerPainter(
            isTop: isTop,
            isLeft: isLeft,
            thickness: thickness,
            color: cornerColor,
          ),
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  const _CornerPainter({
    required this.isTop,
    required this.isLeft,
    required this.thickness,
    required this.color,
  });

  final bool isTop;
  final bool isLeft;
  final double thickness;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    if (isTop && isLeft) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    } else if (isTop && !isLeft) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (!isTop && isLeft) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 0);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScannerIconButton extends StatelessWidget {
  const _ScannerIconButton({
    required this.icon,
    required this.isActive,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final bool isActive;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isActive ? Colors.amber : Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? Colors.amberAccent : Colors.white24,
              width: 1,
            ),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isActive ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }
}
