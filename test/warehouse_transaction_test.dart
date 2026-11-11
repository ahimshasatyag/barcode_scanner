import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
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
      final mockClient = MockClient((request) async {
        final path = request.url.path;

        if (path.endsWith('/suppliers') || path.endsWith('/supplier')) {
          return http.Response(
            jsonEncode({
              'status': true,
              'data': [
                {
                  'id_suppliers': 1,
                  'nm_suppliers': 'Yamazaki Mazak Corporation',
                  'suppliers_address': 'Oguchi, Japan',
                  'suppliers_phone': '+81-587-95-5111',
                },
              ],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        if (path.endsWith('/do') || path.endsWith('/delivery-orders')) {
          return http.Response(
            jsonEncode({
              'status': true,
              'data': [
                {
                  'id_do': 1,
                  'code_do': 'DO-EMM-2026/XI/0088',
                  'date_do': '2026-11-10',
                  'nm_customers': 'PT Astra Honda Motor',
                  'status_do': 'READY TO DELIVER',
                },
              ],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        if (path.endsWith('/gudang')) {
          return http.Response(
            jsonEncode({
              'status': true,
              'data': [
                {
                  'id_gudang': 1,
                  'nm_gudang': 'EMM Head Office Logistik',
                  'code_gudang': 'EMM',
                },
              ],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        if (path.endsWith('/product-lokasi') || path.contains('/lokasi')) {
          return http.Response(
            jsonEncode({
              'status': true,
              'data': [
                {
                  'id_product_lokasi': 3,
                  'nm_product_lokasi': 'Showroom Utama',
                  'complete_name': 'EMM / Gedung Pusat / Showroom',
                  'id_gudang': 1,
                },
              ],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        if (path.endsWith('/product-sn/scan')) {
          return http.Response(
            jsonEncode({
              'status': true,
              'message': 'Serial Number valid di database',
              'data': {
                'id_product_sn': 4951,
                'sn': '20.204.01794.28.04951',
                'model_name': 'Vertical Center Smart 430A',
                'brand': 'Mazak',
                'id_gudang': 1,
                'id_product_lokasi': 3,
              },
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        if (path.endsWith('/product-sn')) {
          return http.Response(
            jsonEncode({
              'status': true,
              'data': [
                {
                  'id_product_sn': 4951,
                  'sn': '20.204.01794.28.04951',
                  'model_name': 'Vertical Center Smart 430A',
                  'brand': 'Mazak',
                  'id_gudang': 1,
                  'id_product_lokasi': 3,
                },
              ],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        if (path.endsWith('/transactions')) {
          return http.Response(
            jsonEncode({
              'status': true,
              'data': [],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        return http.Response('{"status":false}', 404);
      });

      dataSource = TransactionRemoteDataSourceImpl(client: mockClient);
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

    test('Data Source returns empty list initially and stores created transactions', () async {
      final initial = await dataSource.getTransactions();
      expect(initial, isEmpty);

      final inb = WarehouseTransactionModel(
        id: 'TEST-INB-001',
        type: TransactionType.inbound,
        title: 'Penerimaan Inbound Test',
        referenceNumber: 'REF-001',
        partnerName: 'EMM Head Office',
        vehicleOrContainerId: '',
        createdAt: DateTime.now(),
        targetQuantity: 2,
      );
      final outb = WarehouseTransactionModel(
        id: 'TEST-OUT-001',
        type: TransactionType.outbound,
        title: 'Pengiriman Outbound Test',
        referenceNumber: 'REF-002',
        partnerName: 'GKU Kapuk',
        vehicleOrContainerId: '',
        createdAt: DateTime.now(),
        targetQuantity: 1,
      );
      await dataSource.createTransaction(inb);
      await dataSource.createTransaction(outb);

      final all = await dataSource.getTransactions();
      expect(all.length, 2);

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
        rawBarcode: '20.204.01794.28.04951',
      );
      expect(scanResult1.isSuccess, true);
      expect(scanResult1.machineItem != null, true);

      // 2. Second scan with same barcode should be flagged as duplicate
      final scanResultDuplicate = await repository.verifyAndProcessScan(
        transactionId: 'TEST-TRX-001',
        rawBarcode: '20.204.01794.28.04951',
      );
      expect(scanResultDuplicate.isSuccess, false);
      expect(scanResultDuplicate.isDuplicate, true);

      // 3. Scan second machine to complete target
      final scanResult2 = await repository.verifyAndProcessScan(
        transactionId: 'TEST-TRX-001',
        rawBarcode: '20.204.01785.28.04950',
      );
      expect(scanResult2.isSuccess, true);

      final updatedTrx = await repository.getTransactionById('TEST-TRX-001');
      expect(updatedTrx.items.length, 2);
      expect(updatedTrx.isFullyScanned, true);
      expect(updatedTrx.status, TransactionStatus.completed);
    });

    test('Master data fetchers return valid models for m_suppliers, tb_do_hdr, and m_product_sn', () async {
      final suppliers = await repository.getSupplierList();
      expect(suppliers.isNotEmpty, true);
      expect(suppliers.any((s) => s.nmSuppliers.contains('Mazak')), true);

      final doList = await repository.getDoList();
      expect(doList.isNotEmpty, true);
      expect(doList.any((d) => d.codeDo.contains('DO-EMM')), true);

      final snList = await repository.getProductSnList();
      expect(snList.isNotEmpty, true);
      expect(snList.any((s) => s.serialNumber == '20.204.01794.28.04951'), true);

      final gudangs = await repository.getGudangList();
      expect(gudangs.isNotEmpty, true);

      final lokasis = await repository.getProductLokasiList();
      expect(lokasis.isNotEmpty, true);
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
              customQuickBarcodes: const [
                {'code': '20.204.01794.28.04951', 'label': 'SN 20.204 (GKU Stock)'},
              ],
              onBarcodeScanned: (code) {
                scannedBarcode = code;
              },
            ),
          ),
        ),
      );

      expect(find.text('SCANNER AKTIF'), findsOneWidget);
      expect(find.text('20.204.01794.28.04951'), findsOneWidget);

      // Tap on quick barcode chip to simulate scanning
      await tester.tap(find.text('20.204.01794.28.04951'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1300));

      expect(scannedBarcode, '20.204.01794.28.04951');
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
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Inbound'), findsOneWidget);
      expect(find.text('Outbound'), findsOneWidget);
      expect(find.text('Scan Inbound'), findsOneWidget);
      expect(find.text('Scan Outbound'), findsOneWidget);
      expect(find.text('Buat Transaksi'), findsOneWidget);

      // Tap Buat Transaksi button and verify bottom sheet dropdowns open without assertion errors
      await tester.tap(find.text('Buat Transaksi'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Buat Transaksi Inbound / Outbound'), findsOneWidget);
      expect(find.text('Pilih Gudang (m_gudang)'), findsOneWidget);
      expect(find.text('Pilih Supplier (m_suppliers)'), findsOneWidget);
      expect(find.text('Pilih Dokumen DO (tb_do_hdr)'), findsOneWidget);
      expect(find.text('Pilih Nomor Seri (m_product_sn)'), findsOneWidget);
    });
  });
}
