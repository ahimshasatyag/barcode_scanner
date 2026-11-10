import 'dart:async';

import '../../domain/entities/warehouse_transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/usecases/complete_transaction_usecase.dart';
import '../../domain/usecases/create_transaction_usecase.dart';
import '../../domain/usecases/get_transactions_usecase.dart';
import '../../domain/usecases/process_machine_scan_usecase.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc {
  TransactionBloc({
    required this.repository,
    GetTransactionsUseCase? getTransactionsUseCase,
    ProcessMachineScanUseCase? processMachineScanUseCase,
    CreateTransactionUseCase? createTransactionUseCase,
    CompleteTransactionUseCase? completeTransactionUseCase,
  }) : _getTransactionsUseCase =
           getTransactionsUseCase ?? GetTransactionsUseCase(repository),
       _processMachineScanUseCase =
           processMachineScanUseCase ?? ProcessMachineScanUseCase(repository),
       _createTransactionUseCase =
           createTransactionUseCase ?? CreateTransactionUseCase(repository),
       _completeTransactionUseCase =
           completeTransactionUseCase ??
           CompleteTransactionUseCase(repository) {
    _eventSubscription = _eventController.stream.listen(_mapEventToState);
  }

  final TransactionRepository repository;
  final GetTransactionsUseCase _getTransactionsUseCase;
  final ProcessMachineScanUseCase _processMachineScanUseCase;
  final CreateTransactionUseCase _createTransactionUseCase;
  final CompleteTransactionUseCase _completeTransactionUseCase;

  TransactionState _state = const TransactionInitial();
  late final StreamSubscription<TransactionEvent> _eventSubscription;

  final _eventController = StreamController<TransactionEvent>();
  final _stateController = StreamController<TransactionState>.broadcast();

  TransactionState get state => _state;
  Stream<TransactionState> get stream => _stateController.stream;

  void add(TransactionEvent event) {
    if (!_eventController.isClosed) {
      _eventController.add(event);
    }
  }

  void _emit(TransactionState newState) {
    _state = newState;
    if (!_stateController.isClosed) {
      _stateController.add(newState);
    }
  }

  Future<void> _mapEventToState(TransactionEvent event) async {
    switch (event) {
      case LoadTransactions(:final typeFilter):
        await _onLoadTransactions(typeFilter);
        break;
      case SelectTransaction(:final transactionId):
        await _onSelectTransaction(transactionId);
        break;
      case ScanMachineBarcode(:final transactionId, :final barcode):
        await _onScanMachineBarcode(transactionId, barcode);
        break;
      case SubmitCompleteTransaction(:final transactionId):
        await _onSubmitCompleteTransaction(transactionId);
        break;
      case RemoveMachineItem(:final transactionId, :final serialNumber):
        await _onRemoveMachineItem(transactionId, serialNumber);
        break;
      case CreateNewTransaction(:final transaction):
        await _onCreateNewTransaction(transaction);
        break;
      case UpdateItemLocation(:final sn, :final idProductLokasi, :final idGudang, :final transactionId):
        await _onUpdateItemLocation(sn, idProductLokasi, idGudang, transactionId);
        break;
      case ResetScanResultState():
        if (_state is TransactionLoaded) {
          final loaded = _state as TransactionLoaded;
          _emit(loaded.copyWith(clearScanResult: true));
        }
        break;
    }
  }

  Future<void> _onLoadTransactions(TransactionType? typeFilter) async {
    _emit(const TransactionLoading());
    try {
      final transactions = await _getTransactionsUseCase(type: typeFilter);
      _emit(
        TransactionLoaded(transactions: transactions, typeFilter: typeFilter),
      );
    } catch (e) {
      _emit(TransactionError('Gagal memuat transaksi: ${e.toString()}'));
    }
  }

  Future<void> _onSelectTransaction(String transactionId) async {
    final currentState = _state;
    if (currentState is TransactionLoaded) {
      try {
        final transaction = await repository.getTransactionById(transactionId);
        _emit(
          currentState.copyWith(
            selectedTransaction: transaction,
            clearScanResult: true,
          ),
        );
      } catch (e) {
        _emit(TransactionError('Gagal membuka transaksi: ${e.toString()}'));
      }
    } else {
      try {
        final transaction = await repository.getTransactionById(transactionId);
        final all = await _getTransactionsUseCase();
        _emit(
          TransactionLoaded(
            transactions: all,
            selectedTransaction: transaction,
          ),
        );
      } catch (e) {
        _emit(TransactionError('Gagal membuka transaksi: ${e.toString()}'));
      }
    }
  }

  Future<void> _onScanMachineBarcode(
    String transactionId,
    String barcode,
  ) async {
    try {
      final result = await _processMachineScanUseCase(
        transactionId: transactionId,
        rawBarcode: barcode,
      );

      final updatedTrx = await repository.getTransactionById(transactionId);
      final allTrx = await _getTransactionsUseCase();

      if (result.isSuccess && result.machineItem != null) {
        _emit(
          TransactionScanSuccess(
            scannedItem: result.machineItem!,
            transaction: updatedTrx,
            message: result.message,
          ),
        );
      } else {
        _emit(
          TransactionScanFailure(
            message: result.message,
            rawBarcode: barcode,
            isDuplicate: result.isDuplicate,
          ),
        );
      }

      _emit(
        TransactionLoaded(
          transactions: allTrx,
          selectedTransaction: updatedTrx,
          latestScanResult: result,
        ),
      );
    } catch (e) {
      _emit(TransactionError('Gagal memproses pemindaian: ${e.toString()}'));
    }
  }

  Future<void> _onSubmitCompleteTransaction(String transactionId) async {
    try {
      final completed = await _completeTransactionUseCase(transactionId);
      final allTrx = await _getTransactionsUseCase();

      _emit(
        TransactionActionSuccess(
          message:
              'Transaksi ${completed.referenceNumber} berhasil diselesaikan!',
          transaction: completed,
        ),
      );

      _emit(
        TransactionLoaded(transactions: allTrx, selectedTransaction: completed),
      );
    } catch (e) {
      _emit(TransactionError('Gagal menyelesaikan transaksi: ${e.toString()}'));
    }
  }

  Future<void> _onRemoveMachineItem(
    String transactionId,
    String serialNumber,
  ) async {
    try {
      final updated = await repository.removeScannedItem(
        transactionId: transactionId,
        serialNumber: serialNumber,
      );
      final allTrx = await _getTransactionsUseCase();

      _emit(
        TransactionActionSuccess(
          message: 'Item $serialNumber berhasil dihapus dari daftar scan.',
          transaction: updated,
        ),
      );

      _emit(
        TransactionLoaded(transactions: allTrx, selectedTransaction: updated),
      );
    } catch (e) {
      _emit(TransactionError('Gagal menghapus item: ${e.toString()}'));
    }
  }

  Future<void> _onCreateNewTransaction(WarehouseTransaction transaction) async {
    try {
      final created = await _createTransactionUseCase(transaction);
      final allTrx = await _getTransactionsUseCase();

      _emit(
        TransactionActionSuccess(
          message: 'Transaksi baru ${created.referenceNumber} berhasil dibuat!',
          transaction: created,
        ),
      );

      _emit(
        TransactionLoaded(transactions: allTrx, selectedTransaction: created),
      );
    } catch (e) {
      _emit(TransactionError('Gagal membuat transaksi baru: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateItemLocation(
    String sn,
    int idProductLokasi,
    int? idGudang,
    String transactionId,
  ) async {
    try {
      final res = await repository.updateProductLocation(
        sn: sn,
        idProductLokasi: idProductLokasi,
        idGudang: idGudang,
      );
      final message = res['message']?.toString() ?? 'Lokasi barang berhasil dipindahkan.';
      final updatedTrx = await repository.getTransactionById(transactionId);
      final allTrx = await _getTransactionsUseCase();

      _emit(
        TransactionActionSuccess(
          message: message,
          transaction: updatedTrx,
        ),
      );

      _emit(
        TransactionLoaded(transactions: allTrx, selectedTransaction: updatedTrx),
      );
    } catch (e) {
      _emit(TransactionError('Gagal memindahkan lokasi: ${e.toString()}'));
    }
  }

  void close() {
    _eventSubscription.cancel();
    _eventController.close();
    _stateController.close();
  }
}
