import 'package:equatable/equatable.dart';
import 'package:lifeos_client/features/health/data/models/exercise_dto.dart';

abstract class ExerciseState extends Equatable {
  const ExerciseState();

  @override
  List<Object?> get props => [];
}

class ExerciseInitial extends ExerciseState {}

class ExerciseLoading extends ExerciseState {}

class ExerciseLoaded extends ExerciseState {
  final List<ExerciseDto> exercises;
  final List<ExerciseDto> filteredExercises;
  final String searchQuery;

  const ExerciseLoaded({
    required this.exercises,
    required this.filteredExercises,
    this.searchQuery = '',
  });

  ExerciseLoaded copyWith({
    List<ExerciseDto>? exercises,
    List<ExerciseDto>? filteredExercises,
    String? searchQuery,
  }) {
    return ExerciseLoaded(
      exercises: exercises ?? this.exercises,
      filteredExercises: filteredExercises ?? this.filteredExercises,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [exercises, filteredExercises, searchQuery];
}

class ExerciseCreating extends ExerciseState {}

class ExerciseCreated extends ExerciseState {
  final ExerciseDto exercise;

  const ExerciseCreated(this.exercise);

  @override
  List<Object?> get props => [exercise];
}

class ExerciseDeleting extends ExerciseState {}

class ExerciseDeleted extends ExerciseState {
  final int exerciseId;

  const ExerciseDeleted(this.exerciseId);

  @override
  List<Object?> get props => [exerciseId];
}

class ExerciseError extends ExerciseState {
  final String message;

  const ExerciseError(this.message);

  @override
  List<Object?> get props => [message];
}
