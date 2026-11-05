import 'dart:async';
import 'package:flutter/material.dart';
import 'package:barcode/core/constants/app_assets.dart';
import 'package:barcode/core/transitions/smooth_page_transition.dart';
import 'package:barcode/features/auth/presentation/pages/login_page.dart';
import 'package:barcode/shared/theme/theme.dart';

/// Halaman Splash Screen dengan logo PT Eka Maju Mesinindo
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.onToggleTheme,
  });

  final VoidCallback onToggleTheme;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();

    // Navigasi otomatis ke Halaman Login setelah 2.6 detik
    _navigationTimer = Timer(const Duration(milliseconds: 2600), _navigateToNext);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pre-cache gambar logo ke memory agar tidak ada lag/stutter saat render halaman Login
    precacheImage(const AssetImage(AppAssets.logo), context);
  }

  void _navigateToNext() {
    if (!mounted) return;

    context.pushReplacementFadeSmooth(
      LoginPage(
        onToggleTheme: widget.onToggleTheme,
      ),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Latar belakang hitam pekat agar menyatu sempurna dengan gambar logo images.png
      backgroundColor: const Color(0xFF000000),
      body: SafeArea(
        child: Stack(
          children: [
            // Konten Tengah: Logo & Animasi
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: child,
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo Eka Maju Mesinindo dengan Hero Animation
                      Hero(
                        tag: 'app_company_logo',
                        child: Image.asset(
                          AppAssets.logo,
                          width: 320,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.qr_code_scanner,
                                  size: 80,
                                  color: AppColors.primary,
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'EKA MAJU MESININDO',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Indikator Loading Halus
                      SizedBox(
                        width: 140,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: const LinearProgressIndicator(
                            minHeight: 3,
                            backgroundColor: Color(0xFF222222),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Sub-tagline
                      const Text(
                        'Barcode & Inventory System',
                        style: TextStyle(
                          color: Color(0xFFB0B0B0),
                          fontSize: 13,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Footer Bawah
            Positioned(
              left: 0,
              right: 0,
              bottom: 24,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'SINCE 1982',
                      style: TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 11,
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'v1.0.0',
                      style: TextStyle(
                        color: Color(0xFF555555),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

