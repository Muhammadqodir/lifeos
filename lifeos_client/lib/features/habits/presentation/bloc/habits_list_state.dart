import 'package:equatable/equatable.dart';
import 'package:lifeos_client/features/habits/data/models/habit_dto.dart';

abstract class HabitsListState extends Equatable {
  const HabitsListState();

  @override
  List<Object?> get props => [];
}

class HabitsListInitial extends HabitsListState {}

class HabitsListLoading extends HabitsListState {}

class HabitsListSuccess extends HabitsListState {
  final List<HabitDto> habits;

  const HabitsListSuccess({required this.habits});

  @override
  List<Object?> get props => [habits];
}

class HabitsListEmpty extends HabitsListState {}

class HabitsListFailure extends HabitsListState {
  final String message;

  const HabitsListFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
