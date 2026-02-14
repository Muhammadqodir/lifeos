import 'package:equatable/equatable.dart';
import 'package:lifeos_client/features/habits/data/models/habit_dto.dart';

abstract class CreateHabitState extends Equatable {
  const CreateHabitState();

  @override
  List<Object?> get props => [];
}

class CreateHabitInitial extends CreateHabitState {}

class CreateHabitLoading extends CreateHabitState {}

class CreateHabitSuccess extends CreateHabitState {
  final HabitDto habit;

  const CreateHabitSuccess({required this.habit});

  @override
  List<Object?> get props => [habit];
}

class CreateHabitFailure extends CreateHabitState {
  final String message;

  const CreateHabitFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
