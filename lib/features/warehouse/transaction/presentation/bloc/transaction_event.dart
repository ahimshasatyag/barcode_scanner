import '../../domain/entities/warehouse_transaction.dart';

abstract class TransactionEvent {
  const TransactionEvent();
}

/// Memuat daftar transaksi (dapat difilter per Inbound / Outbound / Semua)
class LoadTransactions extends TransactionEvent {
  const LoadTransactions({this.typeFilter});
  final TransactionType? typeFilter;
}

/// Memilih dan memuat detail satu transaksi
class SelectTransaction extends TransactionEvent {
  const SelectTransaction(this.transactionId);
  final String transactionId;
}

/// Memindai barcode mesin pada transaksi aktif
class ScanMachineBarcode extends TransactionEvent {
  const ScanMachineBarcode({
    required this.transactionId,
    required this.barcode,
  });

  final String transactionId;
  final String barcode;
}

/// Menyelesaikan seluruh transaksi pemindaian
class SubmitCompleteTransaction extends TransactionEvent {
  const SubmitCompleteTransaction(this.transactionId);
  final String transactionId;
}

/// Menghapus mesin dari daftar scan (koreksi scan)
class RemoveMachineItem extends TransactionEvent {
  const RemoveMachineItem({
    required this.transactionId,
    required this.serialNumber,
  });

  final String transactionId;
  final String serialNumber;
}

/// Membuat transaksi baru (kontainer baru atau truk baru)
class CreateNewTransaction extends TransactionEvent {
  const CreateNewTransaction(this.transaction);
  final WarehouseTransaction transaction;
}

/// Mereset notifikasi/status scan sesaat
class ResetScanResultState extends TransactionEvent {
  const ResetScanResultState();
}

