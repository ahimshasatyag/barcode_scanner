import 'package:flutter/material.dart';
import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/widgets.dart';

/// Halaman Tracker Warehouse (Pelacakan Lokasi Rak, Bin, Pallet & Pergerakan Material)
class TrackerPage extends StatefulWidget {
  const TrackerPage({super.key});

  @override
  State<TrackerPage> createState() => _TrackerPageState();
}

class _TrackerPageState extends State<TrackerPage> {
  final _searchController = TextEditingController();
  String _selectedZone = 'Semua Zona';

  final List<Map<String, dynamic>> _locations = const [
    {
      'code': 'RAK-A01-02',
      'zone': 'Zona A (Komponen Presisi)',
      'item': 'Bearing SKF Explorer 6205-2RSH',
      'barcode': 'BRG-6205-SKF-889',
      'qty': '85 Pcs',
      'capacity': '85%',
      'status': 'Sesuai Rak',
      'statusColor': Color(0xFF2E7D32),
      'lastMoved': '10 Menit lalu oleh Budi',
    },
    {
      'code': 'BIN-B03-14',
      'zone': 'Zona B (Cutting Tools)',
      'item': 'Endmill Carbide 4-Flute D12',
      'barcode': 'EM-D12-CRB-102',
      'qty': '120 Pcs',
      'capacity': '95%',
      'status': 'Hampir Penuh',
      'statusColor': Color(0xFFED6C02),
      'lastMoved': '1 Jam lalu oleh Operator 02',
    },
    {
      'code': 'PAL-C02-01',
      'zone': 'Zona C (Heavy Parts)',
      'item': 'Chuck Bubut 3 Jaw 10 Inch Hydraulic',
      'barcode': 'CHK-10IN-HYD-55',
      'qty': '4 Unit',
      'capacity': '50%',
      'status': 'Transit Pallet',
      'statusColor': Color(0xFF0288D1),
      'lastMoved': '2 Jam lalu oleh Joko',
    },
    {
      'code': 'RAK-D05-08',
      'zone': 'Zona D (Pneumatic & Valve)',
      'item': 'SMC Solenoid Valve SY5120-5LZD',
      'barcode': 'SMC-SY5120-001',
      'qty': '32 Unit',
      'capacity': '40%',
      'status': 'Tersedia',
      'statusColor': Color(0xFF2E7D32),
      'lastMoved': 'Kemarin oleh Budi',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;

    final query = _searchController.text.trim().toLowerCase();
    final filteredLocations = _locations.where((loc) {
      final matchesSearch = query.isEmpty ||
          loc['code'].toString().toLowerCase().contains(query) ||
          loc['item'].toString().toLowerCase().contains(query) ||
          loc['barcode'].toString().toLowerCase().contains(query);

      final matchesZone = _selectedZone == 'Semua Zona' ||
          loc['zone'].toString().contains(_selectedZone.split(' ')[0]);

      return matchesSearch && matchesZone;
    }).toList();

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
            // Pencarian Barcode / Lokasi Rak
            AppTextField(
              controller: _searchController,
              label: 'Cari Lokasi / Part / Barcode',
              hintText: 'Ketik kode rak (RAK-A01), part, atau barcode...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: IconButton(
                icon: const Icon(Icons.qr_code_scanner, color: AppColors.primary),
                tooltip: 'Scan Barcode Lokasi',
                onPressed: () {
                  AppSnackBar.showInfo(context, 'Membuka Scanner Barcode Lokasi Rak');
                },
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Denah Zona Gudang Eka Maju
            Text(
              'Zona Gudang Logistik',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _ZoneCard(
                    title: 'Semua Zona',
                    count: '4 Zona',
                    isSelected: _selectedZone == 'Semua Zona',
                    icon: Icons.grid_view_rounded,
                    onTap: () => setState(() => _selectedZone = 'Semua Zona'),
                  ),
                  const SizedBox(width: 10),
                  _ZoneCard(
                    title: 'Zona A',
                    count: 'Komponen Presisi',
                    isSelected: _selectedZone == 'Zona A',
                    icon: Icons.precision_manufacturing_outlined,
                    onTap: () => setState(() => _selectedZone = 'Zona A'),
                  ),
                  const SizedBox(width: 10),
                  _ZoneCard(
                    title: 'Zona B',
                    count: 'Cutting Tools',
                    isSelected: _selectedZone == 'Zona B',
                    icon: Icons.carpenter_outlined,
                    onTap: () => setState(() => _selectedZone = 'Zona B'),
                  ),
                  const SizedBox(width: 10),
                  _ZoneCard(
                    title: 'Zona C',
                    count: 'Heavy Parts',
                    isSelected: _selectedZone == 'Zona C',
                    icon: Icons.fire_truck_outlined,
                    onTap: () => setState(() => _selectedZone = 'Zona C'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Header Daftar Pelacakan
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Hasil Pelacakan (${filteredLocations.length})',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.outline,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    AppSnackBar.showInfo(context, 'Membuka Peta Denah Interaktif Gudang');
                  },
                  icon: const Icon(Icons.map_outlined, size: 16),
                  label: const Text('Denah Gudang', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (filteredLocations.isEmpty)
              const AppEmptyState(
                title: 'Lokasi Tidak Ditemukan',
                message: 'Tidak ada item atau rak yang cocok dengan kriteria pencarian.',
                icon: Icons.location_off_outlined,
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredLocations.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final loc = filteredLocations[index];

                  return AppCard(
                    padding: const EdgeInsets.all(16),
                    elevation: 1,
                    onTap: () {
                      _showLocationDetail(context, loc);
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.location_on, size: 14, color: colorScheme.primary),
                                  const SizedBox(width: 4),
                                  Text(
                                    loc['code'] as String,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            AppStatusBadge(
                              status: loc['status'] as String,
                              color: loc['statusColor'] as Color,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          loc['item'] as String,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${loc['zone']} • Barcode: ${loc['barcode']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorScheme.outline,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Stok di Rak: ${loc['qty']} (${loc['capacity']} Kapasitas)',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              loc['lastMoved'] as String,
                              style: TextStyle(
                                fontSize: 11,
                                color: colorScheme.outline,
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

  void _showLocationDetail(BuildContext context, Map<String, dynamic> loc) {
    AppConfirmationDialog.show(
      context,
      title: 'Detail Lokasi: ${loc['code']}',
      message:
          'Nama Barang: ${loc['item']}\nBarcode: ${loc['barcode']}\nArea: ${loc['zone']}\nKapasitas: ${loc['capacity']}\nPergerakan Terakhir: ${loc['lastMoved']}',
      confirmText: 'Tutup',
    );
  }
}

class _ZoneCard extends StatelessWidget {
  const _ZoneCard({
    required this.title,
    required this.count,
    required this.isSelected,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String count;
  final bool isSelected;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = context.isDarkMode;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : isDark
                  ? const Color(0xFF222222)
                  : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : isDark
                    ? const Color(0xFF333333)
                    : const Color(0xFFE0E0E0),
            width: 1,
          ),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? Colors.white : colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isSelected
                        ? Colors.white
                        : isDark
                            ? Colors.white
                            : Colors.black87,
                  ),
                ),
                Text(
                  count,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: isSelected ? Colors.white70 : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
