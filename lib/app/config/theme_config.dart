import 'package:flutter/material.dart';

/// Konfigurasi umum tampilan dan preferensi tema aplikasi
abstract final class ThemeConfig {
  /// Font family default aplikasi
  static const String fontFamily = 'Roboto';

  /// Animasi transisi halaman standar (durasi milidetik)
  static const Duration pageTransitionDuration = Duration(milliseconds: 300);

  /// Default border radius untuk komponen kartu dan tombol
  static const double defaultBorderRadius = 12.0;

  /// Default padding horizontal layar
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0);
}

