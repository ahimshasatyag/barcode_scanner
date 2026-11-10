import 'package:flutter/services.dart';

/// Service untuk memberikan umpan balik taktil (haptic) dan audio saat scan barcode
abstract final class ScannerFeedbackService {
  /// Umpan balik ketika barcode mesin berhasil diverifikasi
  static Future<void> triggerSuccess() async {
    await HapticFeedback.mediumImpact();
    await SystemSound.play(SystemSoundType.click);
  }

  /// Umpan balik ketika barcode terduplikasi atau peringatan
  static Future<void> triggerWarning() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
  }

  /// Umpan balik ketika barcode tidak valid atau gagal
  static Future<void> triggerError() async {
    await HapticFeedback.vibrate();
  }
}

