import '../entities/user_profile.dart';
import '../repositories/profile_repository.dart';

class GetProfileUseCase {
  const GetProfileUseCase(this.repository);

  final ProfileRepository repository;

  Future<UserProfile> call() {
    return repository.getProfile();
  }
}

