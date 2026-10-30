import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos_client/core/storage/secure_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('moves a plain-text token from preferences into the keychain', () async {
    SharedPreferences.setMockInitialValues({
      'auth_token': 'abc',
      'refresh_token': 'old',
      'isDarkTheme': true,
    });
    FlutterSecureStorage.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    final store = SecureStore(prefs);
    await store.load();

    expect(store.read(SecureStore.authTokenKey), 'abc');
    expect(prefs.containsKey('auth_token'), isFalse);
    expect(prefs.containsKey('refresh_token'), isFalse);
    // Unrelated preferences are untouched.
    expect(prefs.getBool('isDarkTheme'), isTrue);
    expect(
      await const FlutterSecureStorage().read(key: SecureStore.authTokenKey),
      'abc',
    );
  });

  test('reads existing keychain values and deletes them', () async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({'local_passcode': '1234'});
    final prefs = await SharedPreferences.getInstance();

    final store = SecureStore(prefs);
    await store.load();
    expect(store.read(SecureStore.passcodeKey), '1234');
    expect(store.read(SecureStore.authTokenKey), isNull);

    await store.delete(SecureStore.passcodeKey);
    expect(store.read(SecureStore.passcodeKey), isNull);
    expect(
      await const FlutterSecureStorage().read(key: SecureStore.passcodeKey),
      isNull,
    );
  });
}
