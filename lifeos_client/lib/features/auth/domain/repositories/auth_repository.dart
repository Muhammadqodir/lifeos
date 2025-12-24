import '../entities/user.dart';

abstract class AuthRepository {
  Future<AuthResult> login(String email, String password);
  Future<AuthResult> register(RegisterParams params);
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<String?> getToken();
  Future<void> saveToken(String token);
  Future<void> clearToken();
}

class AuthResult {
  final User user;
  final String token;

  AuthResult({required this.user, required this.token});
}

class RegisterParams {
  final String firstName;
  final String lastName;
  final String? fatherName;
  final DateTime? dateOfBirth;
  final String email;
  final String password;
  final String passwordConfirmation;

  RegisterParams({
    required this.firstName,
    required this.lastName,
    this.fatherName,
    this.dateOfBirth,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
  });
}
