import 'package:lifeos_client/features/health/data/models/workout_exercise_dto.dart';

class WorkoutSessionDto {
  final int? id;
  final int? userId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String? note;
  final List<WorkoutExerciseDto> exercises;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  WorkoutSessionDto({
    this.id,
    this.userId,
    required this.startedAt,
    this.endedAt,
    this.note,
    this.exercises = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory WorkoutSessionDto.fromJson(Map<String, dynamic> json) {
    return WorkoutSessionDto(
      id: json['id'] as int?,
      userId: json['user_id'] as int?,
      startedAt: DateTime.parse(json['started_at'] as String),
      endedAt: json['ended_at'] != null 
          ? DateTime.parse(json['ended_at'] as String) 
          : null,
      note: json['note'] as String?,
      exercises: (json['exercises'] as List<dynamic>?)
              ?.map((e) => WorkoutExerciseDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at'] as String) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      'started_at': startedAt.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'note': note,
      'exercises': exercises.map((e) => e.toJson()).toList(),
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  WorkoutSessionDto copyWith({
    int? id,
    int? userId,
    DateTime? startedAt,
    DateTime? endedAt,
    String? note,
    List<WorkoutExerciseDto>? exercises,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkoutSessionDto(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      note: note ?? this.note,
      exercises: exercises ?? this.exercises,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Duration get duration {
    if (endedAt != null) {
      return endedAt!.difference(startedAt);
    }
    return Duration.zero;
  }
}
