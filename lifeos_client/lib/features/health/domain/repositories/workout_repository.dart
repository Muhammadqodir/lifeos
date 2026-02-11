import '../../data/models/exercise_dto.dart';
import '../../data/models/workout_completion_dto.dart';
import '../../data/models/workout_session_dto.dart';

abstract class WorkoutRepository {
  /// Get all exercises (system + user's custom)
  Future<List<ExerciseDto>> getExercises({bool includeLastSession = false});

  /// Create a new custom exercise
  Future<ExerciseDto> createExercise({
    required String name,
    required String type,
    String? muscleGroup,
    String? imagePath,
  });

  /// Delete a custom exercise
  Future<void> deleteExercise(int exerciseId);

  /// Get paginated list of workout sessions
  Future<List<WorkoutSessionDto>> getWorkoutSessions({
    DateTime? dateFrom,
    DateTime? dateTo,
    int page = 1,
  });

  /// Delete a workout session
  Future<void> deleteWorkoutSession(int workoutId);

  /// Save active workout locally (offline)
  Future<void> saveActiveWorkoutLocally(WorkoutSessionDto workout);

  /// Get active workout from local storage
  WorkoutSessionDto? getActiveWorkout();

  /// Check if there's an active workout
  bool hasActiveWorkout();

  /// Submit completed workout to server
  Future<WorkoutSessionDto> submitWorkout(WorkoutSessionDto workout);

  /// Submit completed workout with completion data (photo, measurements)
  Future<WorkoutSessionDto> submitWorkoutWithCompletion(
    WorkoutSessionDto workout,
    WorkoutCompletionDto completion,
  );

  /// Clear active workout (cancel)
  Future<void> clearActiveWorkout();
}
