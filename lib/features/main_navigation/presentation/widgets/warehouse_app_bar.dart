import 'package:flutter/material.dart';
import '../../../../shared/theme/theme.dart';

/// AppBar khusus role Warehouse dengan tampilan minimalis, bersih, dan modern.
/// Dilengkapi tombol ikon notifikasi dengan badge indikator interaktif.
class WarehouseAppBar extends StatelessWidget implements PreferredSizeWidget {
  const WarehouseAppBar({
    super.key,
    required this.title,
    this.onToggleTheme,
    this.userName,
    this.roleName = 'WAREHOUSE',
    this.onScanPressed,
    this.unreadNotificationCount = 0,
    this.onNotificationPressed,
  });

  final String title;
  final VoidCallback? onToggleTheme;
  final String? userName;
  final String roleName;
  final VoidCallback? onScanPressed;
  final int unreadNotificationCount;
  final VoidCallback? onNotificationPressed;

  @override
  Size get preferredSize => const Size.fromHeight(60);

  void _showNotificationBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final colorScheme = ctx.colorScheme;
        final isDark = ctx.isDarkMode;

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[700] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Notifikasi Gudang',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.notifications_none_outlined,
                        size: 48,
                        color: colorScheme.outline,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Belum ada notifikasi baru',
                        style: TextStyle(
                          color: colorScheme.outline,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
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
    final isDark = context.isDarkMode;

    return AppBar(
      backgroundColor: isDark ? const Color(0xFF141414) : Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      toolbarHeight: 60,
      titleSpacing: 20,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.4,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  roleName.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                    letterSpacing: 0.4,
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
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ],
      ),
      actions: [
        // Ikon Notifikasi Minimalis dengan Dot Indikator Merah
        _NotificationIconButton(
          unreadCount: unreadNotificationCount,
          onTap: () {
            if (onNotificationPressed != null) {
              onNotificationPressed!();
            } else {
              _showNotificationBottomSheet(context);
            }
          },
        ),
        const SizedBox(width: 16),
      ],
    );
  }
}

class _NotificationIconButton extends StatelessWidget {
  const _NotificationIconButton({
    required this.unreadCount,
    required this.onTap,
  });

  final int unreadCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = context.isDarkMode;

    return Tooltip(
      message: 'Notifikasi Gudang',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF222222) : const Color(0xFFF1F5F9),
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? const Color(0xFF333333) : const Color(0xFFE2E8F0),
              width: 0.8,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(
                Icons.notifications_outlined,
                size: 20,
                color: colorScheme.onSurface,
              ),
              if (unreadCount > 0)
                Positioned(
                  top: 9,
                  right: 9,
                  child: Container(
                    width: 7.5,
                    height: 7.5,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isDark ? const Color(0xFF222222) : Colors.white,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
