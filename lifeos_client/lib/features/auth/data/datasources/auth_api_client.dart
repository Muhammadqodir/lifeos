import 'package:dio/dio.dart';
import '../models/user_dto.dart';

class AuthApiClient {
  final Dio dio;
  final String baseUrl;

  AuthApiClient({required this.dio, required this.baseUrl});

  Future<AuthResponseDto> login(String email, String password) async {
    try {
      final response = await dio.post(
        '$baseUrl/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );
      
      // Check if response is successful
      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResponseDto.fromJson(response.data);
      } else {
        print(response);
        // Handle error responses
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }
    } catch (e) {
      print(e);
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
      return AuthResponseDto.fromJson(response.data);
    } catch (e) {
      print(e);
      throw _handleError(e);
    }
  }

  Future<void> logout(String token) async {
    try {
      await dio.post(
        '$baseUrl/auth/logout',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<UserDto> getCurrentUser(String token) async {
    try {
      final response = await dio.get(
        '$baseUrl/auth/me',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );
      return UserDto.fromJson(response.data['user']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      // Handle redirects (302, 301, etc.)
      if (error.response?.statusCode == 302 || error.response?.statusCode == 301) {
        return Exception('Invalid credentials');
      }
      
      // Handle validation errors (422)
      if (error.response?.statusCode == 422) {
        try {
          final data = error.response?.data;
          if (data is Map) {
            final errors = data['errors'];
            if (errors != null && errors is Map) {
              final firstError = errors.values.first;
              final message = firstError is List ? firstError.first : firstError;
              return Exception(message);
            }
          }
        } catch (e) {
          // Ignore parsing errors
        }
      }
      
      // Handle other error responses
      try {
        final data = error.response?.data;
        if (data is Map && data['message'] != null) {
          final message = data['message'];
          return Exception(message);
        }
      } catch (e) {
        // Ignore parsing errors
      }
      
      // Fallback for unauthorized
      if (error.response?.statusCode == 401) {
        return Exception('Invalid credentials');
      }
      
      return Exception('Network error');
    }
    return Exception('Unknown error occurred');
  }
}
