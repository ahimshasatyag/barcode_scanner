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
  });

  factory WarehouseTransactionModel.fromJson(Map<String, dynamic> json) {
    final typeStr = (json['type'] as String? ?? 'inbound').toLowerCase();
    final type = typeStr.contains('out') ? TransactionType.outbound : TransactionType.inbound;

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

    final rawItems = json['items'] as List<dynamic>? ?? [];
    final items = rawItems
        .map((item) => MachineItemModel.fromJson(item as Map<String, dynamic>))
        .toList();

    return WarehouseTransactionModel(
      id: json['id'] as String? ?? '',
      type: type,
      title: json['title'] as String? ?? '',
      referenceNumber: json['reference_number'] as String? ??
          json['referenceNumber'] as String? ??
          json['ref_no'] as String? ??
          '',
      partnerName: json['partner_name'] as String? ??
          json['partnerName'] as String? ??
          json['partner'] as String? ??
          '',
      vehicleOrContainerId: json['vehicle_or_container_id'] as String? ??
          json['vehicleOrContainerId'] as String? ??
          json['vehicle_id'] as String? ??
          '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      targetQuantity: (json['target_quantity'] ?? json['targetQuantity'] as num?)?.toInt() ?? 0,
      status: status,
      items: items,
      operatorName: json['operator_name'] as String? ?? json['operatorName'] as String?,
      notes: json['notes'] as String?,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'] as String)
          : null,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'reference_number': referenceNumber,
      'partner_name': partnerName,
      'vehicle_or_container_id': vehicleOrContainerId,
      'created_at': createdAt.toIso8601String(),
      'target_quantity': targetQuantity,
      'status': status.name,
      'items': items.map((i) => MachineItemModel.fromEntity(i).toJson()).toList(),
      'operator_name': operatorName,
      'notes': notes,
      'completed_at': completedAt?.toIso8601String(),
    };
  }
}

