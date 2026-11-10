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

/// Memindai barcode mesin pada transaksi aktif langsung ke database backend
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

/// Membuat transaksi baru (registrasi SN baru atau mutasi baru)
class CreateNewTransaction extends TransactionEvent {
  const CreateNewTransaction(this.transaction);
  final WarehouseTransaction transaction;
}

/// Pindah Lokasi Barang di Database Backend via ProductSnController.php
class UpdateItemLocation extends TransactionEvent {
  const UpdateItemLocation({
    required this.sn,
    required this.idProductLokasi,
    this.idGudang,
    required this.transactionId,
  });

  final String sn;
  final int idProductLokasi;
  final int? idGudang;
  final String transactionId;
}

/// Mereset notifikasi/status scan sesaat
class ResetScanResultState extends TransactionEvent {
  const ResetScanResultState();
}
