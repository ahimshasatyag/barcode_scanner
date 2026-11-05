import 'package:flutter/material.dart';
import '../theme/theme.dart';

enum AppStatusBadgeVariant {
  /// Background lembut dengan border dan teks berwarna status
  subtle,

  /// Background solid berwarna status dengan teks putih
  solid,

  /// Hanya outline/border berwarna status
  outlined,
}

/// Widget badge/chip status global yang otomatis mencocokkan warna status dari `theme.ts`
/// (seperti Present, Late, Absent, Pending, Approved, DRAFT, CONFIRMED, PAID, NEW, OPEN, dll.)
class AppStatusBadge extends StatelessWidget {
  const AppStatusBadge({
    super.key,
    required this.status,
    this.label,
    this.color,
    this.variant = AppStatusBadgeVariant.subtle,
    this.showDot = true,
    this.isDense = false,
  });

  /// Nama status (misal: 'Present', 'Pending', 'CONFIRMED', 'PAID', dll.)
  final String status;

  /// Custom label (opsional, jika kosong menggunakan nilai [status])
  final String? label;

  /// Override warna manual (jika tidak ingin mengambil otomatis dari statusColors)
  final Color? color;

  /// Tipe gaya tampilan badge
  final AppStatusBadgeVariant variant;

  /// Menampilkan titik bulat indikator warna
  final bool showDot;

  /// Ukuran lebih ringkas / padat
  final bool isDense;

  @override
  Widget build(BuildContext context) {
    final customColors = context.customColors;
    final colorScheme = context.colorScheme;

    // Ambil warna otomatis dari theme.ts atau gunakan override manual
    final statusColor = color ??
        customColors.colorByStatusName(status) ??
        colorScheme.primary;

    final displayText = label ?? status;

    Color bg;
    Color fg;
    Border? border;

    switch (variant) {
      case AppStatusBadgeVariant.subtle:
        bg = statusColor.withOpacity(0.14);
        fg = statusColor;
        border = Border.all(color: statusColor.withOpacity(0.35), width: 1);
        break;

      case AppStatusBadgeVariant.solid:
        bg = statusColor;
        fg = Colors.white;
        border = null;
        break;

      case AppStatusBadgeVariant.outlined:
        bg = Colors.transparent;
        fg = statusColor;
        border = Border.all(color: statusColor, width: 1.2);
        break;
    }

    final verticalPadding = isDense ? 2.0 : 4.0;
    final horizontalPadding = isDense ? 8.0 : 10.0;
    final fontSize = isDense ? 10.5 : 12.0;
    final dotSize = isDense ? 6.0 : 7.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: border,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot && variant != AppStatusBadgeVariant.solid) ...[
            Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: isDense ? 5 : 6),
          ],
          Text(
            displayText,
            style: TextStyle(
              color: fg,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

