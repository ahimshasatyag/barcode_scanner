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
      idProductLokasi: json['id_product_lokasi'] as int? ?? 0,
      nmProductLokasi: json['nm_product_lokasi'] as String? ?? '-',
      completeName: json['complete_name'] as String?,
      idGudang: json['id_gudang'] as int?,
      nmGudang: json['gudang']?['nm_gudang'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id_product_lokasi': idProductLokasi,
    'nm_product_lokasi': nmProductLokasi,
    'complete_name': completeName,
    'id_gudang': idGudang,
  };
}

