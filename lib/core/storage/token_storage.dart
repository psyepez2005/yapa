import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Abstracción de almacenamiento que usa localStorage en web
/// y flutter_secure_storage en móvil/escritorio.
class TokenStorage {
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    wOptions: WindowsOptions(),
  );

  static const _userTokenKey = 'user_access_token';
  static const _userNameKey = 'user_full_name';
  static const _merchantTokenKey = 'merchant_access_token';
  static const _merchantIdKey = 'merchant_id';

  // ── Escritura ──────────────────────────────────────────────────────────────

  static Future<void> saveUserToken(String token) => _write(_userTokenKey, token);
  static Future<void> saveUserName(String name) => _write(_userNameKey, name);
  static Future<void> saveMerchantToken(String token) => _write(_merchantTokenKey, token);
  static Future<void> saveMerchantId(String id) => _write(_merchantIdKey, id);

  // ── Lectura ───────────────────────────────────────────────────────────────

  static Future<String?> getUserToken() => _read(_userTokenKey);
  static Future<String?> getUserName() => _read(_userNameKey);
  static Future<String?> getMerchantToken() => _read(_merchantTokenKey);
  static Future<String?> getMerchantId() => _read(_merchantIdKey);

  // ── Eliminación ───────────────────────────────────────────────────────────

  static Future<void> clearUserToken() => _delete(_userTokenKey);
  static Future<void> clearMerchantToken() => _delete(_merchantTokenKey);

  static Future<void> clearAll() async {
    if (kIsWeb) {
      html.window.localStorage.remove(_userTokenKey);
      html.window.localStorage.remove(_userNameKey);
      html.window.localStorage.remove(_merchantTokenKey);
      html.window.localStorage.remove(_merchantIdKey);
    } else {
      await _secureStorage.deleteAll();
    }
  }

  // ── Helpers internos ──────────────────────────────────────────────────────

  static Future<void> _write(String key, String value) async {
    if (kIsWeb) {
      html.window.localStorage[key] = value;
    } else {
      await _secureStorage.write(key: key, value: value);
    }
  }

  static Future<String?> _read(String key) async {
    if (kIsWeb) {
      return html.window.localStorage[key];
    } else {
      return await _secureStorage.read(key: key);
    }
  }

  static Future<void> _delete(String key) async {
    if (kIsWeb) {
      html.window.localStorage.remove(key);
    } else {
      await _secureStorage.delete(key: key);
    }
  }
}
