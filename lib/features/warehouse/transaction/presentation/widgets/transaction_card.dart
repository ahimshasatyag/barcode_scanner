import 'package:flutter/material.dart';
import 'package:barcode/shared/theme/theme.dart';
import 'package:barcode/shared/widgets/widgets.dart';
import '../../domain/entities/warehouse_transaction.dart';

class TransactionCard extends StatelessWidget {
  const TransactionCard({
    super.key,
    required this.transaction,
    this.onOpenScanner,
    this.onTapDetail,
  });

  final WarehouseTransaction transaction;
  final VoidCallback? onOpenScanner;
  final VoidCallback? onTapDetail;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isInbound = transaction.type == TransactionType.inbound;
    const greenColor = Color(0xFF2E7D32);
    final accentColor = isInbound ? greenColor : colorScheme.primary;

    Color statusBadgeColor;
    switch (transaction.status) {
      case TransactionStatus.completed:
        statusBadgeColor = greenColor;
        break;
      case TransactionStatus.inProgress:
        statusBadgeColor = const Color(0xFFED6C02);
        break;
      case TransactionStatus.draft:
        statusBadgeColor = const Color(0xFF0288D1);
        break;
      case TransactionStatus.cancelled:
        statusBadgeColor = const Color(0xFFD32F2F);
        break;
    }

    return AppCard(
      padding: const EdgeInsets.all(16),
      elevation: 1,
      onTap: onTapDetail,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Tipe Transaksi, ID & Status Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isInbound ? Icons.archive_outlined : Icons.unarchive_outlined,
                      size: 14,
                      color: accentColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      transaction.type.shortLabel.toUpperCase(),
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  transaction.id,
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.outline,
                    fontFamily: 'monospace',
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppStatusBadge(
                status: transaction.status.label,
                color: statusBadgeColor,
                isDense: true,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Judul Transaksi
          Text(
            transaction.title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),

          // Detail Referensi & Partner
          Row(
            children: [
              Icon(
                isInbound ? Icons.inventory_2_outlined : Icons.local_shipping_outlined,
                size: 15,
                color: colorScheme.outline,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${transaction.type.refLabel}: ${transaction.referenceNumber}',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                isInbound ? Icons.business_outlined : Icons.store_mall_directory_outlined,
                size: 15,
                color: colorScheme.outline,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${transaction.type.partnerLabel}: ${transaction.partnerName}',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.outline,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (transaction.vehicleOrContainerId.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  isInbound ? Icons.lock_outline : Icons.pin_drop_outlined,
                  size: 15,
                  color: colorScheme.outline,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${transaction.type.vehicleLabel}: ${transaction.vehicleOrContainerId}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.outline,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 14),

          // Progress Bar Pemindaian Mesin
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kelengkapan Pemindaian:',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.outline,
                    ),
                  ),
                  Text(
                    '${transaction.scannedQuantity} / ${transaction.targetQuantity} Unit (${transaction.progressPercent}%)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: transaction.isFullyScanned ? greenColor : colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: transaction.progress,
                  minHeight: 6,
                  backgroundColor: colorScheme.outline.withValues(alpha: 0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    transaction.isFullyScanned ? greenColor : accentColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Tombol Aksi
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: 'Detail Transaksi',
                  type: AppButtonType.outlined,
                  size: AppButtonSize.small,
                  onPressed: onTapDetail,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 1,
                child: AppButton(
                  text: transaction.status == TransactionStatus.completed
                      ? 'Lihat Scan'
                      : 'Buka Scanner',
                  icon: Icons.qr_code_scanner,
                  type: AppButtonType.primary,
                  size: AppButtonSize.small,
                  backgroundColor: accentColor,
                  onPressed: onOpenScanner,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
