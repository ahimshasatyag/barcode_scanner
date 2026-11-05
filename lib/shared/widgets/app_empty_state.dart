import 'package:flutter/material.dart';
import '../theme/theme.dart';
import 'app_button.dart';

/// Widget tampilan kosong (Empty State) yang konsisten ketika data belum tersedia atau hasil pencarian nihil.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.actionText,
    this.onActionPressed,
    this.isCompact = false,
  });

  final String title;
  final String? message;
  final IconData icon;
  final String? actionText;
  final VoidCallback? onActionPressed;
  final bool isCompact;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = context.isDarkMode;

    final iconContainer = Container(
      padding: EdgeInsets.all(isCompact ? 12 : 20),
      decoration: BoxDecoration(
        color: isDark
            ? colorScheme.primaryContainer.withOpacity(0.2)
            : colorScheme.primaryContainer.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: isCompact ? 28 : 44,
        color: colorScheme.primary,
      ),
    );

    return Center(
      child: Padding(
        padding: EdgeInsets.all(isCompact ? 16.0 : 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconContainer,
            SizedBox(height: isCompact ? 12 : 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isCompact ? 14 : 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 6),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isCompact ? 12 : 13,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
            if (actionText != null && onActionPressed != null) ...[
              const SizedBox(height: 20),
              AppButton(
                text: actionText!,
                onPressed: onActionPressed,
                size: isCompact ? AppButtonSize.small : AppButtonSize.medium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

