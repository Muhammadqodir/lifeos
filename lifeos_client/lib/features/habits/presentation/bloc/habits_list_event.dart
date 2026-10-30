import 'package:equatable/equatable.dart';
import 'package:lifeos_client/features/habits/data/models/habit_dto.dart';

abstract class HabitsListEvent extends Equatable {
  const HabitsListEvent();

  @override
  List<Object?> get props => [];
}

class HabitsListRequested extends HabitsListEvent {
  final String? status;
  final String? frequency;
  final String? search;

  const HabitsListRequested({this.status, this.frequency, this.search});

  @override
  List<Object?> get props => [status, frequency, search];
}

class HabitsListRefreshed extends HabitsListEvent {
  const HabitsListRefreshed();
}

/// The local store changed (internal).
class HabitsListChanged extends HabitsListEvent {
  final List<HabitDto> habits;

  const HabitsListChanged(this.habits);

  @override
  List<Object?> get props => [habits];
}
