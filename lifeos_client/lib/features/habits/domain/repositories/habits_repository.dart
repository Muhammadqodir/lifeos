import 'package:lifeos_client/features/habits/data/models/habit_dto.dart';
import 'package:lifeos_client/features/habits/data/models/habit_entry_dto.dart';
import 'package:lifeos_client/features/habits/data/models/habit_stats_dto.dart';

/// A habit's entries and the numbers derived from them.
class HabitActivity {
  const HabitActivity({required this.entries, required this.stats});

  /// Newest first.
  final List<HabitEntryDto> entries;
  final HabitStatsDto stats;
}

/// Habits and their entries, read from and written to the device
/// (local-first). Streaks are computed locally (see HabitStats).
abstract class HabitsRepository {
  /// Habits with [status], newest first, with streaks and today's state.
  Stream<List<HabitDto>> watchHabits({String status = 'active'});

  Stream<HabitActivity> watchActivity(String habitId, {int days = 30});

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

  /// Changes the fields that are not null.
  Future<HabitDto?> updateHabit({
    required String habitId,
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

  Future<void> deleteHabit(String habitId);

  /// Marks [habitId] done on [date] (`yyyy-MM-dd`).
  Future<HabitEntryDto> createHabitEntry({
    required String habitId,
    required String date,
    String? completedAt,
    String? note,
  });

  Future<void> deleteHabitEntry(String entryId);
}
