import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:barcode/features/warehouse/transaction/transaction.dart';
import 'package:barcode/shared/theme/theme.dart';

void main() {
  group('Warehouse Transaction Module Tests', () {
    late TransactionRemoteDataSource dataSource;
    late TransactionRepository repository;
    late GetTransactionsUseCase getTransactionsUseCase;
    late ProcessMachineScanUseCase processMachineScanUseCase;
    late CreateTransactionUseCase createTransactionUseCase;
    late CompleteTransactionUseCase completeTransactionUseCase;
    late TransactionBloc bloc;

    setUp(() {
      dataSource = TransactionRemoteDataSourceImpl();
      repository = TransactionRepositoryImpl(remoteDataSource: dataSource);
      getTransactionsUseCase = GetTransactionsUseCase(repository);
      processMachineScanUseCase = ProcessMachineScanUseCase(repository);
      createTransactionUseCase = CreateTransactionUseCase(repository);
      completeTransactionUseCase = CompleteTransactionUseCase(repository);

      bloc = TransactionBloc(
        repository: repository,
        getTransactionsUseCase: getTransactionsUseCase,
        processMachineScanUseCase: processMachineScanUseCase,
        createTransactionUseCase: createTransactionUseCase,
        completeTransactionUseCase: completeTransactionUseCase,
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('Data Source returns Inbound and Outbound mock transactions', () async {
      final all = await dataSource.getTransactions();
      expect(all.isNotEmpty, true);

      final inbounds = await dataSource.getTransactions(type: TransactionType.inbound);
      expect(inbounds.every((t) => t.type == TransactionType.inbound), true);

      final outbounds = await dataSource.getTransactions(type: TransactionType.outbound);
      expect(outbounds.every((t) => t.type == TransactionType.outbound), true);
    });

    test('Process scan succeeds for valid machine barcode and detects duplicate', () async {
      // Setup a fresh test transaction
      final testTrx = WarehouseTransaction(
        id: 'TEST-TRX-001',
        type: TransactionType.inbound,
        title: 'Uji Coba Kontainer Impor',
        referenceNumber: 'CONT-TEST-99',
        partnerName: 'Mazak Japan',
        vehicleOrContainerId: 'SEAL-TEST-01',
        createdAt: DateTime.now(),
        targetQuantity: 2,
        status: TransactionStatus.inProgress,
      );
      await repository.createTransaction(testTrx);

      // 1. First scan should succeed
      final scanResult1 = await repository.verifyAndProcessScan(
        transactionId: 'TEST-TRX-001',
        rawBarcode: 'BC-MZK-8501',
      );
      expect(scanResult1.isSuccess, true);
      expect(scanResult1.machineItem != null, true);
      expect(scanResult1.machineItem!.brand, 'Mazak');

      // 2. Second scan with same barcode should be flagged as duplicate
      final scanResultDuplicate = await repository.verifyAndProcessScan(
        transactionId: 'TEST-TRX-001',
        rawBarcode: 'BC-MZK-8501',
      );
      expect(scanResultDuplicate.isSuccess, false);
      expect(scanResultDuplicate.isDuplicate, true);

      // 3. Scan second machine to complete target
      final scanResult2 = await repository.verifyAndProcessScan(
        transactionId: 'TEST-TRX-001',
        rawBarcode: 'BC-OKM-3001',
      );
      expect(scanResult2.isSuccess, true);

      final updatedTrx = await repository.getTransactionById('TEST-TRX-001');
      expect(updatedTrx.items.length, 2);
      expect(updatedTrx.isFullyScanned, true);
      expect(updatedTrx.status, TransactionStatus.completed);
    });

    test('UseCases operate correctly through repository', () async {
      final transactions = await getTransactionsUseCase(type: TransactionType.outbound);
      expect(transactions.every((t) => t.type == TransactionType.outbound), true);

      final newTrx = WarehouseTransaction(
        id: 'TEST-OUT-002',
        type: TransactionType.outbound,
        title: 'Pemuatan Truk Test',
        referenceNumber: 'SJ-TEST-002',
        partnerName: 'PT Astra Test',
        vehicleOrContainerId: 'B 1234 TEST',
        createdAt: DateTime.now(),
        targetQuantity: 1,
      );
      final created = await createTransactionUseCase(newTrx);
      expect(created.id, 'TEST-OUT-002');

      final completed = await completeTransactionUseCase('TEST-OUT-002');
      expect(completed.status, TransactionStatus.completed);
    });

    testWidgets('TransactionCard renders Inbound transaction info and progress', (tester) async {
      final trx = WarehouseTransaction(
        id: 'TRX-TEST-CARD',
        type: TransactionType.inbound,
        title: 'Kontainer Mesin CNC 40ft',
        referenceNumber: 'TGHU-882914-2',
        partnerName: 'Yamazaki Mazak Corp',
        vehicleOrContainerId: 'SEAL-JP-77491',
        createdAt: DateTime.now(),
        targetQuantity: 4,
        status: TransactionStatus.inProgress,
        items: const [
          MachineItem(
            serialNumber: 'MZK-001',
            modelName: 'VCS 430A',
            brand: 'Mazak',
            barcode: 'BC-001',
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: TransactionCard(
              transaction: trx,
              onOpenScanner: () {},
              onTapDetail: () {},
            ),
          ),
        ),
      );

      expect(find.text('Kontainer Mesin CNC 40ft'), findsOneWidget);
      expect(find.textContaining('TGHU-882914-2'), findsOneWidget);
      expect(find.textContaining('Yamazaki Mazak Corp'), findsOneWidget);
      expect(find.text('Buka Scanner'), findsOneWidget);
      expect(find.text('Detail Transaksi'), findsOneWidget);
    });

    testWidgets('MachineItemTile renders brand, model and serial number', (tester) async {
      const item = MachineItem(
        serialNumber: 'SN-FANUC-2026',
        modelName: 'Robodrill High Speed',
        brand: 'FANUC',
        barcode: 'BC-FNC-2101',
        weightKg: 2400,
        countryOfOrigin: 'Jepang',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: MachineItemTile(
              item: item,
              index: 1,
            ),
          ),
        ),
      );

      expect(find.text('FANUC'), findsOneWidget);
      expect(find.text('Robodrill High Speed'), findsOneWidget);
      expect(find.textContaining('SN-FANUC-2026'), findsOneWidget);
      expect(find.textContaining('2400 Kg'), findsOneWidget);
    });

    testWidgets('CameraScannerView renders HUD and quick barcodes', (tester) async {
      String? scannedBarcode;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: CameraScannerView(
              onBarcodeScanned: (code) {
                scannedBarcode = code;
              },
            ),
          ),
        ),
      );

      expect(find.text('SCANNER AKTIF'), findsOneWidget);
      expect(find.text('BC-MZK-8501'), findsOneWidget);

      // Tap on quick barcode chip to simulate scanning
      await tester.tap(find.text('BC-MZK-8501'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1300));

      expect(scannedBarcode, 'BC-MZK-8501');
    });

    testWidgets('TransactionListPage displays stats, filter chips, and transaction list', (tester) async {
      bloc.add(const LoadTransactions());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: TransactionListPage(bloc: bloc),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Inbound Mesin Impor'), findsOneWidget);
      expect(find.text('Outbound Muat Truk'), findsOneWidget);
      expect(find.text('Scan Inbound'), findsOneWidget);
      expect(find.text('Scan Outbound'), findsOneWidget);
      expect(find.text('Buat Transaksi'), findsOneWidget);
    });
  });
}
