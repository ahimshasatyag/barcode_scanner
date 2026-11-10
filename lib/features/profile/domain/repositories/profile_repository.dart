import '../entities/user_profile.dart';

/// Kontrak repositori profil pengguna
abstract class ProfileRepository {
  /// Mengambil profil pengguna saat ini
  Future<UserProfile> getProfile();

  /// Memperbarui informasi profil pengguna
  Future<UserProfile> updateProfile(UserProfile profile);

  /// Melakukan logout dari sistem
  Future<void> logout();
}

