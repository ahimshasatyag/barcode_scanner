import 'package:flutter/material.dart';
import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../auth/domain/entities/user.dart';
import '../../data/datasources/navigation_local_data_source.dart';
import '../../data/repositories/navigation_repository_impl.dart';
import '../../domain/usecases/change_tab_usecase.dart';
import '../../domain/usecases/get_navigation_items_usecase.dart';
import '../bloc/navigation_bloc.dart';
import '../bloc/navigation_event.dart';
import '../bloc/navigation_state.dart';
import '../widgets/custom_bottom_nav_bar.dart';
import '../widgets/warehouse_app_bar.dart';
import 'opname_page.dart';
import 'tracker_page.dart';
import 'transaksi_page.dart';

/// Halaman Navigasi Utama Shell untuk Role Warehouse
class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({
    super.key,
    required this.onToggleTheme,
    this.user,
    this.navigationBloc,
  });

  final VoidCallback onToggleTheme;
  final User? user;
  final NavigationBloc? navigationBloc;

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  late final NavigationBloc _navigationBloc;

  @override
  void initState() {
    super.initState();

    final repository = NavigationRepositoryImpl(
      localDataSource: NavigationLocalDataSourceImpl(),
    );

    _navigationBloc = widget.navigationBloc ??
        NavigationBloc(
          getItemsUseCase: GetNavigationItemsUseCase(repository),
          changeTabUseCase: ChangeTabUseCase(repository),
          defaultRole: 'warehouse',
        );
  }

  @override
  void dispose() {
    if (widget.navigationBloc == null) {
      _navigationBloc.close();
    }
    super.dispose();
  }

  void _onTabSelected(int index) {
    _navigationBloc.add(ChangeNavigationTab(index));
  }

  void _showGlobalScanBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (context) {
        final colorScheme = context.colorScheme;
        final isDark = context.isDarkMode;

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Pilih Mode Pemindaian Barcode',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Arahkan kamera ke barcode rak, dokumen, atau kardus barang',
                style: TextStyle(fontSize: 12, color: colorScheme.outline),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _ScanOptionTile(
                icon: Icons.receipt_long_rounded,
                title: 'Scan Transaksi Inbound / Outbound',
                subtitle: 'Verifikasi surat jalan PO atau DO gudang',
                color: AppColors.primary,
                onTap: () {
                  Navigator.pop(context);
                  _onTabSelected(0);
                  AppSnackBar.showInfo(context, 'Membuka kamera Scanner Transaksi');
                },
              ),
              const SizedBox(height: 10),
              _ScanOptionTile(
                icon: Icons.location_searching_rounded,
                title: 'Scan Lokasi Rak / Bin Tracker',
                subtitle: 'Pelacakan dan relokasi pallet barang',
                color: const Color(0xFF0288D1),
                onTap: () {
                  Navigator.pop(context);
                  _onTabSelected(1);
                  AppSnackBar.showInfo(context, 'Membuka kamera Scanner Tracker Lokasi');
                },
              ),
              const SizedBox(height: 10),
              _ScanOptionTile(
                icon: Icons.inventory_2_rounded,
                title: 'Scan Fisik Stock Opname',
                subtitle: 'Pencocokan kuantitas fisik berkala',
                color: const Color(0xFF2E7D32),
                onTap: () {
                  Navigator.pop(context);
                  _onTabSelected(2);
                  AppSnackBar.showInfo(context, 'Membuka kamera Scanner Stock Opname');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    return NavigationBlocBuilder(
      bloc: _navigationBloc,
      builder: (context, state) {
        if (state is NavigationLoading) {
          return Scaffold(
            backgroundColor: colorScheme.surface,
            body: const Center(
              child: AppLoadingIndicator(
                message: 'Menyiapkan modul navigasi Warehouse...',
              ),
            ),
          );
        }

        if (state is NavigationError) {
          return Scaffold(
            backgroundColor: colorScheme.surface,
            body: Center(
              child: AppEmptyState(
                title: 'Gagal Memuat Navigasi',
                message: state.message,
                icon: Icons.error_outline,
                actionText: 'Coba Lagi',
                onActionPressed: () => _navigationBloc.add(const LoadNavigationItems(role: 'warehouse')),
              ),
            ),
          );
        }

        if (state is NavigationLoaded) {
          final items = state.items;
          final currentIndex = state.currentIndex;
          final currentTitle = items[currentIndex].label;

          // Halaman khusus Role Warehouse: Transaksi, Tracker, Opname
          final pages = const [
            TransaksiPage(),
            TrackerPage(),
            OpnamePage(),
          ];

          return Scaffold(
            backgroundColor: colorScheme.surface,
            appBar: WarehouseAppBar(
              title: currentTitle,
              onToggleTheme: widget.onToggleTheme,
              userName: widget.user?.name ?? widget.user?.username ?? 'Operator Gudang',
              roleName: 'Warehouse',
              onScanPressed: () => _showGlobalScanBottomSheet(context),
            ),
            body: IndexedStack(
              index: currentIndex,
              children: pages,
            ),
            bottomNavigationBar: CustomBottomNavBar(
              items: items,
              currentIndex: currentIndex,
              onTap: _onTabSelected,
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

class _ScanOptionTile extends StatelessWidget {
  const _ScanOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF242424) : const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? const Color(0xFF333333) : const Color(0xFFE8E8E8),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
