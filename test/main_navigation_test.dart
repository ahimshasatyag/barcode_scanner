import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:barcode/features/main_navigation/main_navigation.dart';
import 'package:barcode/shared/theme/theme.dart';

void main() {
  group('Main Navigation Clean Architecture Tests (Role: Warehouse)', () {
    late NavigationLocalDataSource dataSource;
    late NavigationRepository repository;
    late GetNavigationItemsUseCase getItemsUseCase;
    late ChangeTabUseCase changeTabUseCase;
    late NavigationBloc navigationBloc;

    setUp(() {
      dataSource = NavigationLocalDataSourceImpl();
      repository = NavigationRepositoryImpl(localDataSource: dataSource);
      getItemsUseCase = GetNavigationItemsUseCase(repository);
      changeTabUseCase = ChangeTabUseCase(repository);
      navigationBloc = NavigationBloc(
        getItemsUseCase: getItemsUseCase,
        changeTabUseCase: changeTabUseCase,
        defaultRole: 'warehouse',
        initialItems: NavigationLocalDataSourceImpl.defaultWarehouseItems,
      );
    });

    tearDown(() {
      navigationBloc.close();
    });

    test(
      'GetNavigationItemsUseCase should return 4 items for warehouse role (including Profil)',
      () async {
        final items = await getItemsUseCase.execute(role: 'warehouse');

        expect(items.length, 4);
        expect(items[0].label, 'Transaksi');
        expect(items[0].type, NavItemType.transaksi);

        expect(items[1].label, 'Tracker');
        expect(items[1].type, NavItemType.tracker);

        expect(items[2].label, 'Opname');
        expect(items[2].type, NavItemType.opname);

        expect(items[3].label, 'Profil');
        expect(items[3].type, NavItemType.profile);
      },
    );

    test('ChangeTabUseCase should save and return valid tab index', () async {
      final index = await changeTabUseCase.execute(1, maxIndex: 2);
      expect(index, 1);

      final saved = await repository.getSavedTab();
      expect(saved, 1);
    });

    test(
      'ChangeTabUseCase should throw RangeError for invalid index',
      () async {
        expect(
          () => changeTabUseCase.execute(5, maxIndex: 2),
          throwsA(isA<RangeError>()),
        );
      },
    );

    testWidgets(
      'MainNavigationPage renders warehouse tabs and switches pages',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: MainNavigationPage(
              onToggleTheme: () {},
              navigationBloc: navigationBloc,
            ),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        // Memastikan 4 tab utama role warehouse tampil di navbar
        expect(find.text('Transaksi'), findsWidgets);
        expect(find.text('Tracker'), findsOneWidget);
        expect(find.text('Opname'), findsOneWidget);
        expect(find.text('Profil'), findsOneWidget);

        // Verifikasi halaman Transaksi aktif pertama kali
        expect(find.byType(TransaksiPage), findsOneWidget);

        // Tap tab Tracker
        await tester.tap(find.text('Tracker'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        final stateAfterTracker = navigationBloc.state as NavigationLoaded;
        expect(stateAfterTracker.currentIndex, 1);

        // Tap tab Opname
        await tester.tap(find.text('Opname'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        final stateAfterOpname = navigationBloc.state as NavigationLoaded;
        expect(stateAfterOpname.currentIndex, 2);

        // Tap tab Profil
        await tester.tap(find.text('Profil'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 50));

        final stateAfterProfil = navigationBloc.state as NavigationLoaded;
        expect(stateAfterProfil.currentIndex, 3);
      },
    );
  });
}
