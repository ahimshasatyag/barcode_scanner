import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

/// Implementasi repository autentikasi yang menghubungkan domain layer ke remote data source
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({required this.remoteDataSource});

  final AuthRemoteDataSource remoteDataSource;

  @override
  Future<User> login({
    required String username,
    required String password,
  }) async {
    final userModel = await remoteDataSource.login(
      username: username,
      password: password,
    );
    return userModel.toEntity();
  }

  @override
  Future<void> logout({String? token}) async {
    await remoteDataSource.logout(token: token);
  }

  @override
  Future<User?> getCurrentUser({String? token}) async {
    final userModel = await remoteDataSource.getCurrentUser(token: token);
    return userModel?.toEntity();
  }
}
