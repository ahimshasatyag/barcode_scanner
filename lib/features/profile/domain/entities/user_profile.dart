/// Entitas profil pengguna / staf warehouse
class UserProfile {
  const UserProfile({
    required this.id,
    required this.username,
    required this.name,
    this.role = 'Operator Gudang',
    this.idKaryawan,
    this.phone,
    this.email,
    this.department = 'Warehouse & Logistik Mesin',
    this.warehouseLocation = 'Gudang Utama Cakung (Dock 02)',
    this.shift = 'Shift 1 (08.00 - 17.00 WIB)',
    this.linkFoto,
    this.isActive = true,
  });

  final String id;
  final String username;
  final String name;
  final String role;
  final String? idKaryawan;
  final String? phone;
  final String? email;
  final String department;
  final String warehouseLocation;
  final String shift;
  final String? linkFoto;
  final bool isActive;

  UserProfile copyWith({
    String? id,
    String? username,
    String? name,
    String? role,
    String? idKaryawan,
    String? phone,
    String? email,
    String? department,
    String? warehouseLocation,
    String? shift,
    String? linkFoto,
    bool? isActive,
  }) {
    return UserProfile(
      id: id ?? this.id,
      username: username ?? this.username,
      name: name ?? this.name,
      role: role ?? this.role,
      idKaryawan: idKaryawan ?? this.idKaryawan,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      department: department ?? this.department,
      warehouseLocation: warehouseLocation ?? this.warehouseLocation,
      shift: shift ?? this.shift,
      linkFoto: linkFoto ?? this.linkFoto,
      isActive: isActive ?? this.isActive,
    );
  }
}

