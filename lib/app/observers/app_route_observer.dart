import 'package:flutter/material.dart';

/// Observer navigasi rute untuk mencatat perpindahan halaman aplikasi
class AppRouteObserver extends NavigatorObserver {
  String? _currentRouteName;

  String? get currentRouteName => _currentRouteName;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _currentRouteName = route.settings.name;
    debugPrint('[RouteObserver] PUSH: ${_formatRoute(route)} (dari: ${_formatRoute(previousRoute)})');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _currentRouteName = previousRoute?.settings.name;
    debugPrint('[RouteObserver] POP: ${_formatRoute(route)} (kembali ke: ${_formatRoute(previousRoute)})');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _currentRouteName = newRoute?.settings.name;
    debugPrint('[RouteObserver] REPLACE: ${_formatRoute(oldRoute)} -> ${_formatRoute(newRoute)}');
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    debugPrint('[RouteObserver] REMOVE: ${_formatRoute(route)}');
  }

  String _formatRoute(Route<dynamic>? route) {
    if (route == null) return 'none';
    return route.settings.name ?? route.runtimeType.toString();
  }
}

