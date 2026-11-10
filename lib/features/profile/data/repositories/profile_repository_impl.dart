import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/user_profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({ProfileRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? ProfileRemoteDataSourceImpl();

  final ProfileRemoteDataSource _remoteDataSource;

  @override
  Future<UserProfile> getProfile() async {
    return _remoteDataSource.getProfile();
  }

  @override
  Future<UserProfile> updateProfile(UserProfile profile) async {
    final model = UserProfileModel.fromEntity(profile);
    return _remoteDataSource.updateProfile(model);
  }

  @override
  Future<void> logout() async {
    return _remoteDataSource.logout();
  }
}

