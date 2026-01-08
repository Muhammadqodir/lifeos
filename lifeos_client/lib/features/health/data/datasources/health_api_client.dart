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
  Future<List<ExerciseDto>> getExercises() async {
    try {
      final response = await dio.get('$baseUrl/gym/exercises');

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => ExerciseDto.fromJson(json)).toList();
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

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return Exception('Connection timeout. Please try again.');
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode == 401) {
            return Exception('Unauthorized. Please login again.');
          } else if (statusCode == 403) {
            return Exception('Access forbidden.');
          } else if (statusCode == 404) {
            return Exception('Resource not found.');
          } else if (statusCode! >= 500) {
            return Exception('Server error. Please try again later.');
          }
          final message = error.response?.data['message'];
          return Exception(message ?? 'Request failed with status $statusCode');
        case DioExceptionType.cancel:
          return Exception('Request cancelled.');
        case DioExceptionType.connectionError:
          return Exception(
            'No internet connection. Please check your connection.',
          );
        case DioExceptionType.badCertificate:
          return Exception('Certificate error.');
        case DioExceptionType.unknown:
          return Exception('An unexpected error occurred.');
      }
    }
    return Exception('An unexpected error occurred: $error');
  }
}
