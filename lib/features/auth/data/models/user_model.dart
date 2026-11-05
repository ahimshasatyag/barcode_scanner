import '../../domain/entities/user.dart';

/// Model User pada data layer dengan serialisasi JSON
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.username,
    required super.name,
    required super.role,
    super.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      username: json['username'] as String? ?? '',
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? 'Operator',
      token: json['token'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'role': role,
      'token': token,
    };
  }

  User toEntity() {
    return User(
      id: id,
      username: username,
      name: name,
      role: role,
      token: token,
    );
  }
}

