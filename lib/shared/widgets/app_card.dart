import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Kartu container global dengan penataan gaya, border, dan bayangan yang konsisten
/// di seluruh aplikasi, mendukung interaksi tap (InkWell) dan mode terang/gelap.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.trailing,
    this.leading,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.symmetric(vertical: 6),
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.elevation = 1.0,
    this.showBorder = true,
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? leading;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color? backgroundColor;
  final Color? borderColor;
  final BorderRadius? borderRadius;
  final double elevation;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = context.isDarkMode;

    final defaultRadius = borderRadius ?? BorderRadius.circular(14);
    final bg = backgroundColor ??
        (isDark ? const Color(0xFF231E1F) : Colors.white);

    final border = showBorder
        ? Border.all(
            color: borderColor ??
                (isDark
                    ? const Color(0xFF3B3233)
                    : const Color(0xFFEBEBEB)),
            width: 0.9,
          )
        : null;

    final hasHeader = title != null || subtitle != null || leading != null || trailing != null;

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasHeader) ...[
          Row(
            children: [
              if (leading != null) ...[
                leading!,
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 12),
          Divider(
            height: 1,
            color: isDark ? const Color(0xFF382F30) : const Color(0xFFEEEEEE),
          ),
          const SizedBox(height: 12),
        ],
        child,
      ],
    );

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: defaultRadius,
        border: border,
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.25 : 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: defaultRadius,
          child: Padding(
            padding: padding,
            child: content,
          ),
        ),
      ),
    );
  }
}

