import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageHelper {
  StorageHelper._();

  // In-memory fallback for web/desktop where secure storage may be unreliable.
  static final Map<String, String> _memoryStore = {};

  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    wOptions: WindowsOptions(),
    webOptions: WebOptions(dbName: 'vehicle_expense_db', publicKey: 'vehicle_expense'),
  );

  static bool get _useMemory => kIsWeb;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userNameKey = 'user_name';

  static Future<void> _write(String key, String value) async {
    if (_useMemory) {
      _memoryStore[key] = value;
    } else {
      await _storage.write(key: key, value: value);
    }
  }

  static Future<String?> _read(String key) async {
    if (_useMemory) return _memoryStore[key];
    try {
      return await _storage.read(key: key);
    } catch (_) {
      return null;
    }
  }

  static Future<void> _deleteAll() async {
    if (_useMemory) {
      _memoryStore.clear();
    } else {
      await _storage.deleteAll();
    }
  }

  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _write(_accessTokenKey, accessToken),
      _write(_refreshTokenKey, refreshToken),
    ]);
  }

  static Future<String?> getAccessToken() => _read(_accessTokenKey);

  static Future<String?> getRefreshToken() => _read(_refreshTokenKey);

  static Future<void> saveUserInfo({
    required String userId,
    required String email,
    required String name,
  }) async {
    await Future.wait([
      _write(_userIdKey, userId),
      _write(_userEmailKey, email),
      _write(_userNameKey, name),
    ]);
  }

  static Future<String?> getUserId() => _read(_userIdKey);

  static Future<String?> getUserEmail() => _read(_userEmailKey);

  static Future<String?> getUserName() => _read(_userNameKey);

  static Future<bool> hasValidToken() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }

  static Future<void> clearAll() => _deleteAll();
}

