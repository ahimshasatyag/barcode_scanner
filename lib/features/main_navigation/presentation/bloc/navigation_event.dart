import 'package:flutter/foundation.dart';

/// Event dasar untuk NavigationBloc
@immutable
sealed class NavigationEvent {
  const NavigationEvent();
}

/// Event saat navigasi diinisialisasi untuk role tertentu
final class LoadNavigationItems extends NavigationEvent {
  const LoadNavigationItems({this.role = 'warehouse'});

  final String role;
}

/// Event saat user menekan tab navbar
final class ChangeNavigationTab extends NavigationEvent {
  const ChangeNavigationTab(this.newIndex);

  final int newIndex;
}

/// Event untuk memperbarui badge count pada item tertentu
final class UpdateBadgeCount extends NavigationEvent {
  const UpdateBadgeCount({
    required this.index,
    required this.count,
  });

  final int index;
  final int count;
}

