import 'package:equatable/equatable.dart';
import 'package:lifeos_client/features/health/data/models/exercise_dto.dart';
import 'package:lifeos_client/features/health/data/models/workout_completion_dto.dart';

abstract class WorkoutEvent extends Equatable {
  const WorkoutEvent();

  @override
  List<Object?> get props => [];
}

class LoadActiveWorkout extends WorkoutEvent {}

class StartWorkout extends WorkoutEvent {}

class AddExercise extends WorkoutEvent {
  final ExerciseDto exercise;

  const AddExercise(this.exercise);

  @override
  List<Object?> get props => [exercise];
}

class RemoveExercise extends WorkoutEvent {
  final int exerciseIndex;

  const RemoveExercise(this.exerciseIndex);

  @override
  List<Object?> get props => [exerciseIndex];
}

class AddSet extends WorkoutEvent {
  final int exerciseIndex;

  const AddSet(this.exerciseIndex);

  @override
  List<Object?> get props => [exerciseIndex];
}

class UpdateSet extends WorkoutEvent {
  final int exerciseIndex;
  final int setIndex;
  final double? weightKg;
  final int? reps;
  final int? durationSeconds;
  final double? distanceMeters;
  final int? rpe;

  const UpdateSet({
    required this.exerciseIndex,
    required this.setIndex,
    this.weightKg,
    this.reps,
    this.durationSeconds,
    this.distanceMeters,
    this.rpe,
  });

  @override
  List<Object?> get props => [
        exerciseIndex,
        setIndex,
        weightKg,
        reps,
        durationSeconds,
        distanceMeters,
        rpe,
      ];
}

class RemoveSet extends WorkoutEvent {
  final int exerciseIndex;
  final int setIndex;

  const RemoveSet({
    required this.exerciseIndex,
    required this.setIndex,
  });

  @override
  List<Object?> get props => [exerciseIndex, setIndex];
}

class FinishWorkout extends WorkoutEvent {}

class SaveWorkoutCompletion extends WorkoutEvent {
  final WorkoutCompletionDto completion;

  const SaveWorkoutCompletion(this.completion);

  @override
  List<Object?> get props => [completion];
}

class CancelWorkout extends WorkoutEvent {}

// Internal event for timer updates
class UpdateElapsedTime extends WorkoutEvent {
  final Duration elapsed;

  const UpdateElapsedTime(this.elapsed);

  @override
  List<Object?> get props => [elapsed];
}

