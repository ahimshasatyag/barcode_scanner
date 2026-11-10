import '../../domain/entities/user_profile.dart';

abstract class ProfileState {
  const ProfileState();
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  const ProfileLoaded(this.profile);
  final UserProfile profile;
}

class ProfileUpdateSuccess extends ProfileState {
  const ProfileUpdateSuccess(this.profile, this.message);
  final UserProfile profile;
  final String message;
}

class ProfileLoggedOut extends ProfileState {
  const ProfileLoggedOut();
}

class ProfileError extends ProfileState {
  const ProfileError(this.message);
  final String message;
}

