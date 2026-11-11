import '../../domain/entities/machine_item.dart';

class MachineItemModel extends MachineItem {
  const MachineItemModel({
    required super.serialNumber,
    required super.modelName,
    required super.brand,
    required super.barcode,
    super.weightKg,
    super.countryOfOrigin,
    super.specification,
    super.scannedAt,
    super.isVerified = true,
    super.idProductSn,
    super.idProduct,
    super.idGudang,
    super.nmGudang,
    super.codeGudang,
    super.idProductLokasi,
    super.nmProductLokasi,
    super.completeName,
    super.nqty = 1,
    super.dateCreate,
    super.dateUpdate,
  });

  factory MachineItemModel.fromJson(Map<String, dynamic> json) {
    final sn = json['sn'] as String? ??
        json['serial_number'] as String? ??
        json['serialNumber'] as String? ??
        '';

    final idProductSn = json['id_product_sn'] is int
        ? json['id_product_sn'] as int
        : int.tryParse(json['id_product_sn']?.toString() ?? '') ??
          int.tryParse(json['id']?.toString() ?? '');
    final idProduct = json['id_product'] is int
        ? json['id_product'] as int
        : int.tryParse(json['id_product']?.toString() ?? '');
    final nqty = json['nqty'] is int
        ? json['nqty'] as int
        : int.tryParse(json['nqty']?.toString() ?? '') ?? 1;

    final idGudang = json['id_gudang'] is int
        ? json['id_gudang'] as int
        : int.tryParse(json['id_gudang']?.toString() ?? '');
    final nmGudang = json['nm_gudang'] as String? ??
        json['gudang']?['nm_gudang'] as String?;
    final codeGudang = json['code_gudang'] as String? ??
        json['gudang']?['code_gudang'] as String?;

    final idProductLokasi = json['id_product_lokasi'] is int
        ? json['id_product_lokasi'] as int
        : int.tryParse(json['id_product_lokasi']?.toString() ?? '');
    final nmProductLokasi = json['nm_product_lokasi'] as String? ??
        json['lokasi']?['nm_product_lokasi'] as String?;
    final completeName = json['complete_name'] as String? ??
        json['lokasi']?['complete_name'] as String?;

    final dateCreate = json['date_create'] != null
        ? DateTime.tryParse(json['date_create'].toString())
        : null;
    final dateUpdate = json['date_update'] != null
        ? DateTime.tryParse(json['date_update'].toString())
        : null;

    final brand = json['brand'] as String? ??
        codeGudang ??
        (nmGudang != null ? nmGudang.split(' ').first : 'Eka Maju');

    final modelName = json['model_name'] as String? ??
        json['modelName'] as String? ??
        (completeName != null && completeName != '-'
            ? completeName
            : 'Product Item #$idProduct');

    return MachineItemModel(
      serialNumber: sn,
      modelName: modelName,
      brand: brand,
      barcode: sn,
      weightKg: (json['weight_kg'] ?? json['weightKg'] as num?)?.toDouble() ?? 1200.0,
      countryOfOrigin: json['country_of_origin'] as String? ??
          json['countryOfOrigin'] as String? ??
          nmGudang ??
          'Indonesia',
      specification: json['specification'] as String? ??
          'Lokasi: ${completeName ?? "-"} | Gudang: ${nmGudang ?? "-"}',
      scannedAt: json['scanned_at'] != null
          ? DateTime.tryParse(json['scanned_at'].toString())
          : dateUpdate ?? dateCreate ?? DateTime.now(),
      isVerified: json['is_verified'] as bool? ?? true,
      idProductSn: idProductSn,
      idProduct: idProduct,
      idGudang: idGudang,
      nmGudang: nmGudang,
      codeGudang: codeGudang,
      idProductLokasi: idProductLokasi,
      nmProductLokasi: nmProductLokasi,
      completeName: completeName,
      nqty: nqty,
      dateCreate: dateCreate,
      dateUpdate: dateUpdate,
    );
  }

  @override
  MachineItemModel copyWith({
    String? serialNumber,
    String? modelName,
    String? brand,
    String? barcode,
    double? weightKg,
    String? countryOfOrigin,
    String? specification,
    DateTime? scannedAt,
    bool? isVerified,
    int? idProductSn,
    int? idProduct,
    int? idGudang,
    String? nmGudang,
    String? codeGudang,
    int? idProductLokasi,
    String? nmProductLokasi,
    String? completeName,
    int? nqty,
    DateTime? dateCreate,
    DateTime? dateUpdate,
  }) {
    return MachineItemModel(
      serialNumber: serialNumber ?? this.serialNumber,
      modelName: modelName ?? this.modelName,
      brand: brand ?? this.brand,
      barcode: barcode ?? this.barcode,
      weightKg: weightKg ?? this.weightKg,
      countryOfOrigin: countryOfOrigin ?? this.countryOfOrigin,
      specification: specification ?? this.specification,
      scannedAt: scannedAt ?? this.scannedAt,
      isVerified: isVerified ?? this.isVerified,
      idProductSn: idProductSn ?? this.idProductSn,
      idProduct: idProduct ?? this.idProduct,
      idGudang: idGudang ?? this.idGudang,
      nmGudang: nmGudang ?? this.nmGudang,
      codeGudang: codeGudang ?? this.codeGudang,
      idProductLokasi: idProductLokasi ?? this.idProductLokasi,
      nmProductLokasi: nmProductLokasi ?? this.nmProductLokasi,
      completeName: completeName ?? this.completeName,
      nqty: nqty ?? this.nqty,
      dateCreate: dateCreate ?? this.dateCreate,
      dateUpdate: dateUpdate ?? this.dateUpdate,
    );
  }

  factory MachineItemModel.fromEntity(MachineItem item) {
    return MachineItemModel(
      serialNumber: item.serialNumber,
      modelName: item.modelName,
      brand: item.brand,
      barcode: item.barcode,
      weightKg: item.weightKg,
      countryOfOrigin: item.countryOfOrigin,
      specification: item.specification,
      scannedAt: item.scannedAt,
      isVerified: item.isVerified,
      idProductSn: item.idProductSn,
      idProduct: item.idProduct,
      idGudang: item.idGudang,
      nmGudang: item.nmGudang,
      codeGudang: item.codeGudang,
      idProductLokasi: item.idProductLokasi,
      nmProductLokasi: item.nmProductLokasi,
      completeName: item.completeName,
      nqty: item.nqty,
      dateCreate: item.dateCreate,
      dateUpdate: item.dateUpdate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_product_sn': idProductSn,
      'id_product': idProduct,
      'sn': serialNumber,
      'serial_number': serialNumber,
      'model_name': modelName,
      'brand': brand,
      'barcode': barcode,
      'weight_kg': weightKg,
      'country_of_origin': countryOfOrigin,
      'specification': specification,
      'scanned_at': scannedAt?.toIso8601String(),
      'is_verified': isVerified,
      'id_gudang': idGudang,
      'nm_gudang': nmGudang,
      'code_gudang': codeGudang,
      'id_product_lokasi': idProductLokasi,
      'nm_product_lokasi': nmProductLokasi,
      'complete_name': completeName,
      'nqty': nqty,
      'date_create': dateCreate?.toIso8601String(),
      'date_update': dateUpdate?.toIso8601String(),
    };
  }
}
