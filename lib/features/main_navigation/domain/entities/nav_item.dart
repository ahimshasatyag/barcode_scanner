import 'package:flutter/material.dart';

/// Enum tipe menu navigasi utama untuk role warehouse
enum NavItemType {
  transaksi,
  tracker,
  opname,
  profile,
}

/// Entitas NavItem yang merepresentasikan item/tab pada navigation bar
class NavItem {
  const NavItem({
    required this.type,
    required this.label,
    required this.icon,
    required this.activeIcon,
    this.badgeCount = 0,
    this.tooltip,
  });

  /// Tipe navigasi (transaksi, tracker, opname)
  final NavItemType type;

  /// Label nama tab yang ditampilkan di navbar
  final String label;

  /// Icon saat tab dalam keadaan tidak aktif
  final IconData icon;

  /// Icon saat tab dalam keadaan aktif / terpilih
  final IconData activeIcon;

  /// Jumlah notifikasi / badge penanda (0 jika tidak ada badge)
  final int badgeCount;

  /// Tooltip aksesibilitas
  final String? tooltip;

  NavItem copyWith({
    NavItemType? type,
    String? label,
    IconData? icon,
    IconData? activeIcon,
    int? badgeCount,
    String? tooltip,
  }) {
    return NavItem(
      type: type ?? this.type,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      activeIcon: activeIcon ?? this.activeIcon,
      badgeCount: badgeCount ?? this.badgeCount,
      tooltip: tooltip ?? this.tooltip,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NavItem &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          label == other.label &&
          badgeCount == other.badgeCount;

  @override
  int get hashCode => type.hashCode ^ label.hashCode ^ badgeCount.hashCode;
}

