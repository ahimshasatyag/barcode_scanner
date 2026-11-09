import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:barcode/features/auth/auth.dart';
import 'package:barcode/shared/theme/theme.dart';

void main() {
  group('Auth Clean Architecture Tests (Connected to AuthController.php)', () {
    late http.Client mockClient;

    setUp(() {
      // Mock client yang mensimulasikan respons JSON persis dari AuthController.php
      mockClient = MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        final username = body['username']?.toString();
        final password = body['password']?.toString();

        if (username == 'operator01' && password == 'password123') {
          return http.Response(
            jsonEncode({
              'status': true,
              'message': 'Login berhasil.',
              'data': {
                'user': {
                  'id': 1,
                  'username': 'operator01',
                  'nm_users': 'Budi Operator',
                  'id_users_level': '3',
                  'id_karyawan': 'K-001',
                  'phone': '08123456789',
                  'link_foto': null,
                  'is_active': 1,
                },
                'token': 'mock-token-xyz-12345',
              },
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        if (password == 'wrong') {
          return http.Response(
            jsonEncode({
              'status': false,
              'message': 'Password salah.',
            }),
            401,
            headers: {'content-type': 'application/json'},
          );
        }

        return http.Response(
          jsonEncode({
            'status': false,
            'message': 'Username tidak ditemukan.',
          }),
          404,
          headers: {'content-type': 'application/json'},
        );
      });
    });

    test('LoginUseCase should succeed with valid credentials from AuthController.php', () async {
      final dataSource = AuthRemoteDataSourceImpl(client: mockClient);
      final repository = AuthRepositoryImpl(remoteDataSource: dataSource);
      final useCase = LoginUseCase(repository);

      final user = await useCase.execute(
        username: 'operator01',
        password: 'password123',
      );

      expect(user.username, 'operator01');
      expect(user.name, 'Budi Operator');
      expect(user.role, 'Operator');
      expect(user.token, 'mock-token-xyz-12345');
      expect(user.idKaryawan, 'K-001');
    });

    test('LoginUseCase should throw on empty username', () async {
      final dataSource = AuthRemoteDataSourceImpl(client: mockClient);
      final repository = AuthRepositoryImpl(remoteDataSource: dataSource);
      final useCase = LoginUseCase(repository);

      expect(
        () => useCase.execute(username: '', password: 'password123'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('LoginUseCase should throw AuthApiException on wrong password (401)', () async {
      final dataSource = AuthRemoteDataSourceImpl(client: mockClient);
      final repository = AuthRepositoryImpl(remoteDataSource: dataSource);
      final useCase = LoginUseCase(repository);

      expect(
        () => useCase.execute(username: 'operator01', password: 'wrong'),
        throwsA(isA<AuthApiException>().having((e) => e.message, 'message', 'Password salah.')),
      );
    });

    testWidgets('LoginPage renders header, inputs, and submit button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: LoginPage(
            onToggleTheme: () {},
          ),
        ),
      );

      expect(find.text('Masuk ke Sistem'), findsOneWidget);
      expect(find.text('Username'), findsOneWidget);
      expect(find.text('Kata Sandi'), findsOneWidget);
      expect(find.text('Masuk Sekarang'), findsOneWidget);
    });
  });
}
