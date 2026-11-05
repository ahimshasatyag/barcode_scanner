import 'package:flutter/material.dart';
import '../theme/theme.dart';

/// Form Input TextField global yang mendukung validasi, ikon prefix/suffix,
/// mode password (sembunyi/lihat), mode pencarian, dan tombol pintas scan barcode.
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.onBarcodeScanPressed,
    this.isPassword = false,
    this.isSearch = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.focusNode,
    this.fillColor,
  });

  final TextEditingController? controller;
  final String? initialValue;
  final String? label;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  /// Callback jika tombol scan barcode diaktifkan di sisi kanan input
  final VoidCallback? onBarcodeScanPressed;

  /// Mengaktifkan mode input kata sandi (obscureText) dengan tombol toggle mata
  final bool isPassword;

  /// Mengaktifkan mode pencarian (dengan tombol clear X otomatis ketika ada teks)
  final bool isSearch;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool readOnly;
  final bool enabled;
  final int? maxLines;
  final FocusNode? focusNode;
  final Color? fillColor;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;
  late final TextEditingController _effectiveController;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    _effectiveController = widget.controller ?? TextEditingController(text: widget.initialValue);
    _hasText = _effectiveController.text.isNotEmpty;

    _effectiveController.addListener(_handleControllerChange);
  }

  void _handleControllerChange() {
    final hasTextNow = _effectiveController.text.isNotEmpty;
    if (_hasText != hasTextNow) {
      setState(() {
        _hasText = hasTextNow;
      });
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _effectiveController.dispose();
    } else {
      _effectiveController.removeListener(_handleControllerChange);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = context.isDarkMode;

    Widget? effectiveSuffix;

    if (widget.isPassword) {
      effectiveSuffix = IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: colorScheme.onSurfaceVariant,
          size: 20,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    } else if (widget.isSearch && _hasText) {
      effectiveSuffix = IconButton(
        icon: const Icon(Icons.clear, size: 18),
        onPressed: () {
          _effectiveController.clear();
          widget.onChanged?.call('');
        },
      );
    } else if (widget.onBarcodeScanPressed != null) {
      effectiveSuffix = IconButton(
        icon: const Icon(Icons.qr_code_scanner, color: AppColors.primary),
        tooltip: 'Pindai Barcode',
        onPressed: widget.onBarcodeScanPressed,
      );
    } else {
      effectiveSuffix = widget.suffixIcon;
    }

    final effectivePrefix = widget.prefixIcon ??
        (widget.isSearch
            ? const Icon(Icons.search, size: 20)
            : null);

    final bg = widget.fillColor ??
        (isDark ? const Color(0xFF231E1F) : Colors.white);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextFormField(
          controller: _effectiveController,
          obscureText: _obscureText,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          validator: widget.validator,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          readOnly: widget.readOnly,
          enabled: widget.enabled,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          focusNode: widget.focusNode,
          style: TextStyle(
            fontSize: 14,
            color: colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: widget.hintText,
            helperText: widget.helperText,
            errorText: widget.errorText,
            filled: true,
            fillColor: bg,
            prefixIcon: effectivePrefix,
            suffixIcon: effectiveSuffix,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF453B3C) : const Color(0xFFCCCCCC),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF453B3C) : const Color(0xFFCCCCCC),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.8,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: AppColors.error,
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

