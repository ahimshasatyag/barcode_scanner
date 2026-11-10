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
    this.subtitle =
        'Pastikan barcode atau nomor seri berada dalam kotak pemindai',
    this.isScanningPaused = false,
    this.scannedBarcodes = const [],
    this.customQuickBarcodes,
  });

  final void Function(String barcode) onBarcodeScanned;
  final String title;
  final String subtitle;
  final bool isScanningPaused;
  final List<String> scannedBarcodes;
  final List<Map<String, String>>? customQuickBarcodes;

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

  // Daftar barcode nomor seri mesin real dari database backend (ProductSnController.php)
  late final List<Map<String, String>> _quickBarcodes = widget.customQuickBarcodes ?? const [
    {'code': 'BC-MZK-8501', 'label': 'Mazak VCS 430A'},
    {'code': '20.204.01794.28.04951', 'label': 'SN 20.204 (GKU Stock)'},
    {'code': '20.204.01785.28.04950', 'label': 'SN 20.204 (GKU Stock)'},
    {'code': '20.207.01693.28.04949', 'label': 'SN 20.207 (GSS Sirie)'},
    {'code': '10.102.01527.27.04692', 'label': 'SN 10.102 (EMM Head Office)'},
    {'code': '20.207.01567.28.04948', 'label': 'SN 20.207 (Sparepart)'},
    {'code': '20.203.00409.28.04947', 'label': 'SN 20.203 (Produksi)'},
  ];

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _laserAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _laserController, curve: Curves.easeInOut),
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

  void _scanNextAvailableBarcode() {
    if (_isCoolingDown || widget.isScanningPaused) return;

    for (final item in _quickBarcodes) {
      final code = item['code']!;
      if (!widget.scannedBarcodes.contains(code)) {
        _triggerScan(code);
        return;
      }
    }

    _triggerScan('BC-MZK-8503');
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
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
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
                  style: TextStyle(fontSize: 13, color: colorScheme.outline),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Nomor Barcode / Serial Number (m_product_sn)',
                  hintText: 'Contoh: 20.204.01794.28.04951 atau 10.102.01527.27.04692',
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
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFF0F141C),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background feed kamera simulasi real-time dengan grid scanner
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF0B1017),
                    const Color(0xFF151D28),
                    if (_isTorchOn)
                      const Color(0xFF2C394A)
                    else
                      const Color(0xFF090D12),
                  ],
                ),
              ),
              child: const Opacity(
                opacity: 0.18,
                child: GridPaper(
                  color: Colors.cyanAccent,
                  divisions: 2,
                  subdivisions: 2,
                ),
              ),
            ),
          ),

          // Layout Konten Scanner (Bebas Overflow)
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Baris Atas: Status HUD + Tombol Senter & Keyboard
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(
                      width: 68,
                    ), // Spacer penyeimbang tombol kanan
                    // Status Badge Scanner
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4.5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
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
                          const SizedBox(width: 7),
                          Text(
                            _isCoolingDown
                                ? 'MEMPROSES KODE...'
                                : widget.isScanningPaused
                                ? 'SCANNER DIJEDA'
                                : 'SCANNER AKTIF',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.9,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Tombol Kontrol Flashlight & Keyboard
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ScannerIconButton(
                          icon: _isTorchOn ? Icons.flash_on : Icons.flash_off,
                          isActive: _isTorchOn,
                          tooltip: 'Lampu Senter',
                          onTap: () {
                            setState(() => _isTorchOn = !_isTorchOn);
                          },
                        ),
                        const SizedBox(width: 6),
                        _ScannerIconButton(
                          icon: Icons.keyboard_alt_outlined,
                          isActive: false,
                          tooltip: 'Ketik Barcode Manual',
                          onTap: _showManualInputDialog,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Kotak Viewfinder Barcode Proporsional (Format Horizontal Khusus Barcode Industri)
                Tooltip(
                  message: 'Ketuk kotak untuk simulasi scan barcode mesin berikutnya',
                  child: InkWell(
                    onTap: _scanNextAvailableBarcode,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 250,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        children: [
                          // 4 Sudut Viewfinder Cyan (Presisi di dalam kotak)
                          const _ScannerCorner(alignment: Alignment.topLeft),
                          const _ScannerCorner(alignment: Alignment.topRight),
                          const _ScannerCorner(alignment: Alignment.bottomLeft),
                          const _ScannerCorner(
                            alignment: Alignment.bottomRight,
                          ),

                          // Laser Merah Animasi Vertikal
                          if (!widget.isScanningPaused)
                            AnimatedBuilder(
                              animation: _laserAnimation,
                              builder: (context, child) {
                                return Positioned(
                                  top: _laserAnimation.value * 102 + 7,
                                  left: 10,
                                  right: 10,
                                  child: Container(
                                    height: 2.5,
                                    decoration: BoxDecoration(
                                      color: Colors.redAccent,
                                      borderRadius: BorderRadius.circular(2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.redAccent.withValues(
                                            alpha: 0.85,
                                          ),
                                          blurRadius: 8,
                                          spreadRadius: 1.5,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),

                          // Ikon Watermark Barcode di tengah
                          Center(
                            child: Icon(
                              Icons.qr_code_2_rounded,
                              size: 48,
                              color: Colors.white.withValues(alpha: 0.12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),

                // Label Petunjuk
                Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 10.5,
                  ),
                ),
                const SizedBox(height: 8),

                // Bagian Barcode Uji Cepat dengan Indikator Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pilih Barcode Uji Cepat:',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
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
                const SizedBox(height: 4),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _quickBarcodes.map((item) {
                      final code = item['code']!;
                      final isAlreadyScanned = widget.scannedBarcodes.contains(
                        code,
                      );

                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ActionChip(
                          visualDensity: VisualDensity.compact,
                          backgroundColor: isAlreadyScanned
                              ? (isDark
                                    ? const Color(0xFF1B3320)
                                    : const Color(0xFFE8F5E9))
                              : (isDark
                                    ? const Color(0xFF263238)
                                    : Colors.white.withValues(alpha: 0.92)),
                          avatar: Icon(
                            isAlreadyScanned
                                ? Icons.check_circle
                                : Icons.barcode_reader,
                            size: 13,
                            color: isAlreadyScanned
                                ? const Color(0xFF2E7D32)
                                : Colors.blueAccent,
                          ),
                          label: Text(
                            isAlreadyScanned ? '$code (OK)' : code,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isAlreadyScanned
                                  ? const Color(0xFF2E7D32)
                                  : (isDark ? Colors.white : Colors.black87),
                            ),
                          ),
                          onPressed: () {
                            if (isAlreadyScanned) {
                              AppSnackBar.showWarning(
                                context,
                                'Barcode $code sudah terdaftar di transaksi ini.',
                              );
                            } else {
                              _triggerScan(code);
                            }
                          },
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
    const double length = 20;
    const double thickness = 3.0;
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
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(6.5),
          decoration: BoxDecoration(
            color: isActive
                ? Colors.amber
                : Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive ? Colors.amberAccent : Colors.white24,
              width: 0.8,
            ),
          ),
          child: Icon(
            icon,
            size: 16,
            color: isActive ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }
}
