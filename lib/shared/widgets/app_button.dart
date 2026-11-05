import 'package:flutter/material.dart';
import '../theme/theme.dart';

enum AppButtonType {
  primary,
  secondary,
  outlined,
  text,
}

enum AppButtonSize {
  small,
  medium,
  large,
}

/// Tombol global yang dapat digunakan di seluruh modul aplikasi.
/// Mendukung tipe primary, secondary, outlined, text, status loading, dan ikon.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = AppButtonType.primary,
    this.size = AppButtonSize.medium,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.isFullWidth = false,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
  });

  /// Label teks pada tombol
  final String text;

  /// Callback ketika tombol ditekan. Jika null, tombol dinonaktifkan (disabled).
  final VoidCallback? onPressed;

  /// Tipe tampilan tombol
  final AppButtonType type;

  /// Ukuran tombol
  final AppButtonSize size;

  /// Ikon di sebelah kiri teks
  final IconData? icon;

  /// Ikon di sebelah kanan teks
  final IconData? trailingIcon;

  /// Menampilkan animasi loading spinner jika true
  final bool isLoading;

  /// Mengisi seluruh lebar horizontal container
  final bool isFullWidth;

  /// Custom background color (opsional)
  final Color? backgroundColor;

  /// Custom foreground/text color (opsional)
  final Color? foregroundColor;

  /// Custom border radius (opsional)
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = context.isDarkMode;

    final (padding, fontSize, iconSize, height) = switch (size) {
      AppButtonSize.small => (
          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          12.0,
          16.0,
          36.0,
        ),
      AppButtonSize.medium => (
          const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          14.0,
          20.0,
          48.0,
        ),
      AppButtonSize.large => (
          const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          16.0,
          24.0,
          56.0,
        ),
    };

    final radius = borderRadius ?? BorderRadius.circular(10);
    final isEnabled = onPressed != null && !isLoading;

    Color bg;
    Color fg;
    BorderSide borderSide = BorderSide.none;

    switch (type) {
      case AppButtonType.primary:
        bg = backgroundColor ??
            (isDark ? colorScheme.primary : AppColors.primary);
        fg = foregroundColor ?? colorScheme.onPrimary;
        break;

      case AppButtonType.secondary:
        bg = backgroundColor ??
            (isDark ? colorScheme.secondaryContainer : AppColors.secondaryContainer);
        fg = foregroundColor ??
            (isDark ? colorScheme.onSecondaryContainer : AppColors.onSecondaryContainer);
        break;

      case AppButtonType.outlined:
        bg = backgroundColor ?? Colors.transparent;
        fg = foregroundColor ??
            (isDark ? colorScheme.primary : AppColors.primary);
        borderSide = BorderSide(
          color: fg.withOpacity(0.6),
          width: 1.2,
        );
        break;

      case AppButtonType.text:
        bg = backgroundColor ?? Colors.transparent;
        fg = foregroundColor ??
            (isDark ? colorScheme.primary : AppColors.primary);
        break;
    }

    if (!isEnabled && type != AppButtonType.text && type != AppButtonType.outlined) {
      bg = isDark ? AppColors.surfaceDisabledDark : AppColors.surfaceDisabled;
      fg = isDark ? AppColors.onSurfaceDisabledDark : AppColors.onSurfaceDisabled;
    }

    Widget content = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: iconSize,
            height: iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          ),
          const SizedBox(width: 10),
        ] else if (icon != null) ...[
          Icon(icon, size: iconSize, color: fg),
          const SizedBox(width: 8),
        ],
        Text(
          text,
          style: TextStyle(
            color: fg,
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        if (trailingIcon != null && !isLoading) ...[
          const SizedBox(width: 8),
          Icon(trailingIcon, size: iconSize, color: fg),
        ],
      ],
    );

    Widget button = Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: borderSide,
      ),
      child: InkWell(
        onTap: isEnabled ? onPressed : null,
        borderRadius: radius,
        child: Container(
          height: height,
          padding: padding,
          alignment: Alignment.center,
          child: content,
        ),
      ),
    );

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}

