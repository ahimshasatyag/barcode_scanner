import 'dart:async';
import 'package:flutter/material.dart';
import 'package:barcode/core/transitions/smooth_page_transition.dart';
import 'package:barcode/features/main_navigation/main_navigation.dart';
import '../../../../shared/theme/theme.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/login_usecase.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/login_form.dart';
import '../widgets/login_header.dart';

/// Halaman Login Pengguna PT Eka Maju Mesinindo
class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.onToggleTheme,
    this.authBloc,
  });

  final VoidCallback onToggleTheme;
  final AuthBloc? authBloc;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late final AuthBloc _authBloc;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();

    // Inisialisasi dependensi Clean Architecture untuk AuthBloc jika belum disediakan
    _authBloc = widget.authBloc ??
        AuthBloc(
          loginUseCase: LoginUseCase(
            AuthRepositoryImpl(
              remoteDataSource: AuthRemoteDataSourceImpl(),
            ),
          ),
        );

    // Listener stream untuk menangani side-effects navigasi dan feedback snackbar
    _authSubscription = _authBloc.stream.listen((state) {
      if (!mounted) return;

      switch (state) {
        case AuthSuccess(:final user):
          AppSnackBar.showSuccess(
            context,
            'Berhasil masuk! Selamat datang, ${user.name}',
          );

          // Navigasi ke Halaman Utama Warehouse Navigation (Transaksi, Tracker, Opname)
          context.pushReplacementSmooth(
            MainNavigationPage(
              onToggleTheme: widget.onToggleTheme,
              user: user,
            ),
          );
          break;

        case AuthFailure(:final message):
          AppSnackBar.showError(context, message);
          break;

        case AuthInitial():
        case AuthLoading():
          break;
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    if (widget.authBloc == null) {
      _authBloc.close();
    }
    super.dispose();
  }

  void _onLoginSubmitted(String username, String password) {
    _authBloc.add(
      LoginSubmitted(
        username: username,
        password: password,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = context.isDarkMode;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: isDark ? 'Beralih ke Light Mode' : 'Beralih ke Dark Mode',
            onPressed: widget.onToggleTheme,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Header Logo & Judul
                  const LoginHeader(),
                  const SizedBox(height: 28),

                  // Card Formulir Login
                  AuthBlocBuilder(
                    bloc: _authBloc,
                    builder: (context, state) {
                      final isLoading = state is AuthLoading;

                      return AppCard(
                        padding: const EdgeInsets.all(24.0),
                        elevation: 2.0,
                        child: LoginForm(
                          isLoading: isLoading,
                          onSubmit: _onLoginSubmitted,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Footer Copyright
                  Text(
                    '© 2026 PT Eka Maju Mesinindo. All rights reserved.',
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

