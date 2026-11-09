import 'package:flutter/material.dart';
import 'package:barcode/shared/theme/theme.dart';
import 'package:barcode/shared/widgets/widgets.dart';
import '../../domain/entities/machine_item.dart';

class MachineItemTile extends StatelessWidget {
  const MachineItemTile({
    super.key,
    required this.item,
    this.index,
    this.onDelete,
    this.onTap,
  });

  final MachineItem item;
  final int? index;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    const verifiedColor = Color(0xFF2E7D32);

    return AppCard(
      padding: const EdgeInsets.all(12),
      elevation: 0.5,
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Indikator Nomor & Status Verifikasi
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: verifiedColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: index != null
                  ? Text(
                      '#$index',
                      style: const TextStyle(
                        color: verifiedColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    )
                  : const Icon(
                      Icons.check_circle_rounded,
                      color: verifiedColor,
                      size: 20,
                    ),
            ),
          ),
          const SizedBox(width: 12),

          // Detail Mesin
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.brand.toUpperCase(),
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.modelName,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'SN: ${item.serialNumber} • Code: ${item.barcode}',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontFamily: 'monospace',
                    color: colorScheme.outline,
                  ),
                ),
                if (item.specification != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    item.specification!,
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurface.withValues(alpha: 0.75),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (item.countryOfOrigin != null) ...[
                      Icon(Icons.flag_outlined, size: 13, color: colorScheme.outline),
                      const SizedBox(width: 4),
                      Text(
                        item.countryOfOrigin!,
                        style: TextStyle(fontSize: 11, color: colorScheme.outline),
                      ),
                      const SizedBox(width: 10),
                    ],
                    if (item.weightKg != null) ...[
                      Icon(Icons.scale_outlined, size: 13, color: colorScheme.outline),
                      const SizedBox(width: 4),
                      Text(
                        '${item.weightKg!.toStringAsFixed(0)} Kg',
                        style: TextStyle(fontSize: 11, color: colorScheme.outline),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Tombol Hapus (jika disediakan untuk koreksi salah scan)
          if (onDelete != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
              tooltip: 'Hapus Item',
              onPressed: () async {
                final confirmed = await AppConfirmationDialog.show(
                  context,
                  title: 'Hapus Mesin dari Scan?',
                  message:
                      'Mesin ${item.modelName} (SN: ${item.serialNumber}) akan dihapus dari daftar verifikasi transaksi ini.',
                  confirmText: 'Hapus',
                  cancelText: 'Batal',
                  isDestructive: true,
                );
                if (confirmed == true) {
                  onDelete?.call();
                }
              },
            ),
        ],
      ),
    );
  }
}
