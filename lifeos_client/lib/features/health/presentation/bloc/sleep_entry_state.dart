import 'package:equatable/equatable.dart';
import '../../data/models/sleep_entry_dto.dart';

abstract class SleepEntryState extends Equatable {
  const SleepEntryState();

  @override
  List<Object?> get props => [];
}

class SleepEntryInitial extends SleepEntryState {}

class SleepEntryLoading extends SleepEntryState {}

class SleepEntrySuccess extends SleepEntryState {
  final SleepEntryDto sleepEntry;

  const SleepEntrySuccess({required this.sleepEntry});

  @override
  List<Object?> get props => [sleepEntry];
}

class SleepEntryFailure extends SleepEntryState {
  final String message;

  const SleepEntryFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
