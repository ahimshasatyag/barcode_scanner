import 'dart:async';
import 'package:flutter/material.dart';
import 'package:barcode/shared/theme/theme.dart';
import 'package:barcode/shared/widgets/widgets.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../domain/entities/warehouse_transaction.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';
import '../bloc/transaction_state.dart';
import '../widgets/transaction_card.dart';
import 'scanner_page.dart';
import 'transaction_detail_page.dart';

class TransactionListPage extends StatefulWidget {
  const TransactionListPage({
    super.key,
    this.bloc,
  });

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
    _bloc = widget.bloc ?? TransactionBloc(repository: TransactionRepositoryImpl());

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

  void _openScannerForType(BuildContext context, TransactionType type, List<WarehouseTransaction> list) {
    // Cari transaksi aktif bertipe ini
    final active = list.where((t) => t.type == type && t.status != TransactionStatus.completed).toList();
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
        builder: (_) => ScannerPage(
          transaction: trx,
          bloc: _bloc,
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, WarehouseTransaction trx) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionDetailPage(
          transaction: trx,
          bloc: _bloc,
        ),
      ),
    );
  }

  void _showCreateTransactionSheet(BuildContext context) {
    final titleController = TextEditingController();
    final refController = TextEditingController();
    final partnerController = TextEditingController();
    final vehicleController = TextEditingController();
    final targetController = TextEditingController(text: '3');
    TransactionType selectedType = TransactionType.inbound;

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

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(modalContext).viewInsets.bottom,
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
                            'Buat Transaksi Warehouse',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(modalContext),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Pilihan Jenis Transaksi
                      Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: const Text('Inbound (Kontainer Masuk)'),
                              selected: isInbound,
                              selectedColor: greenColor.withValues(alpha: 0.2),
                              labelStyle: TextStyle(
                                color: isInbound ? greenColor : null,
                                fontWeight: isInbound ? FontWeight.bold : null,
                              ),
                              onSelected: (val) {
                                if (val) setModalState(() => selectedType = TransactionType.inbound);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ChoiceChip(
                              label: const Text('Outbound (Muat Truk)'),
                              selected: !isInbound,
                              selectedColor: colorScheme.primary.withValues(alpha: 0.2),
                              labelStyle: TextStyle(
                                color: !isInbound ? colorScheme.primary : null,
                                fontWeight: !isInbound ? FontWeight.bold : null,
                              ),
                              onSelected: (val) {
                                if (val) setModalState(() => selectedType = TransactionType.outbound);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      AppTextField(
                        label: 'Judul Transaksi',
                        hintText: isInbound
                            ? 'Contoh: Kontainer 40ft Impor CNC Milling Kobe'
                            : 'Contoh: Pengiriman Truk Wingbox ke PT Astra',
                        controller: titleController,
                        prefixIcon: const Icon(Icons.title),
                      ),
                      const SizedBox(height: 12),

                      AppTextField(
                        label: isInbound ? 'Nomor Kontainer / B/L' : 'Nomor Surat Jalan / DO',
                        hintText: isInbound ? 'Contoh: TGHU-992384-1' : 'Contoh: SJ-EMM-2026/XI/881',
                        controller: refController,
                        prefixIcon: const Icon(Icons.description_outlined),
                      ),
                      const SizedBox(height: 12),

                      AppTextField(
                        label: isInbound ? 'Supplier / Eksportir' : 'Klien / Perusahaan Tujuan',
                        hintText: isInbound ? 'Contoh: Yamazaki Mazak Corp Japan' : 'Contoh: PT Astra Honda Motor',
                        controller: partnerController,
                        prefixIcon: const Icon(Icons.business),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: AppTextField(
                              label: isInbound ? 'No. Seal Kontainer' : 'No. Polisi Truk',
                              hintText: isInbound ? 'SEAL-JP-901' : 'B 9482 TXT',
                              controller: vehicleController,
                              prefixIcon: Icon(isInbound ? Icons.lock_outline : Icons.local_shipping),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 1,
                            child: AppTextField(
                              label: 'Target Unit',
                              hintText: 'Jumlah',
                              controller: targetController,
                              keyboardType: TextInputType.number,
                              prefixIcon: const Icon(Icons.pin),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

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
                              text: 'Simpan & Buka Scan',
                              type: AppButtonType.primary,
                              backgroundColor: isInbound ? greenColor : colorScheme.primary,
                              onPressed: () {
                                final title = titleController.text.trim().isEmpty
                                    ? (isInbound ? 'Penerimaan Kontainer Impor' : 'Pengiriman Truk Klien')
                                    : titleController.text.trim();
                                final ref = refController.text.trim().isEmpty
                                    ? 'REF-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}'
                                    : refController.text.trim();
                                final partner = partnerController.text.trim().isEmpty
                                    ? (isInbound ? 'Supplier Luar Negeri' : 'Klien Manufaktur')
                                    : partnerController.text.trim();
                                final target = int.tryParse(targetController.text.trim()) ?? 3;

                                final newTrx = WarehouseTransaction(
                                  id: 'TRX-${isInbound ? 'INB' : 'OUT'}-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}',
                                  type: selectedType,
                                  title: title,
                                  referenceNumber: ref,
                                  partnerName: partner,
                                  vehicleOrContainerId: vehicleController.text.trim(),
                                  createdAt: DateTime.now(),
                                  targetQuantity: target,
                                  status: TransactionStatus.inProgress,
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

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Buat Transaksi'),
        onPressed: () => _showCreateTransactionSheet(context),
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

          final inboundCount = transactions.where((t) => t.type == TransactionType.inbound).length;
          final outboundCount = transactions.where((t) => t.type == TransactionType.outbound).length;

          return RefreshIndicator(
            color: colorScheme.primary,
            onRefresh: () async {
              _bloc.add(const LoadTransactions());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kartu Ringkasan Operasional
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          title: 'Inbound Mesin Impor',
                          value: '$inboundCount Kontainer',
                          subtitle: 'Penerimaan Luar Negeri',
                          icon: Icons.archive_outlined,
                          iconColor: greenColor,
                          bgColor: greenColor.withValues(alpha: 0.12),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          title: 'Outbound Muat Truk',
                          value: '$outboundCount Armada',
                          subtitle: 'Pengiriman Truk Klien',
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
                    'Aksi Cepat Scanner Transaksi',
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
                          sublabel: 'Kontainer Mesin Impor',
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
                          sublabel: 'Pemuatan Truk Klien',
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
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final trx = filteredList[index];
                        return TransactionCard(
                          transaction: trx,
                          onOpenScanner: () => _navigateToScanner(context, trx),
                          onTapDetail: () => _navigateToDetail(context, trx),
                        );
                      },
                    ),
                  const SizedBox(height: 60),
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
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 11,
              color: colorScheme.outline,
            ),
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
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
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
