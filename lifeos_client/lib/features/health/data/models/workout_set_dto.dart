class WorkoutSetDto {
  final int? id; // null for local sets not yet saved
  final int? workoutExerciseId;
  final int setIndex;
  final double? weightKg;
  final int? reps;
  final int? durationSeconds;
  final double? distanceMeters;
  final int? rpe;
  final bool isDone;
  final double? estimated1rm;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  WorkoutSetDto({
    this.id,
    this.workoutExerciseId,
    required this.setIndex,
    this.weightKg,
    this.reps,
    this.durationSeconds,
    this.distanceMeters,
    this.rpe,
    this.isDone = true,
    this.estimated1rm,
    this.createdAt,
    this.updatedAt,
  });

  factory WorkoutSetDto.fromJson(Map<String, dynamic> json) {
    return WorkoutSetDto(
      id: json['id'] as int?,
      workoutExerciseId: json['workout_exercise_id'] as int?,
      setIndex: (json['set_index'] as num?)?.toInt() ?? 0,
      weightKg: json['weight_kg'] != null ? (json['weight_kg'] as num).toDouble() : null,
      reps: (json['reps'] as num?)?.toInt(),
      durationSeconds: (json['duration_seconds'] as num?)?.toInt(),
      distanceMeters: json['distance_meters'] != null 
          ? (json['distance_meters'] as num).toDouble() 
          : null,
      rpe: (json['rpe'] as num?)?.toInt(),
      isDone: json['is_done'] as bool? ?? true,
      estimated1rm: json['estimated_1rm'] != null 
          ? (json['estimated_1rm'] as num).toDouble() 
          : null,
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
      if (workoutExerciseId != null) 'workout_exercise_id': workoutExerciseId,
      'set_index': setIndex,
      'weight_kg': weightKg,
      'reps': reps,
      'duration_seconds': durationSeconds,
      'distance_meters': distanceMeters,
      'rpe': rpe,
      'is_done': isDone,
      if (estimated1rm != null) 'estimated_1rm': estimated1rm,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  WorkoutSetDto copyWith({
    int? id,
    int? workoutExerciseId,
    int? setIndex,
    double? weightKg,
    int? reps,
    int? durationSeconds,
    double? distanceMeters,
    int? rpe,
    bool? isDone,
    double? estimated1rm,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WorkoutSetDto(
      id: id ?? this.id,
      workoutExerciseId: workoutExerciseId ?? this.workoutExerciseId,
      setIndex: setIndex ?? this.setIndex,
      weightKg: weightKg ?? this.weightKg,
      reps: reps ?? this.reps,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      rpe: rpe ?? this.rpe,
      isDone: isDone ?? this.isDone,
      estimated1rm: estimated1rm ?? this.estimated1rm,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
