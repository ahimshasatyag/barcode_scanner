import 'package:flutter/material.dart';
import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/widgets.dart';

/// Form Login dengan Username dan Password
class LoginForm extends StatefulWidget {
  const LoginForm({
    super.key,
    required this.isLoading,
    required this.onSubmit,
  });

  final bool isLoading;
  final void Function(String username, String password) onSubmit;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit(
        _usernameController.text.trim(),
        _passwordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Input Username
          AppTextField(
            controller: _usernameController,
            label: 'Username',
            hintText: 'Masukkan nama pengguna...',
            prefixIcon: const Icon(Icons.person_outline, size: 20),
            textInputAction: TextInputAction.next,
            enabled: !widget.isLoading,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Username tidak boleh kosong';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),

          // Input Password
          AppTextField(
            controller: _passwordController,
            label: 'Kata Sandi',
            hintText: 'Masukkan kata sandi...',
            prefixIcon: const Icon(Icons.lock_outline, size: 20),
            isPassword: true,
            textInputAction: TextInputAction.done,
            enabled: !widget.isLoading,
            onSubmitted: (_) => _handleSubmit(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Kata sandi tidak boleh kosong';
              }
              if (value.length < 4) {
                return 'Kata sandi minimal 4 karakter';
              }
              return null;
            },
          ),
          const SizedBox(height: 28),

          // Tombol Masuk
          AppButton(
            text: 'Masuk Sekarang',
            type: AppButtonType.primary,
            size: AppButtonSize.large,
            icon: Icons.login,
            isFullWidth: true,
            isLoading: widget.isLoading,
            onPressed: widget.isLoading ? null : _handleSubmit,
          ),
        ],
      ),
    );
  }
}

