import 'dart:async';
import 'dart:io';
import '../../app/constats/api_endpoints.dart';

/// Kontrak pengecekan konektivitas jaringan
abstract class NetworkInfo {
  /// Memeriksa apakah perangkat memiliki akses jaringan
  Future<bool> get isConnected;

  /// Memeriksa apakah server pengembangan (192.168.1.127:8000) dapat dihubungi
  Future<bool> checkServerReachable({String? host, int? port, Duration timeout});
}

class NetworkInfoImpl implements NetworkInfo {
  const NetworkInfoImpl();

  @override
  Future<bool> get isConnected async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 3));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      // Fallback: jika offline dari internet publik, periksa apakah server lokal terjangkau
      return checkServerReachable();
    }
  }

  @override
  Future<bool> checkServerReachable({
    String? host,
    int? port,
    Duration timeout = const Duration(seconds: 3),
  }) async {
    final targetHost = host ?? ApiEndpoints.defaultHost;
    final targetPort = port ?? ApiEndpoints.defaultPort;

    try {
      final socket = await Socket.connect(targetHost, targetPort, timeout: timeout);
      socket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }
}

