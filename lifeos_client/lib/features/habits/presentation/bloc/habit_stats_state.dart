import 'package:equatable/equatable.dart';
import 'package:lifeos_client/features/habits/data/models/habit_entry_dto.dart';
import 'package:lifeos_client/features/habits/data/models/habit_stats_dto.dart';

abstract class HabitStatsState extends Equatable {
  const HabitStatsState();

  @override
  List<Object?> get props => [];
}

class HabitStatsInitial extends HabitStatsState {}

class HabitStatsLoading extends HabitStatsState {}

class HabitStatsLoaded extends HabitStatsState {
  final List<HabitEntryDto> entries;

  /// Streaks and completion rate, computed on the device.
  final HabitStatsDto? stats;

  const HabitStatsLoaded(this.entries, {this.stats});

  @override
  List<Object?> get props => [entries, stats];
}

class HabitArchived extends HabitStatsState {}

class HabitStatsError extends HabitStatsState {
  final String message;

  const HabitStatsError(this.message);

  @override
  List<Object?> get props => [message];
}
