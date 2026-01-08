class WorkoutSummaryDto {
  final int count;
  final int currentStreak;
  final List<WorkoutSessionPoint> sessions;

  WorkoutSummaryDto({
    required this.count,
    required this.currentStreak,
    required this.sessions,
  });

  factory WorkoutSummaryDto.fromJson(Map<String, dynamic> json) {
    return WorkoutSummaryDto(
      count: (json['count'] as num?)?.toInt() ?? 0,
      currentStreak: (json['current_streak'] as num?)?.toInt() ?? 0,
      sessions: (json['sessions'] as List<dynamic>?)
              ?.map((e) => WorkoutSessionPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'current_streak': currentStreak,
      'sessions': sessions.map((e) => e.toJson()).toList(),
    };
  }
}

class WorkoutSessionPoint {
  final String date;
  final bool hasSession;

  WorkoutSessionPoint({
    required this.date,
    required this.hasSession,
  });

  factory WorkoutSessionPoint.fromJson(Map<String, dynamic> json) {
    return WorkoutSessionPoint(
      date: json['date'] as String,
      hasSession: (json['has_session'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'has_session': hasSession,
    };
  }
}
