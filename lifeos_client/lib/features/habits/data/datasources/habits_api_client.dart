import 'package:dio/dio.dart';
import 'package:lifeos_client/features/habits/data/models/habit_dto.dart';
import 'package:lifeos_client/features/habits/data/models/habit_entry_dto.dart';
import 'package:lifeos_client/features/habits/data/models/habit_stats_dto.dart';

class HabitsApiClient {
  final Dio dio;
  final String baseUrl;

  HabitsApiClient({required this.dio, required this.baseUrl});

  // Habits CRUD
  Future<List<HabitDto>> getHabits({
    String? status,
    String? frequency,
    String? search,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'with_stats': '1',
        'with_today': '1',
      };

      if (status != null) {
        queryParameters['status'] = status;
      }
      if (frequency != null) {
        queryParameters['frequency'] = frequency;
      }
      if (search != null) {
        queryParameters['search'] = search;
      }

      final response = await dio.get(
        '$baseUrl/habits',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => HabitDto.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<HabitDto> getHabit(int habitId) async {
    try {
      final response = await dio.get(
        '$baseUrl/habits/$habitId',
        queryParameters: {
          'with_stats': '1',
          'with_today': '1',
        },
      );

      if (response.statusCode == 200) {
        return HabitDto.fromJson(response.data['data']);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<HabitDto> createHabit({
    required String title,
    String? description,
    String? color,
    String? icon,
    String? status,
    required String frequency,
    List<int>? frequencyDays,
    String? reminderTime,
    int? goalDuration,
    List<String>? tags,
  }) async {
    try {
      final requestData = {
        'title': title,
        if (description != null) 'description': description,
        if (color != null) 'color': color,
        if (icon != null) 'icon': icon,
        if (status != null) 'status': status,
        'frequency': frequency,
        if (frequencyDays != null) 'frequency_days': frequencyDays,
        if (reminderTime != null) 'reminder_time': reminderTime,
        if (goalDuration != null) 'goal_duration': goalDuration,
        if (tags != null) 'tags': tags,
      };

      final response = await dio.post(
        '$baseUrl/habits',
        data: requestData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return HabitDto.fromJson(response.data['data']);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<HabitDto> updateHabit({
    required int habitId,
    String? title,
    String? description,
    String? color,
    String? icon,
    String? status,
    String? frequency,
    List<int>? frequencyDays,
    String? reminderTime,
    int? goalDuration,
    List<String>? tags,
  }) async {
    try {
      final response = await dio.put(
        '$baseUrl/habits/$habitId',
        data: {
          if (title != null) 'title': title,
          if (description != null) 'description': description,
          if (color != null) 'color': color,
          if (icon != null) 'icon': icon,
          if (status != null) 'status': status,
          if (frequency != null) 'frequency': frequency,
          if (frequencyDays != null) 'frequency_days': frequencyDays,
          if (reminderTime != null) 'reminder_time': reminderTime,
          if (goalDuration != null) 'goal_duration': goalDuration,
          if (tags != null) 'tags': tags,
        },
      );

      if (response.statusCode == 200) {
        return HabitDto.fromJson(response.data['data']);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteHabit(int habitId) async {
    try {
      final response = await dio.delete('$baseUrl/habits/$habitId');

      if (response.statusCode != 200) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  // Habit stats
  Future<HabitStatsDto> getHabitStats({
    required int habitId,
    int days = 30,
  }) async {
    try {
      final response = await dio.get(
        '$baseUrl/habits/$habitId/stats',
        queryParameters: {'days': days},
      );

      if (response.statusCode == 200) {
        return HabitStatsDto.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<HabitDto>> getHabitsWithTodayStatus() async {
    try {
      final response = await dio.get(
        '$baseUrl/habits/today',
        queryParameters: {
          'with_stats': '1',
          'with_today': '1',
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => HabitDto.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  // Habit entries
  Future<List<HabitEntryDto>> getHabitEntries({
    int? habitId,
    String? from,
    String? to,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};

      if (habitId != null) {
        queryParameters['habit_id'] = habitId;
      }
      if (from != null) {
        queryParameters['from'] = from;
      }
      if (to != null) {
        queryParameters['to'] = to;
      }

      final response = await dio.get(
        '$baseUrl/habit-entries',
        queryParameters: queryParameters,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        return data.map((json) => HabitEntryDto.fromJson(json)).toList();
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<HabitEntryDto> createHabitEntry({
    required int habitId,
    required String date,
    String? completedAt,
    String? note,
  }) async {
    try {
      final requestData = {
        'date': date,
        if (completedAt != null) 'completed_at': completedAt,
        if (note != null) 'note': note,
      };

      final response = await dio.post(
        '$baseUrl/habits/$habitId/entries',
        data: requestData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return HabitEntryDto.fromJson(response.data['data']);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteHabitEntry(int entryId) async {
    try {
      final response = await dio.delete('$baseUrl/habit-entries/$entryId');

      if (response.statusCode != 200) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getCalendarEntries({
    required String from,
    required String to,
  }) async {
    try {
      final response = await dio.get(
        '$baseUrl/habit-entries/calendar',
        queryParameters: {
          'from': from,
          'to': to,
        },
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
