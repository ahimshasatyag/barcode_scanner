/// Entitas mesin / produk industri dari database backend (ProductSnController & GudangController)
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
    this.idProductSn,
    this.idProduct,
    this.idGudang,
    this.nmGudang,
    this.codeGudang,
    this.idProductLokasi,
    this.nmProductLokasi,
    this.completeName,
    this.nqty = 1,
    this.dateCreate,
    this.dateUpdate,
  });

  /// Nomor seri unik mesin dari m_product_sn.sn
  final String serialNumber;

  /// Model / nama produk
  final String modelName;

  /// Merk mesin / kode gudang
  final String brand;

  /// Kode barcode (identik dengan sn)
  final String barcode;

  /// Berat mesin dalam Kg
  final double? weightKg;

  /// Negara asal / nama gudang penyimpanan
  final String? countryOfOrigin;

  /// Spesifikasi teknis atau info lokasi lengkap
  final String? specification;

  /// Waktu pemindaian
  final DateTime? scannedAt;

  /// Apakah item valid terdaftar di database
  final bool isVerified;

  // ==========================================
  // Kolom Asli Database Backend (ProductSnController)
  // ==========================================
  final int? idProductSn;
  final int? idProduct;
  final int? idGudang;
  final String? nmGudang;
  final String? codeGudang;
  final int? idProductLokasi;
  final String? nmProductLokasi;
  final String? completeName;
  final int nqty;
  final DateTime? dateCreate;
  final DateTime? dateUpdate;

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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MachineItem &&
          serialNumber.trim().toUpperCase() ==
              other.serialNumber.trim().toUpperCase();

  @override
  int get hashCode => serialNumber.trim().toUpperCase().hashCode;

  @override
  String toString() =>
      'MachineItem(idProductSn: $idProductSn, sn: $serialNumber, gudang: $nmGudang, lokasi: $completeName)';
}
