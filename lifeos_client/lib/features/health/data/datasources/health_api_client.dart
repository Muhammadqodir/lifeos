import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import '../models/exercise_dto.dart';
import '../models/sleep_entry_dto.dart';
import '../models/sleep_summary_dto.dart';
import '../models/wellbeing_entry_dto.dart';
import '../models/wellbeing_summary_dto.dart';
import '../models/workout_session_dto.dart';
import '../models/workout_summary_dto.dart';

class HealthApiClient {
  final Dio dio;
  final String baseUrl;

  HealthApiClient({required this.dio, required this.baseUrl});

  // Sleep endpoints
  Future<List<SleepEntryDto>> getSleepEntries({
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};

      if (dateFrom != null) {
        queryParameters['from'] = dateFrom.toIso8601String().split('T')[0];
      }
      if (dateTo != null) {
        queryParameters['to'] = dateTo.toIso8601String().split('T')[0];
      }

      final response = await dio.get(
        '$baseUrl/health/sleep',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => SleepEntryDto.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<SleepSummaryDto> getSleepSummary({
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};

      if (dateFrom != null) {
        queryParameters['from'] = dateFrom.toIso8601String().split('T')[0];
      }
      if (dateTo != null) {
        queryParameters['to'] = dateTo.toIso8601String().split('T')[0];
      }

      final response = await dio.get(
        '$baseUrl/health/sleep/summary',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        return SleepSummaryDto.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<SleepEntryDto> createSleepEntry({
    required String date,
    required String sleepStart,
    required String sleepEnd,
    required int quality,
    String? note,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/health/sleep',
        data: {
          'date': date,
          'sleep_start': sleepStart,
          'sleep_end': sleepEnd,
          'quality': quality,
          if (note != null) 'note': note,
        },
      );

      if (response.statusCode == 201) {
        return SleepEntryDto.fromJson(response.data['data']);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Wellbeing endpoints
  Future<List<WellbeingEntryDto>> getWellbeingEntries({
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};

      if (dateFrom != null) {
        queryParameters['from'] = dateFrom.toIso8601String().split('T')[0];
      }
      if (dateTo != null) {
        queryParameters['to'] = dateTo.toIso8601String().split('T')[0];
      }

      final response = await dio.get(
        '$baseUrl/health/wellbeing',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => WellbeingEntryDto.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<WellbeingSummaryDto> getWellbeingSummary({
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};

      if (dateFrom != null) {
        queryParameters['from'] = dateFrom.toIso8601String().split('T')[0];
      }
      if (dateTo != null) {
        queryParameters['to'] = dateTo.toIso8601String().split('T')[0];
      }

      final response = await dio.get(
        '$baseUrl/health/wellbeing/summary',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        return WellbeingSummaryDto.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<WellbeingEntryDto> createWellbeingEntry({
    required String date,
    required int energy,
    required int stress,
    String? note,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/health/wellbeing',
        data: {
          'date': date,
          'energy': energy,
          'stress': stress,
          if (note != null) 'note': note,
        },
      );

      if (response.statusCode == 201) {
        return WellbeingEntryDto.fromJson(response.data['data']);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Workout endpoints
  Future<WorkoutSummaryDto> getWorkoutSummary({
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};

      if (dateFrom != null) {
        queryParameters['from'] = dateFrom.toIso8601String().split('T')[0];
      }
      if (dateTo != null) {
        queryParameters['to'] = dateTo.toIso8601String().split('T')[0];
      }

      final response = await dio.get(
        '$baseUrl/health/workout/summary',
        queryParameters: queryParameters,
      );

      print(response.data);

      if (response.statusCode == 200) {
        return WorkoutSummaryDto.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }
    } catch (e, s) {
      throw _handleError(e.toString() + s.toString());
    }
  }

  // Workout endpoints
  Future<List<ExerciseDto>> getExercises({bool includeLastSession = false}) async {
    try {
      final queryParams = includeLastSession ? {'include_last_session': '1'} : null;
      print('Fetching exercises from: $baseUrl/gym/exercises with params: $queryParams');
      
      final response = await dio.get(
        '$baseUrl/gym/exercises',
        queryParameters: queryParams,
      );

      print('Response status: ${response.statusCode}');
      print('Response data type: ${response.data.runtimeType}');
      
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        print('Successfully loaded ${data.length} exercises');
        return data.map((json) => ExerciseDto.fromJson(json)).toList();
      } else {
        print('Unexpected status code: ${response.statusCode}');
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }
    } catch (e, stackTrace) {
      print('Error fetching exercises: $e');
      print('Stack trace: $stackTrace');
      throw _handleError(e);
    }
  }

  Future<ExerciseDto> createExercise(
    Map<String, dynamic> exerciseData,
    String? imagePath,
  ) async {
    try {
      FormData formData;

      if (imagePath != null) {
        // Create multipart form data with image
        formData = FormData.fromMap({
          ...exerciseData,
          'image': await MultipartFile.fromFile(
            imagePath,
            filename: imagePath.split('/').last,
          ),
        });
      } else {
        // Send as regular JSON without image
        formData = FormData.fromMap(exerciseData);
      }

      final response = await dio.post('$baseUrl/gym/exercises', data: formData);

      if (response.statusCode == 201) {
        return ExerciseDto.fromJson(response.data['data']);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteExercise(int exerciseId) async {
    try {
      final response = await dio.delete('$baseUrl/gym/exercises/$exerciseId');

      if (response.statusCode != 200) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<WorkoutSessionDto>> getWorkoutSessions({
    DateTime? dateFrom,
    DateTime? dateTo,
    int page = 1,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'page': page,
      };

      if (dateFrom != null) {
        queryParameters['from'] = dateFrom.toIso8601String().split('T')[0];
      }
      if (dateTo != null) {
        queryParameters['to'] = dateTo.toIso8601String().split('T')[0];
      }

      final response = await dio.get(
        '$baseUrl/gym/workouts',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => WorkoutSessionDto.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteWorkoutSession(int workoutId) async {
    try {
      final response = await dio.delete('$baseUrl/gym/workouts/$workoutId');

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<WorkoutSessionDto> saveCompleteWorkout(
    Map<String, dynamic> workoutData,
  ) async {
    try {
      final response = await dio.post(
        '$baseUrl/gym/workouts/complete',
        data: workoutData,
      );

      if (response.statusCode == 201) {
        print(response.data);
        return WorkoutSessionDto.fromJson(response.data['data']);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }
    } catch (e, s) {
      print('Error: $e\nStack trace: $s');
      throw _handleError(e);
    }
  }

  Future<WorkoutSessionDto> saveCompleteWorkoutWithPhoto(
    Map<String, dynamic> workoutData,
    File? photoFile,
  ) async {
    try {
      // Convert workout_data to JSON string for multipart
      FormData formData = FormData.fromMap({
        'workout_data': jsonEncode(workoutData),
      });

      if (photoFile != null) {
        formData.files.add(
          MapEntry(
            'photo',
            await MultipartFile.fromFile(
              photoFile.path,
              filename: photoFile.path.split('/').last,
            ),
          ),
        );
      }

      final response = await dio.post(
        '$baseUrl/gym/workouts/complete-with-photo',
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      if (response.statusCode == 201) {
        return WorkoutSessionDto.fromJson(response.data['data']);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }
    } catch (e, s) {
      print('Error: $e\nStack trace: $s');
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return Exception('Connection timeout. Please try again.');
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final responseData = error.response?.data;
          
          // Handle specific status codes
          if (statusCode == 401) {
            return Exception('Unauthorized. Please login again.');
          } else if (statusCode == 403) {
            return Exception('Access forbidden.');
          } else if (statusCode == 404) {
            return Exception('Resource not found.');
          } else if (statusCode == 422) {
            // Validation error - extract message
            if (responseData is Map) {
              // Check for Laravel validation errors
              if (responseData['errors'] != null && responseData['errors'] is Map) {
                final errors = responseData['errors'] as Map;
                if (errors.isNotEmpty) {
                  final firstError = errors.values.first;
                  if (firstError is List && firstError.isNotEmpty) {
                    return Exception(firstError.first.toString());
                  }
                }
              }
              // Check for simple message
              if (responseData['message'] != null) {
                return Exception(responseData['message'].toString());
              }
            }
            return Exception('Validation failed. Please check your input.');
          } else if (statusCode! >= 500) {
            // Extract server error message if available
            if (responseData is Map && responseData['message'] != null) {
              return Exception('Server Error ($statusCode): ${responseData['message']}');
            }
            return Exception('Server error ($statusCode). Please try again later.');
          }
          
          // For other errors, try to extract message
          if (responseData is Map && responseData['message'] != null) {
            return Exception(responseData['message'].toString());
          }
          return Exception('Request failed with status $statusCode');
        case DioExceptionType.cancel:
          return Exception('Request cancelled.');
        case DioExceptionType.connectionError:
          return Exception(
            'No internet connection. Please check your connection.',
          );
        case DioExceptionType.badCertificate:
          return Exception('Certificate error.');
        case DioExceptionType.unknown:
          // Check if there's a response with more details
          if (error.response != null) {
            final statusCode = error.response?.statusCode;
            final responseData = error.response?.data;
            if (responseData is Map && responseData['message'] != null) {
              if (statusCode != null && statusCode >= 500) {
                return Exception('Server Error ($statusCode): ${responseData['message']}');
              }
              return Exception(responseData['message'].toString());
            }
            if (statusCode != null) {
              return Exception('Request failed with status $statusCode');
            }
          }
          // Check if there's an underlying error message
          if (error.error != null) {
            final errorMsg = error.error.toString();
            // Provide more context for common network errors
            if (errorMsg.contains('SocketException') || errorMsg.contains('Connection refused')) {
              return Exception('Cannot connect to server. Please check if the server is running and the URL is correct.');
            }
            if (errorMsg.contains('Failed host lookup')) {
              return Exception('Cannot resolve server address. Please check your internet connection.');
            }
            return Exception('Network error: ${error.error}');
          }
          return Exception('An unexpected error occurred. Please try again.');
      }
    }
    return Exception('An unexpected error occurred: $error');
  }
}
