import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:barcode/features/profile/profile.dart';
import 'package:barcode/shared/theme/theme.dart';

void main() {
  group('Profile Clean Architecture Tests', () {
    late ProfileRemoteDataSource dataSource;
    late ProfileRepository repository;
    late GetProfileUseCase getProfileUseCase;
    late ProfileBloc bloc;

    setUp(() {
      dataSource = ProfileRemoteDataSourceImpl();
      repository = ProfileRepositoryImpl(remoteDataSource: dataSource);
      getProfileUseCase = GetProfileUseCase(repository);
      bloc = ProfileBloc(
        repository: repository,
        getProfileUseCase: getProfileUseCase,
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('GetProfileUseCase returns valid warehouse operator profile', () async {
      final profile = await getProfileUseCase();

      expect(profile.id, 'USR-EMM-091');
      expect(profile.username, 'operator.gudang');
      expect(profile.name, 'Budi Santoso');
      expect(profile.role, 'Warehouse Leader');
      expect(profile.department, contains('Logistik'));
      expect(profile.isActive, true);
    });

    test('UpdateProfile updates cached profile correctly', () async {
      const updated = UserProfile(
        id: 'USR-EMM-091',
        username: 'budi.santoso',
        name: 'Budi Santoso, S.T.',
        role: 'Warehouse Supervisor',
        phone: '+62 811-2233-4455',
      );

      final result = await repository.updateProfile(updated);
      expect(result.name, 'Budi Santoso, S.T.');
      expect(result.role, 'Warehouse Supervisor');
    });

    test('ProfileBloc emits ProfileLoaded when LoadProfile event is added', () async {
      bloc.add(const LoadProfile());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<ProfileLoading>(),
          isA<ProfileLoaded>().having((s) => s.profile.name, 'name', contains('Budi Santoso')),
        ]),
      );
    });

    testWidgets('ProfilePage renders user info, department, and menu tiles', (tester) async {
      const testProfile = UserProfile(
        id: 'TEST-001',
        username: 'ahmad.fauzi',
        name: 'Ahmad Fauzi',
        role: 'Staf Penerimaan Inbound',
        idKaryawan: 'NIK-2026-0421',
        phone: '+62 812-9988-7766',
        email: 'ahmad.fauzi@ekamaju.com',
        department: 'Divisi Logistik',
        warehouseLocation: 'Dermaga 02',
        shift: 'Shift Pagi',
      );

      final testBloc = ProfileBloc(
        repository: repository,
        initialProfile: testProfile,
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: ProfilePage(bloc: testBloc),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Ahmad Fauzi'), findsOneWidget);
      expect(find.textContaining('@ahmad.fauzi'), findsOneWidget);
      expect(find.text('Staf Penerimaan Inbound'), findsOneWidget);
      expect(find.text('Informasi Staf Gudang'), findsOneWidget);
      expect(find.text('Server Backend Laravel'), findsOneWidget);
      expect(find.text('Keluar dari Akun'), findsOneWidget);

      testBloc.close();
    });
  });
}
