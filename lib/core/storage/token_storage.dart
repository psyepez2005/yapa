import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();

  static const _userTokenKey = 'user_access_token';
  static const _merchantTokenKey = 'merchant_access_token';

  static Future<void> saveUserToken(String token) =>
      _storage.write(key: _userTokenKey, value: token);

  static Future<void> saveMerchantToken(String token) =>
      _storage.write(key: _merchantTokenKey, value: token);

  static Future<String?> getUserToken() =>
      _storage.read(key: _userTokenKey);

  static Future<String?> getMerchantToken() =>
      _storage.read(key: _merchantTokenKey);

  static Future<void> clearUserToken() =>
      _storage.delete(key: _userTokenKey);

  static Future<void> clearMerchantToken() =>
      _storage.delete(key: _merchantTokenKey);

  static Future<void> clearAll() => _storage.deleteAll();
}
