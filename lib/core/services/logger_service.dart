import 'package:flutter/foundation.dart';

/// Level pencatatan log sistem
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// Service pencatatan log terpusat dengan format yang rapi
abstract final class LoggerService {
  static bool enableLogging = kDebugMode;

  static void d(String message, {String tag = 'DEBUG'}) {
    _log(LogLevel.debug, message, tag);
  }

  static void i(String message, {String tag = 'INFO'}) {
    _log(LogLevel.info, message, tag);
  }

  static void w(String message, {String tag = 'WARN'}) {
    _log(LogLevel.warning, message, tag);
  }

  static void e(String message, {String tag = 'ERROR', Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, tag);
    if (error != null) {
      debugPrint('   └─ Detail Error: $error');
    }
    if (stackTrace != null) {
      debugPrint('   └─ StackTrace: $stackTrace');
    }
  }

  static void _log(LogLevel level, String message, String tag) {
    if (!enableLogging) return;

    final now = DateTime.now();
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

    final symbol = switch (level) {
      LogLevel.debug => '🔍',
      LogLevel.info => 'ℹ️',
      LogLevel.warning => '⚠️',
      LogLevel.error => '🛑',
    };

    debugPrint('$symbol [$timeStr][$tag] $message');
  }
}

