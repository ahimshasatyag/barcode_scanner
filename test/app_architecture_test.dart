import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:barcode/app/config/config.dart';
import 'package:barcode/app/constats/constats.dart';
import 'package:barcode/app/observers/observers.dart';
import 'package:barcode/core/error/error.dart';
import 'package:barcode/core/network/network.dart';
import 'package:barcode/core/services/services.dart';

void main() {
  group('App Config & Constants Tests (Host 192.168.1.127)', () {
    test('ApiEndpoints uses 192.168.1.127 as default host and 8000 as port', () {
      expect(ApiEndpoints.defaultHost, '192.168.1.127');
      expect(ApiEndpoints.defaultPort, 8000);
      expect(ApiEndpoints.defaultBaseUrl, 'http://192.168.1.127:8000/api');
      expect(ApiEndpoints.login, '/login');
      expect(ApiEndpoints.transactions, '/transactions');
      expect(ApiEndpoints.transactionScan('TRX-123'), '/transactions/TRX-123/scan');
    });

    test('AppConfig initializes with development IP and switches environments', () {
      AppConfig.initialize(
        environment: Environment.development,
        host: '192.168.1.127',
        port: 8000,
      );

      expect(AppConfig.current.isDevelopment, true);
      expect(AppConfig.current.host, '192.168.1.127');
      expect(AppConfig.current.baseUrl, 'http://192.168.1.127:8000/api');

      AppConfig.initialize(environment: Environment.production);
      expect(AppConfig.current.isProduction, true);
      expect(AppConfig.current.baseUrl, 'https://api.ekamaju.com/api');

      // Reset back to development
      AppConfig.initialize(environment: Environment.development);
    });
  });

  group('Core Error Handling Tests', () {
    test('ErrorHandler maps AuthApiException and status codes correctly', () {
      const authException = AuthApiException('Kredensial tidak valid', statusCode: 401);
      final failure = ErrorHandler.handle(authException);

      expect(failure, isA<AuthFailure>());
      expect(failure.message, 'Kredensial tidak valid');
      expect(failure.statusCode, 401);

      const validationException = ValidationException(
        'Data tidak valid',
        errors: {'email': ['Email wajib diisi']},
      );
      final valFailure = ErrorHandler.handle(validationException);
      expect(valFailure, isA<ValidationFailure>());
    });

    test('ErrorHandler maps SocketException to friendly LAN message', () {
      const socketException = SocketException('Failed host lookup');
      final failure = ErrorHandler.handle(socketException);

      expect(failure, isA<NetworkFailure>());
      expect(failure.message, contains('192.168.1.127:8000'));
    });

    test('ErrorHandler maps TimeoutException to friendly message', () {
      final timeoutException = TimeoutException('Timeout');
      final failure = ErrorHandler.handle(timeoutException);

      expect(failure, isA<NetworkFailure>());
      expect(failure.message, contains('192.168.1.127'));
    });
  });

  group('Core Network Client Tests', () {
    test('ApiClient handles successful GET and POST responses', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.endsWith('/login')) {
          return http.Response(
            '{"status":"success","message":"Login berhasil","data":{"token":"jwt-token-xyz"}}',
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('{"data":[{"id":"1"}]}', 200);
      });

      final apiClient = ApiClient(httpClient: mockClient);
      final response = await apiClient.post<Map<String, dynamic>>('/login', body: {
        'username': 'admin',
        'password': 'password',
      });

      expect(response.isSuccess, true);
      expect(response.statusCode, 200);
      expect(response.message, 'Login berhasil');

      apiClient.setAuthToken('jwt-token-xyz');
      final getResponse = await apiClient.get<List<dynamic>>('/transactions');
      expect(getResponse.isSuccess, true);
    });

    test('ApiClient throws typed exceptions on 401 and 404', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.contains('/unauthorized')) {
          return http.Response('{"message":"Akses ditolak"}', 401);
        }
        return http.Response('{"message":"Halaman tidak ditemukan"}', 404);
      });

      final apiClient = ApiClient(httpClient: mockClient);

      expect(
        () => apiClient.get('/unauthorized'),
        throwsA(isA<AuthApiException>()),
      );

      expect(
        () => apiClient.get('/not-found'),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('Core Services & Observers Tests', () {
    test('InMemoryStorageService stores and retrieves values', () async {
      final storage = InMemoryStorageService();

      await storage.setString('auth_token', 'TOKEN-9941');
      expect(storage.getString('auth_token'), 'TOKEN-9941');

      await storage.setBool('is_logged_in', true);
      expect(storage.getBool('is_logged_in'), true);

      await storage.remove('auth_token');
      expect(storage.getString('auth_token'), isNull);

      await storage.clear();
      expect(storage.getBool('is_logged_in'), isNull);
    });

    test('LoggerService and Observers instantiate and run safely', () {
      // LoggerService should execute without throwing
      LoggerService.d('Test debug message');
      LoggerService.i('Test info message');
      LoggerService.w('Test warning message');
      LoggerService.e('Test error message');

      const blocObserver = AppBlocObserver();
      blocObserver.onEvent('TestBloc', 'TestEvent');
      blocObserver.onTransition('TestBloc', 'StateA', 'StateB');
      blocObserver.onError('TestBloc', 'Some error', StackTrace.empty);

      final routeObserver = AppRouteObserver();
      expect(routeObserver.currentRouteName, isNull);

      final lifecycleObserver = AppLifecycleObserver();
      expect(lifecycleObserver.lastState, isNotNull);
    });
  });
}

