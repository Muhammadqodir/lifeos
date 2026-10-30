import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lifeos_client/core/storage/secure_store.dart';

class SecurityLocalStorage {
  final SharedPreferences prefs;
  final SecureStore secureStore;
  final LocalAuthentication localAuth;

  static const String _biometricEnabledKey = 'biometric_enabled';

  SecurityLocalStorage({
    required this.prefs,
    required this.secureStore,
    required this.localAuth,
  });

  // Passcode methods
  Future<void> savePasscode(String passcode) async {
    await secureStore.write(SecureStore.passcodeKey, passcode);
  }

  Future<String?> getPasscode() async {
    return secureStore.read(SecureStore.passcodeKey);
  }

  Future<void> clearPasscode() async {
    await secureStore.delete(SecureStore.passcodeKey);
    await prefs.remove(_biometricEnabledKey);
  }

  Future<bool> hasPasscode() async {
    return secureStore.read(SecureStore.passcodeKey) != null;
  }

  Future<bool> verifyPasscode(String passcode) async {
    final savedPasscode = await getPasscode();
    return savedPasscode == passcode;
  }

  // Biometric methods
  Future<void> setBiometricEnabled(bool enabled) async {
    await prefs.setBool(_biometricEnabledKey, enabled);
  }

  Future<bool> isBiometricEnabled() async {
    return prefs.getBool(_biometricEnabledKey) ?? false;
  }

  Future<bool> canCheckBiometrics() async {
    try {
      return await localAuth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await localAuth.canCheckBiometrics;
      if (!canCheck) return false;

      final availableBiometrics = await localAuth.getAvailableBiometrics();
      return availableBiometrics.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      return await localAuth.authenticate(
        localizedReason: 'Unlock LifeOS',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (e) {
      return false;
    }
  }
}
