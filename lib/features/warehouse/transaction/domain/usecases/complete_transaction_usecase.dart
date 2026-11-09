import '../entities/warehouse_transaction.dart';
import '../repositories/transaction_repository.dart';

class CompleteTransactionUseCase {
  const CompleteTransactionUseCase(this.repository);

  final TransactionRepository repository;

  Future<WarehouseTransaction> call(String transactionId) {
    return repository.completeTransaction(transactionId);
  }
}

