import '../entities/scan_result.dart';
import '../repositories/transaction_repository.dart';

class ProcessMachineScanUseCase {
  const ProcessMachineScanUseCase(this.repository);

  final TransactionRepository repository;

  Future<ScanResult> call({
    required String transactionId,
    required String rawBarcode,
  }) {
    return repository.verifyAndProcessScan(
      transactionId: transactionId,
      rawBarcode: rawBarcode,
    );
  }
}

