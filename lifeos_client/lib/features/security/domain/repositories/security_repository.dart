abstract class SecurityRepository {
  Future<void> setPasscode(String passcode, bool enableBiometric);
  Future<bool> verifyPasscode(String passcode);
  Future<bool> hasPasscode();
  Future<void> clearPasscode();
  Future<bool> isBiometricEnabled();
  Future<bool> isBiometricAvailable();
  Future<bool> authenticateWithBiometrics();
}
