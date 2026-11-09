/// Entitas User domain yang merepresentasikan data pengguna dari backend AuthController
class User {
  const User({
    required this.id,
    required this.username,
    required this.name,
    this.role = 'Operator',
    this.token,
    this.nmUsers,
    this.idUsersLevel,
    this.idKaryawan,
    this.phone,
    this.linkFoto,
    this.isActive = 1,
  });

  /// ID User dari database
  final String id;

  /// Username untuk autentikasi login
  final String username;

  /// Nama lengkap pengguna (alias dari [nmUsers])
  final String name;

  /// Peran/Level pengguna (misal: Administrator, Operator, Supervisor)
  final String role;

  /// Token sesi otentikasi (Bearer token dari refresh_token di AuthController)
  final String? token;

  /// Nama pengguna dari database backend (kolom `nm_users`)
  final String? nmUsers;

  /// ID level otorisasi pengguna (`id_users_level`)
  final String? idUsersLevel;

  /// ID atau NIK karyawan (`id_karyawan`)
  final String? idKaryawan;

  /// Nomor telepon / WhatsApp pengguna (`phone`)
  final String? phone;

  /// URL atau tautan foto profil pengguna (`link_foto`)
  final String? linkFoto;

  /// Status aktif user: 1 = Aktif, 0 = Non-aktif (`is_active`)
  final int isActive;

  /// Apakah akun pengguna aktif
  bool get isUserActive => isActive == 1;

  @override
  String toString() =>
      'User(id: $id, username: $username, name: $name, role: $role, token: ${token != null ? "[PROTECTED]" : "null"})';
}
