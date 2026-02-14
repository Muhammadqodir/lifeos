import 'package:equatable/equatable.dart';

abstract class HabitStatsEvent extends Equatable {
  const HabitStatsEvent();

  @override
  List<Object?> get props => [];
}

class LoadHabitStats extends HabitStatsEvent {
  final int habitId;

  const LoadHabitStats(this.habitId);

  @override
  List<Object?> get props => [habitId];
}

class RefreshHabitStats extends HabitStatsEvent {
  final int habitId;

  const RefreshHabitStats(this.habitId);

  @override
  List<Object?> get props => [habitId];
}
