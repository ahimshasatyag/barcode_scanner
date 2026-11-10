import 'dart:async';
import 'package:flutter/material.dart';
import 'package:barcode/app/config/config.dart';
import 'package:barcode/core/transitions/smooth_page_transition.dart';
import 'package:barcode/features/auth/domain/entities/user.dart';
import 'package:barcode/features/auth/presentation/pages/login_page.dart';
import 'package:barcode/shared/theme/theme.dart';
import 'package:barcode/shared/widgets/widgets.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/user_profile.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/profile_menu_tile.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    this.user,
    this.onToggleTheme,
    this.bloc,
  });

  final User? user;
  final VoidCallback? onToggleTheme;
  final ProfileBloc? bloc;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfileBloc _bloc;
  StreamSubscription<ProfileState>? _subscription;

  @override
  void initState() {
    super.initState();

    final initialProfile = widget.bloc?.state is ProfileLoaded
        ? (widget.bloc!.state as ProfileLoaded).profile
        : widget.user != null
            ? UserProfile(
                id: widget.user!.id,
                username: widget.user!.username,
                name: widget.user!.name,
                role: widget.user!.role,
                idKaryawan: widget.user!.idKaryawan ?? 'NIK-EMM-2026-088',
                phone: widget.user!.phone ?? '+62 812-9842-1102',
                email: '${widget.user!.username}@ekamaju.com',
              )
            : null;

    _bloc = widget.bloc ??
        ProfileBloc(
          repository: ProfileRepositoryImpl(),
          initialProfile: initialProfile,
        );

    _subscription = _bloc.stream.listen((state) {
      if (!mounted) return;

      if (state is ProfileLoggedOut) {
        AppSnackBar.showInfo(context, 'Berhasil keluar dari akun.');
        Navigator.of(context).pushAndRemoveUntil(
          SmoothPageRoute(
            page: LoginPage(onToggleTheme: widget.onToggleTheme ?? () {}),
          ),
          (route) => false,
        );
      } else if (state is ProfileError) {
        AppSnackBar.showError(context, state.message);
      }
    });

    if (initialProfile == null) {
      _bloc.add(const LoadProfile());
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    if (widget.bloc == null) {
      _bloc.close();
    }
    super.dispose();
  }

  Future<void> _confirmLogout() async {
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: 'Konfirmasi Keluar',
      message: 'Apakah Anda yakin ingin keluar dari akun staf gudang?',
      confirmText: 'Ya, Keluar',
      cancelText: 'Batal',
      isDestructive: true,
      icon: Icons.logout_rounded,
    );

    if (confirmed == true && mounted) {
      _bloc.add(const LogoutEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;
    final isDark = context.isDarkMode;

    return StreamBuilder<ProfileState>(
      stream: _bloc.stream,
      initialData: _bloc.state,
      builder: (context, snapshot) {
        final state = snapshot.data ?? const ProfileInitial();

        UserProfile profile = const UserProfile(
          id: 'USR-EMM-091',
          username: 'operator.gudang',
          name: 'Budi Santoso',
          role: 'Warehouse Leader',
        );

        if (state is ProfileLoaded) {
          profile = state.profile;
        } else if (state is ProfileUpdateSuccess) {
          profile = state.profile;
        }

        return RefreshIndicator(
          color: colorScheme.primary,
          onRefresh: () async {
            _bloc.add(const LoadProfile());
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Kartu Profil
                ProfileHeaderCard(profile: profile),
                const SizedBox(height: 20),

                // Grup Menu: Akun & Operasional
                Text(
                  'Operasional & Akun',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 10),

                ProfileMenuTile(
                  icon: Icons.badge_outlined,
                  title: 'Informasi Staf Gudang',
                  subtitle: '${profile.phone ?? "-"} • ${profile.email ?? "-"}',
                  onTap: () {
                    AppConfirmationDialog.show(
                      context,
                      title: 'Data Staf Warehouse',
                      message:
                          'Nama: ${profile.name}\nUsername: ${profile.username}\nNIK: ${profile.idKaryawan ?? "-"}\nTelepon: ${profile.phone ?? "-"}\nEmail: ${profile.email ?? "-"}\nDivisi: ${profile.department}\nLokasi: ${profile.warehouseLocation}',
                      confirmText: 'Tutup',
                    );
                  },
                ),
                const SizedBox(height: 8),

                ProfileMenuTile(
                  icon: Icons.receipt_long_outlined,
                  title: 'Aktivitas Scanner Hari Ini',
                  subtitle: 'Riwayat scan peti kemas & muatan truk',
                  iconColor: const Color(0xFF2E7D32),
                  onTap: () {
                    AppSnackBar.showInfo(context, 'Membuka rekap scan shift aktif');
                  },
                ),
                const SizedBox(height: 20),

                // Grup Menu: Pengaturan Sistem & Jaringan
                Text(
                  'Sistem & Jaringan',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 10),

                ProfileMenuTile(
                  icon: Icons.dns_outlined,
                  title: 'Server Backend Laravel',
                  subtitle: AppConfig.current.baseUrl,
                  iconColor: const Color(0xFF0288D1),
                  trailing: const AppStatusBadge(
                    status: 'Connected',
                    color: Color(0xFF2E7D32),
                    isDense: true,
                  ),
                  onTap: () {
                    AppConfirmationDialog.show(
                      context,
                      title: 'Status Server Backend',
                      message:
                          'URL API: ${AppConfig.current.baseUrl}\nHost: ${AppConfig.current.host}\nPort: ${AppConfig.current.port}\nStatus: Terhubung (Online)\nLingkungan: ${AppConfig.current.environment.name.toUpperCase()}',
                      confirmText: 'Tutup',
                    );
                  },
                ),
                const SizedBox(height: 8),

                ProfileMenuTile(
                  icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                  title: 'Tampilan Aplikasi',
                  subtitle: isDark ? 'Mode Gelap (Dark Mode)' : 'Mode Terang (Light Mode)',
                  trailing: Switch.adaptive(
                    value: isDark,
                    onChanged: (val) {
                      widget.onToggleTheme?.call();
                    },
                  ),
                ),
                const SizedBox(height: 8),

                ProfileMenuTile(
                  icon: Icons.help_outline_rounded,
                  title: 'Panduan & SOP Pergudangan',
                  subtitle: 'Standar scan kontainer impor & truk klien',
                  onTap: () {
                    AppConfirmationDialog.show(
                      context,
                      title: 'SOP Pemindaian Mesin',
                      message:
                          '1. Inbound: Buka segel kontainer, scan barcode setiap peti kayu mesin.\n2. Pastikan nomor seri cocok dengan dokumen B/L.\n3. Outbound: Scan mesin saat dinaikkan ke truk klien sesuai nomor Surat Jalan.\n4. Tekan "Selesaikan Transaksi" untuk menutup manifes.',
                      confirmText: 'Mengerti',
                    );
                  },
                ),
                const SizedBox(height: 84),

                // Tombol Keluar / Logout
                ProfileMenuTile(
                  icon: Icons.logout_rounded,
                  title: 'Keluar dari Akun',
                  subtitle: 'Akhiri sesi kerja operator',
                  isDestructive: true,
                  onTap: _confirmLogout,
                ),
                const SizedBox(height: 32),

                // Versi Aplikasi
                Center(
                  child: Text(
                    'PT Eka Maju Mesinindo • Versi 1.0.0+1 (Build 2026)',
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.outline.withValues(alpha: 0.7),
                    ),
                  ),
                ),
                const SizedBox(height: 84),
              ],
            ),
          ),
        );
      },
    );
  }
}
