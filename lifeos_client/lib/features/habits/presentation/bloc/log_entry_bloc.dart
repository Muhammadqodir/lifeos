import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lifeos_client/features/habits/domain/repositories/habits_repository.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/log_entry_event.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/log_entry_state.dart';

class LogEntryBloc extends Bloc<LogEntryEvent, LogEntryState> {
  final HabitsRepository habitsRepository;

  LogEntryBloc({required this.habitsRepository}) : super(LogEntryInitial()) {
    on<LogEntrySubmitted>(_onLogEntrySubmitted);
    on<DeleteEntrySubmitted>(_onDeleteEntrySubmitted);
  }

  Future<void> _onLogEntrySubmitted(
    LogEntrySubmitted event,
    Emitter<LogEntryState> emit,
  ) async {
    emit(LogEntryLoading());
    try {
      final entry = await habitsRepository.createHabitEntry(
        habitId: event.habitId,
        date: event.date,
        completedAt: event.completedAt,
        note: event.note,
      );

      emit(LogEntrySuccess(entry: entry));
    } catch (e) {
      emit(LogEntryFailure(message: e.toString()));
    }
  }

  Future<void> _onDeleteEntrySubmitted(
    DeleteEntrySubmitted event,
    Emitter<LogEntryState> emit,
  ) async {
    emit(LogEntryLoading());
    try {
      await habitsRepository.deleteHabitEntry(event.entryId);
      emit(DeleteEntrySuccess());
    } catch (e) {
      emit(LogEntryFailure(message: e.toString()));
    }
  }
}
