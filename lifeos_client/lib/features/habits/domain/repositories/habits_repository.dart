import 'package:lifeos_client/features/habits/data/models/habit_dto.dart';
import 'package:lifeos_client/features/habits/data/models/habit_entry_dto.dart';
import 'package:lifeos_client/features/habits/data/models/habit_stats_dto.dart';

abstract class HabitsRepository {
  // Habits CRUD
  Future<List<HabitDto>> getHabits({
    String? status,
    String? frequency,
    String? search,
  });

  Future<HabitDto> getHabit(int habitId);

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
  });

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
  });

  Future<void> deleteHabit(int habitId);

  // Habit stats
  Future<HabitStatsDto> getHabitStats({
    required int habitId,
    int days = 30,
  });

  Future<List<HabitDto>> getHabitsWithTodayStatus();

  // Habit entries
  Future<List<HabitEntryDto>> getHabitEntries({
    int? habitId,
    String? from,
    String? to,
  });

  Future<HabitEntryDto> createHabitEntry({
    required int habitId,
    required String date,
    String? completedAt,
    String? note,
  });

  Future<void> deleteHabitEntry(int entryId);

  Future<Map<String, dynamic>> getCalendarEntries({
    required String from,
    required String to,
  });
}
