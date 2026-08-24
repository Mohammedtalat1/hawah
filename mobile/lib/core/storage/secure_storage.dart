import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

/// Secure storage for sensitive data (tokens, credentials).
class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> saveToken(String token) =>
      _storage.write(key: AppConstants.keyAuthToken, value: token);

  Future<String?> getToken() =>
      _storage.read(key: AppConstants.keyAuthToken);

  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: AppConstants.keyRefreshToken, value: token);

  Future<String?> getRefreshToken() =>
      _storage.read(key: AppConstants.keyRefreshToken);

  Future<void> saveUserData(String json) =>
      _storage.write(key: AppConstants.keyUserData, value: json);

  Future<String?> getUserData() =>
      _storage.read(key: AppConstants.keyUserData);

  Future<void> clearAll() => _storage.deleteAll();

  Future<void> clearAuth() async {
    await _storage.delete(key: AppConstants.keyAuthToken);
    await _storage.delete(key: AppConstants.keyRefreshToken);
    await _storage.delete(key: AppConstants.keyUserData);
  }
}
