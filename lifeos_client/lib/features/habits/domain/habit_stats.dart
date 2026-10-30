import '../data/models/habit_dto.dart';
import '../data/models/habit_stats_dto.dart';

/// Streaks and completion rate, computed on the device from local entries.
///
/// A "period" is a day, a Monday-based week or a month depending on the
/// habit's frequency; a streak counts consecutive periods with an entry.
/// Mirrors the backend's HabitStatsService — keep the two in step.
abstract final class HabitStats {
  static HabitStatsDto compute(
    HabitDto habit,
    Iterable<String> entryDates, {
    DateTime? today,
    int days = 30,
  }) {
    final day = _day(today ?? DateTime.now());
    final dates = {
      for (final date in entryDates)
        if (!_day(DateTime.parse(date)).isAfter(day)) date,
    };
    final from = _ymd(day.subtract(Duration(days: days - 1)));
    final recent = dates.where((d) => d.compareTo(from) >= 0).toList()
      ..sort((a, b) => b.compareTo(a));

    return HabitStatsDto(
      currentStreak: currentStreak(habit.frequency, dates, day),
      longestStreak: longestStreak(habit.frequency, dates),
      completionRate: completionRate(habit, dates, day),
      isCompletedToday: dates.contains(_ymd(day)),
      totalEntries: dates.length,
      entriesByDate: {for (final d in recent) d: true},
    );
  }

  /// Consecutive periods with an entry, ending in the current period or the
  /// previous one (so a daily streak survives until tonight).
  static int currentStreak(
    String frequency,
    Set<String> dates,
    DateTime today,
  ) {
    final periods = _periods(frequency, dates);
    var expected = today;
    if (!periods.contains(_key(frequency, expected))) {
      expected = _previous(frequency, expected);
    }
    var streak = 0;
    while (periods.contains(_key(frequency, expected))) {
      streak++;
      expected = _previous(frequency, expected);
    }
    return streak;
  }

  static int longestStreak(String frequency, Set<String> dates) {
    final starts = {
      for (final date in dates) _start(frequency, DateTime.parse(date)),
    }.toList()..sort();
    var longest = 0;
    var run = 0;
    DateTime? previous;
    for (final start in starts) {
      run = previous != null && _next(frequency, previous) == start
          ? run + 1
          : 1;
      if (run > longest) longest = run;
      previous = start;
    }
    return longest;
  }

  /// Percentage of periods since the habit was created that have an entry.
  static double completionRate(
    HabitDto habit,
    Set<String> dates,
    DateTime today,
  ) {
    final start = _day(DateTime.parse(habit.createdAt).toLocal());
    if (start.isAfter(today)) return 0;

    final totalDays = today.difference(start).inDays + 1;
    final expected = switch (habit.frequency) {
      'weekly' => (totalDays / 7).ceil(),
      'monthly' =>
        (today.year - start.year) * 12 + today.month - start.month + 1,
      _ => totalDays,
    };
    final startKey = _ymd(start);
    final done = _periods(
      habit.frequency,
      dates.where((d) => d.compareTo(startKey) >= 0),
    ).length;
    if (expected <= 0) return 0;
    final rate = (done / expected).clamp(0, 1) * 100;
    return (rate * 100).roundToDouble() / 100;
  }

  static Set<String> _periods(String frequency, Iterable<String> dates) => {
    for (final date in dates) _key(frequency, DateTime.parse(date)),
  };

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTime _start(String frequency, DateTime date) {
    final d = _day(date);
    return switch (frequency) {
      'weekly' => d.subtract(Duration(days: d.weekday - DateTime.monday)),
      'monthly' => DateTime(d.year, d.month),
      _ => d,
    };
  }

  static String _key(String frequency, DateTime date) =>
      _ymd(_start(frequency, date));

  static DateTime _previous(String frequency, DateTime date) =>
      switch (frequency) {
        'weekly' => DateTime(date.year, date.month, date.day - 7),
        'monthly' => DateTime(date.year, date.month - 1),
        _ => DateTime(date.year, date.month, date.day - 1),
      };

  static DateTime _next(String frequency, DateTime start) =>
      switch (frequency) {
        'weekly' => DateTime(start.year, start.month, start.day + 7),
        'monthly' => DateTime(start.year, start.month + 1),
        _ => DateTime(start.year, start.month, start.day + 1),
      };

  static String _ymd(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// Today's date as the API writes it (local calendar day).
  static String todayKey([DateTime? now]) => _ymd(now ?? DateTime.now());
}
