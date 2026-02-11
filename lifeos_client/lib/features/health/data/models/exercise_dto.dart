import 'package:lifeos_client/features/health/data/models/workout_set_dto.dart';

class ExerciseDto {
  final int id;
  final String name;
  final String type; // 'strength', 'distance', 'time'
  final String? image;
  final String? muscleGroup;
  final bool isSystem;
  final List<WorkoutSetDto>? lastSessionSets;
  final DateTime createdAt;
  final DateTime updatedAt;

  ExerciseDto({
    required this.id,
    required this.name,
    required this.type,
    this.image,
    this.muscleGroup,
    required this.isSystem,
    this.lastSessionSets,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExerciseDto.fromJson(Map<String, dynamic> json) {
    return ExerciseDto(
      id: json['id'] as int,
      name: json['name'] as String,
      type: json['type'] as String,
      image: json['image'] as String?,
      muscleGroup: json['muscle_group'] as String?,
      isSystem: json['is_system'] as bool,
      lastSessionSets: json['last_session_sets'] != null
          ? (json['last_session_sets'] as List<dynamic>)
              .map((s) => WorkoutSetDto.fromJson(s as Map<String, dynamic>))
              .toList()
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'image': image,
      'muscle_group': muscleGroup,
      'is_system': isSystem,
      if (lastSessionSets != null)
        'last_session_sets': lastSessionSets!.map((s) => s.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
