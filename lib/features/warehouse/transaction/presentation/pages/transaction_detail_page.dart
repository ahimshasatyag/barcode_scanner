import 'dart:async';
import 'package:flutter/material.dart';
import 'package:barcode/shared/theme/theme.dart';
import 'package:barcode/shared/widgets/widgets.dart';
import '../../data/models/gudang_model.dart';
import '../../data/models/machine_item_model.dart';
import '../../data/models/product_lokasi_model.dart';
import '../../domain/entities/machine_item.dart';
import '../../domain/entities/warehouse_transaction.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';
import '../widgets/machine_item_tile.dart';
import 'scanner_page.dart';

class TransactionDetailPage extends StatefulWidget {
  const TransactionDetailPage({
    super.key,
    required this.transaction,
    required this.bloc,
  });

  final WarehouseTransaction transaction;
  final TransactionBloc bloc;

  @override
  State<TransactionDetailPage> createState() => _TransactionDetailPageState();
}

class _TransactionDetailPageState extends State<TransactionDetailPage> {
  late WarehouseTransaction _currentTransaction;
  StreamSubscription<TransactionState>? _blocSubscription;

  @override
  void initState() {
    super.initState();
    _currentTransaction = widget.transaction;

    _blocSubscription = widget.bloc.stream.listen((state) {
      if (!mounted) return;

      if (state is TransactionActionSuccess) {
        AppSnackBar.showSuccess(context, state.message);
      } else if (state is TransactionError) {
        AppSnackBar.showError(context, state.message);
      }

      if (state is TransactionLoaded) {
        final matched = state.transactions.where((t) => t.id == widget.transaction.id).toList();
        if (matched.isNotEmpty) {
          setState(() {
            _currentTransaction = matched.first;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _blocSubscription?.cancel();
    super.dispose();
  }

  void _showItemDetailDialog(BuildContext context, MachineItem item) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.inventory_2_outlined, color: Color(0xFF2E7D32)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.modelName,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DetailRow(icon: Icons.tag, label: 'ID Product SN', value: '${item.idProductSn ?? "-"}'),
                _DetailRow(icon: Icons.qr_code, label: 'Serial Number', value: item.serialNumber),
                _DetailRow(icon: Icons.warehouse_outlined, label: 'Gudang', value: item.nmGudang ?? '-'),
                _DetailRow(icon: Icons.pin_drop_outlined, label: 'Lokasi Rak', value: item.completeName ?? item.nmProductLokasi ?? '-'),
                _DetailRow(icon: Icons.numbers, label: 'Kuantitas (nqty)', value: '${item.nqty} Unit'),
                if (item.dateCreate != null)
                  _DetailRow(icon: Icons.calendar_today, label: 'Tanggal Input', value: item.dateCreate.toString().substring(0, 19)),
                if (item.dateUpdate != null)
                  _DetailRow(icon: Icons.update, label: 'Update Terakhir', value: item.dateUpdate.toString().substring(0, 19)),
              ],
            ),
          ),
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.swap_horiz),
              label: const Text('Pindah Lokasi'),
              onPressed: () {
                Navigator.pop(ctx);
                _showRelocateModal(context, item);
              },
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showAddSnModal(BuildContext context) async {
    List<MachineItemModel> availableSns = [];
    try {
      final list = await widget.bloc.repository.getProductSnList(
        idGudang: _currentTransaction.idGudang,
      );
      availableSns = list;
    } catch (_) {}

    if (!context.mounted) return;

    MachineItemModel? selectedSn = availableSns.isNotEmpty ? availableSns.first : null;
    final manualSnController = TextEditingController(text: selectedSn?.serialNumber ?? '');

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        final colorScheme = modalCtx.colorScheme;
        final isDark = modalCtx.isDarkMode;
        final isInbound = _currentTransaction.type == TransactionType.inbound;
        const greenColor = Color(0xFF2E7D32);
        final accentColor = isInbound ? greenColor : colorScheme.primary;

        return StatefulBuilder(
          builder: (ctx, setModalState) {
            // Deduplikasi daftar nomor seri dari database backend
            final uniqueSns = <String, MachineItemModel>{};
            for (final s in availableSns) {
              if (s.serialNumber.trim().isNotEmpty) {
                uniqueSns.putIfAbsent(s.serialNumber.trim().toUpperCase(), () => s);
              }
            }
            final deduplicatedSns = uniqueSns.values.toList();

            final effectiveSn = deduplicatedSns.any((s) => s.serialNumber.trim().toUpperCase() == selectedSn?.serialNumber.trim().toUpperCase())
                ? deduplicatedSns.firstWhere((s) => s.serialNumber.trim().toUpperCase() == selectedSn?.serialNumber.trim().toUpperCase())
                : (deduplicatedSns.isNotEmpty ? deduplicatedSns.first : null);

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
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pilih Nomor Seri (${isInbound ? "Inbound" : "Outbound"})',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(modalCtx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pilih nomor seri mesin dari master data m_product_sn untuk diverifikasi ke dalam transaksi ini.',
                        style: TextStyle(fontSize: 12.5, color: colorScheme.outline),
                      ),
                      const SizedBox(height: 16),

                      if (deduplicatedSns.isNotEmpty) ...[
                        Text(
                          'Pilih Nomor Seri Database (m_product_sn)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            border: Border.all(color: accentColor.withValues(alpha: 0.4)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<MachineItemModel>(
                              value: effectiveSn,
                              isExpanded: true,
                              items: deduplicatedSns.map((sn) {
                                final isAlready = _currentTransaction.items.any((i) => i.serialNumber == sn.serialNumber);
                                return DropdownMenuItem<MachineItemModel>(
                                  value: sn,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${sn.serialNumber} • ${sn.modelName} (${sn.codeGudang ?? "-"})',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: isAlready ? FontWeight.normal : FontWeight.w600,
                                            color: isAlready ? Colors.grey : null,
                                          ),
                                        ),
                                      ),
                                      if (isAlready)
                                        const Icon(Icons.check, size: 14, color: Colors.green),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) {
                                  setModalState(() {
                                    selectedSn = val;
                                    manualSnController.text = val.serialNumber;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      AppTextField(
                        label: 'Nomor Seri / Barcode (atau ketik manual)',
                        hintText: selectedSn?.serialNumber ?? 'Ketik nomor seri atau scan barcode',
                        controller: manualSnController,
                        prefixIcon: const Icon(Icons.qr_code_2),
                      ),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              text: 'Batal',
                              type: AppButtonType.outlined,
                              onPressed: () => Navigator.pop(modalCtx),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppButton(
                              text: 'Verifikasi & Tambah',
                              type: AppButtonType.primary,
                              backgroundColor: accentColor,
                              onPressed: () {
                                final code = manualSnController.text.trim().isNotEmpty
                                    ? manualSnController.text.trim()
                                    : (selectedSn?.serialNumber ?? '');
                                if (code.isNotEmpty) {
                                  Navigator.pop(modalCtx);
                                  widget.bloc.add(
                                    ScanMachineBarcode(
                                      transactionId: _currentTransaction.id,
                                      barcode: code,
                                    ),
                                  );
                                }
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

  Future<void> _showRelocateModal(BuildContext context, MachineItem item) async {
    List<GudangModel> gudangs = [];
    List<ProductLokasiModel> lokasis = [];

    try {
      final gList = await widget.bloc.repository.getGudangList();
      final lList = await widget.bloc.repository.getProductLokasiList();
      gudangs = gList;
      lokasis = lList;
    } catch (_) {}

    if (!context.mounted) return;

    GudangModel? selectedGudang = gudangs.isNotEmpty ? gudangs.first : null;
    ProductLokasiModel? selectedLokasi = lokasis.isNotEmpty ? lokasis.first : null;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final colorScheme = ctx.colorScheme;
        final isDark = ctx.isDarkMode;

        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            final uniqueGudangs = <int, GudangModel>{};
            for (final g in gudangs) {
              uniqueGudangs.putIfAbsent(g.idGudang, () => g);
            }
            final deduplicatedGudangs = uniqueGudangs.values.toList();
            final effectiveGudang = deduplicatedGudangs.any((g) => g.idGudang == selectedGudang?.idGudang)
                ? deduplicatedGudangs.firstWhere((g) => g.idGudang == selectedGudang?.idGudang)
                : (deduplicatedGudangs.isNotEmpty ? deduplicatedGudangs.first : null);

            final filteredLokasi = effectiveGudang != null
                ? lokasis.where((l) => l.idGudang == null || l.idGudang == effectiveGudang.idGudang).toList()
                : lokasis;
            final uniqueLokasi = <int, ProductLokasiModel>{};
            for (final l in filteredLokasi) {
              uniqueLokasi.putIfAbsent(l.idProductLokasi, () => l);
            }
            final deduplicatedLokasi = uniqueLokasi.values.toList();
            final effectiveLokasi = deduplicatedLokasi.any((l) => l.idProductLokasi == selectedLokasi?.idProductLokasi)
                ? deduplicatedLokasi.firstWhere((l) => l.idProductLokasi == selectedLokasi?.idProductLokasi)
                : (deduplicatedLokasi.isNotEmpty ? deduplicatedLokasi.first : null);

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(modalCtx).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Mutasi Lokasi Barang',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(modalCtx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Pindahkan lokasi penyimpanan fisik untuk serial number ini di database (ProductSnController & ProductLokasiController).',
                        style: TextStyle(fontSize: 12.5, color: colorScheme.outline),
                      ),
                      const Divider(height: 24),
                      _DetailRow(
                        icon: Icons.qr_code,
                        label: 'Serial Number',
                        value: item.serialNumber,
                      ),
                      _DetailRow(
                        icon: Icons.pin_drop_outlined,
                        label: 'Lokasi Sekarang',
                        value: item.completeName ?? item.nmProductLokasi ?? 'Belum ditentukan',
                      ),
                      _DetailRow(
                        icon: Icons.warehouse_outlined,
                        label: 'Gudang Sekarang',
                        value: item.nmGudang ?? '-',
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Pilih Gudang Tujuan',
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
                          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<GudangModel>(
                            value: effectiveGudang,
                            isExpanded: true,
                            hint: const Text('Pilih Gudang Tujuan'),
                            items: deduplicatedGudangs.map((g) {
                              return DropdownMenuItem<GudangModel>(
                                value: g,
                                child: Text('${g.nmGudang} (${g.codeGudang})'),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setModalState(() {
                                  selectedGudang = val;
                                  final newLocs = lokasis
                                      .where((l) => l.idGudang == null || l.idGudang == val.idGudang)
                                      .toList();
                                  selectedLokasi = newLocs.isNotEmpty ? newLocs.first : null;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Pilih Lokasi Rak Tujuan (m_product_lokasi)',
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
                          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<ProductLokasiModel>(
                            value: effectiveLokasi,
                            isExpanded: true,
                            hint: const Text('Pilih Lokasi Rak'),
                            items: deduplicatedLokasi.map((l) {
                              return DropdownMenuItem<ProductLokasiModel>(
                                value: l,
                                child: Text(
                                  (l.completeName != null && l.completeName!.isNotEmpty)
                                      ? l.completeName!
                                      : l.nmProductLokasi,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 12.5),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setModalState(() => selectedLokasi = val);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              text: 'Batal',
                              type: AppButtonType.outlined,
                              onPressed: () => Navigator.pop(modalCtx),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: AppButton(
                              text: 'Simpan Mutasi',
                              type: AppButtonType.primary,
                              onPressed: () {
                                if (selectedLokasi != null) {
                                  widget.bloc.add(
                                    UpdateItemLocation(
                                      sn: item.serialNumber,
                                      idProductLokasi: selectedLokasi!.idProductLokasi,
                                      idGudang: selectedGudang?.idGudang ?? selectedLokasi!.idGudang,
                                      transactionId: _currentTransaction.id,
                                    ),
                                  );
                                  Navigator.pop(modalCtx);
                                } else {
                                  AppSnackBar.showError(modalCtx, 'Pilih lokasi rak tujuan terlebih dahulu.');
                                }
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
    final isDark = context.isDarkMode;
    const greenColor = Color(0xFF2E7D32);
    final isInbound = _currentTransaction.type == TransactionType.inbound;
    final accentColor = isInbound ? greenColor : colorScheme.primary;
    final isCompleted = _currentTransaction.status == TransactionStatus.completed;

    return StreamBuilder<TransactionState>(
      stream: widget.bloc.stream,
      initialData: widget.bloc.state,
      builder: (context, snapshot) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              isInbound ? 'Detail Penerimaan Inbound' : 'Detail Pengiriman Outbound',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined),
                tooltip: 'Bagikan Dokumen',
                onPressed: () {
                  AppSnackBar.showInfo(context, 'Mengekspor data transaksi ${_currentTransaction.id}');
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kartu Ringkasan Status & Dokumen
                AppCard(
                  padding: const EdgeInsets.all(16),
                  elevation: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _currentTransaction.type.shortLabel.toUpperCase(),
                              style: TextStyle(
                                color: accentColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          AppStatusBadge(
                            status: _currentTransaction.status.label,
                            color: isCompleted ? greenColor : const Color(0xFFED6C02),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _currentTransaction.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(height: 24),

                      // Metadata Tabel Baru (t_transaksi_gudang)
                      if (_currentTransaction.nmGudang != null)
                        _DetailRow(
                          icon: Icons.warehouse_outlined,
                          label: 'Gudang (m_gudang)',
                          value: _currentTransaction.nmGudang!,
                        ),
                      if (isInbound && _currentTransaction.nmSupplier != null)
                        _DetailRow(
                          icon: Icons.business_outlined,
                          label: 'Supplier (m_supplier)',
                          value: _currentTransaction.nmSupplier!,
                        ),
                      if (!isInbound && _currentTransaction.codeDo != null)
                        _DetailRow(
                          icon: Icons.assignment_outlined,
                          label: 'Delivery Order (tb_do_hdr)',
                          value: _currentTransaction.codeDo!,
                        ),
                      _DetailRow(
                        icon: isInbound ? Icons.inventory_2_outlined : Icons.description_outlined,
                        label: _currentTransaction.type.refLabel,
                        value: _currentTransaction.referenceNumber,
                      ),
                      _DetailRow(
                        icon: isInbound ? Icons.business_outlined : Icons.store_mall_directory_outlined,
                        label: _currentTransaction.type.partnerLabel,
                        value: _currentTransaction.partnerName,
                      ),
                      if (_currentTransaction.vehicleOrContainerId.isNotEmpty)
                        _DetailRow(
                          icon: isInbound ? Icons.lock_outline : Icons.local_shipping_outlined,
                          label: _currentTransaction.type.vehicleLabel,
                          value: _currentTransaction.vehicleOrContainerId,
                        ),
                      if (_currentTransaction.operatorName != null)
                        _DetailRow(
                          icon: Icons.person_outline,
                          label: 'Petugas / Operator',
                          value: _currentTransaction.operatorName!,
                        ),
                      _DetailRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Tanggal Dibuat',
                        value:
                            '${_currentTransaction.createdAt.day}/${_currentTransaction.createdAt.month}/${_currentTransaction.createdAt.year} ${_currentTransaction.createdAt.hour.toString().padLeft(2, '0')}:${_currentTransaction.createdAt.minute.toString().padLeft(2, '0')} WIB',
                      ),
                      if (_currentTransaction.notes != null)
                        _DetailRow(
                          icon: Icons.notes_outlined,
                          label: 'Catatan Lapangan',
                          value: _currentTransaction.notes!,
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Kartu Progress Scanning
                AppCard(
                  padding: const EdgeInsets.all(16),
                  elevation: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Progres Verifikasi Fisik Mesin',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${_currentTransaction.scannedQuantity} / ${_currentTransaction.targetQuantity} Unit',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _currentTransaction.isFullyScanned ? greenColor : accentColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: _currentTransaction.progress,
                          minHeight: 8,
                          backgroundColor: colorScheme.outline.withValues(alpha: 0.15),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _currentTransaction.isFullyScanned ? greenColor : accentColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _currentTransaction.isFullyScanned
                            ? 'Semua unit telah terverifikasi secara akurat.'
                            : 'Masih tersisa ${_currentTransaction.targetQuantity - _currentTransaction.scannedQuantity} unit mesin yang harus dipindai.',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Daftar Mesin Terverifikasi
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Daftar Unit Mesin (${_currentTransaction.items.length})',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (!isCompleted)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton.icon(
                            icon: const Icon(Icons.playlist_add, size: 16),
                            label: const Text('Pilih SN'),
                            onPressed: () => _showAddSnModal(context),
                          ),
                          const SizedBox(width: 4),
                          TextButton.icon(
                            icon: const Icon(Icons.qr_code_scanner, size: 16),
                            label: const Text('Buka Scanner'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ScannerPage(
                                    transaction: _currentTransaction,
                                    bloc: widget.bloc,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                if (_currentTransaction.items.isEmpty)
                  const AppEmptyState(
                    title: 'Belum Ada Mesin Terverifikasi',
                    message: 'Klik "Buka Scanner" untuk mulai memindai barcode mesin.',
                    icon: Icons.barcode_reader,
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _currentTransaction.items.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final item = _currentTransaction.items[index];
                      return MachineItemTile(
                        item: item,
                        index: index + 1,
                        onTap: () => _showItemDetailDialog(context, item),
                        onRelocate: isCompleted ? null : () => _showRelocateModal(context, item),
                      );
                    },
                  ),
                const SizedBox(height: 32),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: AppButton(
                    text: isCompleted ? 'Scan Ditutup' : 'Buka Scanner',
                    icon: Icons.qr_code_scanner,
                    type: isCompleted ? AppButtonType.outlined : AppButtonType.primary,
                    backgroundColor: accentColor,
                    onPressed: isCompleted
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ScannerPage(
                                  transaction: _currentTransaction,
                                  bloc: widget.bloc,
                                ),
                              ),
                            );
                          },
                  ),
                ),
                if (!isCompleted) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: 'Selesaikan',
                      icon: Icons.check_circle_outline,
                      type: AppButtonType.outlined,
                      foregroundColor: greenColor,
                      onPressed: () async {
                        final confirmed = await AppConfirmationDialog.show(
                          context,
                          title: 'Selesaikan Transaksi?',
                          message:
                              'Tandai transaksi ${_currentTransaction.referenceNumber} selesai terverifikasi.',
                          confirmText: 'Selesai',
                        );
                        if (confirmed == true && context.mounted) {
                          widget.bloc.add(
                            SubmitCompleteTransaction(_currentTransaction.id),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: colorScheme.outline),
          const SizedBox(width: 10),
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                color: colorScheme.outline,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
