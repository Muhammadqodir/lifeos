import 'dart:io';
import '../../domain/repositories/workout_repository.dart';
import '../datasources/health_api_client.dart';
import '../datasources/workout_local_storage.dart';
import '../models/exercise_dto.dart';
import '../models/workout_completion_dto.dart';
import '../models/workout_session_dto.dart';

class WorkoutRepositoryImpl implements WorkoutRepository {
  final HealthApiClient apiClient;
  final WorkoutLocalStorage localStorage;

  WorkoutRepositoryImpl({
    required this.apiClient,
    required this.localStorage,
  });

  @override
  Future<List<ExerciseDto>> getExercises() async {
    return await apiClient.getExercises();
  }

  @override
  Future<ExerciseDto> createExercise({
    required String name,
    required String type,
    String? muscleGroup,
    String? imagePath,
  }) async {
    return await apiClient.createExercise(
      {
        'name': name,
        'type': type,
        if (muscleGroup != null) 'muscle_group': muscleGroup,
      },
      imagePath,
    );
  }

  @override
  Future<void> deleteExercise(int exerciseId) async {
    await apiClient.deleteExercise(exerciseId);
  }

  @override
  Future<List<WorkoutSessionDto>> getWorkoutSessions({
    DateTime? dateFrom,
    DateTime? dateTo,
    int page = 1,
  }) async {
    return await apiClient.getWorkoutSessions(
      dateFrom: dateFrom,
      dateTo: dateTo,
      page: page,
    );
  }

  @override
  Future<void> saveActiveWorkoutLocally(WorkoutSessionDto workout) async {
    await localStorage.saveActiveWorkout(workout);
  }

  @override
  WorkoutSessionDto? getActiveWorkout() {
    return localStorage.getActiveWorkout();
  }

  @override
  bool hasActiveWorkout() {
    return localStorage.hasActiveWorkout();
  }

  @override
  Future<WorkoutSessionDto> submitWorkout(WorkoutSessionDto workout) async {
    final workoutData = {
      'started_at': workout.startedAt.toIso8601String(),
      'ended_at': workout.endedAt!.toIso8601String(),
      'note': workout.note,
      'exercises': workout.exercises.map((exercise) {
        return {
          'exercise_id': exercise.exerciseId,
          'order_index': exercise.orderIndex,
          'note': exercise.note,
          'sets': exercise.sets.map((set) {
            return {
              'set_index': set.setIndex,
              'weight_kg': set.weightKg,
              'reps': set.reps,
              'duration_seconds': set.durationSeconds,
              'distance_meters': set.distanceMeters,
              'rpe': set.rpe,
              'is_done': set.isDone,
            };
          }).toList(),
        };
      }).toList(),
    };

    final saved = await apiClient.saveCompleteWorkout(workoutData);
    
    // Clear local storage after successful submission
    await localStorage.clearActiveWorkout();
    
    return saved;
  }

  @override
  Future<WorkoutSessionDto> submitWorkoutWithCompletion(
    WorkoutSessionDto workout,
    WorkoutCompletionDto completion,
  ) async {
    final workoutData = {
      'started_at': workout.startedAt.toIso8601String(),
      'ended_at': workout.endedAt!.toIso8601String(),
      'note': workout.note,
      'exercises': workout.exercises.map((exercise) {
        return {
          'exercise_id': exercise.exerciseId,
          'order_index': exercise.orderIndex,
          'note': exercise.note,
          'sets': exercise.sets.map((set) {
            return {
              'set_index': set.setIndex,
              'weight_kg': set.weightKg,
              'reps': set.reps,
              'duration_seconds': set.durationSeconds,
              'distance_meters': set.distanceMeters,
              'rpe': set.rpe,
              'is_done': set.isDone,
            };
          }).toList(),
        };
      }).toList(),
      'completion': {
        'body_weight_kg': completion.bodyWeightKg,
        'height_cm': completion.heightCm,
        'biceps_cm': completion.bicepsCm,
        'chest_cm': completion.chestCm,
        'waist_cm': completion.waistCm,
        'thighs_cm': completion.thighsCm,
        'calfs_cm': completion.calfsCm,
        'notes': completion.notes,
      },
    };

    File? photoFile;
    if (completion.photoPath != null) {
      photoFile = File(completion.photoPath!);
    }

    final saved = await apiClient.saveCompleteWorkoutWithPhoto(
      workoutData,
      photoFile,
    );
    
    // Clear local storage after successful submission
    await localStorage.clearActiveWorkout();
    
    return saved;
  }

  @override
  Future<void> clearActiveWorkout() async {
    await localStorage.clearActiveWorkout();
  }
}
