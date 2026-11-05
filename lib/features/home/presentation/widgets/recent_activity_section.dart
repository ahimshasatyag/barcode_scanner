import 'package:flutter/material.dart';
import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/widgets.dart';

/// Bagian riwayat pemindaian barcode & aktivitas terkini
class RecentActivitySection extends StatelessWidget {
  const RecentActivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = context.textTheme;

    final activities = <_ActivityData>[
      const _ActivityData(
        barcode: 'BC-EMM-2026-081',
        title: 'Mesin Roll Forming EM-82',
        category: 'Heavy Machinery',
        statusName: 'CONFIRMED',
        time: '10 mnt lalu',
      ),
      const _ActivityData(
        barcode: 'BC-EMM-2026-080',
        title: 'Bearing Conical Roller 32208',
        category: 'Sparepart Mesin',
        statusName: 'PAID',
        time: '35 mnt lalu',
      ),
      const _ActivityData(
        barcode: 'BC-EMM-2026-079',
        title: 'Inverter Motor 3-Phase 5.5KW',
        category: 'Electrical Component',
        statusName: 'Approved',
        time: '2 jam lalu',
      ),
      const _ActivityData(
        barcode: 'BC-EMM-2026-078',
        title: 'Timing Belt Industrial HTD-8M',
        category: 'Sparepart Mekanikal',
        statusName: 'DRAFT',
        time: '4 jam lalu',
      ),
      const _ActivityData(
        barcode: 'BC-EMM-2026-077',
        title: 'Sensor Proximity Omron 24V',
        category: 'Automation Sensor',
        statusName: 'Pending',
        time: 'Kemarin',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Aktivitas Barcode Terkini',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                AppSnackBar.showInfo(
                  context,
                  'Membuka riwayat lengkap barcode PT Eka Maju Mesinindo...',
                );
              },
              child: const Text('Lihat Semua'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: activities.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = activities[index];
            return _ActivityTile(data: item);
          },
        ),
      ],
    );
  }
}

class _ActivityData {
  const _ActivityData({
    required this.barcode,
    required this.title,
    required this.category,
    required this.statusName,
    required this.time,
  });

  final String barcode;
  final String title;
  final String category;
  final String statusName;
  final String time;
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.data});

  final _ActivityData data;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final isDark = context.isDarkMode;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF241E1F) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF382F30) : const Color(0xFFECECEC),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon Barcode
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark
                  ? colorScheme.surfaceVariant
                  : const Color(0xFFF3F3F3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.qr_code,
              color: colorScheme.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),

          // Detail Item
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      data.barcode,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '• ${data.category}',
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Status Badge Global & Waktu
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AppStatusBadge(
                status: data.statusName,
                isDense: true,
              ),
              const SizedBox(height: 4),
              Text(
                data.time,
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: colorScheme.outline,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

