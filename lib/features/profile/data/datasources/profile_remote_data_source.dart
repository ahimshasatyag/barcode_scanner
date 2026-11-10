import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:barcode/app/constats/api_endpoints.dart';
import '../models/user_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserProfileModel> getProfile();
  Future<UserProfileModel> updateProfile(UserProfileModel profile);
  Future<void> logout();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = (baseUrl ?? ApiEndpoints.defaultBaseUrl).replaceAll(RegExp(r'/+$'), '');

  final http.Client _client;
  final String _baseUrl;

  static UserProfileModel _cachedProfile = const UserProfileModel(
    id: 'USR-EMM-091',
    username: 'operator.gudang',
    name: 'Budi Santoso',
    role: 'Warehouse Leader',
    idKaryawan: 'NIK-2026-0914',
    phone: '+62 812-3456-7890',
    email: 'budi.santoso@ekamaju.com',
    department: 'Divisi Logistik & Pergudangan Mesin',
    warehouseLocation: 'Gudang Utama Cakung (Loading Dock 02)',
    shift: 'Shift 1 (Pagi: 08.00 - 17.00 WIB)',
  );

  @override
  Future<UserProfileModel> getProfile() async {
    try {
      final response = await _client.get(
        Uri.parse('$_baseUrl${ApiEndpoints.me}'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(milliseconds: 1500));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final data = (decoded['data'] ?? decoded) as Map<String, dynamic>;
        _cachedProfile = UserProfileModel.fromJson(data);
        return _cachedProfile;
      }
    } catch (_) {
      // Fallback seamlessly to mock data
    }
    return _cachedProfile;
  }

  @override
  Future<UserProfileModel> updateProfile(UserProfileModel profile) async {
    _cachedProfile = profile;
    return _cachedProfile;
  }

  @override
  Future<void> logout() async {
    try {
      await _client.post(
        Uri.parse('$_baseUrl${ApiEndpoints.logout}'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(milliseconds: 1000));
    } catch (_) {
      // Local logout succeeds regardless
    }
  }
}

