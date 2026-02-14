import 'package:equatable/equatable.dart';

class HabitStatsDto extends Equatable {
  final int currentStreak;
  final int longestStreak;
  final double completionRate;
  final bool isCompletedToday;
  final int totalEntries;
  final Map<String, bool> entriesByDate;

  const HabitStatsDto({
    required this.currentStreak,
    required this.longestStreak,
    required this.completionRate,
    required this.isCompletedToday,
    required this.totalEntries,
    this.entriesByDate = const {},
  });

  factory HabitStatsDto.fromJson(Map<String, dynamic> json) {
    return HabitStatsDto(
      currentStreak: json['current_streak'] as int,
      longestStreak: json['longest_streak'] as int,
      completionRate: (json['completion_rate'] as num).toDouble(),
      isCompletedToday: json['is_completed_today'] as bool,
      totalEntries: json['total_entries'] as int,
      entriesByDate: json['entries_by_date'] != null
          ? Map<String, bool>.from(json['entries_by_date'] as Map)
          : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'completion_rate': completionRate,
      'is_completed_today': isCompletedToday,
      'total_entries': totalEntries,
      'entries_by_date': entriesByDate,
    };
  }

  @override
  List<Object?> get props => [
        currentStreak,
        longestStreak,
        completionRate,
        isCompletedToday,
        totalEntries,
        entriesByDate,
      ];
}
