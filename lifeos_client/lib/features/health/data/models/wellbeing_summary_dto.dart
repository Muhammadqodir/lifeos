import 'package:equatable/equatable.dart';

class WellbeingSummaryDto extends Equatable {
  final int count;
  final double avgEnergy;
  final double avgStress;
  final List<WellbeingSummaryPoint> points;

  const WellbeingSummaryDto({
    required this.count,
    required this.avgEnergy,
    required this.avgStress,
    required this.points,
  });

  factory WellbeingSummaryDto.fromJson(Map<String, dynamic> json) {
    final pointsList = (json['points'] as List?) ?? [];
    return WellbeingSummaryDto(
      count: json['count'] as int,
      avgEnergy: (json['avg_energy'] as num?)?.toDouble() ?? 0.0,
      avgStress: (json['avg_stress'] as num?)?.toDouble() ?? 0.0,
      points: pointsList
          .map((p) => WellbeingSummaryPoint.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  List<Object?> get props => [count, avgEnergy, avgStress, points];
}

class WellbeingSummaryPoint extends Equatable {
  final String date;
  final int? energy;
  final int? stress;

  const WellbeingSummaryPoint({
    required this.date,
    this.energy,
    this.stress,
  });

  factory WellbeingSummaryPoint.fromJson(Map<String, dynamic> json) {
    return WellbeingSummaryPoint(
      date: json['date'] as String,
      energy: json['energy'] as int?,
      stress: json['stress'] as int?,
    );
  }

  @override
  List<Object?> get props => [date, energy, stress];
}
