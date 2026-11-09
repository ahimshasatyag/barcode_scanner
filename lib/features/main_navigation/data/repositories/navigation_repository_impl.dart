import '../../domain/entities/nav_item.dart';
import '../../domain/repositories/navigation_repository.dart';
import '../datasources/navigation_local_data_source.dart';

/// Implementasi NavigationRepository yang menghubungkan domain ke data source
class NavigationRepositoryImpl implements NavigationRepository {
  const NavigationRepositoryImpl({required this.localDataSource});

  final NavigationLocalDataSource localDataSource;

  @override
  Future<List<NavItem>> getNavItemsForRole({required String role}) async {
    final models = await localDataSource.getNavItemsForRole(role: role);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> saveCurrentTab(int index) async {
    await localDataSource.saveCurrentTab(index);
  }

  @override
  Future<int> getSavedTab() async {
    return await localDataSource.getSavedTab();
  }
}

