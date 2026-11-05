import 'package:flutter/material.dart';

/// Definisi konstanta warna yang diambil dan disesuaikan dari `theme.ts`.
abstract final class AppColors {
  // ===========================================================================
  // Light Palette
  // ===========================================================================
  /// Merah elegan untuk elemen utama (#9e0b0f)
  static const Color primary = Color(0xFF9E0B0F);
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Versi lebih terang dari primary untuk background elemen (#F4C4C5)
  static const Color primaryContainer = Color(0xFFF4C4C5);
  static const Color onPrimaryContainer = Color(0xFF600608);

  /// Versi netral terang untuk container nonaktif/sekunder (#E0E0E0)
  static const Color offPrimaryContainer = Color(0xFFE0E0E0);

  /// Merah keunguan gelap untuk elemen sekunder (#5E2129)
  static const Color secondary = Color(0xFF5E2129);
  static const Color onSecondary = Color(0xFFFFFFFF);

  /// Versi terang untuk background sekunder (#D69399)
  static const Color secondaryContainer = Color(0xFFD69399);
  static const Color onSecondaryContainer = Color(0xFF3C1116);

  /// Merah bata sebagai aksen warna (#B3475B)
  static const Color tertiary = Color(0xFFB3475B);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFFFD9DF);
  static const Color onTertiaryContainer = Color(0xFF3F0015);

  /// Abu-abu terang untuk latar belakang utama (#F5F5F5)
  static const Color background = Color(0xFFF5F5F5);
  static const Color onBackground = Color(0xFF2E2E2E);

  /// Warna dasar untuk elemen UI seperti card (#FFFFFF)
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF3D1C20);

  /// Abu-abu netral untuk varian permukaan (#E0E0E0)
  static const Color surfaceVariant = Color(0xFFE0E0E0);
  static const Color onSurfaceVariant = Color(0xFF5A2D32);

  /// Warna abu-abu kemerahan untuk border (#7A3E42)
  static const Color outline = Color(0xFF7A3E42);
  static const Color outlineVariant = Color(0xFFBFA5A7);

  /// Inverse colors (Light theme)
  static const Color inverseSurface = Color(0xFF2C2C2C);
  static const Color inverseOnSurface = Color(0xFFF5F5F5);
  static const Color inversePrimary = Color(0xFFF4C4C5);

  /// Elemen netral & disabled
  static const Color surfaceDisabled = Color(0x1F2E2E2E); // rgba(46, 46, 46, 0.12)
  static const Color onSurfaceDisabled = Color(0x612E2E2E); // rgba(46, 46, 46, 0.38)
  static const Color backdrop = Color(0x801C1C1C); // rgba(28, 28, 28, 0.5)

  /// Card, text, border, & notification
  static const Color card = Color(0xFFFFFFFF);
  static const Color text = Color(0xFF2E2E2E);
  static const Color border = Color(0xFFCCCCCC);
  static const Color notification = Color(0xFFE63946);

  /// Error palette
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF410002);

  // Elevation Levels (Light)
  static const Color elevationLevel0 = Color(0xFFFFFFFF);
  static const Color elevationLevel1 = Color(0xFFF8F8F8);
  static const Color elevationLevel2 = Color(0xFFF2F2F2);
  static const Color elevationLevel3 = Color(0xFFECECEC);
  static const Color elevationLevel4 = Color(0xFFE6E6E6);
  static const Color elevationLevel5 = Color(0xFFDFDFDF);

  // ===========================================================================
  // Dark Palette
  // ===========================================================================
  /// Warna utama dalam dark mode (diambil dari inversePrimary #F4C4C5)
  static const Color primaryDark = Color(0xFFFFB3B8);
  static const Color onPrimaryDark = Color(0xFF600608);
  static const Color primaryContainerDark = Color(0xFF7D000A);
  static const Color onPrimaryContainerDark = Color(0xFFFFDAD9);
  static const Color offPrimaryContainerDark = Color(0xFF382E30);

  /// Secondary dark
  static const Color secondaryDark = Color(0xFFD69399);
  static const Color onSecondaryDark = Color(0xFF3C1116);
  static const Color secondaryContainerDark = Color(0xFF5E2129);
  static const Color onSecondaryContainerDark = Color(0xFFFFD9DD);

  /// Tertiary dark
  static const Color tertiaryDark = Color(0xFFFFB2BE);
  static const Color onTertiaryDark = Color(0xFF561D2A);
  static const Color tertiaryContainerDark = Color(0xFF7B2D3C);
  static const Color onTertiaryContainerDark = Color(0xFFFFD9DF);

  /// Background & Surface dark
  static const Color backgroundDark = Color(0xFF141213);
  static const Color onBackgroundDark = Color(0xFFF5F5F5);

  static const Color surfaceDark = Color(0xFF1E1A1A);
  static const Color onSurfaceDark = Color(0xFFEDE0E0);
  static const Color surfaceVariantDark = Color(0xFF524345);
  static const Color onSurfaceVariantDark = Color(0xFFD7C1C3);

  static const Color outlineDark = Color(0xFF9F8C8E);
  static const Color outlineVariantDark = Color(0xFF524345);

  /// Inverse colors (Dark theme)
  static const Color inverseSurfaceDark = Color(0xFFF5F5F5);
  static const Color inverseOnSurfaceDark = Color(0xFF2C2C2C);
  static const Color inversePrimaryDark = Color(0xFF9E0B0F);

  /// Elemen netral & disabled (Dark)
  static const Color surfaceDisabledDark = Color(0x1FFFFFFF);
  static const Color onSurfaceDisabledDark = Color(0x61FFFFFF);
  static const Color backdropDark = Color(0x99000000);

  /// Card, text, border, & notification (Dark)
  static const Color cardDark = Color(0xFF262021);
  static const Color textDark = Color(0xFFF5F5F5);
  static const Color borderDark = Color(0xFF4A3E41);
  static const Color notificationDark = Color(0xFFFF5449);

  /// Error palette (Dark)
  static const Color errorDark = Color(0xFFFFB4AB);
  static const Color onErrorDark = Color(0xFF690005);
  static const Color errorContainerDark = Color(0xFF93000A);
  static const Color onErrorContainerDark = Color(0xFFFFDAD6);

  // Elevation Levels (Dark)
  static const Color elevationLevel0Dark = Color(0xFF141213);
  static const Color elevationLevel1Dark = Color(0xFF1F1B1B);
  static const Color elevationLevel2Dark = Color(0xFF252021);
  static const Color elevationLevel3Dark = Color(0xFF2B2527);
  static const Color elevationLevel4Dark = Color(0xFF312A2C);
  static const Color elevationLevel5Dark = Color(0xFF383032);

  // ===========================================================================
  // Status Colors (Sesuai `statusColors` di theme.ts)
  // ===========================================================================

  // Attendance
  static const Color statusPresent = Color(0xFF4CAF50);
  static const Color statusLate = Color(0xFFFF9800);
  static const Color statusAbsent = Color(0xFFF44336);
  static const Color statusLeftEarly = Color(0xFF2196F3);
  static const Color statusNoClockOut = Color(0xFF607D8B);

  // Cuti (Leave)
  static const Color statusPending = Color(0xFF2196F3);
  static const Color statusApproved = Color(0xFF4CAF50);
  static const Color statusRejected = Color(0xFFFF7043);
  static const Color statusCanceled = Color(0xFFF44336);

  // Request Form
  static const Color statusDraft = Color(0xFF2196F3);
  static const Color statusConfirmed = Color(0xFF3DDAD7);
  static const Color statusPaid = Color(0xFF4CAF50);

  // Lead Status
  static const Color statusNew = Color(0xFF2196F3);
  static const Color statusOpen = Color(0xFF4CAF50);
  static const Color statusFail = Color(0xFF9E9E9E);
  static const Color statusSuccess = Color(0xFF2196F3);
}

