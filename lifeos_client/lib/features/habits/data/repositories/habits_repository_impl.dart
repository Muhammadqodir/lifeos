import 'package:lifeos_client/features/habits/data/datasources/habits_api_client.dart';
import 'package:lifeos_client/features/habits/data/models/habit_dto.dart';
import 'package:lifeos_client/features/habits/data/models/habit_entry_dto.dart';
import 'package:lifeos_client/features/habits/data/models/habit_stats_dto.dart';
import 'package:lifeos_client/features/habits/domain/repositories/habits_repository.dart';

class HabitsRepositoryImpl implements HabitsRepository {
  final HabitsApiClient apiClient;

  HabitsRepositoryImpl({required this.apiClient});

  @override
  Future<List<HabitDto>> getHabits({
    String? status,
    String? frequency,
    String? search,
  }) async {
    return await apiClient.getHabits(
      status: status,
      frequency: frequency,
      search: search,
    );
  }

  @override
  Future<HabitDto> getHabit(int habitId) async {
    return await apiClient.getHabit(habitId);
  }

  @override
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
    return await apiClient.createHabit(
      title: title,
      description: description,
      color: color,
      icon: icon,
      status: status,
      frequency: frequency,
      frequencyDays: frequencyDays,
      reminderTime: reminderTime,
      goalDuration: goalDuration,
      tags: tags,
    );
  }

  @override
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
    return await apiClient.updateHabit(
      habitId: habitId,
      title: title,
      description: description,
      color: color,
      icon: icon,
      status: status,
      frequency: frequency,
      frequencyDays: frequencyDays,
      reminderTime: reminderTime,
      goalDuration: goalDuration,
      tags: tags,
    );
  }

  @override
  Future<void> deleteHabit(int habitId) async {
    return await apiClient.deleteHabit(habitId);
  }

  @override
  Future<HabitStatsDto> getHabitStats({
    required int habitId,
    int days = 30,
  }) async {
    return await apiClient.getHabitStats(
      habitId: habitId,
      days: days,
    );
  }

  @override
  Future<List<HabitDto>> getHabitsWithTodayStatus() async {
    return await apiClient.getHabitsWithTodayStatus();
  }

  @override
  Future<List<HabitEntryDto>> getHabitEntries({
    int? habitId,
    String? from,
    String? to,
  }) async {
    return await apiClient.getHabitEntries(
      habitId: habitId,
      from: from,
      to: to,
    );
  }

  @override
  Future<HabitEntryDto> createHabitEntry({
    required int habitId,
    required String date,
    String? completedAt,
    String? note,
  }) async {
    try {
      final result = await apiClient.createHabitEntry(
        habitId: habitId,
        date: date,
        completedAt: completedAt,
        note: note,
      );
      return result;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteHabitEntry(int entryId) async {
    return await apiClient.deleteHabitEntry(entryId);
  }

  @override
  Future<Map<String, dynamic>> getCalendarEntries({
    required String from,
    required String to,
  }) async {
    return await apiClient.getCalendarEntries(from: from, to: to);
  }
}
