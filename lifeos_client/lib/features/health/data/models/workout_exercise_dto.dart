import 'package:lifeos_client/features/health/data/models/exercise_dto.dart';
import 'package:lifeos_client/features/health/data/models/workout_set_dto.dart';

class WorkoutExerciseDto {
  final int? id; // null for local exercises not yet saved
  final int exerciseId;
  final ExerciseDto? exercise; // Loaded from API
  final int orderIndex;
  final String? note;
  final List<WorkoutSetDto> sets;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  WorkoutExerciseDto({
    this.id,
    required this.exerciseId,
    this.exercise,
    required this.orderIndex,
    this.note,
    this.sets = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory WorkoutExerciseDto.fromJson(Map<String, dynamic> json) {
    return WorkoutExerciseDto(
      id: json['id'] as int?,
      exerciseId: (json['exercise_id'] as num?)?.toInt() ?? 0,
      exercise: json['exercise'] != null 
          ? ExerciseDto.fromJson(json['exercise'] as Map<String, dynamic>)
          : null,
      orderIndex: (json['order_index'] as num?)?.toInt() ?? 0,
      note: json['note'] as String?,
      sets: (json['sets'] as List<dynamic>?)
              ?.map((s) => WorkoutSetDto.fromJson(s as Map<String, dynamic>))
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
      'exercise_id': exerciseId,
      if (exercise != null) 'exercise': exercise!.toJson(),
      'order_index': orderIndex,
      'note': note,
      'sets': sets.map((s) => s.toJson()).toList(),
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  WorkoutExerciseDto copyWith({
    int? id,
    int? exerciseId,
    ExerciseDto? exercise,
    int? orderIndex,
    String? note,
    List<WorkoutSetDto>? sets,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkoutExerciseDto(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      exercise: exercise ?? this.exercise,
      orderIndex: orderIndex ?? this.orderIndex,
      note: note ?? this.note,
      sets: sets ?? this.sets,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
