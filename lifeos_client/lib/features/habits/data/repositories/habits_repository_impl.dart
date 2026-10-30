import 'package:lifeos_client/core/sync/ids.dart';
import 'package:lifeos_client/core/sync/local_store.dart';
import 'package:lifeos_client/core/sync/sync_engine.dart';
import 'package:lifeos_client/features/habits/data/models/habit_dto.dart';
import 'package:lifeos_client/features/habits/data/models/habit_entry_dto.dart';
import 'package:lifeos_client/features/habits/domain/habit_stats.dart';
import 'package:lifeos_client/features/habits/domain/repositories/habits_repository.dart';

class HabitsRepositoryImpl implements HabitsRepository {
  HabitsRepositoryImpl({required this.store, required this.sync});

  final LocalStore store;
  final SyncEngine sync;

  static const _watched = {SyncEntities.habits, SyncEntities.habitEntries};

  Future<Map<String, List<Json>>> _entriesByHabit() async {
    final byHabit = <String, List<Json>>{};
    for (final entry in await store.all(SyncEntities.habitEntries)) {
      (byHabit[entry['habit_id'] as String] ??= []).add(entry);
    }
    return byHabit;
  }

  @override
  Stream<List<HabitDto>> watchHabits({String status = 'active'}) =>
      store.watch(_watched, () async {
        final entries = await _entriesByHabit();
        final habits = [
          for (final record in await store.all(SyncEntities.habits))
            if ((record['status'] ?? 'active') == status)
              () {
                final habit = HabitDto.fromJson(record);
                final dates = (entries[habit.id] ?? const []).map(
                  (e) => e['date'] as String,
                );
                return habit.withStats(HabitStats.compute(habit, dates));
              }(),
        ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return habits;
      });

  @override
  Stream<HabitActivity> watchActivity(String habitId, {int days = 30}) =>
      store.watch(_watched, () async {
        final record = await store.get(SyncEntities.habits, habitId);
        final entries = [
          for (final e in (await _entriesByHabit())[habitId] ?? const <Json>[])
            HabitEntryDto.fromJson(e),
        ]..sort((a, b) => b.date.compareTo(a.date));
        final stats = record == null
            ? HabitStats.compute(_placeholder(habitId), const [])
            : HabitStats.compute(
                HabitDto.fromJson(record),
                entries.map((e) => e.date),
                days: days,
              );
        return HabitActivity(entries: entries, stats: stats);
      });

  static HabitDto _placeholder(String id) => HabitDto(
    id: id,
    title: '',
    color: '3b82f6',
    frequency: 'daily',
    createdAt: DateTime.now().toIso8601String(),
    updatedAt: DateTime.now().toIso8601String(),
  );

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
    final record = await sync.create(SyncEntities.habits, {
      'title': title,
      'description': description,
      'color': color ?? '3b82f6',
      'icon': icon,
      'status': status ?? 'active',
      'frequency': frequency,
      'frequency_days': frequencyDays ?? const <int>[],
      'reminder_time': reminderTime,
      'goal_duration': goalDuration,
      'tags': tags ?? const <String>[],
    });
    final habit = HabitDto.fromJson(record);
    return habit.withStats(HabitStats.compute(habit, const []));
  }

  @override
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
  }) async {
    final record = await sync.update(SyncEntities.habits, habitId, {
      'title': ?title,
      'description': ?description,
      'color': ?color,
      'icon': ?icon,
      'status': ?status,
      'frequency': ?frequency,
      'frequency_days': ?frequencyDays,
      'reminder_time': ?reminderTime,
      'goal_duration': ?goalDuration,
      'tags': ?tags,
    });
    return record == null ? null : HabitDto.fromJson(record);
  }

  @override
  Future<void> deleteHabit(String habitId) =>
      sync.delete(SyncEntities.habits, habitId);

  @override
  Future<HabitEntryDto> createHabitEntry({
    required String habitId,
    required String date,
    String? completedAt,
    String? note,
  }) async {
    final record = await sync.create(SyncEntities.habitEntries, {
      'habit_id': habitId,
      'date': date,
      'completed_at': completedAt ?? DateTime.now().toUtc().toIso8601String(),
      'note': note,
    }, id: habitEntryId(habitId, date));
    return HabitEntryDto.fromJson(record);
  }

  @override
  Future<void> deleteHabitEntry(String entryId) =>
      sync.delete(SyncEntities.habitEntries, entryId);
}
