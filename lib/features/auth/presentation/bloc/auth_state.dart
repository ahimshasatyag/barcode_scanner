import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';

/// State dasar untuk Autentikasi
@immutable
sealed class AuthState {
  const AuthState();
}

/// State awal (sebelum ada aksi login atau setelah logout)
final class AuthInitial extends AuthState {
  const AuthInitial();
}

/// State sedang memproses login atau komunikasi API (menampilkan loading spinner)
final class AuthLoading extends AuthState {
  const AuthLoading();
}

/// State berhasil login dengan payload data User dari AuthController.php
final class AuthSuccess extends AuthState {
  const AuthSuccess(this.user);

  final User user;
}

/// State gagal login dengan pesan error dari backend
final class AuthFailure extends AuthState {
  const AuthFailure(this.message);

  final String message;
}
