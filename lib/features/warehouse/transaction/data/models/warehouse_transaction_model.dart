import '../../domain/entities/warehouse_transaction.dart';
import 'machine_item_model.dart';

class WarehouseTransactionModel extends WarehouseTransaction {
  const WarehouseTransactionModel({
    required super.id,
    required super.type,
    required super.title,
    required super.referenceNumber,
    required super.partnerName,
    required super.vehicleOrContainerId,
    required super.createdAt,
    required super.targetQuantity,
    super.status,
    super.items,
    super.operatorName,
    super.notes,
    super.completedAt,
    super.idGudang,
    super.nmGudang,
    super.idSupplier,
    super.nmSupplier,
    super.idDo,
    super.codeDo,
    super.idProductLokasi,
    super.nmProductLokasi,
  });

  factory WarehouseTransactionModel.fromJson(Map<String, dynamic> json) {
    final typeStr = (json['trx_type'] as String? ??
            json['type'] as String? ??
            'inbound')
        .toLowerCase();
    final type =
        typeStr.contains('out') ? TransactionType.outbound : TransactionType.inbound;

    final statusStr = (json['status'] as String? ?? 'in_progress').toLowerCase();
    TransactionStatus status;
    if (statusStr.contains('comp') || statusStr.contains('selesai')) {
      status = TransactionStatus.completed;
    } else if (statusStr.contains('cancel') || statusStr.contains('batal')) {
      status = TransactionStatus.cancelled;
    } else if (statusStr.contains('draft') || statusStr.contains('tunggu')) {
      status = TransactionStatus.draft;
    } else {
      status = TransactionStatus.inProgress;
    }

    final rawItems = (json['items'] ?? json['details'] ?? []) as List<dynamic>? ?? [];
    final items = rawItems
        .map((item) => MachineItemModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return WarehouseTransactionModel(
      id: json['trx_code'] as String? ??
          json['id_transaksi']?.toString() ??
          json['id'] as String? ??
          '',
      type: type,
      title: json['title'] as String? ?? '',
      referenceNumber: json['ref_number'] as String? ??
          json['reference_number'] as String? ??
          json['referenceNumber'] as String? ??
          json['code_do'] as String? ??
          json['ref_no'] as String? ??
          '',
      partnerName: json['partner_name'] as String? ??
          json['partnerName'] as String? ??
          json['nm_suppliers'] as String? ??
          json['nm_customers'] as String? ??
          json['partner'] as String? ??
          '',
      vehicleOrContainerId: json['vehicle_or_container'] as String? ??
          json['vehicle_or_container_id'] as String? ??
          json['vehicleOrContainerId'] as String? ??
          json['vehicle_id'] as String? ??
          '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      targetQuantity: (json['target_qty'] ??
              json['target_quantity'] ??
              json['targetQuantity'] as num?)
          ?.toInt() ??
          0,
      status: status,
      items: items,
      operatorName: json['operator_name'] as String? ?? json['operatorName'] as String?,
      notes: json['notes'] as String?,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'].toString())
          : null,
      idGudang: json['id_gudang'] as int?,
      nmGudang: json['nm_gudang'] as String? ?? json['gudang']?['nm_gudang'] as String?,
      idSupplier: json['id_supplier'] as int? ?? json['id_suppliers'] as int?,
      nmSupplier: json['nm_supplier'] as String? ?? json['nm_suppliers'] as String?,
      idDo: json['id_do'] as int?,
      codeDo: json['code_do'] as String?,
      idProductLokasi: json['id_product_lokasi'] as int?,
      nmProductLokasi: json['nm_product_lokasi'] as String? ??
          json['lokasi']?['nm_product_lokasi'] as String?,
    );
  }

  factory WarehouseTransactionModel.fromEntity(WarehouseTransaction entity) {
    return WarehouseTransactionModel(
      id: entity.id,
      type: entity.type,
      title: entity.title,
      referenceNumber: entity.referenceNumber,
      partnerName: entity.partnerName,
      vehicleOrContainerId: entity.vehicleOrContainerId,
      createdAt: entity.createdAt,
      targetQuantity: entity.targetQuantity,
      status: entity.status,
      items: entity.items,
      operatorName: entity.operatorName,
      notes: entity.notes,
      completedAt: entity.completedAt,
      idGudang: entity.idGudang,
      nmGudang: entity.nmGudang,
      idSupplier: entity.idSupplier,
      nmSupplier: entity.nmSupplier,
      idDo: entity.idDo,
      codeDo: entity.codeDo,
      idProductLokasi: entity.idProductLokasi,
      nmProductLokasi: entity.nmProductLokasi,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trx_code': id,
      'type': type.name,
      'trx_type': type.name,
      'title': title,
      'reference_number': referenceNumber,
      'ref_number': referenceNumber,
      'partner_name': partnerName,
      'vehicle_or_container_id': vehicleOrContainerId,
      'vehicle_or_container': vehicleOrContainerId,
      'created_at': createdAt.toIso8601String(),
      'target_quantity': targetQuantity,
      'target_qty': targetQuantity,
      'scanned_qty': items.length,
      'status': status.name,
      'items': items.map((i) => MachineItemModel.fromEntity(i).toJson()).toList(),
      'operator_name': operatorName,
      'notes': notes,
      'completed_at': completedAt?.toIso8601String(),
      'id_gudang': idGudang,
      'nm_gudang': nmGudang,
      'id_supplier': idSupplier,
      'nm_supplier': nmSupplier,
      'id_do': idDo,
      'code_do': codeDo,
      'id_product_lokasi': idProductLokasi,
      'nm_product_lokasi': nmProductLokasi,
    };
  }
}

