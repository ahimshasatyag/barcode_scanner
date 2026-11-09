import '../../domain/entities/scan_result.dart';
import '../../domain/entities/warehouse_transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_remote_data_source.dart';
import '../models/warehouse_transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl({TransactionRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? TransactionRemoteDataSourceImpl();

  final TransactionRemoteDataSource _remoteDataSource;

  @override
  Future<List<WarehouseTransaction>> getTransactions({TransactionType? type}) async {
    return _remoteDataSource.getTransactions(type: type);
  }

  @override
  Future<WarehouseTransaction> getTransactionById(String id) async {
    return _remoteDataSource.getTransactionById(id);
  }

  @override
  Future<ScanResult> verifyAndProcessScan({
    required String transactionId,
    required String rawBarcode,
  }) async {
    return _remoteDataSource.verifyAndProcessScan(
      transactionId: transactionId,
      rawBarcode: rawBarcode,
    );
  }

  @override
  Future<WarehouseTransaction> completeTransaction(String transactionId) async {
    return _remoteDataSource.completeTransaction(transactionId);
  }

  @override
  Future<WarehouseTransaction> createTransaction(WarehouseTransaction transaction) async {
    final model = WarehouseTransactionModel.fromEntity(transaction);
    return _remoteDataSource.createTransaction(model);
  }

  @override
  Future<WarehouseTransaction> removeScannedItem({
    required String transactionId,
    required String serialNumber,
  }) async {
    return _remoteDataSource.removeScannedItem(
      transactionId: transactionId,
      serialNumber: serialNumber,
    );
  }
}
