import '../../../../core/storage/secure_store.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_api_client.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiClient apiClient;
  final SecureStore store;

  AuthRepositoryImpl({required this.apiClient, required this.store});

  @override
  Future<AuthResult> login(String email, String password) async {
    final response = await apiClient.login(email, password);
    await saveToken(response.token);
    return AuthResult(user: response.user.toEntity(), token: response.token);
  }

  @override
  Future<AuthResult> register(RegisterParams params) async {
    final response = await apiClient.register(
      firstName: params.firstName,
      lastName: params.lastName,
      fatherName: params.fatherName,
      dateOfBirth: params.dateOfBirth,
      email: params.email,
      password: params.password,
      passwordConfirmation: params.passwordConfirmation,
    );
    await saveToken(response.token);
    return AuthResult(user: response.user.toEntity(), token: response.token);
  }

  @override
  Future<void> logout() async {
    final token = await getToken();
    if (token != null) {
      await apiClient.logout(token);
    }
    await clearToken();
  }

  @override
  Future<User?> getCurrentUser() async {
    final token = await getToken();
    if (token == null) return null;

    try {
      final userDto = await apiClient.getCurrentUser(token);
      return userDto.toEntity();
    } catch (e) {
      await clearToken();
      return null;
    }
  }

  @override
  Future<String?> getToken() async {
    return store.read(SecureStore.authTokenKey);
  }

  @override
  Future<void> saveToken(String token) async {
    await store.write(SecureStore.authTokenKey, token);
  }

  @override
  Future<void> clearToken() async {
    await store.delete(SecureStore.authTokenKey);
  }
}
