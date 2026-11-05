import '../entities/user.dart';

/// Kontrak repository autentikasi pada domain layer
abstract class AuthRepository {
  /// Melakukan login dengan [username] dan [password]
  Future<User> login({
    required String username,
    required String password,
  });

  /// Melakukan logout
  Future<void> logout();

  /// Mendapatkan user yang sedang aktif
  Future<User?> getCurrentUser();
}

