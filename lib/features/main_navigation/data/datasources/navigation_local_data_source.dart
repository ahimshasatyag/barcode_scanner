import 'package:flutter/material.dart';
import '../../domain/entities/nav_item.dart';
import '../models/nav_item_model.dart';

/// Kontrak Local Data Source untuk navigasi
abstract class NavigationLocalDataSource {
  /// Mengambil daftar menu berdasarkan role
  Future<List<NavItemModel>> getNavItemsForRole({required String role});

  /// Menyimpan tab aktif ke memori lokal
  Future<void> saveCurrentTab(int index);

  /// Mengambil tab aktif terakhir
  Future<int> getSavedTab();
}

/// Implementasi Local Data Source Navigasi
class NavigationLocalDataSourceImpl implements NavigationLocalDataSource {
  int _cachedIndex = 0;

  /// Daftar menu bawaan untuk role 'warehouse' (Gudang): Transaksi, Tracker, Opname
  static const List<NavItemModel> defaultWarehouseItems = [
    NavItemModel(
      type: NavItemType.transaksi,
      label: 'Transaksi',
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
      badgeCount: 2, // 2 transaksi inbound/outbound pending
      tooltip: 'Kelola transaksi masuk & keluar barang gudang',
    ),
    NavItemModel(
      type: NavItemType.tracker,
      label: 'Tracker',
      icon: Icons.location_searching_rounded,
      activeIcon: Icons.my_location_rounded,
      badgeCount: 0,
      tooltip: 'Pelacakan posisi rak, bin, dan pergerakan material',
    ),
    NavItemModel(
      type: NavItemType.opname,
      label: 'Opname',
      icon: Icons.inventory_2_outlined,
      activeIcon: Icons.inventory_2_rounded,
      badgeCount: 1, // 1 jadwal stock opname aktif
      tooltip: 'Stock Opname & audit fisik berkala',
    ),
    NavItemModel(
      type: NavItemType.profile,
      label: 'Profil',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      badgeCount: 0,
      tooltip: 'Profil staf gudang & pengaturan akun',
    ),
  ];

  @override
  Future<List<NavItemModel>> getNavItemsForRole({required String role}) async {
    return defaultWarehouseItems;
  }

  @override
  Future<void> saveCurrentTab(int index) async {
    _cachedIndex = index;
  }

  @override
  Future<int> getSavedTab() async {
    return _cachedIndex;
  }
}
