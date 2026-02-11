import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lifeos_client/features/health/domain/repositories/workout_repository.dart';
import 'exercise_event.dart';
import 'exercise_state.dart';

class ExerciseBloc extends Bloc<ExerciseEvent, ExerciseState> {
  final WorkoutRepository repository;

  ExerciseBloc({required this.repository}) : super(ExerciseInitial()) {
    on<LoadExercises>(_onLoadExercises);
    on<FilterExercises>(_onFilterExercises);
    on<SearchExercises>(_onSearchExercises);
    on<CreateExercise>(_onCreateExercise);
    on<DeleteExercise>(_onDeleteExercise);
  }

  Future<void> _onLoadExercises(
    LoadExercises event,
    Emitter<ExerciseState> emit,
  ) async {
    emit(ExerciseLoading());

    try {
      // Load exercises with last session data for workout hints
      final exercises = await repository.getExercises(includeLastSession: true);
      
      // Filter to only show user's custom exercises (not system)
      final userExercises = exercises.where((e) => !e.isSystem).toList();

      emit(ExerciseLoaded(
        exercises: userExercises,
        filteredExercises: userExercises,
      ));
    } catch (e) {
      // Extract clean error message
      String errorMessage = e.toString();
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring('Exception: '.length);
      }
      emit(ExerciseError(errorMessage));
    }
  }

  Future<void> _onFilterExercises(
    FilterExercises event,
    Emitter<ExerciseState> emit,
  ) async {
    if (state is! ExerciseLoaded) return;

    final currentState = state as ExerciseLoaded;
    var filtered = currentState.exercises;

    if (event.type != null) {
      filtered = filtered.where((e) => e.type == event.type).toList();
    }

    if (event.muscleGroup != null) {
      filtered = filtered
          .where((e) => e.muscleGroup == event.muscleGroup)
          .toList();
    }

    emit(ExerciseLoaded(
      exercises: currentState.exercises,
      filteredExercises: filtered,
      searchQuery: currentState.searchQuery,
    ));
  }

  Future<void> _onSearchExercises(
    SearchExercises event,
    Emitter<ExerciseState> emit,
  ) async {
    if (state is! ExerciseLoaded) return;

    final currentState = state as ExerciseLoaded;
    final query = event.query.toLowerCase();

    if (query.isEmpty) {
      emit(currentState.copyWith(
        filteredExercises: currentState.exercises,
        searchQuery: '',
      ));
      return;
    }

    final filtered = currentState.exercises.where((exercise) {
      return exercise.name.toLowerCase().contains(query) ||
          (exercise.muscleGroup?.toLowerCase().contains(query) ?? false);
    }).toList();

    emit(currentState.copyWith(
      filteredExercises: filtered,
      searchQuery: event.query,
    ));
  }

  Future<void> _onCreateExercise(
    CreateExercise event,
    Emitter<ExerciseState> emit,
  ) async {
    final previousState = state;
    emit(ExerciseCreating());

    try {
      final newExercise = await repository.createExercise(
        name: event.name,
        type: event.type,
        muscleGroup: event.muscleGroup,
        imagePath: event.imagePath,
      );

      emit(ExerciseCreated(newExercise));

      // Reload exercises
      add(LoadExercises());
    } catch (e) {
      emit(ExerciseError(e.toString()));
      
      // Restore previous state after error
      if (previousState is ExerciseLoaded) {
        emit(previousState);
      }
    }
  }

  Future<void> _onDeleteExercise(
    DeleteExercise event,
    Emitter<ExerciseState> emit,
  ) async {
    final previousState = state;
    emit(ExerciseDeleting());

    try {
      await repository.deleteExercise(event.exerciseId);

      emit(ExerciseDeleted(event.exerciseId));

      // Reload exercises
      add(LoadExercises());
    } catch (e) {
      emit(ExerciseError(e.toString()));
      
      // Restore previous state after error
      if (previousState is ExerciseLoaded) {
        emit(previousState);
      }
    }
  }
}
