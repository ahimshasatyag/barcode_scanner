import '../entities/scan_result.dart';
import '../entities/warehouse_transaction.dart';

/// Kontrak repositori transaksi warehouse
abstract class TransactionRepository {
  /// Mengambil daftar semua transaksi (dengan opsi filter tipe Inbound/Outbound)
  Future<List<WarehouseTransaction>> getTransactions({TransactionType? type});

  /// Mengambil detail satu transaksi berdasarkan ID
  Future<WarehouseTransaction> getTransactionById(String id);

  /// Memverifikasi dan memproses pemindaian barcode terhadap transaksi aktif
  Future<ScanResult> verifyAndProcessScan({
    required String transactionId,
    required String rawBarcode,
  });

  /// Menandai transaksi telah selesai dan memvalidasi kelengkapan fisik
  Future<WarehouseTransaction> completeTransaction(String transactionId);

  /// Membuat transaksi baru (misal kedatangan kontainer atau muat truk baru)
  Future<WarehouseTransaction> createTransaction(WarehouseTransaction transaction);

  /// Menghapus item mesin dari daftar transaksi (jika salah scan)
  Future<WarehouseTransaction> removeScannedItem({
    required String transactionId,
    required String serialNumber,
  });
}
