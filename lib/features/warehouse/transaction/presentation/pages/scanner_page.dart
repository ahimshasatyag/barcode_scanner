import 'dart:async';
import 'package:flutter/material.dart';
import 'package:barcode/shared/theme/theme.dart';
import 'package:barcode/shared/widgets/widgets.dart';
import '../../data/models/machine_item_model.dart';
import '../../domain/entities/warehouse_transaction.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';
import '../widgets/camera_scanner_view.dart';
import '../widgets/machine_item_tile.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({
    super.key,
    required this.transaction,
    required this.bloc,
  });

  final WarehouseTransaction transaction;
  final TransactionBloc bloc;

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  late WarehouseTransaction _currentTransaction;
  StreamSubscription<TransactionState>? _blocSubscription;
  List<MachineItemModel> _availableSns = [];
  MachineItemModel? _selectedDropdownSn;

  @override
  void initState() {
    super.initState();
    _currentTransaction = widget.transaction;
    _loadProductSns();

    _blocSubscription = widget.bloc.stream.listen((state) {
      if (!mounted) return;

      if (state is TransactionScanSuccess) {
        AppSnackBar.showSuccess(
          context,
          'Terverifikasi: ${state.message}',
        );
      } else if (state is TransactionScanFailure) {
        if (state.isDuplicate) {
          AppSnackBar.showWarning(context, state.message);
        } else {
          AppSnackBar.showError(context, state.message);
        }
      } else if (state is TransactionActionSuccess) {
        AppSnackBar.showSuccess(context, state.message);
        if (state.transaction != null &&
            state.transaction!.status == TransactionStatus.completed) {
          Navigator.pop(context);
        }
      } else if (state is TransactionError) {
        AppSnackBar.showError(context, state.message);
      }

      if (state is TransactionLoaded && state.selectedTransaction != null) {
        setState(() {
          _currentTransaction = state.selectedTransaction!;
        });
      }
    });
  }

  Future<void> _loadProductSns() async {
    try {
      final list = await widget.bloc.repository.getProductSnList(
        idGudang: _currentTransaction.idGudang,
      );
      if (mounted) {
        setState(() {
          _availableSns = list;
          if (list.isNotEmpty && _selectedDropdownSn == null) {
            _selectedDropdownSn = list.first;
          }
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _blocSubscription?.cancel();
    super.dispose();
  }

  void _onBarcodeScanned(String barcode) {
    widget.bloc.add(
      ScanMachineBarcode(
        transactionId: _currentTransaction.id,
        barcode: barcode,
      ),
    );
  }

  Future<void> _confirmCompleteTransaction() async {
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: 'Selesaikan Transaksi?',
      message:
          'Semua mesin yang dipindai (${_currentTransaction.scannedQuantity}/${_currentTransaction.targetQuantity} unit) akan diverifikasi dan dokumen transaksi ditutup.',
      confirmText: 'Ya, Selesaikan',
      cancelText: 'Kembali',
    );
    if (confirmed == true && mounted) {
      widget.bloc.add(
        SubmitCompleteTransaction(_currentTransaction.id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = context.isDarkMode;
    final isInbound = _currentTransaction.type == TransactionType.inbound;
    const greenColor = Color(0xFF2E7D32);
    final accentColor = isInbound ? greenColor : colorScheme.primary;

    return StreamBuilder<TransactionState>(
      stream: widget.bloc.stream,
      initialData: widget.bloc.state,
      builder: (context, snapshot) {
        final items = _currentTransaction.items;
        final isCompleted = _currentTransaction.status == TransactionStatus.completed;

        // Deduplikasi nomor seri dari database backend agar DropdownMenuItem memiliki value unik
        final uniqueSns = <String, MachineItemModel>{};
        for (final s in _availableSns) {
          if (s.serialNumber.trim().isNotEmpty) {
            uniqueSns.putIfAbsent(s.serialNumber.trim().toUpperCase(), () => s);
          }
        }
        final deduplicatedSns = uniqueSns.values.toList();

        final effectiveDropdownSn = deduplicatedSns.any((s) => s.serialNumber.trim().toUpperCase() == _selectedDropdownSn?.serialNumber.trim().toUpperCase())
            ? deduplicatedSns.firstWhere((s) => s.serialNumber.trim().toUpperCase() == _selectedDropdownSn?.serialNumber.trim().toUpperCase())
            : (deduplicatedSns.isNotEmpty ? deduplicatedSns.first : null);

        final quickBarcodes = deduplicatedSns.map((s) => {
          'code': s.serialNumber,
          'label': '${s.brand} • ${s.serialNumber.length > 12 ? s.serialNumber.substring(s.serialNumber.length - 7) : s.serialNumber}',
        }).toList();

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isInbound ? 'Scanner Penerimaan Inbound' : 'Scanner Pemuatan Outbound',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${_currentTransaction.type.refLabel}: ${_currentTransaction.referenceNumber}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 14),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: accentColor.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _currentTransaction.isFullyScanned
                          ? Icons.check_circle
                          : Icons.hourglass_top_rounded,
                      size: 14,
                      color: accentColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_currentTransaction.scannedQuantity}/${_currentTransaction.targetQuantity} Unit',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Column(
              children: [
                // Info Relasi Database (m_gudang, m_supplier / tb_do_hdr)
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 6, 16, 2),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF262626) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colorScheme.outline.withValues(alpha: 0.15)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warehouse_outlined, size: 15, color: accentColor),
                      const SizedBox(width: 5),
                      Text(
                        _currentTransaction.nmGudang ?? 'Gudang (m_gudang)',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Icon(
                        isInbound ? Icons.business_outlined : Icons.description_outlined,
                        size: 14,
                        color: colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isInbound
                            ? (_currentTransaction.nmSupplier ?? _currentTransaction.partnerName)
                            : (_currentTransaction.codeDo ?? _currentTransaction.referenceNumber),
                        style: TextStyle(fontSize: 12, color: colorScheme.outline, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Dropdown Nomor Seri Database (m_product_sn)
                if (deduplicatedSns.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.qr_code_2, size: 20, color: accentColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<MachineItemModel>(
                              value: effectiveDropdownSn,
                              hint: Text(
                                'Pilih Nomor Seri (m_product_sn)',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: accentColor,
                                ),
                              ),
                              isExpanded: true,
                              items: deduplicatedSns.map((sn) {
                                final isAlready = items.any((i) => i.serialNumber == sn.serialNumber);
                                return DropdownMenuItem<MachineItemModel>(
                                  value: sn,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '${sn.serialNumber} • ${sn.modelName}',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: isAlready ? FontWeight.normal : FontWeight.bold,
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
                              onChanged: isCompleted
                                  ? null
                                  : (sn) {
                                      if (sn != null) {
                                        setState(() => _selectedDropdownSn = sn);
                                        _onBarcodeScanned(sn.serialNumber);
                                      }
                                    },
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.add_task, size: 18, color: accentColor),
                          tooltip: 'Scan Nomor Seri Terpilih',
                          onPressed: isCompleted || _selectedDropdownSn == null
                              ? null
                              : () => _onBarcodeScanned(_selectedDropdownSn!.serialNumber),
                        ),
                      ],
                    ),
                  ),

                // Komponen Kamera Scanner Viewfinder
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 4.0, 16.0, 4.0),
                  child: SizedBox(
                    height: 290,
                    child: CameraScannerView(
                      isScanningPaused: isCompleted,
                      scannedBarcodes: items.map((e) => e.barcode).toList(),
                      customQuickBarcodes: quickBarcodes.isNotEmpty ? quickBarcodes : null,
                      title: isInbound
                          ? 'Arahkan ke Barcode / Serial Number (Inbound)'
                          : 'Arahkan ke Barcode / Serial Number (Outbound)',
                      subtitle:
                          '${_currentTransaction.title} • ${_currentTransaction.referenceNumber}',
                      onBarcodeScanned: _onBarcodeScanned,
                    ),
                  ),
                ),

                // Header Daftar Mesin Terpindai
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Daftar Barang Terverifikasi (${items.length})',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (_currentTransaction.isFullyScanned)
                        const Row(
                          children: [
                            Icon(Icons.check_circle, size: 16, color: greenColor),
                            SizedBox(width: 4),
                            Text(
                              'Target Lengkap',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: greenColor,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),

                // List Mesin Terpindai
                Expanded(
                  child: items.isEmpty
                      ? const Center(
                          child: AppEmptyState(
                            title: 'Belum Ada Barang Terpindai',
                            message:
                                'Arahkan kamera ke barcode serial number atau pilih dari dropdown nomor seri (m_product_sn) di atas.',
                            icon: Icons.qr_code_scanner,
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: items.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final item = items[items.length - 1 - index];
                            return MachineItemTile(
                              item: item,
                              index: items.length - index,
                              onTap: () {
                                AppConfirmationDialog.show(
                                  context,
                                  title: item.modelName,
                                  message:
                                      'Serial Number: ${item.serialNumber}\nGudang: ${item.nmGudang ?? "-"}\nLokasi: ${item.completeName ?? item.nmProductLokasi ?? "-"}\nJumlah: ${item.nqty} Unit\nWaktu Scan: ${item.scannedAt ?? "-"}',
                                  confirmText: 'Tutup',
                                );
                              },
                              onDelete: isCompleted
                                  ? null
                                  : () {
                                      widget.bloc.add(
                                        RemoveMachineItem(
                                          transactionId: _currentTransaction.id,
                                          serialNumber: item.serialNumber,
                                        ),
                                      );
                                    },
                            );
                          },
                        ),
                ),

                // Bottom Action Bar: Selesaikan Transaksi
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, -3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Status Kelengkapan',
                              style: TextStyle(
                                fontSize: 11,
                                color: colorScheme.outline,
                              ),
                            ),
                            Text(
                              '${_currentTransaction.scannedQuantity} dari ${_currentTransaction.targetQuantity} Mesin (${_currentTransaction.progressPercent}%)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _currentTransaction.isFullyScanned
                                    ? greenColor
                                    : colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      AppButton(
                        text: isCompleted ? 'Transaksi Selesai' : 'Selesaikan Transaksi',
                        icon: isCompleted ? Icons.check : Icons.assignment_turned_in,
                        type: AppButtonType.primary,
                        backgroundColor: _currentTransaction.isFullyScanned
                            ? greenColor
                            : colorScheme.primary,
                        onPressed: isCompleted
                            ? null
                            : _confirmCompleteTransaction,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
