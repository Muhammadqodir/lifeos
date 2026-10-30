import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keychain-backed storage for secrets (auth token, local passcode).
///
/// Values are cached in memory after [load], so hot paths such as the auth
/// interceptor can read them synchronously.
///
/// Earlier builds kept these values in plain [SharedPreferences]. [load]
/// moves any value it finds there into the Keychain and deletes the plain
/// copy, so existing users stay signed in.
class SecureStore {
  SecureStore(this._prefs, {FlutterSecureStorage? storage})
    : _storage = storage ?? _defaultStorage;

  final SharedPreferences _prefs;
  final FlutterSecureStorage _storage;

  // The data-protection keychain needs the keychain-access-groups
  // entitlement and a provisioning profile on macOS. The legacy login
  // keychain is still encrypted and works with ad-hoc signed builds.
  static const _defaultStorage = FlutterSecureStorage(
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    mOptions: MacOsOptions(usesDataProtectionKeychain: false),
  );

  static const authTokenKey = 'auth_token';
  static const passcodeKey = 'local_passcode';
  static const _legacyRefreshTokenKey = 'refresh_token';
  static const _keys = [authTokenKey, passcodeKey];

  final Map<String, String> _cache = {};

  Future<void> load() async {
    for (final key in _keys) {
      try {
        final legacy = _prefs.getString(key);
        if (legacy != null) {
          await _storage.write(key: key, value: legacy);
          await _prefs.remove(key);
        }
        final value = legacy ?? await _storage.read(key: key);
        if (value != null) _cache[key] = value;
      } catch (e) {
        // A locked or unavailable keychain must not block app start; the
        // user is simply treated as signed out.
        debugPrint('SecureStore: could not read $key: $e');
      }
    }
    await _prefs.remove(_legacyRefreshTokenKey);
  }

  String? read(String key) => _cache[key];

  Future<void> write(String key, String value) async {
    _cache[key] = value;
    await _storage.write(key: key, value: value);
  }

  Future<void> delete(String key) async {
    _cache.remove(key);
    await _storage.delete(key: key);
  }
}
