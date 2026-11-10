import 'dart:async';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc {
  ProfileBloc({
    required this.repository,
    GetProfileUseCase? getProfileUseCase,
    UserProfile? initialProfile,
  })  : _getProfileUseCase = getProfileUseCase ?? GetProfileUseCase(repository),
        _state = initialProfile != null ? ProfileLoaded(initialProfile) : const ProfileInitial() {
    _eventSubscription = _eventController.stream.listen(_mapEventToState);
  }

  final ProfileRepository repository;
  final GetProfileUseCase _getProfileUseCase;

  ProfileState _state;
  late final StreamSubscription<ProfileEvent> _eventSubscription;

  final _eventController = StreamController<ProfileEvent>();
  final _stateController = StreamController<ProfileState>.broadcast();

  ProfileState get state => _state;
  Stream<ProfileState> get stream => _stateController.stream;

  void add(ProfileEvent event) {
    if (!_eventController.isClosed) {
      _eventController.add(event);
    }
  }

  void _emit(ProfileState newState) {
    _state = newState;
    if (!_stateController.isClosed) {
      _stateController.add(newState);
    }
  }

  Future<void> _mapEventToState(ProfileEvent event) async {
    switch (event) {
      case LoadProfile():
        await _onLoadProfile();
        break;
      case UpdateProfileEvent(:final profile):
        await _onUpdateProfile(profile);
        break;
      case LogoutEvent():
        await _onLogout();
        break;
    }
  }

  Future<void> _onLoadProfile() async {
    _emit(const ProfileLoading());
    try {
      final profile = await _getProfileUseCase();
      _emit(ProfileLoaded(profile));
    } catch (e) {
      _emit(ProfileError('Gagal memuat profil: $e'));
    }
  }

  Future<void> _onUpdateProfile(UserProfile profile) async {
    try {
      final updated = await repository.updateProfile(profile);
      _emit(ProfileUpdateSuccess(updated, 'Profil berhasil diperbarui'));
      _emit(ProfileLoaded(updated));
    } catch (e) {
      _emit(ProfileError('Gagal memperbarui profil: $e'));
    }
  }

  Future<void> _onLogout() async {
    try {
      await repository.logout();
      _emit(const ProfileLoggedOut());
    } catch (e) {
      _emit(const ProfileLoggedOut());
    }
  }

  void close() {
    _eventSubscription.cancel();
    _eventController.close();
    _stateController.close();
  }
}

