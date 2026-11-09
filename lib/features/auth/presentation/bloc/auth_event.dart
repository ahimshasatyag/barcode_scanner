import 'package:flutter/foundation.dart';

/// Event dasar untuk Autentikasi
@immutable
sealed class AuthEvent {
  const AuthEvent();
}

/// Event saat user menekan tombol login dengan username & password
final class LoginSubmitted extends AuthEvent {
  const LoginSubmitted({
    required this.username,
    required this.password,
  });

  final String username;
  final String password;
}

/// Event saat user meminta logout
final class LogoutRequested extends AuthEvent {
  const LogoutRequested({this.token});

  final String? token;
}

/// Event untuk memeriksa status login / profil user saat aplikasi dimulai
final class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested({this.token});

  final String? token;
}
