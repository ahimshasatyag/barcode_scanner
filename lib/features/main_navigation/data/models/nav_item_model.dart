import 'package:flutter/material.dart';
import '../../domain/entities/nav_item.dart';

/// Model data NavItem untuk serialisasi dan manipulasi data navigasi
class NavItemModel extends NavItem {
  const NavItemModel({
    required super.type,
    required super.label,
    required super.icon,
    required super.activeIcon,
    super.badgeCount = 0,
    super.tooltip,
  });

  /// Factory untuk membuat model dari Map/JSON
  factory NavItemModel.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type']?.toString().toLowerCase() ?? 'transaksi';
    final type = NavItemType.values.firstWhere(
      (e) => e.name == typeStr,
      orElse: () => NavItemType.transaksi,
    );

    return NavItemModel(
      type: type,
      label: json['label'] as String? ?? 'Menu',
      icon: _getIconData(json['icon'] as String?),
      activeIcon: _getActiveIconData(json['activeIcon'] as String?),
      badgeCount: json['badgeCount'] as int? ?? 0,
      tooltip: json['tooltip'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'label': label,
      'badgeCount': badgeCount,
      'tooltip': tooltip,
    };
  }

  static IconData _getIconData(String? name) {
    switch (name) {
      case 'tracker':
        return Icons.location_searching_rounded;
      case 'opname':
        return Icons.inventory_2_outlined;
      case 'transaksi':
      default:
        return Icons.receipt_long_outlined;
    }
  }

  static IconData _getActiveIconData(String? name) {
    switch (name) {
      case 'tracker':
        return Icons.my_location_rounded;
      case 'opname':
        return Icons.inventory_2_rounded;
      case 'transaksi':
      default:
        return Icons.receipt_long_rounded;
    }
  }

  NavItem toEntity() {
    return NavItem(
      type: type,
      label: label,
      icon: icon,
      activeIcon: activeIcon,
      badgeCount: badgeCount,
      tooltip: tooltip,
    );
  }
}

