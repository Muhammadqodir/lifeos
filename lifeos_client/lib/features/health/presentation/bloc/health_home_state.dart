import 'package:equatable/equatable.dart';
import '../../data/models/sleep_summary_dto.dart';
import '../../data/models/wellbeing_summary_dto.dart';
import '../../data/models/workout_summary_dto.dart';

abstract class HealthHomeState extends Equatable {
  const HealthHomeState();

  @override
  List<Object?> get props => [];
}

class HealthHomeInitial extends HealthHomeState {
  const HealthHomeInitial();
}

class HealthHomeLoading extends HealthHomeState {
  const HealthHomeLoading();
}

class HealthHomeSuccess extends HealthHomeState {
  final SleepSummaryDto sleepSummary;
  final WellbeingSummaryDto wellbeingSummary;
  final WorkoutSummaryDto workoutSummary;

  const HealthHomeSuccess({
    required this.sleepSummary,
    required this.wellbeingSummary,
    required this.workoutSummary,
  });

  @override
  List<Object?> get props => [sleepSummary, wellbeingSummary, workoutSummary];

  HealthHomeSuccess copyWith({
    SleepSummaryDto? sleepSummary,
    WellbeingSummaryDto? wellbeingSummary,
    WorkoutSummaryDto? workoutSummary,
  }) {
    return HealthHomeSuccess(
      sleepSummary: sleepSummary ?? this.sleepSummary,
      wellbeingSummary: wellbeingSummary ?? this.wellbeingSummary,
      workoutSummary: workoutSummary ?? this.workoutSummary,
    );
  }
}

class HealthHomeEmpty extends HealthHomeState {
  const HealthHomeEmpty();
}

class HealthHomeFailure extends HealthHomeState {
  final String message;

  const HealthHomeFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
