import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';

class SecurityLocalStorage {
  final SharedPreferences prefs;
  final LocalAuthentication localAuth;

  static const String _passcodeKey = 'local_passcode';
  static const String _biometricEnabledKey = 'biometric_enabled';

  SecurityLocalStorage({
    required this.prefs,
    required this.localAuth,
  });

  // Passcode methods
  Future<void> savePasscode(String passcode) async {
    await prefs.setString(_passcodeKey, passcode);
  }

  Future<String?> getPasscode() async {
    return prefs.getString(_passcodeKey);
  }

  Future<void> clearPasscode() async {
    await prefs.remove(_passcodeKey);
    await prefs.remove(_biometricEnabledKey);
  }

  Future<bool> hasPasscode() async {
    return prefs.containsKey(_passcodeKey);
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
