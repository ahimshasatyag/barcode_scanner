/// Kelas dasar Failure untuk Clean Architecture domain layer
abstract class Failure {
  const Failure(this.message, {this.statusCode, this.code});

  final String message;
  final int? statusCode;
  final String? code;

  @override
  String toString() => '$runtimeType: $message (code: $statusCode)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure &&
        other.message == message &&
        other.statusCode == statusCode &&
        other.code == code;
  }

  @override
  int get hashCode => Object.hash(message, statusCode, code);
}

/// Kegagalan komunikasi dengan server (HTTP 500, error response)
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.statusCode, super.code});
}

/// Kegagalan jaringan / koneksi tidak terhubung ke server (misal IP 192.168.1.127 tidak terjangkau)
class NetworkFailure extends Failure {
  const NetworkFailure(
    super.message, {
    super.statusCode,
    super.code = 'NETWORK_ERROR',
  });
}

/// Kegagalan autentikasi / kredensial salah / sesi kedaluwarsa (HTTP 401 / 403)
class AuthFailure extends Failure {
  const AuthFailure(
    super.message, {
    super.statusCode = 401,
    super.code = 'AUTH_ERROR',
  });
}

/// Kegagalan validasi input pengguna atau manifes (HTTP 422)
class ValidationFailure extends Failure {
  const ValidationFailure(
    super.message, {
    this.errors,
    super.statusCode = 422,
    super.code = 'VALIDATION_ERROR',
  });

  final Map<String, dynamic>? errors;
}

/// Data tidak ditemukan di server / database lokal (HTTP 404)
class NotFoundFailure extends Failure {
  const NotFoundFailure(
    super.message, {
    super.statusCode = 404,
    super.code = 'NOT_FOUND',
  });
}

/// Kegagalan penyimpanan lokal / cache
class CacheFailure extends Failure {
  const CacheFailure(
    super.message, {
    super.statusCode,
    super.code = 'CACHE_ERROR',
  });
}

