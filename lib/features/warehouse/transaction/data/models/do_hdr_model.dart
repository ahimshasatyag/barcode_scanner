/// Model Dokumen Delivery Order (DO) dari tabel tb_do_hdr
class DoHdrModel {
  const DoHdrModel({
    required this.idDo,
    required this.codeDo,
    this.dateDo,
    this.idCustomers,
    this.nmCustomers,
    this.codeSo,
    this.statusDo,
  });

  final int idDo;
  final String codeDo;
  final String? dateDo;
  final int? idCustomers;
  final String? nmCustomers;
  final String? codeSo;
  final String? statusDo;

  factory DoHdrModel.fromJson(Map<String, dynamic> json) {
    return DoHdrModel(
      idDo: json['id_do'] is int
          ? json['id_do'] as int
          : int.tryParse(json['id_do']?.toString() ?? '') ??
            int.tryParse(json['id']?.toString() ?? '') ??
            0,
      codeDo: json['code_do'] as String? ??
          json['no_do'] as String? ??
          json['code'] as String? ??
          '-',
      dateDo: json['date_do']?.toString(),
      idCustomers: json['id_customers'] is int
          ? json['id_customers'] as int
          : int.tryParse(json['id_customers']?.toString() ?? '') ??
            int.tryParse(json['id_customer']?.toString() ?? ''),
      nmCustomers: json['nm_customers'] as String? ??
          json['customer'] as String? ??
          json['client'] as String?,
      codeSo: json['code_so'] as String? ?? json['no_so'] as String?,
      statusDo: json['status_do'] as String? ?? json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id_do': idDo,
    'code_do': codeDo,
    'date_do': dateDo,
    'id_customers': idCustomers,
    'nm_customers': nmCustomers,
    'code_so': codeSo,
    'status_do': statusDo,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoHdrModel && idDo == other.idDo;

  @override
  int get hashCode => idDo.hashCode;
}

