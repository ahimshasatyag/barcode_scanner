/// Model Master Supplier dari tabel m_suppliers / m_supplier
class SupplierModel {
  const SupplierModel({
    required this.idSuppliers,
    required this.nmSuppliers,
    this.suppliersAddress,
    this.suppliersPhone,
    this.suppliersEmail,
  });

  final int idSuppliers;
  final String nmSuppliers;
  final String? suppliersAddress;
  final String? suppliersPhone;
  final String? suppliersEmail;

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      idSuppliers: json['id_suppliers'] is int
          ? json['id_suppliers'] as int
          : int.tryParse(json['id_suppliers']?.toString() ?? '') ??
            int.tryParse(json['id_supplier']?.toString() ?? '') ??
            int.tryParse(json['id']?.toString() ?? '') ??
            0,
      nmSuppliers: json['nm_suppliers'] as String? ??
          json['nm_supplier'] as String? ??
          json['nama_supplier'] as String? ??
          json['name'] as String? ??
          '-',
      suppliersAddress: json['suppliers_address'] as String? ??
          json['address'] as String? ??
          json['alamat'] as String?,
      suppliersPhone: json['suppliers_phone'] as String? ??
          json['phone'] as String? ??
          json['no_telp'] as String? ??
          json['suppliers_mobile'] as String?,
      suppliersEmail: json['suppliers_email'] as String? ??
          json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id_suppliers': idSuppliers,
    'nm_suppliers': nmSuppliers,
    'suppliers_address': suppliersAddress,
    'suppliers_phone': suppliersPhone,
    'suppliers_email': suppliersEmail,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupplierModel && idSuppliers == other.idSuppliers;

  @override
  int get hashCode => idSuppliers.hashCode;
}

