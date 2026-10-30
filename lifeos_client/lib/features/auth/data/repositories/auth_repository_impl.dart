import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/secure_store.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_api_client.dart';
import '../models/user_dto.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiClient apiClient;
  final SecureStore store;

  /// Keeps the signed-in profile so the app opens offline (local-first).
  /// Not secret; the token stays in [store].
  final SharedPreferences? prefs;

  static const _cachedUserKey = 'cached_user';

  AuthRepositoryImpl({
    required this.apiClient,
    required this.store,
    this.prefs,
  });

  Future<void> _cacheUser(UserDto user) async =>
      prefs?.setString(_cachedUserKey, jsonEncode(user.toJson()));

  UserDto? _cachedUser() {
    final raw = prefs?.getString(_cachedUserKey);
    if (raw == null) return null;
    try {
      return UserDto.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AuthResult> login(String email, String password) async {
    final response = await apiClient.login(email, password);
    await saveToken(response.token);
    await _cacheUser(response.user);
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
    await _cacheUser(response.user);
    return AuthResult(user: response.user.toEntity(), token: response.token);
  }

  @override
  Future<void> logout() async {
    final token = await getToken();
    try {
      if (token != null) await apiClient.logout(token);
    } finally {
      // Signed out locally even when the server can't be reached.
      await clearToken();
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    final token = await getToken();
    if (token == null) return null;

    try {
      final userDto = await apiClient.getCurrentUser(token);
      await _cacheUser(userDto);
      return userDto.toEntity();
    } on ApiException catch (e) {
      // Offline or a server hiccup: stay signed in with the cached profile.
      // Only a rejected token (401, also handled by AuthInterceptor) signs
      // the user out.
      final cached = _cachedUser();
      if (e.statusCode != 401 && cached != null) return cached.toEntity();
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
    await prefs?.remove(_cachedUserKey);
  }
}
