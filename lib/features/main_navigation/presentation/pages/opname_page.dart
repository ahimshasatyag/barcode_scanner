import 'package:flutter/material.dart';

import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/widgets.dart';

/// Halaman Stock Opname Warehouse (Audit Fisik Stok, Scan Barcode & Rekonsiliasi Sistem)
class OpnamePage extends StatefulWidget {
  const OpnamePage({super.key});

  @override
  State<OpnamePage> createState() => _OpnamePageState();
}

class _OpnamePageState extends State<OpnamePage> {
  int _selectedFilter = 0; // 0: Semua, 1: Ada Selisih, 2: Cocok

  final List<Map<String, dynamic>> _opnameItems = const [
    {
      'id': 'OPN-001',
      'partNo': 'EMM-SP-6205',
      'name': 'Bearing SKF Explorer 6205',
      'barcode': 'BRG-6205-SKF-889',
      'systemQty': 85,
      'physicalQty': 85,
      'diff': 0,
      'location': 'RAK-A01-02',
      'status': 'Cocok',
      'statusColor': Color(0xFF2E7D32),
    },
    {
      'id': 'OPN-002',
      'partNo': 'EMM-CT-D12',
      'name': 'Endmill Carbide D12 TiAlN',
      'barcode': 'EM-D12-CRB-102',
      'systemQty': 120,
      'physicalQty': 116,
      'diff': -4,
      'location': 'BIN-B03-14',
      'status': 'Kurang 4',
      'statusColor': Color(0xFFD32F2F),
    },
    {
      'id': 'OPN-003',
      'partNo': 'EMM-VL-SY5',
      'name': 'SMC Solenoid Valve SY5120',
      'barcode': 'SMC-SY5120-001',
      'systemQty': 32,
      'physicalQty': 34,
      'diff': 2,
      'location': 'RAK-D05-08',
      'status': 'Lebih 2',
      'statusColor': Color(0xFFED6C02),
    },
    {
      'id': 'OPN-004',
      'partNo': 'EMM-OL-S2',
      'name': 'Oli Hidrolik Shell Tellus 20L',
      'barcode': 'OIL-SHELL-S2-20',
      'systemQty': 15,
      'physicalQty': 15,
      'diff': 0,
      'location': 'RAK-C01-01',
      'status': 'Cocok',
      'statusColor': Color(0xFF2E7D32),
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    final isDark = context.isDarkMode;

    final filteredItems = _opnameItems.where((item) {
      if (_selectedFilter == 1) return (item['diff'] as int) != 0;
      if (_selectedFilter == 2) return (item['diff'] as int) == 0;
      return true;
    }).toList();

    const successColor = Color(0xFF2E7D32);
    const errorColor = Color(0xFFD32F2F);
    const warningColor = Color(0xFFED6C02);

    return RefreshIndicator(
      color: colorScheme.primary,
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 600));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kartu Ringkasan Periode Stock Opname
            AppCard(
              padding: const EdgeInsets.all(18),
              elevation: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withValues(
                                alpha: 0.12,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.fact_check_outlined,
                              color: colorScheme.primary,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Stock Opname Q4',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                'Gudang Utama • Nov 2026',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const AppStatusBadge(
                        status: 'Sedang Berjalan',
                        color: Color(0xFF0288D1),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Progress Bar Audit Opname
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Progres Audit Fisik',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '74% (259/350 SKU)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: 0.74,
                      minHeight: 8,
                      backgroundColor: isDark
                          ? const Color(0xFF333333)
                          : const Color(0xFFEEEEEE),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 3 Counter Metrik: Sesuai, Selisih, Belum
                  Row(
                    children: [
                      const Expanded(
                        child: _MetricItem(
                          label: 'Sesuai',
                          value: '251',
                          color: successColor,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 32,
                        color: Colors.grey.withValues(alpha: 0.2),
                      ),
                      const Expanded(
                        child: _MetricItem(
                          label: 'Ada Selisih',
                          value: '8',
                          color: errorColor,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 32,
                        color: Colors.grey.withValues(alpha: 0.2),
                      ),
                      const Expanded(
                        child: _MetricItem(
                          label: 'Belum Scan',
                          value: '91',
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Tombol Utama: Mulai Scan Opname
            AppButton(
              text: 'Mulai Scan Fisik Opname',
              icon: Icons.qr_code_scanner,
              size: AppButtonSize.large,
              type: AppButtonType.primary,
              isFullWidth: true,
              onPressed: () {
                AppSnackBar.showInfo(
                  context,
                  'Membuka Scanner Barcode Verifikasi Fisik Opname',
                );
              },
            ),
            const SizedBox(height: 24),

            // Filter Tab Hasil Opname
            Row(
              children: [
                _FilterChip(
                  label: 'Semua SKU (${_opnameItems.length})',
                  isSelected: _selectedFilter == 0,
                  onTap: () => setState(() => _selectedFilter = 0),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Ada Selisih (2)',
                  isSelected: _selectedFilter == 1,
                  onTap: () => setState(() => _selectedFilter = 1),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Cocok Sesuai (2)',
                  isSelected: _selectedFilter == 2,
                  onTap: () => setState(() => _selectedFilter = 2),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Daftar Audit Item
            Text(
              'Daftar Verifikasi Stok Fisik',
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.outline,
              ),
            ),
            const SizedBox(height: 12),

            if (filteredItems.isEmpty)
              const AppEmptyState(
                title: 'Data Opname Bersih',
                message: 'Tidak ada item dengan kategori selisih ini.',
                icon: Icons.check_circle_outline,
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredItems.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = filteredItems[index];
                  final diff = item['diff'] as int;

                  return AppCard(
                    padding: const EdgeInsets.all(16),
                    elevation: 1,
                    onTap: () {
                      _showOpnameDetail(context, item);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['name'] as String,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${item['partNo']} • Lokasi: ${item['location']}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colorScheme.outline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            AppStatusBadge(
                              status: item['status'] as String,
                              color: item['statusColor'] as Color,
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Sistem: ${item['systemQty']}',
                              style: TextStyle(
                                fontSize: 12,
                                color: colorScheme.outline,
                              ),
                            ),
                            Text(
                              'Fisik: ${item['physicalQty']}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              diff == 0
                                  ? 'Selisih: 0 (Cocok)'
                                  : 'Selisih: ${diff > 0 ? "+$diff" : "$diff"}',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: diff == 0
                                    ? successColor
                                    : diff > 0
                                    ? warningColor
                                    : errorColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 110),
          ],
        ),
      ),
    );
  }

  void _showOpnameDetail(BuildContext context, Map<String, dynamic> item) {
    AppConfirmationDialog.show(
      context,
      title: 'Verifikasi: ${item['name']}',
      message:
          'Part No: ${item['partNo']}\nBarcode: ${item['barcode']}\nLokasi Rak: ${item['location']}\nStok Sistem: ${item['systemQty']}\nStok Fisik: ${item['physicalQty']}\nSelisih: ${item['diff']}',
      confirmText: 'Tutup',
    );
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = context.isDarkMode;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : isDark
              ? const Color(0xFF242424)
              : const Color(0xFFEEEEEE),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? colorScheme.onPrimary
                : isDark
                ? Colors.white70
                : Colors.black87,
          ),
        ),
      ),
    );
  }
}
