import 'package:equatable/equatable.dart';

class SleepSummaryDto extends Equatable {
  final int count;
  final double avgDurationHours;
  final double avgQuality;
  final List<SleepSummaryPoint> points;

  const SleepSummaryDto({
    required this.count,
    required this.avgDurationHours,
    required this.avgQuality,
    required this.points,
  });

  factory SleepSummaryDto.fromJson(Map<String, dynamic> json) {
    final pointsList = (json['points'] as List?) ?? [];
    return SleepSummaryDto(
      count: json['count'] as int,
      avgDurationHours: (json['avg_duration_hours'] as num?)?.toDouble() ?? 0.0,
      avgQuality: (json['avg_quality'] as num?)?.toDouble() ?? 0.0,
      points: pointsList
          .map((p) => SleepSummaryPoint.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [count, avgDurationHours, avgQuality, points];
}

class SleepSummaryPoint extends Equatable {
  final String date;
  final double durationHours;
  final int? quality;

  const SleepSummaryPoint({
    required this.date,
    required this.durationHours,
    this.quality,
  });

  factory SleepSummaryPoint.fromJson(Map<String, dynamic> json) {
    return SleepSummaryPoint(
      date: json['date'] as String,
      durationHours: (json['duration_hours'] as num?)?.toDouble() ?? 0.0,
      quality: json['quality'] as int?,
    );
  }

  @override
  List<Object?> get props => [date, durationHours, quality];
}
