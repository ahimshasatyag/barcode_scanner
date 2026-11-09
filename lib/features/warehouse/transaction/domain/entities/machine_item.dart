/// Entitas mesin industri yang dipindai saat Inbound / Outbound
class MachineItem {
  const MachineItem({
    required this.serialNumber,
    required this.modelName,
    required this.brand,
    required this.barcode,
    this.weightKg,
    this.countryOfOrigin,
    this.specification,
    this.scannedAt,
    this.isVerified = true,
  });

  /// Nomor seri unik mesin (misal: `CNC-VMC850-2026-091`)
  final String serialNumber;

  /// Model atau tipe mesin (misal: `Vertical Machining Center VMC-850`)
  final String modelName;

  /// Merk mesin (misal: `Mazak`, `Okuma`, `Makino`, `Doosan`, `Fanuc`)
  final String brand;

  /// Kode barcode yang dipindai
  final String barcode;

  /// Berat mesin dalam Kilogram (Kg)
  final double? weightKg;

  /// Negara asal pembuat (misal: Jepang, Jerman, Taiwan)
  final String? countryOfOrigin;

  /// Spesifikasi singkat (misal: `3-Axis, Spindle 12.000 RPM, BT40`)
  final String? specification;

  /// Waktu pemindaian barcode
  final DateTime? scannedAt;

  /// Apakah verifikasi barcode valid
  final bool isVerified;

  MachineItem copyWith({
    String? serialNumber,
    String? modelName,
    String? brand,
    String? barcode,
    double? weightKg,
    String? countryOfOrigin,
    String? specification,
    DateTime? scannedAt,
    bool? isVerified,
  }) {
    return MachineItem(
      serialNumber: serialNumber ?? this.serialNumber,
      modelName: modelName ?? this.modelName,
      brand: brand ?? this.brand,
      barcode: barcode ?? this.barcode,
      weightKg: weightKg ?? this.weightKg,
      countryOfOrigin: countryOfOrigin ?? this.countryOfOrigin,
      specification: specification ?? this.specification,
      scannedAt: scannedAt ?? this.scannedAt,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  @override
  String toString() =>
      'MachineItem(sn: $serialNumber, model: $modelName, brand: $brand, barcode: $barcode)';
}

