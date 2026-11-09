import '../entities/warehouse_transaction.dart';
import '../repositories/transaction_repository.dart';

class CreateTransactionUseCase {
  const CreateTransactionUseCase(this.repository);

  final TransactionRepository repository;

  Future<WarehouseTransaction> call(WarehouseTransaction transaction) {
    return repository.createTransaction(transaction);
  }
}

