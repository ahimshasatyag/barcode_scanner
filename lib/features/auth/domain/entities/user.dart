/// Entitas User domain
class User {
  const User({
    required this.id,
    required this.username,
    required this.name,
    required this.role,
    this.token,
  });

  final String id;
  final String username;
  final String name;
  final String role;
  final String? token;
}

