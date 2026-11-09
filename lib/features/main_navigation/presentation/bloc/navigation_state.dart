import 'package:flutter/foundation.dart';
import '../../domain/entities/nav_item.dart';

/// State dasar untuk NavigationBloc
@immutable
sealed class NavigationState {
  const NavigationState();
}

/// State saat navigasi sedang memuat item menu
final class NavigationLoading extends NavigationState {
  const NavigationLoading();
}

/// State saat navigasi telah siap dan menampilkan tab aktif
final class NavigationLoaded extends NavigationState {
  const NavigationLoaded({
    required this.currentIndex,
    required this.items,
    this.role = 'warehouse',
  });

  /// Index tab aktif saat ini (0: Transaksi, 1: Tracker, 2: Opname)
  final int currentIndex;

  /// Daftar item navigasi yang tersedia
  final List<NavItem> items;

  /// Role pengguna aktif
  final String role;

  /// Item yang sedang aktif
  NavItem get currentItem => items[currentIndex];

  NavigationLoaded copyWith({
    int? currentIndex,
    List<NavItem>? items,
    String? role,
  }) {
    return NavigationLoaded(
      currentIndex: currentIndex ?? this.currentIndex,
      items: items ?? this.items,
      role: role ?? this.role,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NavigationLoaded &&
          runtimeType == other.runtimeType &&
          currentIndex == other.currentIndex &&
          role == other.role &&
          listEquals(items, other.items);

  @override
  int get hashCode => currentIndex.hashCode ^ items.hashCode ^ role.hashCode;
}

/// State jika terjadi error pada navigasi
final class NavigationError extends NavigationState {
  const NavigationError(this.message);

  final String message;
}

