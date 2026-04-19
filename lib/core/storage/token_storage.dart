import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    wOptions: WindowsOptions(),
  );

  static const _userTokenKey = 'user_access_token';
  static const _userNameKey = 'user_full_name';
  static const _merchantTokenKey = 'merchant_access_token';
  static const _merchantIdKey = 'merchant_id';

  static Future<void> saveUserToken(String token) => _write(_userTokenKey, token);
  static Future<void> saveUserName(String name) => _write(_userNameKey, name);
  static Future<void> saveMerchantToken(String token) => _write(_merchantTokenKey, token);
  static Future<void> saveMerchantId(String id) => _write(_merchantIdKey, id);

  static Future<String?> getUserToken() => _read(_userTokenKey);
  static Future<String?> getUserName() => _read(_userNameKey);
  static Future<String?> getMerchantToken() => _read(_merchantTokenKey);
  static Future<String?> getMerchantId() => _read(_merchantIdKey);

  static Future<void> clearUserToken() => _delete(_userTokenKey);
  static Future<void> clearMerchantToken() => _delete(_merchantTokenKey);

  static Future<void> clearAll() async {
    await _secureStorage.deleteAll();
  }

  static Future<void> _write(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  static Future<String?> _read(String key) async {
    return await _secureStorage.read(key: key);
  }

  static Future<void> _delete(String key) async {
    await _secureStorage.delete(key: key);
  }
}
