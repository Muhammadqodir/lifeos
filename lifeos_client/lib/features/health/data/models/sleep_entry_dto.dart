import 'package:equatable/equatable.dart';

class SleepEntryDto extends Equatable {
  final int id;
  final String date;
  final String sleepStart;
  final String sleepEnd;
  final double durationHours;
  final int? quality;
  final String? note;

  const SleepEntryDto({
    required this.id,
    required this.date,
    required this.sleepStart,
    required this.sleepEnd,
    required this.durationHours,
    this.quality,
    this.note,
  });

  factory SleepEntryDto.fromJson(Map<String, dynamic> json) {
    return SleepEntryDto(
      id: json['id'] as int,
      date: json['date'] as String,
      sleepStart: json['sleep_start'] as String,
      sleepEnd: json['sleep_end'] as String,
      durationHours: (json['duration_hours'] as num).toDouble(),
      quality: json['quality'] as int?,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'sleep_start': sleepStart,
      'sleep_end': sleepEnd,
      'duration_hours': durationHours,
      'quality': quality,
      'note': note,
    };
  }

  @override
  List<Object?> get props => [
        id,
        date,
        sleepStart,
        sleepEnd,
        durationHours,
        quality,
        note,
      ];
}
