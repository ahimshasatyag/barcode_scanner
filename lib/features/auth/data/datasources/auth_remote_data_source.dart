import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_endpoints.dart';
import '../models/user_model.dart';

/// Exception kustom untuk kesalahan komunikasi dengan API Autentikasi
class AuthApiException implements Exception {
  const AuthApiException(this.message, {this.statusCode, this.errors});

  final String message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  @override
  String toString() => message;
}

/// Kontrak Data Source Autentikasi
abstract class AuthRemoteDataSource {
  /// Melakukan login via HTTP POST ke backend
  Future<UserModel> login({
    required String username,
    required String password,
  });

  /// Melakukan logout dan menghapus token di backend
  Future<void> logout({String? token});

  /// Mengambil profil user saat ini via HTTP GET dengan Bearer token
  Future<UserModel?> getCurrentUser({String? token});
}

/// Implementasi Data Source Autentikasi menggunakan HTTP Client
/// Terhubung langsung dengan Laravel AuthController.php
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = (baseUrl ?? ApiEndpoints.defaultBaseUrl).replaceAll(RegExp(r'/+$'), '');

  final http.Client _client;
  final String _baseUrl;
  UserModel? _cachedUser;

  /// Header standar untuk request JSON
  Map<String, String> _buildHeaders({String? token}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    } else if (_cachedUser?.token != null) {
      headers['Authorization'] = 'Bearer ${_cachedUser!.token}';
    }
    return headers;
  }

  @override
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    final uri = Uri.parse('$_baseUrl${ApiEndpoints.login}');

    try {
      final response = await _client
          .post(
            uri,
            headers: _buildHeaders(),
            body: jsonEncode({
              'username': username,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 15));

      return _handleLoginResponse(response);
    } on SocketException {
      throw const AuthApiException(
        'Tidak dapat terhubung ke server backend. Pastikan server Laravel menyala dan perangkat terhubung ke jaringan yang sama.',
      );
    } on TimeoutException {
      throw const AuthApiException(
        'Koneksi waktu habis (Request timeout). Server backend tidak merespons dalam 15 detik.',
      );
    } on http.ClientException catch (e) {
      throw AuthApiException(
        'Gagal berkomunikasi dengan server: ${e.message}',
      );
    } on FormatException {
      throw const AuthApiException(
        'Format respons dari server tidak valid (Bukan JSON).',
      );
    }
  }

  UserModel _handleLoginResponse(http.Response response) {
    Map<String, dynamic> responseJson;
    try {
      responseJson = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw AuthApiException(
        'Server mengembalikan respons tidak terduga (${response.statusCode}): ${response.body}',
        statusCode: response.statusCode,
      );
    }

    final message = responseJson['message']?.toString() ?? 'Terjadi kesalahan pada server.';
    final isSuccess = responseJson['status'] == true;

    if (response.statusCode == 200 && isSuccess) {
      final data = responseJson['data'] as Map<String, dynamic>?;
      if (data == null) {
        throw const AuthApiException('Respons server tidak memuat data pengguna.');
      }
      final user = UserModel.fromApiData(data);
      _cachedUser = user;
      return user;
    }

    // Penanganan respons error dari AuthController.php (401, 403, 404, 422, dll)
    final errors = responseJson['errors'] is Map<String, dynamic>
        ? responseJson['errors'] as Map<String, dynamic>
        : null;

    String detailedMessage = message;
    if (errors != null && errors.isNotEmpty) {
      final firstError = errors.values.first;
      if (firstError is List && firstError.isNotEmpty) {
        detailedMessage = '$message ${firstError.first}';
      }
    }

    throw AuthApiException(
      detailedMessage,
      statusCode: response.statusCode,
      errors: errors,
    );
  }

  @override
  Future<void> logout({String? token}) async {
    final activeToken = token ?? _cachedUser?.token;
    final uri = Uri.parse('$_baseUrl${ApiEndpoints.logout}');

    try {
      if (activeToken != null && activeToken.isNotEmpty) {
        await _client
            .post(
              uri,
              headers: _buildHeaders(token: activeToken),
            )
            .timeout(const Duration(seconds: 10));
      }
    } catch (_) {
      // Mengabaikan kegagalan jaringan saat logout agar sesi lokal tetap terhapus
    } finally {
      _cachedUser = null;
    }
  }

  @override
  Future<UserModel?> getCurrentUser({String? token}) async {
    final activeToken = token ?? _cachedUser?.token;
    if (activeToken == null || activeToken.isEmpty) {
      return _cachedUser;
    }

    final uri = Uri.parse('$_baseUrl${ApiEndpoints.me}');

    try {
      final response = await _client
          .get(
            uri,
            headers: _buildHeaders(token: activeToken),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        if (json['status'] == true && json['data'] != null) {
          final data = json['data'] as Map<String, dynamic>;
          final user = UserModel.fromApiData(data);
          _cachedUser = user;
          return user;
        }
      }
    } catch (_) {
      // Jika request profil gagal, gunakan cache terakhir
    }

    return _cachedUser;
  }
}
