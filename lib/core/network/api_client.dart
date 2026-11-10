import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../app/constats/api_endpoints.dart';
import '../error/exceptions.dart';
import 'api_response.dart';

/// Client HTTP terpusat untuk komunikasi dengan backend Laravel
class ApiClient {
  ApiClient({
    http.Client? httpClient,
    String? baseUrl,
    this.defaultTimeout = const Duration(seconds: 15),
  })  : _httpClient = httpClient ?? http.Client(),
        _baseUrl = (baseUrl ?? ApiEndpoints.defaultBaseUrl).replaceAll(RegExp(r'/+$'), '');

  final http.Client _httpClient;
  final String _baseUrl;
  final Duration defaultTimeout;

  String? _authToken;

  /// Mengatur token otentikasi Bearer secara global
  void setAuthToken(String? token) {
    _authToken = token;
  }

  /// Menghapus token saat logout
  void clearAuthToken() {
    _authToken = null;
  }

  String get baseUrl => _baseUrl;

  /// Membangun header request JSON
  Map<String, String> _buildHeaders({Map<String, String>? extraHeaders}) {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
    };

    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }

    return headers;
  }

  Uri _resolveUri(String endpoint, [Map<String, dynamic>? queryParameters]) {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final fullUrl = '$_baseUrl$cleanEndpoint';

    final uri = Uri.parse(fullUrl);
    if (queryParameters == null || queryParameters.isEmpty) {
      return uri;
    }

    final queryMap = queryParameters.map((key, value) => MapEntry(key, value.toString()));
    return uri.replace(queryParameters: queryMap);
  }

  /// HTTP GET Request
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    T Function(dynamic data)? decoder,
  }) async {
    return _sendRequest<T>(
      () => _httpClient.get(
        _resolveUri(endpoint, queryParameters),
        headers: _buildHeaders(extraHeaders: headers),
      ),
      decoder: decoder,
    );
  }

  /// HTTP POST Request
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
    T Function(dynamic data)? decoder,
  }) async {
    final encodedBody = (body != null && body is! String) ? jsonEncode(body) : body as String?;

    return _sendRequest<T>(
      () => _httpClient.post(
        _resolveUri(endpoint),
        headers: _buildHeaders(extraHeaders: headers),
        body: encodedBody,
      ),
      decoder: decoder,
    );
  }

  /// HTTP PUT Request
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
    T Function(dynamic data)? decoder,
  }) async {
    final encodedBody = (body != null && body is! String) ? jsonEncode(body) : body as String?;

    return _sendRequest<T>(
      () => _httpClient.put(
        _resolveUri(endpoint),
        headers: _buildHeaders(extraHeaders: headers),
        body: encodedBody,
      ),
      decoder: decoder,
    );
  }

  /// HTTP DELETE Request
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    dynamic body,
    Map<String, String>? headers,
    T Function(dynamic data)? decoder,
  }) async {
    final encodedBody = (body != null && body is! String) ? jsonEncode(body) : body as String?;

    return _sendRequest<T>(
      () => _httpClient.delete(
        _resolveUri(endpoint),
        headers: _buildHeaders(extraHeaders: headers),
        body: encodedBody,
      ),
      decoder: decoder,
    );
  }

  Future<ApiResponse<T>> _sendRequest<T>(
    Future<http.Response> Function() requestFn, {
    T Function(dynamic data)? decoder,
  }) async {
    try {
      final response = await requestFn().timeout(defaultTimeout);
      return _handleResponse<T>(response, decoder: decoder);
    } on SocketException {
      throw NetworkException(
        'Gagal terhubung ke host $_baseUrl. Pastikan server Laravel aktif di IP ${ApiEndpoints.defaultHost}:${ApiEndpoints.defaultPort}.',
      );
    } on TimeoutException {
      throw RequestTimeoutException(
        'Permintaan ke $_baseUrl melebihi batas waktu ($defaultTimeout).',
      );
    }
  }

  ApiResponse<T> _handleResponse<T>(
    http.Response response, {
    T Function(dynamic data)? decoder,
  }) {
    final statusCode = response.statusCode;

    dynamic decodedBody;
    try {
      decodedBody = response.body.isNotEmpty ? jsonDecode(response.body) : null;
    } catch (_) {
      decodedBody = response.body;
    }

    if (statusCode >= 200 && statusCode < 300) {
      T? parsedData;
      String? message;

      if (decodedBody is Map<String, dynamic>) {
        message = decodedBody['message'] as String?;
        final rawData = decodedBody['data'] ?? decodedBody;
        parsedData = (decoder != null) ? decoder(rawData) : (rawData as T?);
      } else if (decodedBody != null && decoder != null) {
        parsedData = decoder(decodedBody);
      } else {
        parsedData = decodedBody as T?;
      }

      return ApiResponse.success(
        statusCode: statusCode,
        data: parsedData,
        message: message,
      );
    }

    // Penanganan Error HTTP
    String errorMessage = 'Terjadi kesalahan pada server (Status: $statusCode)';
    Map<String, dynamic>? validationErrors;

    if (decodedBody is Map<String, dynamic>) {
      errorMessage = (decodedBody['message'] ?? decodedBody['error'] ?? errorMessage).toString();
      if (decodedBody['errors'] is Map<String, dynamic>) {
        validationErrors = decodedBody['errors'] as Map<String, dynamic>;
      }
    }

    if (statusCode == 401 || statusCode == 403) {
      throw AuthApiException(errorMessage, statusCode: statusCode);
    } else if (statusCode == 422) {
      throw ValidationException(errorMessage, statusCode: 422, errors: validationErrors);
    } else if (statusCode == 404) {
      throw NotFoundException(errorMessage, statusCode: 404);
    } else if (statusCode >= 500) {
      throw ServerException(errorMessage, statusCode: statusCode, body: decodedBody);
    }

    throw ServerException(errorMessage, statusCode: statusCode, body: decodedBody);
  }
}
