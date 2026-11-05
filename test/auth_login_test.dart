import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:barcode/features/auth/auth.dart';
import 'package:barcode/shared/theme/theme.dart';

void main() {
  group('Auth Clean Architecture Tests', () {
    test('LoginUseCase should succeed with valid credentials', () async {
      final dataSource = AuthRemoteDataSourceImpl();
      final repository = AuthRepositoryImpl(remoteDataSource: dataSource);
      final useCase = LoginUseCase(repository);

      final user = await useCase.execute(
        username: 'operator01',
        password: 'password123',
      );

      expect(user.username, 'operator01');
      expect(user.role, 'Operator');
    });

    test('LoginUseCase should throw on empty username', () async {
      final dataSource = AuthRemoteDataSourceImpl();
      final repository = AuthRepositoryImpl(remoteDataSource: dataSource);
      final useCase = LoginUseCase(repository);

      expect(
        () => useCase.execute(username: '', password: 'password123'),
        throwsA(isA<ArgumentError>()),
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

