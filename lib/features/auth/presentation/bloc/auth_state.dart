import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';

/// State dasar untuk Autentikasi
@immutable
sealed class AuthState {
  const AuthState();
}

/// State awal (sebelum ada aksi login)
final class AuthInitial extends AuthState {
  const AuthInitial();
}

/// State sedang memproses login (menampilkan loading spinner)
final class AuthLoading extends AuthState {
  const AuthLoading();
}

/// State berhasil login dengan data User
final class AuthSuccess extends AuthState {
  const AuthSuccess(this.user);

  final User user;
}

/// State gagal login dengan pesan error
final class AuthFailure extends AuthState {
  const AuthFailure(this.message);

  final String message;
}

