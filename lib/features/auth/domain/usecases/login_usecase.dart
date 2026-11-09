import '../entities/user.dart';
import '../repositories/auth_repository.dart';

/// UseCase untuk menangani alur logika bisnis login ke backend AuthController
class LoginUseCase {
  const LoginUseCase(this.repository);

  final AuthRepository repository;

  Future<User> execute({
    required String username,
    required String password,
  }) async {
    final cleanUsername = username.trim();

    if (cleanUsername.isEmpty) {
      throw ArgumentError('Username wajib diisi.');
    }

    if (password.isEmpty) {
      throw ArgumentError('Password wajib diisi.');
    }

    return await repository.login(username: cleanUsername, password: password);
  }
}
