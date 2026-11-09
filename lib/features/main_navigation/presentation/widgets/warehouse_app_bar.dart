import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../shared/theme/theme.dart';

/// AppBar khusus role Warehouse dengan info pengguna dan toggle tema
class WarehouseAppBar extends StatelessWidget implements PreferredSizeWidget {
  const WarehouseAppBar({
    super.key,
    required this.title,
    required this.onToggleTheme,
    this.userName,
    this.roleName = 'WAREHOUSE',
    this.onScanPressed,
  });

  final String title;
  final VoidCallback onToggleTheme;
  final String? userName;
  final String roleName;
  final VoidCallback? onScanPressed;

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = context.isDarkMode;

    return AppBar(
      backgroundColor: isDark ? const Color(0xFF141414) : Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1.5,
      toolbarHeight: 68,
      titleSpacing: 16,
      title: Row(
        children: [
          // Logo Eka Maju Mesinindo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? const Color(0xFF333333) : const Color(0xFF222222),
                width: 0.8,
              ),
            ),
            child: Image.asset(
              AppAssets.logo,
              height: 24,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.qr_code_scanner,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Judul Tab & Badge Role Warehouse
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        roleName.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    if (userName != null && userName!.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Text(
                        '• $userName',
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.outline,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (onScanPressed != null)
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Scan Barcode Cepat',
            onPressed: onScanPressed,
            color: colorScheme.primary,
          ),
        IconButton(
          icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
          tooltip: isDark ? 'Beralih ke Light Mode' : 'Beralih ke Dark Mode',
          onPressed: onToggleTheme,
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}
