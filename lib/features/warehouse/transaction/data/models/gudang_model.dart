/// Model data Master Gudang dari backend (GudangController.php)
class GudangModel {
  const GudangModel({
    required this.idGudang,
    required this.nmGudang,
    required this.codeGudang,
  });

  final int idGudang;
  final String nmGudang;
  final String codeGudang;

  factory GudangModel.fromJson(Map<String, dynamic> json) {
    return GudangModel(
      idGudang: json['id_gudang'] is int
          ? json['id_gudang'] as int
          : int.tryParse(json['id_gudang']?.toString() ?? '') ??
            int.tryParse(json['id']?.toString() ?? '') ??
            0,
      nmGudang: json['nm_gudang'] as String? ??
          json['name'] as String? ??
          json['nama_gudang'] as String? ??
          '-',
      codeGudang: json['code_gudang'] as String? ??
          json['code'] as String? ??
          json['kode_gudang'] as String? ??
          '-',
    );
  }

  Map<String, dynamic> toJson() => {
    'id_gudang': idGudang,
    'nm_gudang': nmGudang,
    'code_gudang': codeGudang,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GudangModel && idGudang == other.idGudang;

  @override
  int get hashCode => idGudang.hashCode;
}

