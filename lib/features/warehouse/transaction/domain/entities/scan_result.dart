import 'machine_item.dart';

/// Hasil dari proses pemindaian barcode mesin
class ScanResult {
  const ScanResult({
    required this.isSuccess,
    required this.rawBarcode,
    required this.message,
    this.machineItem,
    required this.timestamp,
    this.isDuplicate = false,
  });

  /// Apakah barcode valid dan berhasil diverifikasi
  final bool isSuccess;

  /// Teks barcode yang dibaca oleh kamera
  final String rawBarcode;

  /// Pesan status (misal: "Mesin Mazak VMC-850 berhasil diverifikasi")
  final String message;

  /// Data entitas mesin jika ditemukan
  final MachineItem? machineItem;

  /// Waktu scan dilakukan
  final DateTime timestamp;

  /// Apakah item ini sudah pernah discan sebelumnya dalam transaksi ini
  final bool isDuplicate;

  factory ScanResult.success({
    required String rawBarcode,
    required MachineItem machineItem,
    String? message,
  }) {
    return ScanResult(
      isSuccess: true,
      rawBarcode: rawBarcode,
      machineItem: machineItem,
      message: message ?? 'Mesin ${machineItem.modelName} berhasil diverifikasi.',
      timestamp: DateTime.now(),
    );
  }

  factory ScanResult.duplicate({
    required String rawBarcode,
    required MachineItem machineItem,
  }) {
    return ScanResult(
      isSuccess: false,
      rawBarcode: rawBarcode,
      machineItem: machineItem,
      message: 'Peringatan: Barcode $rawBarcode (${machineItem.serialNumber}) sudah pernah dipindai!',
      timestamp: DateTime.now(),
      isDuplicate: true,
    );
  }

  factory ScanResult.failure({
    required String rawBarcode,
    required String message,
  }) {
    return ScanResult(
      isSuccess: false,
      rawBarcode: rawBarcode,
      message: message,
      timestamp: DateTime.now(),
    );
  }
}

