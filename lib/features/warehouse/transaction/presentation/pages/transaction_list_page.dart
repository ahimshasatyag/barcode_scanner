import 'dart:async';

import 'package:flutter/material.dart';
import 'package:barcode/shared/theme/theme.dart';
import 'package:barcode/shared/widgets/widgets.dart';

import '../../data/models/do_hdr_model.dart';
import '../../data/models/gudang_model.dart';
import '../../data/models/machine_item_model.dart';
import '../../data/models/product_lokasi_model.dart';
import '../../data/models/supplier_model.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../domain/entities/warehouse_transaction.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';
import '../widgets/transaction_card.dart';
import 'scanner_page.dart';
import 'transaction_detail_page.dart';

class TransactionListPage extends StatefulWidget {
  const TransactionListPage({super.key, this.bloc});

  final TransactionBloc? bloc;

  @override
  State<TransactionListPage> createState() => _TransactionListPageState();
}

class _TransactionListPageState extends State<TransactionListPage> {
  late final TransactionBloc _bloc;
  StreamSubscription<TransactionState>? _blocSubscription;
  int _selectedFilter = 0; // 0: Semua, 1: Inbound, 2: Outbound

  @override
  void initState() {
    super.initState();
    _bloc =
        widget.bloc ?? TransactionBloc(repository: TransactionRepositoryImpl());

    _blocSubscription = _bloc.stream.listen((state) {
      if (!mounted) return;
      if (state is TransactionActionSuccess) {
        AppSnackBar.showSuccess(context, state.message);
      } else if (state is TransactionError) {
        AppSnackBar.showError(context, state.message);
      }
    });

    _bloc.add(const LoadTransactions());
  }

  @override
  void dispose() {
    _blocSubscription?.cancel();
    if (widget.bloc == null) {
      _bloc.close();
    }
    super.dispose();
  }

  void _openScannerForType(
    BuildContext context,
    TransactionType type,
    List<WarehouseTransaction> list,
  ) {
    // Cari transaksi aktif bertipe ini
    final active = list
        .where((t) => t.type == type && t.status != TransactionStatus.completed)
        .toList();
    if (active.isNotEmpty) {
      _navigateToScanner(context, active.first);
    } else {
      final anyOfThisType = list.where((t) => t.type == type).toList();
      if (anyOfThisType.isNotEmpty) {
        _navigateToScanner(context, anyOfThisType.first);
      } else {
        AppSnackBar.showInfo(
          context,
          'Belum ada transaksi ${type.shortLabel} aktif. Silakan buat transaksi baru.',
        );
      }
    }
  }

  void _navigateToScanner(BuildContext context, WarehouseTransaction trx) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ScannerPage(transaction: trx, bloc: _bloc),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, WarehouseTransaction trx) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionDetailPage(transaction: trx, bloc: _bloc),
      ),
    );
  }

  Future<void> _showCreateTransactionSheet(BuildContext context) async {
    TransactionType selectedType = TransactionType.inbound;

    List<GudangModel> gudangs = [];
    List<ProductLokasiModel> lokasis = [];
    List<SupplierModel> suppliers = [];
    List<DoHdrModel> deliveryOrders = [];
    List<MachineItemModel> productSns = [];

    try {
      gudangs = await _bloc.repository.getGudangList();
    } catch (_) {}
    try {
      lokasis = await _bloc.repository.getProductLokasiList();
    } catch (_) {}
    try {
      suppliers = await _bloc.repository.getSupplierList();
    } catch (_) {}
    try {
      deliveryOrders = await _bloc.repository.getDoList();
    } catch (_) {}
    try {
      productSns = await _bloc.repository.getProductSnList();
    } catch (_) {}

    if (!context.mounted) return;

    int? selectedGudangId = gudangs.isNotEmpty ? gudangs.first.idGudang : null;
    int? selectedSupplierId = suppliers.isNotEmpty
        ? suppliers.first.idSuppliers
        : null;
    int? selectedDoId = deliveryOrders.isNotEmpty
        ? deliveryOrders.first.idDo
        : null;

    final initialLokasiList = selectedGudangId != null
        ? lokasis
              .where(
                (l) => l.idGudang == null || l.idGudang == selectedGudangId,
              )
              .toList()
        : lokasis;
    int? selectedLokasiId = initialLokasiList.isNotEmpty
        ? initialLokasiList.first.idProductLokasi
        : null;

    final initialSnList = selectedGudangId != null
        ? productSns
              .where(
                (s) => s.idGudang == null || s.idGudang == selectedGudangId,
              )
              .toList()
        : productSns;
    String? selectedSn = initialSnList.isNotEmpty
        ? initialSnList.first.serialNumber
        : null;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final colorScheme = ctx.colorScheme;
        final isDark = ctx.isDarkMode;

        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            final isInbound = selectedType == TransactionType.inbound;
            const greenColor = Color(0xFF2E7D32);

            // Deduplikasi Master Gudang (m_gudang)
            final uniqueGudangs = <int, GudangModel>{};
            for (final g in gudangs) {
              uniqueGudangs.putIfAbsent(g.idGudang, () => g);
            }
            final deduplicatedGudangs = uniqueGudangs.values.toList();
            if (selectedGudangId == null ||
                !deduplicatedGudangs.any(
                  (g) => g.idGudang == selectedGudangId,
                )) {
              selectedGudangId = deduplicatedGudangs.isNotEmpty
                  ? deduplicatedGudangs.first.idGudang
                  : null;
            }
            GudangModel? effectiveGudang;
            for (final g in deduplicatedGudangs) {
              if (g.idGudang == selectedGudangId) {
                effectiveGudang = g;
                break;
              }
            }

            // Deduplikasi & filter Lokasi Rak (m_product_lokasi) sesuai gudang terpilih
            final filteredLokasi = selectedGudangId != null
                ? lokasis
                      .where(
                        (l) =>
                            l.idGudang == null ||
                            l.idGudang == selectedGudangId,
                      )
                      .toList()
                : lokasis;
            final uniqueLokasi = <int, ProductLokasiModel>{};
            for (final l in filteredLokasi) {
              uniqueLokasi.putIfAbsent(l.idProductLokasi, () => l);
            }
            final deduplicatedLokasi = uniqueLokasi.values.toList();
            if (selectedLokasiId == null ||
                !deduplicatedLokasi.any(
                  (l) => l.idProductLokasi == selectedLokasiId,
                )) {
              selectedLokasiId = deduplicatedLokasi.isNotEmpty
                  ? deduplicatedLokasi.first.idProductLokasi
                  : null;
            }
            ProductLokasiModel? effectiveLokasi;
            for (final l in deduplicatedLokasi) {
              if (l.idProductLokasi == selectedLokasiId) {
                effectiveLokasi = l;
                break;
              }
            }

            // Deduplikasi Master Supplier (m_suppliers)
            final uniqueSuppliers = <int, SupplierModel>{};
            for (final s in suppliers) {
              uniqueSuppliers.putIfAbsent(s.idSuppliers, () => s);
            }
            final deduplicatedSuppliers = uniqueSuppliers.values.toList();
            if (selectedSupplierId == null ||
                !deduplicatedSuppliers.any(
                  (s) => s.idSuppliers == selectedSupplierId,
                )) {
              selectedSupplierId = deduplicatedSuppliers.isNotEmpty
                  ? deduplicatedSuppliers.first.idSuppliers
                  : null;
            }
            SupplierModel? effectiveSupplier;
            for (final s in deduplicatedSuppliers) {
              if (s.idSuppliers == selectedSupplierId) {
                effectiveSupplier = s;
                break;
              }
            }

            // Deduplikasi Delivery Order (tb_do_hdr)
            final uniqueDos = <int, DoHdrModel>{};
            for (final d in deliveryOrders) {
              uniqueDos.putIfAbsent(d.idDo, () => d);
            }
            final deduplicatedDos = uniqueDos.values.toList();
            if (selectedDoId == null ||
                !deduplicatedDos.any((d) => d.idDo == selectedDoId)) {
              selectedDoId = deduplicatedDos.isNotEmpty
                  ? deduplicatedDos.first.idDo
                  : null;
            }
            DoHdrModel? effectiveDo;
            for (final d in deduplicatedDos) {
              if (d.idDo == selectedDoId) {
                effectiveDo = d;
                break;
              }
            }

            // Deduplikasi Nomor Seri Produk (m_product_sn) sesuai gudang
            final filteredSns = selectedGudangId != null
                ? productSns
                      .where(
                        (s) =>
                            s.idGudang == null ||
                            s.idGudang == selectedGudangId,
                      )
                      .toList()
                : productSns;
            final uniqueSns = <String, MachineItemModel>{};
            for (final s in filteredSns) {
              final key = s.serialNumber.trim().toUpperCase();
              if (key.isNotEmpty) {
                uniqueSns.putIfAbsent(key, () => s);
              }
            }
            final deduplicatedSns = uniqueSns.values.toList();
            if (selectedSn == null ||
                !deduplicatedSns.any(
                  (s) =>
                      s.serialNumber.trim().toUpperCase() ==
                      selectedSn?.trim().toUpperCase(),
                )) {
              selectedSn = deduplicatedSns.isNotEmpty
                  ? deduplicatedSns.first.serialNumber
                  : null;
            }
            MachineItemModel? effectiveSn;
            for (final s in deduplicatedSns) {
              if (s.serialNumber.trim().toUpperCase() ==
                  selectedSn?.trim().toUpperCase()) {
                effectiveSn = s;
                break;
              }
            }

            // Judul transaksi otomatis dibuat berdasarkan pilihan dropdown transaksi (Tanpa Input Text)
            final autoTitle = isInbound
                ? (effectiveSupplier != null
                      ? 'Penerimaan Stok - ${effectiveSupplier.nmSuppliers}'
                      : (effectiveDo != null
                            ? 'Penerimaan ${effectiveDo.codeDo}'
                            : 'Penerimaan Stok ${effectiveGudang?.codeGudang ?? "Gudang"}'))
                : (effectiveDo != null
                      ? 'Pengiriman ${effectiveDo.codeDo} - ${effectiveDo.nmCustomers ?? ""}'
                      : (effectiveSupplier != null
                            ? 'Pengiriman ke ${effectiveSupplier.nmSuppliers}'
                            : 'Pengiriman Barang ${effectiveGudang?.codeGudang ?? "Gudang"}'));

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(modalContext).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'Buat Transaksi Inbound / Outbound',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(modalContext),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Pilihan Jenis Transaksi: Inbound vs Outbound
                      Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: const Text('Inbound (Penerimaan)'),
                              selected: isInbound,
                              selectedColor: greenColor.withValues(alpha: 0.2),
                              labelStyle: TextStyle(
                                color: isInbound ? greenColor : null,
                                fontWeight: isInbound ? FontWeight.bold : null,
                              ),
                              onSelected: (val) {
                                if (val) {
                                  setModalState(() {
                                    selectedType = TransactionType.inbound;
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ChoiceChip(
                              label: const Text('Outbound (Pengiriman)'),
                              selected: !isInbound,
                              selectedColor: colorScheme.primary.withValues(
                                alpha: 0.2,
                              ),
                              labelStyle: TextStyle(
                                color: !isInbound ? colorScheme.primary : null,
                                fontWeight: !isInbound ? FontWeight.bold : null,
                              ),
                              onSelected: (val) {
                                if (val) {
                                  setModalState(() {
                                    selectedType = TransactionType.outbound;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Info Judul Transaksi Otomatis (Tanpa Input Text)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: (isInbound ? greenColor : colorScheme.primary)
                              .withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color:
                                (isInbound ? greenColor : colorScheme.primary)
                                    .withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isInbound
                                  ? Icons.input
                                  : Icons.local_shipping_outlined,
                              size: 18,
                              color: isInbound
                                  ? greenColor
                                  : colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                autoTitle,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: isInbound
                                      ? greenColor
                                      : colorScheme.primary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 1. Dropdown Master Gudang (m_gudang)
                      Text(
                        'Pilih Gudang (m_gudang)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: colorScheme.outline.withValues(alpha: 0.3),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int?>(
                            value: selectedGudangId,
                            hint: const Text('Pilih Gudang (m_gudang)'),
                            isExpanded: true,
                            items: deduplicatedGudangs.isNotEmpty
                                ? deduplicatedGudangs.map((g) {
                                    return DropdownMenuItem<int?>(
                                      value: g.idGudang,
                                      child: Text(
                                        '${g.nmGudang} (${g.codeGudang})',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    );
                                  }).toList()
                                : [
                                    const DropdownMenuItem<int?>(
                                      value: null,
                                      child: Text(
                                        'Tidak ada data di tabel m_gudang',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                            onChanged: deduplicatedGudangs.isNotEmpty
                                ? (val) {
                                    if (val != null) {
                                      setModalState(() {
                                        selectedGudangId = val;
                                        final newLocs = lokasis
                                            .where(
                                              (l) =>
                                                  l.idGudang == null ||
                                                  l.idGudang == val,
                                            )
                                            .toList();
                                        selectedLokasiId = newLocs.isNotEmpty
                                            ? newLocs.first.idProductLokasi
                                            : null;

                                        final newSns = productSns
                                            .where(
                                              (s) =>
                                                  s.idGudang == null ||
                                                  s.idGudang == val,
                                            )
                                            .toList();
                                        selectedSn = newSns.isNotEmpty
                                            ? newSns.first.serialNumber
                                            : null;
                                      });
                                    }
                                  }
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 2. Dropdown Supplier (m_suppliers) - Tersedia untuk Inbound & Outbound (Murni Dropdown)
                      Text(
                        'Pilih Supplier (m_suppliers)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isInbound ? greenColor : colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                (isInbound ? greenColor : colorScheme.outline)
                                    .withValues(alpha: 0.35),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int?>(
                            value: selectedSupplierId,
                            hint: const Text('Pilih Supplier (m_suppliers)'),
                            isExpanded: true,
                            items: deduplicatedSuppliers.isNotEmpty
                                ? deduplicatedSuppliers.map((s) {
                                    return DropdownMenuItem<int?>(
                                      value: s.idSuppliers,
                                      child: Text(
                                        s.nmSuppliers,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    );
                                  }).toList()
                                : [
                                    const DropdownMenuItem<int?>(
                                      value: null,
                                      child: Text(
                                        'Belum ada data supplier di tabel m_suppliers',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                            onChanged: deduplicatedSuppliers.isNotEmpty
                                ? (val) {
                                    if (val != null) {
                                      setModalState(
                                        () => selectedSupplierId = val,
                                      );
                                    }
                                  }
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 3. Dropdown Dokumen DO (tb_do_hdr) - Tersedia untuk Inbound & Outbound (Murni Dropdown)
                      Text(
                        'Pilih Dokumen DO (tb_do_hdr)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: !isInbound
                              ? colorScheme.primary
                              : colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                (!isInbound
                                        ? colorScheme.primary
                                        : colorScheme.outline)
                                    .withValues(alpha: 0.35),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int?>(
                            value: selectedDoId,
                            hint: const Text('Pilih Dokumen DO (tb_do_hdr)'),
                            isExpanded: true,
                            items: deduplicatedDos.isNotEmpty
                                ? deduplicatedDos.map((d) {
                                    return DropdownMenuItem<int?>(
                                      value: d.idDo,
                                      child: Text(
                                        '${d.codeDo} • ${d.nmCustomers ?? "-"}',
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                    );
                                  }).toList()
                                : [
                                    const DropdownMenuItem<int?>(
                                      value: null,
                                      child: Text(
                                        'Belum ada data DO di tabel tb_do_hdr',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                            onChanged: deduplicatedDos.isNotEmpty
                                ? (val) {
                                    if (val != null) {
                                      setModalState(() => selectedDoId = val);
                                    }
                                  }
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 4. Dropdown Nomor Seri Mesin (m_product_sn) - Tersedia untuk Inbound & Outbound (Murni Dropdown)
                      Text(
                        'Pilih Nomor Seri (m_product_sn)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: colorScheme.outline.withValues(alpha: 0.3),
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String?>(
                            value: selectedSn,
                            hint: const Text(
                              'Pilih Nomor Seri Barang (m_product_sn)',
                            ),
                            isExpanded: true,
                            items: deduplicatedSns.isNotEmpty
                                ? deduplicatedSns.map((sn) {
                                    return DropdownMenuItem<String?>(
                                      value: sn.serialNumber,
                                      child: Text(
                                        '${sn.serialNumber} • ${sn.modelName} (${sn.codeGudang ?? sn.brand})',
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 12.5),
                                      ),
                                    );
                                  }).toList()
                                : [
                                    const DropdownMenuItem<String?>(
                                      value: null,
                                      child: Text(
                                        'Tidak ada nomor seri di tabel m_product_sn',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                            onChanged: deduplicatedSns.isNotEmpty
                                ? (val) {
                                    if (val != null) {
                                      setModalState(() => selectedSn = val);
                                    }
                                  }
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // 5. Dropdown Master Lokasi Rak (m_product_lokasi)
                      if (deduplicatedLokasi.isNotEmpty) ...[
                        Text(
                          'Pilih Lokasi Rak (m_product_lokasi)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: colorScheme.outline.withValues(alpha: 0.3),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<int?>(
                              value: selectedLokasiId,
                              hint: const Text(
                                'Pilih Lokasi Rak (m_product_lokasi)',
                              ),
                              isExpanded: true,
                              items: deduplicatedLokasi.map((l) {
                                return DropdownMenuItem<int?>(
                                  value: l.idProductLokasi,
                                  child: Text(
                                    (l.completeName != null &&
                                            l.completeName!.isNotEmpty)
                                        ? l.completeName!
                                        : l.nmProductLokasi,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontSize: 12.5),
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setModalState(() => selectedLokasiId = val);
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              text: 'Batal',
                              type: AppButtonType.outlined,
                              onPressed: () => Navigator.pop(modalContext),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppButton(
                              text: 'Simpan & Scan',
                              type: AppButtonType.primary,
                              backgroundColor: isInbound
                                  ? greenColor
                                  : colorScheme.primary,
                              onPressed: () {
                                final title = autoTitle;
                                final ref =
                                    effectiveDo?.codeDo ??
                                    (effectiveSn?.serialNumber ?? '-');
                                final partner = isInbound
                                    ? (effectiveSupplier?.nmSuppliers ??
                                          (effectiveDo?.nmCustomers ?? '-'))
                                    : (effectiveDo?.nmCustomers ??
                                          (effectiveSupplier?.nmSuppliers ??
                                              '-'));

                                final newTrx = WarehouseTransaction(
                                  id: 'TRX-${isInbound ? 'INB' : 'OUT'}-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
                                  type: selectedType,
                                  title: title,
                                  referenceNumber: ref,
                                  partnerName: partner,
                                  vehicleOrContainerId: '',
                                  createdAt: DateTime.now(),
                                  targetQuantity: 1,
                                  status: TransactionStatus.inProgress,
                                  operatorName:
                                      'Operator ${effectiveGudang?.codeGudang ?? "EMM"}',
                                  notes:
                                      'Gudang: ${effectiveGudang?.nmGudang ?? "-"} | Lokasi: ${effectiveLokasi?.completeName ?? effectiveLokasi?.nmProductLokasi ?? "-"}',
                                  idGudang: effectiveGudang?.idGudang,
                                  nmGudang: effectiveGudang?.nmGudang,
                                  idSupplier: effectiveSupplier?.idSuppliers,
                                  nmSupplier: effectiveSupplier?.nmSuppliers,
                                  idDo: effectiveDo?.idDo,
                                  codeDo: effectiveDo?.codeDo,
                                  idProductLokasi:
                                      effectiveLokasi?.idProductLokasi,
                                  nmProductLokasi:
                                      effectiveLokasi?.nmProductLokasi,
                                );

                                _bloc.add(CreateNewTransaction(newTrx));
                                Navigator.pop(modalContext);
                                _navigateToScanner(context, newTrx);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final textTheme = context.textTheme;
    const greenColor = Color(0xFF2E7D32);

    // Posisi ideal melayang: turun lebih ke bawah agar tepat dan proporsional di atas floating glass navbar
    final bottomSafeArea = MediaQuery.of(context).padding.bottom;
    final double fabBottomMargin = bottomSafeArea > 0 ? 88 : 86;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: fabBottomMargin),
        child: FloatingActionButton.extended(
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          label: const Text('Buat Transaksi'),
          onPressed: () => _showCreateTransactionSheet(context),
        ),
      ),
      body: StreamBuilder<TransactionState>(
        stream: _bloc.stream,
        initialData: _bloc.state,
        builder: (context, snapshot) {
          final state = snapshot.data ?? const TransactionInitial();

          List<WarehouseTransaction> transactions = const [];
          bool isLoading = false;

          if (state is TransactionLoading) {
            isLoading = true;
          } else if (state is TransactionLoaded) {
            transactions = state.transactions;
          }

          final filteredList = transactions.where((t) {
            if (_selectedFilter == 1) return t.type == TransactionType.inbound;
            if (_selectedFilter == 2) return t.type == TransactionType.outbound;
            return true;
          }).toList();

          final inboundCount = transactions
              .where((t) => t.type == TransactionType.inbound)
              .length;
          final outboundCount = transactions
              .where((t) => t.type == TransactionType.outbound)
              .length;

          return RefreshIndicator(
            color: colorScheme.primary,
            onRefresh: () async {
              _bloc.add(const LoadTransactions());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kartu Ringkasan Operasional
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Inbound',
                          value: '$inboundCount Transaksi',
                          subtitle: 'Penerimaan Barang',
                          icon: Icons.archive_outlined,
                          iconColor: greenColor,
                          bgColor: greenColor.withValues(alpha: 0.12),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: 'Outbound',
                          value: '$outboundCount Transaksi',
                          subtitle: 'Pengiriman Barang',
                          icon: Icons.unarchive_outlined,
                          iconColor: colorScheme.primary,
                          bgColor: colorScheme.primary.withValues(alpha: 0.12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Aksi Cepat Scanner Inbound & Outbound
                  Text(
                    'Barcode Scanner',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _QuickScannerButton(
                          label: 'Scan Inbound',
                          sublabel: 'Penerimaan Barang',
                          icon: Icons.qr_code_scanner,
                          color: greenColor,
                          onTap: () => _openScannerForType(
                            context,
                            TransactionType.inbound,
                            transactions,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _QuickScannerButton(
                          label: 'Scan Outbound',
                          sublabel: 'Pengiriman Barang',
                          icon: Icons.barcode_reader,
                          color: colorScheme.primary,
                          onTap: () => _openScannerForType(
                            context,
                            TransactionType.outbound,
                            transactions,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Filter Chips
                  Row(
                    children: [
                      _FilterTabChip(
                        label: 'Semua (${transactions.length})',
                        isSelected: _selectedFilter == 0,
                        onTap: () => setState(() => _selectedFilter = 0),
                      ),
                      const SizedBox(width: 8),
                      _FilterTabChip(
                        label: 'Inbound ($inboundCount)',
                        isSelected: _selectedFilter == 1,
                        onTap: () => setState(() => _selectedFilter = 1),
                      ),
                      const SizedBox(width: 8),
                      _FilterTabChip(
                        label: 'Outbound ($outboundCount)',
                        isSelected: _selectedFilter == 2,
                        onTap: () => setState(() => _selectedFilter = 2),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Header Judul Daftar Transaksi
                  Text(
                    'Daftar Transaksi Gudang (${filteredList.length})',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 12),

                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: AppLoadingIndicator()),
                    )
                  else if (filteredList.isEmpty)
                    const AppEmptyState(
                      title: 'Tidak Ada Transaksi',
                      message: 'Belum ada transaksi pada kategori ini. Silakan buat transaksi baru.',
                      icon: Icons.receipt_long_outlined,
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredList.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final trx = filteredList[index];
                        return TransactionCard(
                          transaction: trx,
                          onOpenScanner: () => _navigateToScanner(context, trx),
                          onTapDetail: () => _navigateToDetail(context, trx),
                        );
                      },
                    ),
                  SizedBox(height: fabBottomMargin + 36),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return AppCard(
      padding: const EdgeInsets.all(14),
      elevation: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.outline,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11, color: colorScheme.outline),
          ),
        ],
      ),
    );
  }
}

class _QuickScannerButton extends StatelessWidget {
  const _QuickScannerButton({
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final String sublabel;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: color,
                    ),
                  ),
                  Text(
                    sublabel,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterTabChip extends StatelessWidget {
  const _FilterTabChip({
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
