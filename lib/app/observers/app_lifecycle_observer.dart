import 'package:flutter/material.dart';

/// Observer siklus hidup aplikasi (foreground, background, minimized)
class AppLifecycleObserver with WidgetsBindingObserver {
  AppLifecycleObserver({
    this.onResumed,
    this.onPaused,
    this.onInactive,
    this.onDetached,
  });

  final VoidCallback? onResumed;
  final VoidCallback? onPaused;
  final VoidCallback? onInactive;
  final VoidCallback? onDetached;

  AppLifecycleState _lastState = AppLifecycleState.resumed;

  AppLifecycleState get lastState => _lastState;

  void attach() {
    WidgetsBinding.instance.addObserver(this);
  }

  void detach() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lastState = state;
    debugPrint('[LifecycleObserver] App state changed to: $state');

    switch (state) {
      case AppLifecycleState.resumed:
        onResumed?.call();
        break;
      case AppLifecycleState.paused:
        onPaused?.call();
        break;
      case AppLifecycleState.inactive:
        onInactive?.call();
        break;
      case AppLifecycleState.detached:
        onDetached?.call();
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }
}

