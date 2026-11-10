import 'package:flutter/foundation.dart';
import '../constats/api_endpoints.dart';

/// Lingkungan eksekusi aplikasi
enum Environment {
  development,
  staging,
  production,
}

/// Konfigurasi Global Aplikasi PT Eka Maju Mesinindo
class AppConfig {
  AppConfig._({
    required this.environment,
    required this.host,
    required this.port,
    required this.apiPrefix,
    required this.connectTimeout,
    required this.receiveTimeout,
    required this.enableLogging,
  });

  /// Instance singleton aktif
  static AppConfig current = AppConfig.development();

  final Environment environment;
  final String host;
  final int port;
  final String apiPrefix;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final bool enableLogging;

  /// Menginisialisasi konfigurasi aplikasi saat startup
  static void initialize({
    Environment environment = Environment.development,
    String? host,
    int? port,
    String? apiPrefix,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    bool? enableLogging,
  }) {
    switch (environment) {
      case Environment.development:
        current = AppConfig.development(
          host: host,
          port: port,
          apiPrefix: apiPrefix,
          connectTimeout: connectTimeout,
          receiveTimeout: receiveTimeout,
          enableLogging: enableLogging,
        );
        break;
      case Environment.staging:
        current = AppConfig.staging(
          host: host,
          port: port,
          apiPrefix: apiPrefix,
          connectTimeout: connectTimeout,
          receiveTimeout: receiveTimeout,
          enableLogging: enableLogging,
        );
        break;
      case Environment.production:
        current = AppConfig.production(
          host: host,
          port: port,
          apiPrefix: apiPrefix,
          connectTimeout: connectTimeout,
          receiveTimeout: receiveTimeout,
          enableLogging: enableLogging,
        );
        break;
    }
  }

  /// Konfigurasi Development (default ke IP 192.168.1.127:8000)
  factory AppConfig.development({
    String? host,
    int? port,
    String? apiPrefix,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    bool? enableLogging,
  }) {
    return AppConfig._(
      environment: Environment.development,
      host: host ?? ApiEndpoints.defaultHost,
      port: port ?? ApiEndpoints.defaultPort,
      apiPrefix: apiPrefix ?? ApiEndpoints.apiPrefix,
      connectTimeout: connectTimeout ?? const Duration(seconds: 15),
      receiveTimeout: receiveTimeout ?? const Duration(seconds: 15),
      enableLogging: enableLogging ?? kDebugMode,
    );
  }

  /// Konfigurasi Staging
  factory AppConfig.staging({
    String? host,
    int? port,
    String? apiPrefix,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    bool? enableLogging,
  }) {
    return AppConfig._(
      environment: Environment.staging,
      host: host ?? 'staging-api.ekamaju.com',
      port: port ?? 443,
      apiPrefix: apiPrefix ?? ApiEndpoints.apiPrefix,
      connectTimeout: connectTimeout ?? const Duration(seconds: 20),
      receiveTimeout: receiveTimeout ?? const Duration(seconds: 20),
      enableLogging: enableLogging ?? true,
    );
  }

  /// Konfigurasi Production
  factory AppConfig.production({
    String? host,
    int? port,
    String? apiPrefix,
    Duration? connectTimeout,
    Duration? receiveTimeout,
    bool? enableLogging,
  }) {
    return AppConfig._(
      environment: Environment.production,
      host: host ?? 'api.ekamaju.com',
      port: port ?? 443,
      apiPrefix: apiPrefix ?? ApiEndpoints.apiPrefix,
      connectTimeout: connectTimeout ?? const Duration(seconds: 30),
      receiveTimeout: receiveTimeout ?? const Duration(seconds: 30),
      enableLogging: enableLogging ?? false,
    );
  }

  /// Base URL API lengkap (misal: `http://192.168.1.127:8000/api`)
  String get baseUrl {
    final scheme = (port == 443) ? 'https' : 'http';
    final portPart = (port == 80 || port == 443) ? '' : ':$port';
    return '$scheme://$host$portPart$apiPrefix';
  }

  /// Apakah saat ini berjalan di mode development
  bool get isDevelopment => environment == Environment.development;

  /// Apakah saat ini berjalan di mode production
  bool get isProduction => environment == Environment.production;
}

