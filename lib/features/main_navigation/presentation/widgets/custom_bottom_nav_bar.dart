import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../shared/theme/theme.dart';
import '../../domain/entities/nav_item.dart';

/// Navigation Bar Melayang (*Floating*) dengan gaya Glassmorphism
/// berbentuk oval panjang (stadium pill) modern dan elegan.
class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<NavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = context.isDarkMode;
    final bottomSafeArea = MediaQuery.of(context).padding.bottom;

    // Jarak melayang dari tepi bawah layar
    final double bottomMargin = bottomSafeArea > 0 ? bottomSafeArea + 6 : 18;

    return Padding(
      padding: EdgeInsets.fromLTRB(18, 0, 18, bottomMargin),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(38),
          boxShadow: [
            // Ambient soft diffusion shadow untuk efek melayang (floating elevation)
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.50)
                  : const Color(0xFF0F172A).withValues(alpha: 0.12),
              blurRadius: 28,
              spreadRadius: -2,
              offset: const Offset(0, 10),
            ),
            // Contact rim shadow: mempertegas kristal kaca di atas latar terang
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.30)
                  : const Color(0xFF0F172A).withValues(alpha: 0.06),
              blurRadius: 8,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
            // Aksen pendaran warna primer yang sangat halus
            BoxShadow(
              color: colorScheme.primary.withValues(
                alpha: isDark ? 0.08 : 0.05,
              ),
              blurRadius: 18,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(38),
          child: BackdropFilter(
            // Efek buram frosted glass (blur kuat untuk tekstur kaca beku yang kaya)
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              height: 72,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(38),
                // Gradien kaca semi-transparan tembus pandang (translucent frosted glass)
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          const Color(0xFF323234).withValues(alpha: 0.62),
                          const Color(0xFF1C1C1E).withValues(alpha: 0.45),
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.52),
                          Colors.white.withValues(alpha: 0.28),
                        ],
                ),
                // Border kilau kaca specular highlight (refraksi tepi kaca kristal)
                border: Border.all(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.22)
                      : Colors.white.withValues(alpha: 0.90),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(items.length, (index) {
                  final item = items[index];
                  final isSelected = index == currentIndex;

                  return Expanded(
                    child: _GlassNavBarItemTile(
                      item: item,
                      isSelected: isSelected,
                      primaryColor: colorScheme.primary,
                      onTap: () => onTap(index),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassNavBarItemTile extends StatelessWidget {
  const _GlassNavBarItemTile({
    required this.item,
    required this.isSelected,
    required this.primaryColor,
    required this.onTap,
  });

  final NavItem item;
  final bool isSelected;
  final Color primaryColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeTextColor = isDark ? Colors.white : primaryColor;
    final inactiveTextColor = isDark
        ? const Color(0xFFAAAAAA)
        : const Color(0xFF6B7280);

    return Tooltip(
      message: item.tooltip ?? item.label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        splashColor: primaryColor.withValues(alpha: 0.12),
        highlightColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? primaryColor.withValues(alpha: isDark ? 0.22 : 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(28),
            border: isSelected
                ? Border.all(
                    color: primaryColor.withValues(alpha: isDark ? 0.35 : 0.22),
                    width: 1,
                  )
                : null,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    AnimatedScale(
                      duration: const Duration(milliseconds: 200),
                      scale: isSelected ? 1.08 : 1.0,
                      child: Icon(
                        isSelected ? item.activeIcon : item.icon,
                        size: 22,
                        color: isSelected ? primaryColor : inactiveTextColor,
                      ),
                    ),

                    // Badge Notifikasi Dinamis
                    if (item.badgeCount > 0)
                      Positioned(
                        right: -10,
                        top: -5,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4.5,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF1E1E1E)
                                  : Colors.white,
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.error.withValues(alpha: 0.4),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            item.badgeCount > 99 ? '99+' : '${item.badgeCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 2),

                // Label Tab
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: 10.5,
                    height: 1.15,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? activeTextColor : inactiveTextColor,
                    letterSpacing: 0.1,
                  ),
                  child: Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
