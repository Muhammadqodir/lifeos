import 'package:equatable/equatable.dart';
import 'package:lifeos_client/features/health/data/models/workout_session_dto.dart';

abstract class WorkoutState extends Equatable {
  const WorkoutState();

  @override
  List<Object?> get props => [];
}

class WorkoutInitial extends WorkoutState {}

class WorkoutIdle extends WorkoutState {}

class WorkoutInProgress extends WorkoutState {
  final WorkoutSessionDto workout;
  final Duration elapsedTime;

  const WorkoutInProgress({
    required this.workout,
    required this.elapsedTime,
  });

  @override
  List<Object?> get props => [workout, elapsedTime];

  WorkoutInProgress copyWith({
    WorkoutSessionDto? workout,
    Duration? elapsedTime,
  }) {
    return WorkoutInProgress(
      workout: workout ?? this.workout,
      elapsedTime: elapsedTime ?? this.elapsedTime,
    );
  }
}

class WorkoutLoading extends WorkoutState {}

class WorkoutSaved extends WorkoutState {
  final WorkoutSessionDto workout;

  const WorkoutSaved(this.workout);

  @override
  List<Object?> get props => [workout];
}

class WorkoutError extends WorkoutState {
  final String message;

  const WorkoutError(this.message);

  @override
  List<Object?> get props => [message];
}
