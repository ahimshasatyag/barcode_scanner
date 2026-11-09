import '../entities/nav_item.dart';
import '../repositories/navigation_repository.dart';

/// UseCase untuk mengambil daftar tab menu sesuai role pengguna (khususnya role 'warehouse')
class GetNavigationItemsUseCase {
  const GetNavigationItemsUseCase(this.repository);

  final NavigationRepository repository;

  Future<List<NavItem>> execute({String role = 'warehouse'}) async {
    return await repository.getNavItemsForRole(role: role);
  }
}

