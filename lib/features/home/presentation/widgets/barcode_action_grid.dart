import 'package:flutter/material.dart';
import '../../../../shared/theme/theme.dart';

/// Grid menu aksi utama untuk pemindaian dan manajemen barcode
class BarcodeActionGrid extends StatelessWidget {
  const BarcodeActionGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    final actions = <_ActionItem>[
      const _ActionItem(
        title: 'Scan Barcode',
        subtitle: 'Pindai kode QR / 1D',
        icon: Icons.qr_code_scanner,
        isPrimary: true,
      ),
      const _ActionItem(
        title: 'Cek Stok Mesin',
        subtitle: 'Katalog sparepart',
        icon: Icons.inventory_2_outlined,
      ),
      const _ActionItem(
        title: 'Barang Masuk',
        subtitle: 'Inbound receipt',
        icon: Icons.move_to_inbox_outlined,
      ),
      const _ActionItem(
        title: 'Barang Keluar',
        subtitle: 'Pengiriman & DO',
        icon: Icons.outbox_outlined,
      ),
      const _ActionItem(
        title: 'Stock Opname',
        subtitle: 'Audit fisik gudang',
        icon: Icons.assignment_turned_in_outlined,
      ),
      const _ActionItem(
        title: 'Cetak Barcode',
        subtitle: 'Label thermal printer',
        icon: Icons.print_outlined,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Menu Operasional',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '6 Layanan',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: actions.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.35,
          ),
          itemBuilder: (context, index) {
            final item = actions[index];
            return _ActionCard(item: item);
          },
        ),
      ],
    );
  }
}

class _ActionItem {
  const _ActionItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isPrimary = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isPrimary;
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.item});

  final _ActionItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = context.isDarkMode;

    final backgroundColor = item.isPrimary
        ? (isDark ? colorScheme.primaryContainer : AppColors.primary)
        : (isDark ? const Color(0xFF241E1F) : Colors.white);

    final contentColor = item.isPrimary
        ? (isDark ? colorScheme.onPrimaryContainer : Colors.white)
        : colorScheme.onSurface;

    final subtitleColor = item.isPrimary
        ? (isDark
            ? colorScheme.onPrimaryContainer.withOpacity(0.8)
            : Colors.white.withOpacity(0.85))
        : colorScheme.onSurfaceVariant;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(16),
      elevation: item.isPrimary ? 2 : 1,
      shadowColor: Colors.black.withOpacity(0.08),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Membuka menu: ${item.title}'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: item.isPrimary
                  ? Colors.transparent
                  : (isDark
                      ? const Color(0xFF382F30)
                      : const Color(0xFFEEEEEE)),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: item.isPrimary
                      ? Colors.white.withOpacity(0.2)
                      : colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  item.icon,
                  size: 24,
                  color: item.isPrimary ? Colors.white : colorScheme.primary,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: contentColor,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: subtitleColor,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

