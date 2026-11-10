import '../../domain/entities/user_profile.dart';

abstract class ProfileEvent {
  const ProfileEvent();
}

class LoadProfile extends ProfileEvent {
  const LoadProfile();
}

class UpdateProfileEvent extends ProfileEvent {
  const UpdateProfileEvent(this.profile);
  final UserProfile profile;
}

class LogoutEvent extends ProfileEvent {
  const LogoutEvent();
}

