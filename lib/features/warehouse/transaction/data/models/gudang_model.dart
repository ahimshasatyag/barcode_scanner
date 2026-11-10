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
      idGudang: json['id_gudang'] as int? ?? 0,
      nmGudang: json['nm_gudang'] as String? ?? '-',
      codeGudang: json['code_gudang'] as String? ?? '-',
    );
  }

  Map<String, dynamic> toJson() => {
    'id_gudang': idGudang,
    'nm_gudang': nmGudang,
    'code_gudang': codeGudang,
  };
}

