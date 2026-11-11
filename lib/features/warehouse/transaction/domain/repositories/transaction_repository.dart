import '../entities/scan_result.dart';
import '../entities/warehouse_transaction.dart';
import '../../data/models/do_hdr_model.dart';
import '../../data/models/gudang_model.dart';
import '../../data/models/machine_item_model.dart';
import '../../data/models/product_lokasi_model.dart';
import '../../data/models/supplier_model.dart';

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

  // =========================================================================
  // Integrasi Database Backend (m_gudang, m_product_lokasi, m_product_sn, m_suppliers, tb_do_hdr)
  // =========================================================================
  Future<List<GudangModel>> getGudangList();
  Future<List<ProductLokasiModel>> getProductLokasiList({int? idGudang});
  Future<List<SupplierModel>> getSupplierList();
  Future<List<DoHdrModel>> getDoList();
  Future<List<MachineItemModel>> getProductSnList({
    int? idGudang,
    int? idProductLokasi,
    String? search,
  });
  Future<Map<String, dynamic>> updateProductLocation({
    required String sn,
    required int idProductLokasi,
    int? idGudang,
  });
}
