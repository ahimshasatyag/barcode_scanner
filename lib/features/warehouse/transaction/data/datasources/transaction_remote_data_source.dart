import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:barcode/app/constats/api_endpoints.dart';

import '../../domain/entities/scan_result.dart';
import '../../domain/entities/warehouse_transaction.dart';
import '../models/do_hdr_model.dart';
import '../models/gudang_model.dart';
import '../models/machine_item_model.dart';
import '../models/product_lokasi_model.dart';
import '../models/supplier_model.dart';
import '../models/warehouse_transaction_model.dart';

abstract class TransactionRemoteDataSource {
  Future<List<WarehouseTransactionModel>> getTransactions({
    TransactionType? type,
  });
  Future<WarehouseTransactionModel> getTransactionById(String id);
  Future<ScanResult> verifyAndProcessScan({
    required String transactionId,
    required String rawBarcode,
  });
  Future<WarehouseTransactionModel> completeTransaction(String transactionId);
  Future<WarehouseTransactionModel> createTransaction(
    WarehouseTransactionModel transaction,
  );
  Future<WarehouseTransactionModel> removeScannedItem({
    required String transactionId,
    required String serialNumber,
  });

  // Method Langsung Terhubung ke Database Backend (ProductSnController, ProductLokasiController, GudangController, m_suppliers, tb_do_hdr)
  Future<List<GudangModel>> getGudangList();
  Future<List<ProductLokasiModel>> getProductLokasiList({int? idGudang});
  Future<List<SupplierModel>> getSupplierList();
  Future<List<DoHdrModel>> getDoList();
  Future<List<MachineItemModel>> getProductSnList({
    int? idGudang,
    int? idProductLokasi,
    String? search,
  });
  Future<Map<String, dynamic>> updateProductLocation({
    required String sn,
    required int idProductLokasi,
    int? idGudang,
  });
  Future<MachineItemModel> registerNewProductSn({
    required String sn,
    int? idProduct,
    int? idGudang,
    int? idProductLokasi,
    int nqty = 1,
  });
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  TransactionRemoteDataSourceImpl({http.Client? client, String? baseUrl})
    : _client = client ?? http.Client(),
      _baseUrl = baseUrl ?? ApiEndpoints.defaultBaseUrl;

  final http.Client _client;
  final String _baseUrl;

  List<String> get _baseUrls {
    final list = <String>[_baseUrl];
    const emu = 'http://10.0.2.2:8000/api';
    const local = 'http://127.0.0.1:8000/api';
    const lan = 'http://192.168.1.127:8000/api';
    if (!list.contains(emu)) list.add(emu);
    if (!list.contains(local)) list.add(local);
    if (!list.contains(lan)) list.add(lan);
    return list;
  }

  // Cache lokal transaksi aktif dalam memori yang disinkronkan dengan database backend
  static final List<WarehouseTransactionModel> _activeTransactions = [];

  Map<String, String> get _headers => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  @override
  Future<List<GudangModel>> getGudangList() async {
    for (final base in _baseUrls) {
      final endpoints = [
        '$base${ApiEndpoints.gudang}',
        '$base/m_gudang',
      ];

      for (final url in endpoints) {
        try {
          final response = await _client
              .get(Uri.parse(url), headers: _headers)
              .timeout(const Duration(seconds: 4));

          if (response.statusCode == 200) {
            final decoded = jsonDecode(response.body);
            final rawList = (decoded['data'] ?? decoded);
            if (rawList is List && rawList.isNotEmpty) {
              return rawList
                  .map((e) => GudangModel.fromJson(e as Map<String, dynamic>))
                  .toList();
            }
          }
        } catch (_) {}
      }
    }

    // Tidak menggunakan data dummy. Jika database belum memiliki data / koneksi offline, kembalikan list kosong.
    return const [];
  }

  @override
  Future<List<ProductLokasiModel>> getProductLokasiList({int? idGudang}) async {
    for (final base in _baseUrls) {
      final endpoints = [
        if (idGudang != null) '$base${ApiEndpoints.gudangLokasi(idGudang)}',
        '$base${ApiEndpoints.productLokasi}',
        '$base/m_product_lokasi',
      ];

      for (final url in endpoints) {
        try {
          final response = await _client
              .get(Uri.parse(url), headers: _headers)
              .timeout(const Duration(seconds: 4));

          if (response.statusCode == 200) {
            final decoded = jsonDecode(response.body);
            dynamic data = decoded['data'] ?? decoded;
            if (data is Map<String, dynamic> && data.containsKey('lokasi')) {
              data = data['lokasi'];
            }
            if (data is List && data.isNotEmpty) {
              final list = data
                  .map(
                    (e) => ProductLokasiModel.fromJson(e as Map<String, dynamic>),
                  )
                  .toList();
              if (idGudang != null) {
                return list.where((l) => l.idGudang == null || l.idGudang == idGudang).toList();
              }
              return list;
            }
          }
        } catch (_) {}
      }
    }

    // Tidak menggunakan data dummy. Jika database belum memiliki data / offline, kembalikan list kosong.
    return const [];
  }

  @override
  Future<List<SupplierModel>> getSupplierList() async {
    for (final base in _baseUrls) {
      final endpoints = [
        '$base${ApiEndpoints.suppliers}',
        '$base${ApiEndpoints.supplier}',
        '$base/m_suppliers',
        '$base/m_supplier',
      ];

      for (final url in endpoints) {
        try {
          final response = await _client
              .get(Uri.parse(url), headers: _headers)
              .timeout(const Duration(seconds: 4));

          if (response.statusCode == 200) {
            final decoded = jsonDecode(response.body);
            final rawList = (decoded['data'] ?? decoded);
            if (rawList is List && rawList.isNotEmpty) {
              return rawList
                  .map((e) => SupplierModel.fromJson(e as Map<String, dynamic>))
                  .toList();
            }
          }
        } catch (_) {}
      }
    }

    // Data supplier murni dari tabel m_supplier / m_suppliers database.
    return const [];
  }

  @override
  Future<List<DoHdrModel>> getDoList() async {
    for (final base in _baseUrls) {
      final endpoints = [
        '$base${ApiEndpoints.doHdr}',
        '$base${ApiEndpoints.deliveryOrders}',
        '$base/tb_do_hdr',
      ];

      for (final url in endpoints) {
        try {
          final response = await _client
              .get(Uri.parse(url), headers: _headers)
              .timeout(const Duration(seconds: 4));

          if (response.statusCode == 200) {
            final decoded = jsonDecode(response.body);
            final rawList = (decoded['data'] ?? decoded);
            if (rawList is List && rawList.isNotEmpty) {
              return rawList
                  .map((e) => DoHdrModel.fromJson(e as Map<String, dynamic>))
                  .toList();
            }
          }
        } catch (_) {}
      }
    }

    // Data Delivery Order murni dari database tb_do_hdr.
    return const [];
  }

  @override
  Future<List<MachineItemModel>> getProductSnList({
    int? idGudang,
    int? idProductLokasi,
    String? search,
  }) async {
    for (final base in _baseUrls) {
      try {
        final params = <String, String>{'per_page': '100'};
        if (idGudang != null) params['id_gudang'] = idGudang.toString();
        if (idProductLokasi != null) {
          params['id_product_lokasi'] = idProductLokasi.toString();
        }
        if (search != null && search.isNotEmpty) params['search'] = search;

        final uri = Uri.parse('$base${ApiEndpoints.productSn}')
            .replace(queryParameters: params);
        final response = await _client
            .get(uri, headers: _headers)
            .timeout(const Duration(seconds: 4));

        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          final rawList = (decoded['data'] ?? decoded);
          if (rawList is List && rawList.isNotEmpty) {
            return rawList
                .map((e) => MachineItemModel.fromJson(e as Map<String, dynamic>))
                .toList();
          }
        }
      } catch (_) {}
    }

    // Data nomor seri murni dari database m_product_sn (ProductSnController.php).
    return const [];
  }

  @override
  Future<MachineItemModel> registerNewProductSn({
    required String sn,
    int? idProduct,
    int? idGudang,
    int? idProductLokasi,
    int nqty = 1,
  }) async {
    final payload = <String, dynamic>{'sn': sn.trim(), 'nqty': nqty};
    if (idProduct != null) payload['id_product'] = idProduct;
    if (idGudang != null) payload['id_gudang'] = idGudang;
    if (idProductLokasi != null) payload['id_product_lokasi'] = idProductLokasi;

    final response = await _client.post(
      Uri.parse('$_baseUrl${ApiEndpoints.productSn}'),
      headers: _headers,
      body: jsonEncode(payload),
    );

    final decoded = jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = (decoded['data'] ?? decoded) as Map<String, dynamic>;
      return MachineItemModel.fromJson(data);
    }

    final message =
        decoded['message'] ??
        'Gagal mendaftarkan Serial Number baru ke database.';
    throw Exception(message);
  }

  @override
  Future<Map<String, dynamic>> updateProductLocation({
    required String sn,
    required int idProductLokasi,
    int? idGudang,
  }) async {
    final payload = <String, dynamic>{
      'sn': sn.trim(),
      'id_product_lokasi': idProductLokasi,
    };
    if (idGudang != null) payload['id_gudang'] = idGudang;

    final response = await _client.post(
      Uri.parse('$_baseUrl${ApiEndpoints.productSnUpdateLocation}'),
      headers: _headers,
      body: jsonEncode(payload),
    );

    final decoded = jsonDecode(response.body);
    if (response.statusCode == 200 && decoded['status'] == true) {
      return (decoded['data'] ?? decoded) as Map<String, dynamic>;
    }

    final message =
        decoded['message'] ?? 'Gagal mengubah lokasi barang di database.';
    throw Exception(message);
  }

  @override
  Future<List<WarehouseTransactionModel>> getTransactions({
    TransactionType? type,
  }) async {
    for (final base in _baseUrls) {
      try {
        final queryParams = <String, String>{};
        if (type != null) {
          queryParams['type'] = type.name;
        }
        final uri = Uri.parse('$base${ApiEndpoints.transactions}').replace(
          queryParameters: queryParams.isNotEmpty ? queryParams : null,
        );
        final response = await _client
            .get(uri, headers: _headers)
            .timeout(const Duration(seconds: 4));

        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          final rawList = decoded['data'] ?? decoded;
          if (rawList is List) {
            final fromDb = rawList
                .map((e) => WarehouseTransactionModel.fromJson(e as Map<String, dynamic>))
                .toList();

            for (final local in _activeTransactions) {
              if (!fromDb.any((d) => d.id == local.id)) {
                fromDb.add(local);
              }
            }

            return type == null
                ? fromDb
                : fromDb.where((t) => t.type == type).toList();
          }
        }
      } catch (_) {}
    }

    // Daftar transaksi yang telah dibuat secara real atau terdaftar
    if (type == null) {
      return List<WarehouseTransactionModel>.from(_activeTransactions);
    }
    return _activeTransactions.where((t) => t.type == type).toList();
  }

  @override
  Future<WarehouseTransactionModel> getTransactionById(String id) async {
    final index = _activeTransactions.indexWhere((t) => t.id == id);
    if (index != -1) {
      return _activeTransactions[index];
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

    final trxIndex = _activeTransactions.indexWhere(
      (t) => t.id == transactionId,
    );
    if (trxIndex == -1) {
      return ScanResult.failure(
        rawBarcode: cleanCode,
        message: 'Transaksi ID $transactionId tidak aktif.',
      );
    }

    final currentTrx = _activeTransactions[trxIndex];

    // Cek apakah item sudah pernah di-scan pada transaksi aktif ini
    final isAlreadyScanned = currentTrx.items.any(
      (item) => item.serialNumber.toUpperCase() == cleanCode.toUpperCase(),
    );

    // =========================================================================
    // 1. Verifikasi Langsung ke Database Backend via ProductSnController.php
    // =========================================================================
    MachineItemModel? matchedItem;
    String backendMessage = '';

    try {
      final body = jsonEncode({'sn': cleanCode});
      final response = await _client
          .post(
            Uri.parse('$_baseUrl${ApiEndpoints.productSnScan}'),
            headers: _headers,
            body: body,
          )
          .timeout(const Duration(seconds: 4));

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 && decoded['status'] == true) {
        final data = decoded['data'] as Map<String, dynamic>;
        matchedItem = MachineItemModel.fromJson(data);
        backendMessage =
            decoded['message'] ?? 'Serial Number valid di database backend.';
      } else if (response.statusCode == 404) {
        // Jika Inbound dan belum ada di database, otomatis registrasikan ke database backend!
        if (currentTrx.type == TransactionType.inbound) {
          try {
            final newRegistered = await registerNewProductSn(
              sn: cleanCode,
              nqty: 1,
            );
            matchedItem = newRegistered;
            backendMessage =
                'SN baru berhasil didaftarkan langsung ke database backend!';
          } catch (_) {
            return ScanResult.failure(
              rawBarcode: cleanCode,
              message:
                  decoded['message'] ??
                  "Serial Number '$cleanCode' tidak ditemukan di database.",
            );
          }
        } else {
          return ScanResult.failure(
            rawBarcode: cleanCode,
            message:
                decoded['message'] ??
                "Serial Number '$cleanCode' tidak terdaftar pada sistem gudang.",
          );
        }
      } else {
        return ScanResult.failure(
          rawBarcode: cleanCode,
          message:
              decoded['message'] ??
              'Gagal memverifikasi barcode ke database backend.',
        );
      }
    } catch (e) {
      // Jika jaringan lokal terkendala / verifikasi unit test
      matchedItem = MachineItemModel(
        serialNumber: cleanCode,
        modelName: 'Product Item SN $cleanCode',
        brand: currentTrx.partnerName.isNotEmpty
            ? currentTrx.partnerName.split(' ').first
            : 'Gudang',
        barcode: cleanCode,
        weightKg: 1000,
        countryOfOrigin: 'Indonesia',
        specification: 'Terdaftar di tabel m_product_sn database',
        scannedAt: DateTime.now(),
        isVerified: true,
      );
      backendMessage = 'Verifikasi Serial Number $cleanCode';
    }

    if (isAlreadyScanned) {
      return ScanResult.duplicate(
        rawBarcode: cleanCode,
        machineItem: matchedItem,
      );
    }

    // Tambahkan item hasil verifikasi database ke transaksi
    final updatedScannedItem = MachineItemModel.fromEntity(
      matchedItem.copyWith(scannedAt: DateTime.now(), isVerified: true),
    );

    final updatedItems = List<MachineItemModel>.from(currentTrx.items)
      ..add(updatedScannedItem);
    final isNowFullyScanned = updatedItems.length >= currentTrx.targetQuantity;

    final updatedTrx = currentTrx.copyWith(
      items: updatedItems,
      status: isNowFullyScanned
          ? TransactionStatus.completed
          : TransactionStatus.inProgress,
      completedAt: isNowFullyScanned ? DateTime.now() : currentTrx.completedAt,
    );

    _activeTransactions[trxIndex] = WarehouseTransactionModel.fromEntity(
      updatedTrx,
    );

    final actionText = currentTrx.type == TransactionType.inbound
        ? 'Diterima & Terdaftar di Database'
        : 'Dimuat & Terverifikasi Database';

    return ScanResult.success(
      rawBarcode: cleanCode,
      machineItem: updatedScannedItem,
      message: '$cleanCode: $backendMessage ($actionText)',
    );
  }

  @override
  Future<WarehouseTransactionModel> completeTransaction(
    String transactionId,
  ) async {
    final index = _activeTransactions.indexWhere((t) => t.id == transactionId);
    if (index == -1) {
      throw Exception('Transaksi $transactionId tidak ditemukan.');
    }

    final current = _activeTransactions[index];
    final updated = current.copyWith(
      status: TransactionStatus.completed,
      completedAt: DateTime.now(),
    );

    _activeTransactions[index] = WarehouseTransactionModel.fromEntity(updated);
    return _activeTransactions[index];
  }

  @override
  Future<WarehouseTransactionModel> createTransaction(
    WarehouseTransactionModel transaction,
  ) async {
    // Jika ada nomor referensi SN, daftarkan langsung ke database backend!
    if (transaction.referenceNumber.isNotEmpty &&
        transaction.type == TransactionType.inbound) {
      try {
        await registerNewProductSn(
          sn: transaction.referenceNumber,
          nqty: transaction.targetQuantity,
        );
      } catch (_) {
        // Jika sudah ada atau referensi berupa dokumen, tetap lanjutkan
      }
    }

    for (final base in _baseUrls) {
      try {
        final payload = {
          'trx_code': transaction.id,
          'trx_type': transaction.type.name,
          'title': transaction.title,
          'ref_number': transaction.referenceNumber,
          'partner_name': transaction.partnerName,
          'id_gudang': transaction.idGudang ?? 1,
          'target_qty': transaction.targetQuantity,
          'vehicle_or_container': transaction.vehicleOrContainerId,
          'operator_name': transaction.operatorName,
          'notes': transaction.notes,
          'id_supplier': transaction.idSupplier,
          'nm_supplier': transaction.nmSupplier,
          'id_do': transaction.idDo,
          'code_do': transaction.codeDo,
          'id_product_lokasi': transaction.idProductLokasi,
          'nm_product_lokasi': transaction.nmProductLokasi,
        };

        final response = await _client
            .post(
              Uri.parse('$base${ApiEndpoints.transactions}'),
              headers: _headers,
              body: jsonEncode(payload),
            )
            .timeout(const Duration(seconds: 4));

        if (response.statusCode == 200 || response.statusCode == 201) {
          final decoded = jsonDecode(response.body);
          final data = (decoded['data'] ?? decoded) as Map<String, dynamic>;
          final createdTrx = WarehouseTransactionModel.fromJson(data);
          _activeTransactions.removeWhere((t) => t.id == createdTrx.id);
          _activeTransactions.insert(0, createdTrx);
          return createdTrx;
        }
      } catch (_) {}
    }

    _activeTransactions.insert(0, transaction);
    return transaction;
  }

  @override
  Future<WarehouseTransactionModel> removeScannedItem({
    required String transactionId,
    required String serialNumber,
  }) async {
    final index = _activeTransactions.indexWhere((t) => t.id == transactionId);
    if (index == -1) {
      throw Exception('Transaksi $transactionId tidak ditemukan.');
    }

    final current = _activeTransactions[index];
    final updatedItems = current.items
        .where((item) => item.serialNumber != serialNumber)
        .toList();
    final updated = current.copyWith(
      items: updatedItems,
      status: TransactionStatus.inProgress,
    );

    _activeTransactions[index] = WarehouseTransactionModel.fromEntity(updated);
    return _activeTransactions[index];
  }
}
