import '../entities/nav_item.dart';

/// Kontrak repositori untuk navigasi utama
abstract class NavigationRepository {
  /// Mendapatkan daftar item navigasi berdasarkan role pengguna (misal: 'warehouse')
  Future<List<NavItem>> getNavItemsForRole({required String role});

  /// Menyimpan tab index aktif terakhir
  Future<void> saveCurrentTab(int index);

  /// Mendapatkan tab index aktif yang tersimpan
  Future<int> getSavedTab();
}

