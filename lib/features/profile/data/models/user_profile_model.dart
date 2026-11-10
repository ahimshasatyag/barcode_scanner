import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.id,
    required super.username,
    required super.name,
    super.role,
    super.idKaryawan,
    super.phone,
    super.email,
    super.department,
    super.warehouseLocation,
    super.shift,
    super.linkFoto,
    super.isActive,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: (json['id_users'] ?? json['id'] ?? 'USR-001').toString(),
      username: (json['username'] ?? 'operator').toString(),
      name: (json['nm_users'] ?? json['name'] ?? 'Budi Santoso').toString(),
      role: (json['role'] ?? json['id_users_level'] ?? 'Warehouse Operator').toString(),
      idKaryawan: json['id_karyawan'] as String? ?? 'NIK-EMM-2026-088',
      phone: json['phone'] as String? ?? '+62 812-9842-1102',
      email: json['email'] as String? ?? 'budi.santoso@ekamaju.com',
      department: json['department'] as String? ?? 'Warehouse & Logistik Mesin',
      warehouseLocation: json['warehouse_location'] as String? ?? 'Gudang Utama Cakung (Dock 02)',
      shift: json['shift'] as String? ?? 'Shift 1 (08.00 - 17.00 WIB)',
      linkFoto: json['link_foto'] as String?,
      isActive: (json['is_active'] ?? 1) == 1,
    );
  }

  factory UserProfileModel.fromEntity(UserProfile entity) {
    return UserProfileModel(
      id: entity.id,
      username: entity.username,
      name: entity.name,
      role: entity.role,
      idKaryawan: entity.idKaryawan,
      phone: entity.phone,
      email: entity.email,
      department: entity.department,
      warehouseLocation: entity.warehouseLocation,
      shift: entity.shift,
      linkFoto: entity.linkFoto,
      isActive: entity.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'name': name,
      'role': role,
      'id_karyawan': idKaryawan,
      'phone': phone,
      'email': email,
      'department': department,
      'warehouse_location': warehouseLocation,
      'shift': shift,
      'link_foto': linkFoto,
      'is_active': isActive ? 1 : 0,
    };
  }
}

