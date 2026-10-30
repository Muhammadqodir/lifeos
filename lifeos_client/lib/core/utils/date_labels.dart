import 'package:intl/intl.dart';

/// Shared human-readable date labels so every list shows dates the same way.
abstract final class DateLabels {
  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  /// "Today", "Yesterday", "Tomorrow", a weekday within the current week,
  /// otherwise "12 Mar" (current year) or "12 Mar 2025".
  static String relativeDay(DateTime date, {DateTime? now}) {
    final today = _day(now ?? DateTime.now());
    final day = _day(date);
    final diff = day.difference(today).inDays;
    if (diff == 0) return 'Today';
    if (diff == -1) return 'Yesterday';
    if (diff == 1) return 'Tomorrow';
    if (diff < 0 && diff > -7) return DateFormat('EEEE').format(date);
    if (day.year == today.year) return DateFormat('d MMM').format(date);
    return DateFormat('d MMM y').format(date);
  }

  /// 24-hour time, e.g. "14:05".
  static String time(DateTime date) => DateFormat('HH:mm').format(date);

  /// "Today, 14:05" / "12 Mar, 09:30".
  static String relativeDayTime(DateTime date, {DateTime? now}) =>
      '${relativeDay(date, now: now)}, ${time(date)}';

  /// Formats a backend `HH:mm[:ss]` time string as "14:05".
  static String? apiTime(String? value) {
    if (value == null || value.isEmpty) return null;
    final parts = value.split(':');
    if (parts.length < 2) return value;
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }

  /// True when [date] is before today (date only).
  static bool isPastDay(DateTime date, {DateTime? now}) =>
      _day(date).isBefore(_day(now ?? DateTime.now()));
}
