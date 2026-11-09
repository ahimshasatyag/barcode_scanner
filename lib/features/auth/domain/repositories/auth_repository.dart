import '../entities/user.dart';

/// Kontrak repository autentikasi pada domain layer
abstract class AuthRepository {
  /// Melakukan login dengan [username] dan [password] ke backend
  Future<User> login({
    required String username,
    required String password,
  });

  /// Melakukan logout dan membatalkan sesi pengguna
  Future<void> logout({String? token});

  /// Mendapatkan user yang sedang aktif dari sesi atau cache
  Future<User?> getCurrentUser({String? token});
}
