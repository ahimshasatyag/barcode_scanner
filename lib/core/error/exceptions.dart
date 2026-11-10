/// Kelas dasar Exception untuk data layer
abstract class AppException implements Exception {
  const AppException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// Exception ketika server merespon dengan status error HTTP 5xx
class ServerException extends AppException {
  const ServerException(super.message, {super.statusCode, this.body});

  final dynamic body;
}

/// Exception ketika tidak ada koneksi jaringan atau host tidak terjangkau
class NetworkException extends AppException {
  const NetworkException(super.message, {super.statusCode});
}

/// Exception khusus untuk API Autentikasi (AuthController.php)
class AuthApiException extends AppException {
  const AuthApiException(super.message, {super.statusCode, this.errors});

  final Map<String, dynamic>? errors;
}

/// Exception ketika request melebihi batas waktu (timeout)
class RequestTimeoutException extends AppException {
  const RequestTimeoutException(super.message, {super.statusCode});
}

/// Exception ketika resource / ID tidak ditemukan (HTTP 404)
class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.statusCode = 404});
}

/// Exception ketika validasi gagal (HTTP 422)
class ValidationException extends AppException {
  const ValidationException(super.message, {super.statusCode = 422, this.errors});

  final Map<String, dynamic>? errors;
}

/// Exception ketika gagal membaca atau menyimpan ke cache lokal
class CacheException extends AppException {
  const CacheException(super.message, {super.statusCode});
}

