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
  });

  factory MachineItemModel.fromJson(Map<String, dynamic> json) {
    return MachineItemModel(
      serialNumber: json['serial_number'] as String? ?? json['serialNumber'] as String? ?? '',
      modelName: json['model_name'] as String? ?? json['modelName'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      barcode: json['barcode'] as String? ?? '',
      weightKg: (json['weight_kg'] ?? json['weightKg'] as num?)?.toDouble(),
      countryOfOrigin: json['country_of_origin'] as String? ?? json['countryOfOrigin'] as String?,
      specification: json['specification'] as String?,
      scannedAt: json['scanned_at'] != null
          ? DateTime.tryParse(json['scanned_at'] as String)
          : json['scannedAt'] != null
              ? DateTime.tryParse(json['scannedAt'] as String)
              : null,
      isVerified: json['is_verified'] as bool? ?? json['isVerified'] as bool? ?? true,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serial_number': serialNumber,
      'model_name': modelName,
      'brand': brand,
      'barcode': barcode,
      'weight_kg': weightKg,
      'country_of_origin': countryOfOrigin,
      'specification': specification,
      'scanned_at': scannedAt?.toIso8601String(),
      'is_verified': isVerified,
    };
  }
}

