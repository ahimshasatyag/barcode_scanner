import 'package:flutter/foundation.dart';

/// Observer untuk memantau siklus event, state, dan error pada BLoC
class AppBlocObserver {
  const AppBlocObserver();

  /// Dipanggil saat sebuah event dikirim ke BLoC
  void onEvent(String blocName, dynamic event) {
    if (kDebugMode) {
      debugPrint('[BlocObserver] [$blocName] onEvent: $event');
    }
  }

  /// Dipanggil saat state pada BLoC berubah
  void onTransition(String blocName, dynamic currentState, dynamic nextState) {
    if (kDebugMode) {
      debugPrint('[BlocObserver] [$blocName] Transition: $currentState -> $nextState');
    }
  }

  /// Dipanggil saat terjadi error pada BLoC
  void onError(String blocName, Object error, StackTrace stackTrace) {
    debugPrint('[BlocObserver] [$blocName] Error: $error');
  }
}

