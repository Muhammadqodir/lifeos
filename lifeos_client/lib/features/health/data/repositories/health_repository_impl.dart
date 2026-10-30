import '../../../../core/sync/local_store.dart';
import '../../../../core/sync/sync_engine.dart';
import '../../domain/repositories/health_repository.dart';
import '../models/sleep_entry_dto.dart';
import '../models/sleep_summary_dto.dart';
import '../models/wellbeing_entry_dto.dart';
import '../models/wellbeing_summary_dto.dart';
import '../models/workout_summary_dto.dart';

/// Local-first health data (docs/local-first.md). Summaries are computed
/// here the same way the backend's summary endpoints compute them.
class HealthRepositoryImpl implements HealthRepository {
  HealthRepositoryImpl({required this.store, required this.sync});

  final LocalStore store;
  final SyncEngine sync;

  static const _entities = {
    SyncEntities.sleepEntries,
    SyncEntities.wellbeingEntries,
    SyncEntities.workoutSessions,
  };

  @override
  Stream<void> get changes =>
      store.changes.where((touched) => touched.any(_entities.contains));

  static String _ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// Records of [entity] whose `date` is within the range, oldest first.
  Future<List<Json>> _byDate(
    String entity,
    DateTime? from,
    DateTime? to,
  ) async {
    final lo = from == null ? null : _ymd(from);
    final hi = to == null ? null : _ymd(to);
    return (await store.all(entity)).where((r) {
        final date = r['date'] as String;
        return (lo == null || date.compareTo(lo) >= 0) &&
            (hi == null || date.compareTo(hi) <= 0);
      }).toList()
      ..sort((a, b) => (a['date'] as String).compareTo(b['date'] as String));
  }

  static double? _durationHours(Json r) {
    final start = DateTime.tryParse(r['sleep_start'] as String? ?? '');
    final end = DateTime.tryParse(r['sleep_end'] as String? ?? '');
    if (start == null || end == null) return null;
    return end.difference(start).inMinutes / 60;
  }

  static double _avg(Iterable<num> values) => values.isEmpty
      ? 0
      : values.fold<double>(0, (sum, v) => sum + v) / values.length;

  static double _round2(double v) => (v * 100).roundToDouble() / 100;

  // ---------------------------------------------------------------------------
  // Sleep

  @override
  Future<List<SleepEntryDto>> getSleepEntries({
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async => [
    for (final r in (await _byDate(
      SyncEntities.sleepEntries,
      dateFrom,
      dateTo,
    )).reversed)
      SleepEntryDto.fromJson({...r, 'duration_hours': _durationHours(r) ?? 0}),
  ];

  @override
  Future<SleepSummaryDto> getSleepSummary({
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    final entries = await _byDate(SyncEntities.sleepEntries, dateFrom, dateTo);
    final durations = entries.map(_durationHours).whereType<double>();
    return SleepSummaryDto.fromJson({
      'count': entries.length,
      'avg_duration_hours': _round2(_avg(durations)),
      'avg_quality': _round2(_avg(entries.map((e) => e['quality'] as num))),
      'points': [
        for (final e in entries)
          {
            'date': e['date'],
            'duration_hours': _durationHours(e) ?? 0,
            'quality': e['quality'],
          },
      ],
    });
  }

  @override
  Future<SleepEntryDto> createSleepEntry({
    required String date,
    required String sleepStart,
    required String sleepEnd,
    required int quality,
    String? note,
  }) async {
    final data = {
      'date': date,
      'sleep_start': DateTime.parse(sleepStart).toUtc().toIso8601String(),
      'sleep_end': DateTime.parse(sleepEnd).toUtc().toIso8601String(),
      'quality': quality,
      'note': note,
    };
    final record = await _upsertForDate(SyncEntities.sleepEntries, date, data);
    return SleepEntryDto.fromJson({
      ...record,
      'duration_hours': _durationHours(record) ?? 0,
    });
  }

  /// One entry per day: logging a day again updates its entry (the server
  /// does the same when two devices log the same day).
  Future<Json> _upsertForDate(String entity, String date, Json data) async {
    final existing = (await store.all(
      entity,
    )).where((r) => r['date'] == date).firstOrNull;
    if (existing == null) return sync.create(entity, data);
    return (await sync.update(entity, existing['id'] as String, data))!;
  }

  // ---------------------------------------------------------------------------
  // Wellbeing

  @override
  Future<List<WellbeingEntryDto>> getWellbeingEntries({
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async => [
    for (final r in (await _byDate(
      SyncEntities.wellbeingEntries,
      dateFrom,
      dateTo,
    )).reversed)
      WellbeingEntryDto.fromJson(r),
  ];

  @override
  Future<WellbeingSummaryDto> getWellbeingSummary({
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    final entries = await _byDate(
      SyncEntities.wellbeingEntries,
      dateFrom,
      dateTo,
    );
    return WellbeingSummaryDto.fromJson({
      'count': entries.length,
      'avg_energy': _round2(_avg(entries.map((e) => e['energy'] as num))),
      'avg_stress': _round2(_avg(entries.map((e) => e['stress'] as num))),
      'points': [
        for (final e in entries)
          {'date': e['date'], 'energy': e['energy'], 'stress': e['stress']},
      ],
    });
  }

  @override
  Future<WellbeingEntryDto> createWellbeingEntry({
    required String date,
    required int energy,
    required int stress,
    String? note,
  }) async => WellbeingEntryDto.fromJson(
    await _upsertForDate(SyncEntities.wellbeingEntries, date, {
      'date': date,
      'energy': energy,
      'stress': stress,
      'note': note,
    }),
  );

  // ---------------------------------------------------------------------------
  // Workouts

  /// Days with a workout in the range, and the streak of consecutive days
  /// up to today (or yesterday), like the backend's WorkoutService.
  @override
  Future<WorkoutSummaryDto> getWorkoutSummary({
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    final days = <String>{};
    var count = 0;
    final lo = dateFrom == null ? null : _ymd(dateFrom);
    final hi = dateTo == null ? null : _ymd(dateTo);
    final allDays = <String>{};
    for (final w in await store.all(SyncEntities.workoutSessions)) {
      final started = DateTime.tryParse(w['started_at'] as String? ?? '');
      if (started == null) continue;
      final day = _ymd(started.toLocal());
      allDays.add(day);
      if ((lo == null || day.compareTo(lo) >= 0) &&
          (hi == null || day.compareTo(hi) <= 0)) {
        count++;
        days.add(day);
      }
    }

    final now = DateTime.now();
    var expected = DateTime(now.year, now.month, now.day);
    if (!allDays.contains(_ymd(expected))) {
      expected = DateTime(expected.year, expected.month, expected.day - 1);
    }
    var streak = 0;
    while (allDays.contains(_ymd(expected))) {
      streak++;
      expected = DateTime(expected.year, expected.month, expected.day - 1);
    }

    return WorkoutSummaryDto.fromJson({
      'count': count,
      'current_streak': streak,
      'sessions': [
        for (final day in days.toList()..sort())
          {'date': day, 'has_session': true},
      ],
    });
  }
}
