import '../../domain/entities/user.dart';

/// Model User pada data layer dengan serialisasi JSON sesuai respon AuthController.php
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.username,
    required super.name,
    super.role = 'Operator',
    super.token,
    super.nmUsers,
    super.idUsersLevel,
    super.idKaryawan,
    super.phone,
    super.linkFoto,
    super.isActive = 1,
  });

  /// Factory untuk mem-parsing payload `data` dari JSON respon AuthController.php:
  /// ```json
  /// {
  ///   "user": {
  ///     "id": 1,
  ///     "username": "...",
  ///     "nm_users": "...",
  ///     "id_users_level": "...",
  ///     "id_karyawan": "...",
  ///     "phone": "...",
  ///     "link_foto": "...",
  ///     "is_active": 1
  ///   },
  ///   "token": "..."
  /// }
  /// ```
  factory UserModel.fromApiData(Map<String, dynamic> dataJson) {
    final userMap = dataJson['user'] is Map<String, dynamic>
        ? dataJson['user'] as Map<String, dynamic>
        : dataJson;
    final token = dataJson['token']?.toString() ?? userMap['token']?.toString();

    return UserModel.fromJson(userMap, token: token);
  }

  /// Factory untuk mem-parsing Map objek user
  factory UserModel.fromJson(Map<String, dynamic> json, {String? token}) {
    final id = json['id']?.toString() ?? '';
    final username = json['username']?.toString() ?? '';
    final nmUsers = json['nm_users']?.toString() ?? json['name']?.toString() ?? '';
    final idUsersLevel = json['id_users_level']?.toString();
    
    // Konversi level user ke nama role yang ramah pengguna
    final role = json['role']?.toString() ??
        (idUsersLevel == '1'
            ? 'Administrator'
            : idUsersLevel == '2'
                ? 'Supervisor'
                : 'Operator');

    final idKaryawan = json['id_karyawan']?.toString();
    final phone = json['phone']?.toString();
    final linkFoto = json['link_foto']?.toString();
    final isActive = int.tryParse(json['is_active']?.toString() ?? '1') ?? 1;

    return UserModel(
      id: id,
      username: username,
      name: nmUsers.isNotEmpty ? nmUsers : username,
      role: role,
      token: token ?? json['token']?.toString(),
      nmUsers: nmUsers,
      idUsersLevel: idUsersLevel,
      idKaryawan: idKaryawan,
      phone: phone,
      linkFoto: linkFoto,
      isActive: isActive,
    );
  }

  /// Serialisasi ke Map JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'nm_users': nmUsers,
      'id_users_level': idUsersLevel,
      'id_karyawan': idKaryawan,
      'phone': phone,
      'link_foto': linkFoto,
      'is_active': isActive,
      'role': role,
      'token': token,
    };
  }

  /// Konversi dari Model Data ke Entity Domain
  User toEntity() {
    return User(
      id: id,
      username: username,
      name: name,
      role: role,
      token: token,
      nmUsers: nmUsers,
      idUsersLevel: idUsersLevel,
      idKaryawan: idKaryawan,
      phone: phone,
      linkFoto: linkFoto,
      isActive: isActive,
    );
  }
}
