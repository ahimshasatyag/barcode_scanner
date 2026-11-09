import '../../domain/entities/machine_item.dart';
import '../../domain/entities/scan_result.dart';
import '../../domain/entities/warehouse_transaction.dart';

abstract class TransactionState {
  const TransactionState();
}

class TransactionInitial extends TransactionState {
  const TransactionInitial();
}

class TransactionLoading extends TransactionState {
  const TransactionLoading();
}

class TransactionLoaded extends TransactionState {
  const TransactionLoaded({
    required this.transactions,
    this.selectedTransaction,
    this.typeFilter,
    this.latestScanResult,
  });

  final List<WarehouseTransaction> transactions;
  final WarehouseTransaction? selectedTransaction;
  final TransactionType? typeFilter;
  final ScanResult? latestScanResult;

  int get totalInbound =>
      transactions.where((t) => t.type == TransactionType.inbound).length;

  int get totalOutbound =>
      transactions.where((t) => t.type == TransactionType.outbound).length;

  int get totalActive =>
      transactions.where((t) => t.status != TransactionStatus.completed).length;

  TransactionLoaded copyWith({
    List<WarehouseTransaction>? transactions,
    WarehouseTransaction? selectedTransaction,
    TransactionType? typeFilter,
    ScanResult? latestScanResult,
    bool clearSelectedTransaction = false,
    bool clearScanResult = false,
  }) {
    return TransactionLoaded(
      transactions: transactions ?? this.transactions,
      selectedTransaction: clearSelectedTransaction
          ? null
          : (selectedTransaction ?? this.selectedTransaction),
      typeFilter: typeFilter ?? this.typeFilter,
      latestScanResult:
          clearScanResult ? null : (latestScanResult ?? this.latestScanResult),
    );
  }
}

class TransactionScanSuccess extends TransactionState {
  const TransactionScanSuccess({
    required this.scannedItem,
    required this.transaction,
    required this.message,
  });

  final MachineItem scannedItem;
  final WarehouseTransaction transaction;
  final String message;
}

class TransactionScanFailure extends TransactionState {
  const TransactionScanFailure({
    required this.message,
    required this.rawBarcode,
    this.isDuplicate = false,
  });

  final String message;
  final String rawBarcode;
  final bool isDuplicate;
}

class TransactionActionSuccess extends TransactionState {
  const TransactionActionSuccess({
    required this.message,
    this.transaction,
  });

  final String message;
  final WarehouseTransaction? transaction;
}

class TransactionError extends TransactionState {
  const TransactionError(this.message);
  final String message;
}

