import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Keys used in secure storage.
class StorageKeys {
  StorageKeys._();
  static const String authToken = 'auth_token';
  static const String userData = 'user_data';
  static const String userRole = 'user_role';
  static const String userEmail = 'user_email';
  static const String userName = 'user_nama';
  static const String userId = 'user_id';
}

/// Wrapper around FlutterSecureStorage for encrypted token & user data.
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  // ─────────────────────────────────────────
  // Token
  // ─────────────────────────────────────────
  Future<void> saveToken(String token) async {
    await _storage.write(key: StorageKeys.authToken, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: StorageKeys.authToken);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: StorageKeys.authToken);
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // ─────────────────────────────────────────
  // User data (stored as JSON string)
  // ─────────────────────────────────────────
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _storage.write(
      key: StorageKeys.userData,
      value: jsonEncode(userData),
    );
    // Also store individual fields for legacy compatibility
    if (userData['id'] != null) {
      await _storage.write(
        key: StorageKeys.userId,
        value: userData['id'].toString(),
      );
    }
    if (userData['nama'] != null) {
      await _storage.write(key: StorageKeys.userName, value: userData['nama']);
    }
    if (userData['email'] != null) {
      await _storage.write(key: StorageKeys.userEmail, value: userData['email']);
    }
    if (userData['role'] != null) {
      await _storage.write(key: StorageKeys.userRole, value: userData['role']);
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final data = await _storage.read(key: StorageKeys.userData);
    if (data == null) return null;
    return jsonDecode(data) as Map<String, dynamic>;
  }

  Future<String?> getUserRole() async {
    return await _storage.read(key: StorageKeys.userRole);
  }

  Future<String?> getUserEmail() async {
    return await _storage.read(key: StorageKeys.userEmail);
  }

  // ─────────────────────────────────────────
  // Clear all
  // ─────────────────────────────────────────
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}

/// Riverpod provider for SecureStorageService.
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});
