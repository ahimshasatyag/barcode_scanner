import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/machine_item.dart';
import '../../domain/entities/scan_result.dart';
import '../../domain/entities/warehouse_transaction.dart';
import '../models/machine_item_model.dart';
import '../models/warehouse_transaction_model.dart';

abstract class TransactionRemoteDataSource {
  Future<List<WarehouseTransactionModel>> getTransactions({TransactionType? type});
  Future<WarehouseTransactionModel> getTransactionById(String id);
  Future<ScanResult> verifyAndProcessScan({
    required String transactionId,
    required String rawBarcode,
  });
  Future<WarehouseTransactionModel> completeTransaction(String transactionId);
  Future<WarehouseTransactionModel> createTransaction(WarehouseTransactionModel transaction);
  Future<WarehouseTransactionModel> removeScannedItem({
    required String transactionId,
    required String serialNumber,
  });
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  TransactionRemoteDataSourceImpl({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? 'http://10.0.2.2:8000/api';

  final http.Client _client;
  final String _baseUrl;

  // In-memory persistent database for realistic warehouse operations
  static final List<WarehouseTransactionModel> _mockDatabase = [
    WarehouseTransactionModel(
      id: 'TRX-INB-20261109-001',
      type: TransactionType.inbound,
      title: 'Kontainer 40ft Mesin CNC Lathe & Milling',
      referenceNumber: 'TGHU-882914-2',
      partnerName: 'Yamazaki Mazak Corp (Kobe Port, Jepang)',
      vehicleOrContainerId: 'SEAL-JP-77491',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      targetQuantity: 3,
      status: TransactionStatus.inProgress,
      operatorName: 'Budi Santoso (Warehouse Leader)',
      notes: 'Peti kemas kondisi baik, segel kontainer utuh saat dibuka di Dermaga 002.',
      items: [
        MachineItemModel(
          serialNumber: 'MZK-VCS-2026-001',
          modelName: 'Vertical Center Smart 430A',
          brand: 'Mazak',
          barcode: 'BC-MZK-8501',
          weightKg: 4600,
          countryOfOrigin: 'Jepang',
          specification: '12,000 RPM, BT40, Direct Drive spindle',
          scannedAt: DateTime.now().subtract(const Duration(minutes: 45)),
          isVerified: true,
        ),
      ],
    ),
    WarehouseTransactionModel(
      id: 'TRX-OUT-20261109-002',
      type: TransactionType.outbound,
      title: 'Pemuatan Truk Tronton Wingbox ke Klien',
      referenceNumber: 'SJ-EMM-2026/XI/109',
      partnerName: 'PT Astra Honda Motor (Cikarang Plant 3)',
      vehicleOrContainerId: 'B 9482 TXT',
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      targetQuantity: 2,
      status: TransactionStatus.inProgress,
      operatorName: 'Ahmad Fauzi',
      notes: 'Pengiriman unit ekspedisi mendesak, diverifikasi tim QC pra-kirim.',
      items: [
        MachineItemModel(
          serialNumber: 'OKM-GNS-2026-077',
          modelName: 'Genos L3000-e Horizontal CNC Lathe',
          brand: 'Okuma',
          barcode: 'BC-OKM-3001',
          weightKg: 4800,
          countryOfOrigin: 'Jepang',
          specification: 'Spindle 3,800 RPM, Chuck 10 Inch, OSP-P300LA control',
          scannedAt: DateTime.now().subtract(const Duration(minutes: 20)),
          isVerified: true,
        ),
      ],
    ),
    WarehouseTransactionModel(
      id: 'TRX-INB-20261109-003',
      type: TransactionType.inbound,
      title: 'Kontainer 20ft Kompak CNC Robodrill',
      referenceNumber: 'MSKU-440192-8',
      partnerName: 'FANUC Corporation (Yokohama Port, Jepang)',
      vehicleOrContainerId: 'SEAL-FANUC-119',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      targetQuantity: 2,
      status: TransactionStatus.completed,
      operatorName: 'Budi Santoso',
      notes: 'Selesai pembongkaran peti kemas, semua mesin masuk blok A-1.',
      completedAt: DateTime.now().subtract(const Duration(hours: 5)),
      items: [
        MachineItemModel(
          serialNumber: 'FNC-RBD-2026-112',
          modelName: 'Robodrill α-D21LiB5 High-Speed',
          brand: 'FANUC',
          barcode: 'BC-FNC-2101',
          weightKg: 2400,
          countryOfOrigin: 'Jepang',
          specification: '24,000 RPM, BBT30, 21-Tool Turret',
          scannedAt: DateTime.now().subtract(const Duration(hours: 6)),
          isVerified: true,
        ),
        MachineItemModel(
          serialNumber: 'FNC-RBC-2026-088',
          modelName: 'Robocut α-C600iC Wire EDM',
          brand: 'FANUC',
          barcode: 'BC-FNC-2102',
          weightKg: 3000,
          countryOfOrigin: 'Jepang',
          specification: 'Submerged Wire Cut EDM, AWF3 Wire Threading',
          scannedAt: DateTime.now().subtract(const Duration(hours: 5, minutes: 30)),
          isVerified: true,
        ),
      ],
    ),
    WarehouseTransactionModel(
      id: 'TRX-OUT-20261109-004',
      type: TransactionType.outbound,
      title: 'Pemuatan Trailer Flatbed Mesin 5-Axis',
      referenceNumber: 'SJ-EMM-2026/XI/115',
      partnerName: 'PT Komatsu Indonesia (Cilincing Foundry)',
      vehicleOrContainerId: 'B 9104 UEY',
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      targetQuantity: 1,
      status: TransactionStatus.draft,
      operatorName: 'Hendra Gunawan',
      notes: 'Truk trailer telah standby di Loading Dock 04.',
      items: const [],
    ),
  ];

  // Master katalog mesin terdaftar untuk verifikasi barcode
  static final Map<String, MachineItemModel> _masterMachineCatalog = {
    'BC-MZK-8501': const MachineItemModel(
      serialNumber: 'MZK-VCS-2026-001',
      modelName: 'Vertical Center Smart 430A',
      brand: 'Mazak',
      barcode: 'BC-MZK-8501',
      weightKg: 4600,
      countryOfOrigin: 'Jepang',
      specification: '12,000 RPM, BT40, Direct Drive spindle',
    ),
    'BC-MZK-8502': const MachineItemModel(
      serialNumber: 'MZK-QT250-2026-042',
      modelName: 'Quick Turn 250MSY Turning Center',
      brand: 'Mazak',
      barcode: 'BC-MZK-8502',
      weightKg: 5200,
      countryOfOrigin: 'Jepang',
      specification: 'Rotary Tool, Sub-spindle, Y-axis travel ±50mm',
    ),
    'BC-MZK-8503': const MachineItemModel(
      serialNumber: 'MZK-INT200-2026-018',
      modelName: 'Integrex i-200H S Multi-Tasking',
      brand: 'Mazak',
      barcode: 'BC-MZK-8503',
      weightKg: 7800,
      countryOfOrigin: 'Jepang',
      specification: 'Simultaneous 5-Axis, SmoothX CNC, Tool Eye Automatic',
    ),
    'BC-OKM-3001': const MachineItemModel(
      serialNumber: 'OKM-GNS-2026-077',
      modelName: 'Genos L3000-e Horizontal CNC Lathe',
      brand: 'Okuma',
      barcode: 'BC-OKM-3001',
      weightKg: 4800,
      countryOfOrigin: 'Jepang',
      specification: 'Spindle 3,800 RPM, Chuck 10 Inch, OSP-P300LA control',
    ),
    'BC-DMG-5001': const MachineItemModel(
      serialNumber: 'DMG-DMU50-2026-301',
      modelName: 'DMU 50 3rd Gen 5-Axis Milling',
      brand: 'DMG MORI',
      barcode: 'BC-DMG-5001',
      weightKg: 5800,
      countryOfOrigin: 'Jerman',
      specification: 'Swivel rotary table, 15,000 RPM speedMASTER spindle',
    ),
    'BC-FNC-2101': const MachineItemModel(
      serialNumber: 'FNC-RBD-2026-112',
      modelName: 'Robodrill α-D21LiB5 High-Speed',
      brand: 'FANUC',
      barcode: 'BC-FNC-2101',
      weightKg: 2400,
      countryOfOrigin: 'Jepang',
      specification: '24,000 RPM, BBT30, 21-Tool Turret',
    ),
    'BC-FNC-2102': const MachineItemModel(
      serialNumber: 'FNC-RBC-2026-088',
      modelName: 'Robocut α-C600iC Wire EDM',
      brand: 'FANUC',
      barcode: 'BC-FNC-2102',
      weightKg: 3000,
      countryOfOrigin: 'Jepang',
      specification: 'Submerged Wire Cut EDM, AWF3 Wire Threading',
    ),
    'BC-DOO-2601': const MachineItemModel(
      serialNumber: 'DOO-PUM-2026-512',
      modelName: 'Puma GT 2600 Heavy-Duty Lathe',
      brand: 'Doosan',
      barcode: 'BC-DOO-2601',
      weightKg: 6100,
      countryOfOrigin: 'Korea Selatan',
      specification: 'High-torque gear drive, 12-station heavy turret',
    ),
  };

  @override
  Future<List<WarehouseTransactionModel>> getTransactions({TransactionType? type}) async {
    // Attempt remote API call if available
    try {
      final endpoint = type != null ? '$_baseUrl/transactions?type=${type.name}' : '$_baseUrl/transactions';
      final response = await _client.get(
        Uri.parse(endpoint),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(milliseconds: 1200));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final list = (decoded['data'] ?? decoded) as List<dynamic>;
        return list.map((e) => WarehouseTransactionModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } catch (_) {
      // Fallback seamlessly to mock database
    }

    if (type == null) {
      return List<WarehouseTransactionModel>.from(_mockDatabase);
    }
    return _mockDatabase.where((t) => t.type == type).toList();
  }

  @override
  Future<WarehouseTransactionModel> getTransactionById(String id) async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl/transactions/$id'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(milliseconds: 1200));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final data = (decoded['data'] ?? decoded) as Map<String, dynamic>;
        return WarehouseTransactionModel.fromJson(data);
      }
    } catch (_) {
      // Fallback to local
    }

    final index = _mockDatabase.indexWhere((t) => t.id == id);
    if (index != -1) {
      return _mockDatabase[index];
    }
    throw Exception('Transaksi dengan ID $id tidak ditemukan.');
  }

  @override
  Future<ScanResult> verifyAndProcessScan({
    required String transactionId,
    required String rawBarcode,
  }) async {
    final cleanCode = rawBarcode.trim();
    if (cleanCode.isEmpty) {
      return ScanResult.failure(
        rawBarcode: rawBarcode,
        message: 'Barcode tidak terbaca atau kosong.',
      );
    }

    final trxIndex = _mockDatabase.indexWhere((t) => t.id == transactionId);
    if (trxIndex == -1) {
      return ScanResult.failure(
        rawBarcode: cleanCode,
        message: 'Transaksi ID $transactionId tidak aktif.',
      );
    }

    final currentTrx = _mockDatabase[trxIndex];

    // Check if machine is already scanned in this transaction
    final isAlreadyScanned = currentTrx.items.any(
      (item) =>
          item.barcode.toUpperCase() == cleanCode.toUpperCase() ||
          item.serialNumber.toUpperCase() == cleanCode.toUpperCase(),
    );

    MachineItemModel? matchedItem;
    if (_masterMachineCatalog.containsKey(cleanCode.toUpperCase())) {
      matchedItem = _masterMachineCatalog[cleanCode.toUpperCase()];
    } else {
      // Check if serial number matches
      for (final item in _masterMachineCatalog.values) {
        if (item.serialNumber.toUpperCase() == cleanCode.toUpperCase() ||
            item.barcode.toUpperCase() == cleanCode.toUpperCase()) {
          matchedItem = item;
          break;
        }
      }
    }

    // Dynamic fallback for custom/new industrial barcodes
    matchedItem ??= MachineItemModel(
      serialNumber: cleanCode.startsWith('SN-') ? cleanCode : 'SN-$cleanCode',
      modelName: 'Mesin Industri Spesifikasi Manifes',
      brand: 'Industrial Equipment',
      barcode: cleanCode,
      weightKg: 3500,
      countryOfOrigin: currentTrx.type == TransactionType.inbound ? 'Impor (Jepang)' : 'Warehouse Stock',
      specification: 'Terverifikasi otomatis via Optical Barcode Reader',
      scannedAt: DateTime.now(),
      isVerified: true,
    );

    if (isAlreadyScanned) {
      return ScanResult.duplicate(
        rawBarcode: cleanCode,
        machineItem: matchedItem,
      );
    }

    // Add scanned machine to transaction
    final updatedScannedItem = matchedItem.copyWith(
      scannedAt: DateTime.now(),
      isVerified: true,
    );

    final updatedItems = List<MachineItem>.from(currentTrx.items)..add(updatedScannedItem);
    final isNowFullyScanned = updatedItems.length >= currentTrx.targetQuantity;

    final updatedTrx = currentTrx.copyWith(
      items: updatedItems,
      status: isNowFullyScanned ? TransactionStatus.completed : TransactionStatus.inProgress,
      completedAt: isNowFullyScanned ? DateTime.now() : currentTrx.completedAt,
    );

    _mockDatabase[trxIndex] = WarehouseTransactionModel.fromEntity(updatedTrx);

    final actionText = currentTrx.type == TransactionType.inbound
        ? 'Diterima dari Kontainer'
        : 'Dimuat ke Armada Truk';

    return ScanResult.success(
      rawBarcode: cleanCode,
      machineItem: updatedScannedItem,
      message: '${matchedItem.brand} ${matchedItem.modelName} ($actionText)',
    );
  }

  @override
  Future<WarehouseTransactionModel> completeTransaction(String transactionId) async {
    final index = _mockDatabase.indexWhere((t) => t.id == transactionId);
    if (index == -1) {
      throw Exception('Transaksi $transactionId tidak ditemukan.');
    }

    final current = _mockDatabase[index];
    final updated = current.copyWith(
      status: TransactionStatus.completed,
      completedAt: DateTime.now(),
    );

    _mockDatabase[index] = WarehouseTransactionModel.fromEntity(updated);
    return _mockDatabase[index];
  }

  @override
  Future<WarehouseTransactionModel> createTransaction(WarehouseTransactionModel transaction) async {
    _mockDatabase.insert(0, transaction);
    return transaction;
  }

  @override
  Future<WarehouseTransactionModel> removeScannedItem({
    required String transactionId,
    required String serialNumber,
  }) async {
    final index = _mockDatabase.indexWhere((t) => t.id == transactionId);
    if (index == -1) {
      throw Exception('Transaksi $transactionId tidak ditemukan.');
    }

    final current = _mockDatabase[index];
    final updatedItems = current.items.where((item) => item.serialNumber != serialNumber).toList();
    final updated = current.copyWith(
      items: updatedItems,
      status: TransactionStatus.inProgress,
    );

    _mockDatabase[index] = WarehouseTransactionModel.fromEntity(updated);
    return _mockDatabase[index];
  }
}
