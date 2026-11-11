/// Model data Master Lokasi Rak / Bin dari backend (ProductLokasiController.php)
class ProductLokasiModel {
  const ProductLokasiModel({
    required this.idProductLokasi,
    required this.nmProductLokasi,
    this.completeName,
    this.idGudang,
    this.nmGudang,
  });

  final int idProductLokasi;
  final String nmProductLokasi;
  final String? completeName;
  final int? idGudang;
  final String? nmGudang;

  factory ProductLokasiModel.fromJson(Map<String, dynamic> json) {
    return ProductLokasiModel(
      idProductLokasi: json['id_product_lokasi'] is int
          ? json['id_product_lokasi'] as int
          : int.tryParse(json['id_product_lokasi']?.toString() ?? '') ??
            int.tryParse(json['id']?.toString() ?? '') ??
            0,
      nmProductLokasi: json['nm_product_lokasi'] as String? ??
          json['nm_lokasi'] as String? ??
          json['name'] as String? ??
          '-',
      completeName: json['complete_name'] as String? ??
          json['nama_lokasi'] as String?,
      idGudang: json['id_gudang'] is int
          ? json['id_gudang'] as int
          : int.tryParse(json['id_gudang']?.toString() ?? ''),
      nmGudang: json['gudang']?['nm_gudang'] as String? ??
          json['nm_gudang'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id_product_lokasi': idProductLokasi,
    'nm_product_lokasi': nmProductLokasi,
    'complete_name': completeName,
    'id_gudang': idGudang,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductLokasiModel && idProductLokasi == other.idProductLokasi;

  @override
  int get hashCode => idProductLokasi.hashCode;
}

