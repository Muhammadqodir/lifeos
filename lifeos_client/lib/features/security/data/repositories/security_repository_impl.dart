import '../../domain/repositories/security_repository.dart';
import '../datasources/security_local_storage.dart';

class SecurityRepositoryImpl implements SecurityRepository {
  final SecurityLocalStorage localStorage;

  SecurityRepositoryImpl({required this.localStorage});

  @override
  Future<void> setPasscode(String passcode, bool enableBiometric) async {
    await localStorage.savePasscode(passcode);
    if (enableBiometric && await localStorage.isBiometricAvailable()) {
      await localStorage.setBiometricEnabled(true);
    } else {
      await localStorage.setBiometricEnabled(false);
    }
  }

  @override
  Future<bool> verifyPasscode(String passcode) async {
    return await localStorage.verifyPasscode(passcode);
  }

  @override
  Future<bool> hasPasscode() async {
    return await localStorage.hasPasscode();
  }

  @override
  Future<void> clearPasscode() async {
    await localStorage.clearPasscode();
  }

  @override
  Future<bool> isBiometricEnabled() async {
    return await localStorage.isBiometricEnabled();
  }

  @override
  Future<bool> isBiometricAvailable() async {
    return await localStorage.isBiometricAvailable();
  }

  @override
  Future<bool> authenticateWithBiometrics() async {
    return await localStorage.authenticateWithBiometrics();
  }
}
