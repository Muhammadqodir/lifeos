import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lifeos_client/features/health/data/models/workout_exercise_dto.dart';
import 'package:lifeos_client/features/health/data/models/workout_session_dto.dart';
import 'package:lifeos_client/features/health/data/models/workout_set_dto.dart';
import 'package:lifeos_client/features/health/domain/repositories/workout_repository.dart';
import 'workout_event.dart';
import 'workout_state.dart';

class WorkoutBloc extends Bloc<WorkoutEvent, WorkoutState> {
  final WorkoutRepository repository;
  Timer? _timer;
  DateTime? _workoutStartTime;

  WorkoutBloc({required this.repository}) : super(WorkoutInitial()) {
    on<LoadActiveWorkout>(_onLoadActiveWorkout);
    on<StartWorkout>(_onStartWorkout);
    on<AddExercise>(_onAddExercise);
    on<RemoveExercise>(_onRemoveExercise);
    on<AddSet>(_onAddSet);
    on<UpdateSet>(_onUpdateSet);
    on<RemoveSet>(_onRemoveSet);
    on<FinishWorkout>(_onFinishWorkout);
    on<SaveWorkoutCompletion>(_onSaveWorkoutCompletion);
    on<CancelWorkout>(_onCancelWorkout);
    on<UpdateElapsedTime>(_onUpdateElapsedTime);
  }

  Future<void> _onLoadActiveWorkout(
    LoadActiveWorkout event,
    Emitter<WorkoutState> emit,
  ) async {
    final activeWorkout = repository.getActiveWorkout();

    if (activeWorkout != null) {
      _workoutStartTime = activeWorkout.startedAt;
      _startTimer();

      emit(
        WorkoutInProgress(
          workout: activeWorkout,
          elapsedTime: DateTime.now().difference(_workoutStartTime!),
        ),
      );
    } else {
      // Auto-start a new workout if none exists
      _workoutStartTime = DateTime.now();

      final workout = WorkoutSessionDto(
        startedAt: _workoutStartTime!,
        exercises: [],
      );

      await repository.saveActiveWorkoutLocally(workout);
      _startTimer();

      emit(WorkoutInProgress(workout: workout, elapsedTime: Duration.zero));
    }
  }

  Future<void> _onStartWorkout(
    StartWorkout event,
    Emitter<WorkoutState> emit,
  ) async {
    _workoutStartTime = DateTime.now();

    final workout = WorkoutSessionDto(
      startedAt: _workoutStartTime!,
      exercises: [],
    );

    await repository.saveActiveWorkoutLocally(workout);
    _startTimer();

    emit(WorkoutInProgress(workout: workout, elapsedTime: Duration.zero));
  }

  Future<void> _onAddExercise(
    AddExercise event,
    Emitter<WorkoutState> emit,
  ) async {
    if (state is! WorkoutInProgress) return;

    final currentState = state as WorkoutInProgress;
    final exercises = List<WorkoutExerciseDto>.from(
      currentState.workout.exercises,
    );

    exercises.add(
      WorkoutExerciseDto(
        exerciseId: event.exercise.id,
        exercise: event.exercise,
        orderIndex: exercises.length,
        sets: [],
      ),
    );

    final updatedWorkout = currentState.workout.copyWith(exercises: exercises);
    await repository.saveActiveWorkoutLocally(updatedWorkout);

    emit(currentState.copyWith(workout: updatedWorkout));
  }

  Future<void> _onRemoveExercise(
    RemoveExercise event,
    Emitter<WorkoutState> emit,
  ) async {
    if (state is! WorkoutInProgress) return;

    final currentState = state as WorkoutInProgress;
    final exercises = List<WorkoutExerciseDto>.from(
      currentState.workout.exercises,
    );

    if (event.exerciseIndex >= exercises.length) return;

    exercises.removeAt(event.exerciseIndex);

    // Re-index remaining exercises
    for (int i = 0; i < exercises.length; i++) {
      exercises[i] = exercises[i].copyWith(orderIndex: i);
    }

    final updatedWorkout = currentState.workout.copyWith(exercises: exercises);
    await repository.saveActiveWorkoutLocally(updatedWorkout);

    emit(currentState.copyWith(workout: updatedWorkout));
  }

  Future<void> _onAddSet(AddSet event, Emitter<WorkoutState> emit) async {
    if (state is! WorkoutInProgress) return;

    final currentState = state as WorkoutInProgress;
    final exercises = List<WorkoutExerciseDto>.from(
      currentState.workout.exercises,
    );

    if (event.exerciseIndex >= exercises.length) return;

    final exercise = exercises[event.exerciseIndex];
    final sets = List<WorkoutSetDto>.from(exercise.sets);

    // Get the last set's values for easy continuation
    final lastSet = sets.isNotEmpty ? sets.last : null;

    sets.add(
      WorkoutSetDto(
        setIndex: sets.length,
        weightKg: lastSet?.weightKg,
        reps: lastSet?.reps,
        durationSeconds: lastSet?.durationSeconds,
        distanceMeters: lastSet?.distanceMeters,
        rpe: null,
        isDone: true,
      ),
    );

    exercises[event.exerciseIndex] = exercise.copyWith(sets: sets);

    final updatedWorkout = currentState.workout.copyWith(exercises: exercises);
    await repository.saveActiveWorkoutLocally(updatedWorkout);

    emit(currentState.copyWith(workout: updatedWorkout));
  }

  Future<void> _onUpdateSet(UpdateSet event, Emitter<WorkoutState> emit) async {
    if (state is! WorkoutInProgress) return;

    final currentState = state as WorkoutInProgress;
    final exercises = List<WorkoutExerciseDto>.from(
      currentState.workout.exercises,
    );

    if (event.exerciseIndex >= exercises.length) return;

    final exercise = exercises[event.exerciseIndex];
    final sets = List<WorkoutSetDto>.from(exercise.sets);

    if (event.setIndex >= sets.length) return;

    sets[event.setIndex] = sets[event.setIndex].copyWith(
      weightKg: event.weightKg,
      reps: event.reps,
      durationSeconds: event.durationSeconds,
      distanceMeters: event.distanceMeters,
      rpe: event.rpe,
    );

    exercises[event.exerciseIndex] = exercise.copyWith(sets: sets);

    final updatedWorkout = currentState.workout.copyWith(exercises: exercises);
    await repository.saveActiveWorkoutLocally(updatedWorkout);

    emit(currentState.copyWith(workout: updatedWorkout));
  }

  Future<void> _onRemoveSet(RemoveSet event, Emitter<WorkoutState> emit) async {
    if (state is! WorkoutInProgress) return;

    final currentState = state as WorkoutInProgress;
    final exercises = List<WorkoutExerciseDto>.from(
      currentState.workout.exercises,
    );

    if (event.exerciseIndex >= exercises.length) return;

    final exercise = exercises[event.exerciseIndex];
    final sets = List<WorkoutSetDto>.from(exercise.sets);

    if (event.setIndex >= sets.length) return;

    sets.removeAt(event.setIndex);

    // Re-index remaining sets
    for (int i = 0; i < sets.length; i++) {
      sets[i] = sets[i].copyWith(setIndex: i);
    }

    exercises[event.exerciseIndex] = exercise.copyWith(sets: sets);

    final updatedWorkout = currentState.workout.copyWith(exercises: exercises);
    await repository.saveActiveWorkoutLocally(updatedWorkout);

    emit(currentState.copyWith(workout: updatedWorkout));
  }

  Future<void> _onFinishWorkout(
    FinishWorkout event,
    Emitter<WorkoutState> emit,
  ) async {
    // This event now just triggers validation and prepares for completion flow
    // The actual saving happens in SaveWorkoutCompletion
    if (state is! WorkoutInProgress) return;

    final currentState = state as WorkoutInProgress;

    // Validate workout before allowing camera/completion
    final validationError = _validateWorkout(currentState.workout);
    if (validationError != null) {
      emit(WorkoutError(validationError));
      emit(currentState);
      return;
    }

    // State stays in WorkoutInProgress to maintain data during camera flow
    // The UI will navigate to camera page
  }

  Future<void> _onSaveWorkoutCompletion(
    SaveWorkoutCompletion event,
    Emitter<WorkoutState> emit,
  ) async {
    if (state is! WorkoutInProgress) return;

    final currentState = state as WorkoutInProgress;

    emit(WorkoutLoading());

    try {
      final completedWorkout = currentState.workout.copyWith(
        endedAt: DateTime.now(),
      );

      final savedWorkout = await repository.submitWorkoutWithCompletion(
        completedWorkout,
        event.completion,
      );

      _stopTimer();
      _workoutStartTime = null;

      emit(WorkoutSaved(savedWorkout));
    } catch (e, stackTrace) {
      emit(WorkoutError('$e\n$stackTrace'));
      emit(currentState);
    }
  }

  String? _validateWorkout(WorkoutSessionDto workout) {
    if (workout.exercises.isEmpty) {
      return 'Add at least one exercise to your workout';
    }

    for (int i = 0; i < workout.exercises.length; i++) {
      final exercise = workout.exercises[i];
      final exerciseName = exercise.exercise?.name ?? 'Exercise ${i + 1}';
      final exerciseType = exercise.exercise?.type ?? 'strength';

      if (exercise.sets.isEmpty) {
        return '$exerciseName: Add at least one set';
      }

      for (int j = 0; j < exercise.sets.length; j++) {
        final set = exercise.sets[j];
        final setNumber = j + 1;

        // RPE is always required
        if (set.rpe == null) {
          return '$exerciseName - Set $setNumber: RPE must be selected';
        }

        // Validate based on exercise type
        if (exerciseType == 'strength') {
          if (set.weightKg == null || set.weightKg! <= 0) {
            return '$exerciseName - Set $setNumber: Weight must be filled';
          }
          if (set.reps == null || set.reps! <= 0) {
            return '$exerciseName - Set $setNumber: Reps must be filled';
          }
        } else if (exerciseType == 'distance' || exerciseType == 'time') {
          if (set.durationSeconds == null || set.durationSeconds! <= 0) {
            return '$exerciseName - Set $setNumber: Duration must be filled';
          }
          if (set.distanceMeters == null || set.distanceMeters! <= 0) {
            return '$exerciseName - Set $setNumber: Distance must be filled';
          }
        }
      }
    }

    return null;
  }

  Future<void> _onCancelWorkout(
    CancelWorkout event,
    Emitter<WorkoutState> emit,
  ) async {
    await repository.clearActiveWorkout();
    _stopTimer();
    _workoutStartTime = null;
    emit(WorkoutIdle());
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state is WorkoutInProgress && _workoutStartTime != null) {
        final elapsed = DateTime.now().difference(_workoutStartTime!);
        // Use add to trigger state change instead of emit
        add(UpdateElapsedTime(elapsed));
      }
    });
  }

  Future<void> _onUpdateElapsedTime(
    UpdateElapsedTime event,
    Emitter<WorkoutState> emit,
  ) async {
    if (state is WorkoutInProgress) {
      final currentState = state as WorkoutInProgress;
      emit(currentState.copyWith(elapsedTime: event.elapsed));
    }
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  Future<void> close() {
    _stopTimer();
    return super.close();
  }
}
