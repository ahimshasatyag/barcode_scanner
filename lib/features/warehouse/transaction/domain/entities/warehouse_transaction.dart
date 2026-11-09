import 'machine_item.dart';

/// Jenis transaksi gudang mesin industri
enum TransactionType {
  /// Penerimaan kontainer mesin dari luar negeri (Jepang, Jerman, Taiwan, dsb)
  inbound,

  /// Pengeluaran mesin yang dimuat ke truk pengiriman klien
  outbound,
}

extension TransactionTypeX on TransactionType {
  String get label {
    switch (this) {
      case TransactionType.inbound:
        return 'Inbound (Masuk)';
      case TransactionType.outbound:
        return 'Outbound (Keluar)';
    }
  }

  String get shortLabel {
    switch (this) {
      case TransactionType.inbound:
        return 'Inbound';
      case TransactionType.outbound:
        return 'Outbound';
    }
  }

  String get description {
    switch (this) {
      case TransactionType.inbound:
        return 'Penerimaan Kontainer Mesin Impor';
      case TransactionType.outbound:
        return 'Pemuatan Truk Pengiriman Klien';
    }
  }

  String get refLabel {
    switch (this) {
      case TransactionType.inbound:
        return 'No. Kontainer / B/L';
      case TransactionType.outbound:
        return 'No. Surat Jalan / DO';
    }
  }

  String get partnerLabel {
    switch (this) {
      case TransactionType.inbound:
        return 'Eksportir / Pabrik Asal';
      case TransactionType.outbound:
        return 'Klien / Perusahaan Tujuan';
    }
  }

  String get vehicleLabel {
    switch (this) {
      case TransactionType.inbound:
        return 'No. Seal Kontainer';
      case TransactionType.outbound:
        return 'No. Polisi Truk';
    }
  }
}

/// Status alur kerja transaksi pemindaian
enum TransactionStatus {
  draft,
  inProgress,
  completed,
  cancelled,
}

extension TransactionStatusX on TransactionStatus {
  String get label {
    switch (this) {
      case TransactionStatus.draft:
        return 'Menunggu Scan';
      case TransactionStatus.inProgress:
        return 'Sedang Scan';
      case TransactionStatus.completed:
        return 'Selesai Terverifikasi';
      case TransactionStatus.cancelled:
        return 'Dibatalkan';
    }
  }
}

/// Entitas Transaksi Pergudangan Mesin
class WarehouseTransaction {
  const WarehouseTransaction({
    required this.id,
    required this.type,
    required this.title,
    required this.referenceNumber,
    required this.partnerName,
    required this.vehicleOrContainerId,
    required this.createdAt,
    required this.targetQuantity,
    this.status = TransactionStatus.inProgress,
    this.items = const [],
    this.operatorName,
    this.notes,
    this.completedAt,
  });

  /// ID unik transaksi (misal: `TRX-INB-20261109-001`)
  final String id;

  /// Tipe transaksi (Inbound atau Outbound)
  final TransactionType type;

  /// Judul deskriptif (misal: `Kontainer 40ft Mesin CNC Lathe dari Kobe Port`)
  final String title;

  /// Nomor referensi dokumen (No. Kontainer atau No. Surat Jalan / Delivery Order)
  final String referenceNumber;

  /// Nama partner (Shipper Jepang/Jerman atau Klien Manufaktur)
  final String partnerName;

  /// Nomor armada / identitas kontainer (Plat Truk atau No Seal Kontainer)
  final String vehicleOrContainerId;

  /// Waktu pembuatan transaksi
  final DateTime createdAt;

  /// Target jumlah mesin yang harus dipindai sesuai dokumen manifes
  final int targetQuantity;

  /// Status pemindaian transaksi
  final TransactionStatus status;

  /// Daftar mesin yang sudah berhasil dipindai
  final List<MachineItem> items;

  /// Nama operator warehouse yang bertugas
  final String? operatorName;

  /// Catatan khusus (kondisi peti kemas, inspeksi fisik, dll)
  final String? notes;

  /// Waktu saat transaksi dinyatakan selesai
  final DateTime? completedAt;

  /// Jumlah mesin yang telah dipindai
  int get scannedQuantity => items.length;

  /// Apakah semua mesin sesuai target sudah selesai dipindai
  bool get isFullyScanned => scannedQuantity >= targetQuantity;

  /// Persentase progres pemindaian (0.0 sampai 1.0)
  double get progress {
    if (targetQuantity <= 0) return 0.0;
    return (scannedQuantity / targetQuantity).clamp(0.0, 1.0);
  }

  /// Persentase dalam bilangan bulat (0 - 100)
  int get progressPercent => (progress * 100).round();

  WarehouseTransaction copyWith({
    String? id,
    TransactionType? type,
    String? title,
    String? referenceNumber,
    String? partnerName,
    String? vehicleOrContainerId,
    DateTime? createdAt,
    int? targetQuantity,
    TransactionStatus? status,
    List<MachineItem>? items,
    String? operatorName,
    String? notes,
    DateTime? completedAt,
  }) {
    return WarehouseTransaction(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      partnerName: partnerName ?? this.partnerName,
      vehicleOrContainerId: vehicleOrContainerId ?? this.vehicleOrContainerId,
      createdAt: createdAt ?? this.createdAt,
      targetQuantity: targetQuantity ?? this.targetQuantity,
      status: status ?? this.status,
      items: items ?? this.items,
      operatorName: operatorName ?? this.operatorName,
      notes: notes ?? this.notes,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}

