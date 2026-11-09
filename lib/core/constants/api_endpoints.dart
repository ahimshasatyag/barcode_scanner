import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

/// Konfigurasi URL dan Endpoint API Backend (Laravel AuthController)
abstract final class ApiEndpoints {
  /// Base URL API default yang otomatis mendeteksi platform:
  /// - Android Emulator: 10.0.2.2 (alias localhost pada host mesin pengembangan)
  /// - Windows / Web / iOS: 127.0.0.1 atau localhost
  static String get defaultBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000/api';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8000/api';
      }
    } catch (_) {
      // Fallback untuk platform tanpa dart:io
    }
    return 'http://127.0.0.1:8000/api';
  }

  /// Endpoint Autentikasi sesuai dengan AuthController.php
  static const String login = '/login';
  static const String me = '/me';
  static const String logout = '/logout';
}

