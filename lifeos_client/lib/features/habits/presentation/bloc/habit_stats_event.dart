import 'package:equatable/equatable.dart';
import 'package:lifeos_client/features/habits/domain/repositories/habits_repository.dart';

abstract class HabitStatsEvent extends Equatable {
  const HabitStatsEvent();

  @override
  List<Object?> get props => [];
}

class LoadHabitStats extends HabitStatsEvent {
  final String habitId;

  const LoadHabitStats(this.habitId);

  @override
  List<Object?> get props => [habitId];
}

class RefreshHabitStats extends HabitStatsEvent {
  final String habitId;

  const RefreshHabitStats(this.habitId);

  @override
  List<Object?> get props => [habitId];
}

/// Archives the habit (hidden from active lists, history kept).
class ArchiveHabit extends HabitStatsEvent {
  final String habitId;

  const ArchiveHabit(this.habitId);

  @override
  List<Object?> get props => [habitId];
}

/// The local store changed (internal).
class HabitActivityChanged extends HabitStatsEvent {
  final HabitActivity activity;

  const HabitActivityChanged(this.activity);

  @override
  List<Object?> get props => [activity];
}
