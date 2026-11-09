import 'package:flutter/material.dart';
import '../../../warehouse/transaction/transaction.dart';

/// Halaman Transaksi Warehouse (Inbound Kontainer Impor & Outbound Muat Truk Klien)
/// Menghubungkan langsung ke TransactionListPage Clean Architecture
class TransaksiPage extends StatelessWidget {
  const TransaksiPage({
    super.key,
    this.transactionBloc,
  });

  final TransactionBloc? transactionBloc;

  @override
  Widget build(BuildContext context) {
    return TransactionListPage(
      bloc: transactionBloc,
    );
  }
}
