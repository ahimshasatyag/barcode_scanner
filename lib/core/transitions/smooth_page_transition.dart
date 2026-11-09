import 'package:flutter/material.dart';

/// Transisi halaman kustom yang sangat halus (*smooth*), ringan (*lightweight*),
/// dan bebas *jank/lag* karena hanya memanfaatkan GPU Layer Transform (Opacity & Translasi kecil)
/// tanpa operasi rendering berat.
class SmoothPageTransitionsBuilder extends PageTransitionsBuilder {
  const SmoothPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    // Animasi kurva halus yang responsif dan natural (300ms)
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    // Animasi Fade: 0.0 -> 1.0
    final fade = FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation),
      child: child,
    );

    // Animasi Slide mikro: hanya bergeser 3% dari kanan ke kiri
    // (Jarak pergeseran sangat kecil sehingga tidak membebani raster thread GPU)
    final slide = SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.03, 0.0),
        end: Offset.zero,
      ).animate(curvedAnimation),
      child: fade,
    );

    // Efek halus saat halaman baru menumpuk di atasnya
    final secondaryFade = FadeTransition(
      opacity: Tween<double>(begin: 1.0, end: 0.92).animate(
        CurvedAnimation(
          parent: secondaryAnimation,
          curve: Curves.easeOutQuad,
        ),
      ),
      child: slide,
    );

    return secondaryFade;
  }
}

/// Custom Route siap pakai untuk perpindahan halaman yang halus
class SmoothPageRoute<T> extends PageRouteBuilder<T> {
  SmoothPageRoute({
    required Widget page,
    super.settings,
    Duration duration = const Duration(milliseconds: 300),
    Duration reverseDuration = const Duration(milliseconds: 250),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: reverseDuration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curvedAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
              reverseCurve: Curves.easeInCubic,
            );

            return FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation),
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.03, 0.0),
                  end: Offset.zero,
                ).animate(curvedAnimation),
                child: child,
              ),
            );
          },
        );
}

/// Route transisi Pure Fade (Crossfade) yang sangat elegan untuk transisi Splash -> Login
/// Bebas lonjakan kontras dan sangat cocok dipadukan dengan Hero animation.
class FadePageRoute<T> extends PageRouteBuilder<T> {
  FadePageRoute({
    required Widget page,
    super.settings,
    Duration duration = const Duration(milliseconds: 600),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
          reverseTransitionDuration: duration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOutCubic,
              ),
              child: child,
            );
          },
        );
}

/// Extension pada [BuildContext] agar navigasi antar halaman menjadi sangat ringkas & otomatis smooth
extension SmoothNavigationExtension on BuildContext {
  /// Berpindah ke halaman baru dengan transisi smooth & ringan
  Future<T?> pushSmooth<T>(Widget page, {RouteSettings? settings}) {
    return Navigator.of(this).push<T>(
      SmoothPageRoute<T>(page: page, settings: settings),
    );
  }

  /// Menggantikan halaman saat ini dengan halaman baru (slide + fade)
  Future<T?> pushReplacementSmooth<T, TO>(Widget page, {RouteSettings? settings}) {
    return Navigator.of(this).pushReplacement<T, TO>(
      SmoothPageRoute<T>(page: page, settings: settings),
    );
  }

  /// Menggantikan halaman saat ini dengan transisi Crossfade yang sangat halus
  /// Khususnya ideal untuk Splash Screen -> Login Page
  Future<T?> pushReplacementFadeSmooth<T, TO>(Widget page, {RouteSettings? settings}) {
    return Navigator.of(this).pushReplacement<T, TO>(
      FadePageRoute<T>(page: page, settings: settings),
    );
  }

  /// Mengosongkan backstack dan berpindah ke halaman baru (contoh: Logout -> Login)
  Future<T?> pushAndRemoveUntilSmooth<T>(
    Widget page, {
    RouteSettings? settings,
    bool Function(Route<dynamic>)? predicate,
  }) {
    return Navigator.of(this).pushAndRemoveUntil<T>(
      SmoothPageRoute<T>(page: page, settings: settings),
      predicate ?? (route) => false,
    );
  }

  /// Kembali ke halaman sebelumnya
  void popPage<T>([T? result]) {
    Navigator.of(this).pop<T>(result);
  }
}

