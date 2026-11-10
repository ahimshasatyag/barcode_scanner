/// Kontrak service penyimpanan persisten lokal
abstract class StorageService {
  Future<void> setString(String key, String value);
  String? getString(String key);

  Future<void> setBool(String key, bool value);
  bool? getBool(String key);

  Future<void> setInt(String key, int value);
  int? getInt(String key);

  Future<void> remove(String key);
  Future<void> clear();
}

/// Implementasi in-memory storage yang handal untuk sesi aplikasi
class InMemoryStorageService implements StorageService {
  final Map<String, dynamic> _storage = {};

  @override
  Future<void> setString(String key, String value) async {
    _storage[key] = value;
  }

  @override
  String? getString(String key) {
    return _storage[key] as String?;
  }

  @override
  Future<void> setBool(String key, bool value) async {
    _storage[key] = value;
  }

  @override
  bool? getBool(String key) {
    return _storage[key] as bool?;
  }

  @override
  Future<void> setInt(String key, int value) async {
    _storage[key] = value;
  }

  @override
  int? getInt(String key) {
    return _storage[key] as int?;
  }

  @override
  Future<void> remove(String key) async {
    _storage.remove(key);
  }

  @override
  Future<void> clear() async {
    _storage.clear();
  }
}

