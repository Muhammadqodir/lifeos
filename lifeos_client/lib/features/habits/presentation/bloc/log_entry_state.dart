import 'package:equatable/equatable.dart';
import 'package:lifeos_client/features/habits/data/models/habit_entry_dto.dart';

abstract class LogEntryState extends Equatable {
  const LogEntryState();

  @override
  List<Object?> get props => [];
}

class LogEntryInitial extends LogEntryState {}

class LogEntryLoading extends LogEntryState {}

class LogEntrySuccess extends LogEntryState {
  final HabitEntryDto entry;

  const LogEntrySuccess({required this.entry});

  @override
  List<Object?> get props => [entry];
}

class DeleteEntrySuccess extends LogEntryState {}

class LogEntryFailure extends LogEntryState {
  final String message;

  const LogEntryFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
