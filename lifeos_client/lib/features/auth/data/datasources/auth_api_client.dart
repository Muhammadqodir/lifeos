import 'package:dio/dio.dart';
import '../../../../core/network/api_exception.dart';
import '../models/user_dto.dart';

class AuthApiClient {
  final Dio dio;
  final String baseUrl;

  AuthApiClient({required this.dio, required this.baseUrl});

  Future<AuthResponseDto> login(String email, String password) async {
    try {
      final response = await dio.post(
        '$baseUrl/auth/login',
        data: {'email': email, 'password': password},
      );

      // Check if response is successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResponseDto.fromJson(response.data['data']);
      } else {
        // Handle error responses
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<AuthResponseDto> register({
    required String firstName,
    required String lastName,
    String? fatherName,
    DateTime? dateOfBirth,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/auth/register',
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'father_name': fatherName,
          'date_of_birth': dateOfBirth?.toIso8601String().split('T')[0],
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );
      return AuthResponseDto.fromJson(response.data['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout(String token) async {
    try {
      await dio.post(
        '$baseUrl/auth/logout',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<UserDto> getCurrentUser(String token) async {
    try {
      final response = await dio.get(
        '$baseUrl/auth/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return UserDto.fromJson(response.data['data']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(Object error) => ApiException.from(error);
}
