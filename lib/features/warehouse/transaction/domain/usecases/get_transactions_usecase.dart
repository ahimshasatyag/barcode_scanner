import '../entities/warehouse_transaction.dart';
import '../repositories/transaction_repository.dart';

class GetTransactionsUseCase {
  const GetTransactionsUseCase(this.repository);

  final TransactionRepository repository;

  Future<List<WarehouseTransaction>> call({TransactionType? type}) {
    return repository.getTransactions(type: type);
  }
}

