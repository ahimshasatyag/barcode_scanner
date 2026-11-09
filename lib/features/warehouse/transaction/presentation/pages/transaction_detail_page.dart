import 'dart:async';
import 'package:flutter/material.dart';
import 'package:barcode/shared/theme/theme.dart';
import 'package:barcode/shared/widgets/widgets.dart';
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

                      // Metadata Tabel
                      _DetailRow(
                        icon: isInbound ? Icons.inventory_2_outlined : Icons.description_outlined,
                        label: _currentTransaction.type.refLabel,
                        value: _currentTransaction.referenceNumber,
                      ),
                      _DetailRow(
                        icon: Icons.business_outlined,
                        label: _currentTransaction.type.partnerLabel,
                        value: _currentTransaction.partnerName,
                      ),
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
                        onTap: () {
                          AppConfirmationDialog.show(
                            context,
                            title: '${item.brand} ${item.modelName}',
                            message:
                                'Nomor Seri: ${item.serialNumber}\nBarcode: ${item.barcode}\nAsal: ${item.countryOfOrigin ?? '-'}\nBerat: ${item.weightKg ?? '-'} Kg\nSpesifikasi: ${item.specification ?? '-'}\nWaktu Scan: ${item.scannedAt ?? '-'}',
                            confirmText: 'Tutup',
                          );
                        },
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
