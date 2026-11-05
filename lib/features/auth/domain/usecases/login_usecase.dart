import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// UseCase untuk menangani alur bisnis Login dengan username dan password
class LoginUseCase {
  const LoginUseCase(this.repository);

  final AuthRepository repository;

  Future<User> execute({
    required String username,
    required String password,
  }) async {
    final cleanUsername = username.trim();

    if (cleanUsername.isEmpty) {
      throw ArgumentError('Username tidak boleh kosong');
    }

    if (password.isEmpty) {
      throw ArgumentError('Password tidak boleh kosong');
    }

    if (password.length < 4) {
      throw ArgumentError('Password minimal 4 karakter');
    }

    return await repository.login(
      username: cleanUsername,
      password: password,
    );
  }
}

