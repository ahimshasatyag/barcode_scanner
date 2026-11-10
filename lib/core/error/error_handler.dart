import 'dart:async';
import 'dart:io';
import 'exceptions.dart';
import 'failures.dart';

/// Utilitas penanganan dan pemetaan error/exception menjadi Failure
abstract final class ErrorHandler {
  /// Mengonversi berbagai tipe exception menjadi Failure yang ramah pengguna
  static Failure handle(dynamic error) {
    if (error is AuthApiException) {
      if (error.statusCode == 422) {
        return ValidationFailure(
          error.message,
          errors: error.errors,
          statusCode: error.statusCode,
        );
      }
      return AuthFailure(
        error.message,
        statusCode: error.statusCode ?? 401,
      );
    }

    if (error is ValidationException) {
      return ValidationFailure(
        error.message,
        errors: error.errors,
        statusCode: error.statusCode,
      );
    }

    if (error is NotFoundException) {
      return NotFoundFailure(
        error.message,
        statusCode: error.statusCode,
      );
    }

    if (error is ServerException) {
      return ServerFailure(
        error.message,
        statusCode: error.statusCode,
      );
    }

    if (error is NetworkException) {
      return NetworkFailure(error.message);
    }

    if (error is RequestTimeoutException || error is TimeoutException) {
      return const NetworkFailure(
        'Koneksi waktu habis (Timeout). Server di 192.168.1.127 tidak merespon dalam batas waktu yang ditentukan.',
      );
    }

    if (error is SocketException) {
      return NetworkFailure(
        'Tidak dapat terhubung ke server (192.168.1.127:8000). Pastikan HP dan PC berada di jaringan Wi-Fi yang sama dan artisan serve aktif.',
      );
    }

    if (error is HttpException) {
      return ServerFailure('Terjadi kesalahan protokol HTTP: ${error.message}');
    }

    if (error is FormatException) {
      return const ServerFailure('Format respon data dari server tidak valid (bukan JSON yang valid).');
    }

    return ServerFailure(error.toString());
  }
}

