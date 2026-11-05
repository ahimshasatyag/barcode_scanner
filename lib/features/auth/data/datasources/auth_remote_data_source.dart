import '../models/user_model.dart';

/// Kontrak Data Source Autentikasi
abstract class AuthRemoteDataSource {
  Future<UserModel> login({
    required String username,
    required String password,
  });

  Future<void> logout();

  Future<UserModel?> getCurrentUser();
}

/// Implementasi Data Source Autentikasi (Mock / API Service)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  UserModel? _cachedUser;

  @override
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    // Simulasi latensi jaringan (network delay)
    await Future.delayed(const Duration(milliseconds: 900));

    // Validasi kredensial login
    // Mendukung kredensial operator atau password valid apa pun (min 4 karakter)
    if (password == 'wrong' || password == 'salah') {
      throw Exception('Username atau kata sandi yang Anda masukkan salah');
    }

    final user = UserModel(
      id: 'USR-EMM-${DateTime.now().millisecondsSinceEpoch % 10000}',
      username: username,
      name: username.toUpperCase() == 'ADMIN'
          ? 'Administrator Gudang'
          : 'Operator Mesin ($username)',
      role: username.toUpperCase() == 'ADMIN' ? 'Supervisor' : 'Operator',
      token: 'jwt-token-emm-${DateTime.now().millisecondsSinceEpoch}',
    );

    _cachedUser = user;
    return user;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _cachedUser = null;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    return _cachedUser;
  }
}

