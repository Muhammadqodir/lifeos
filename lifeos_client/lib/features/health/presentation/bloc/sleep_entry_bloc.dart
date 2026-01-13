import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/health_repository.dart';
import 'sleep_entry_event.dart';
import 'sleep_entry_state.dart';

class SleepEntryBloc extends Bloc<SleepEntryEvent, SleepEntryState> {
  final HealthRepository healthRepository;

  SleepEntryBloc({required this.healthRepository})
      : super(SleepEntryInitial()) {
    on<CreateSleepEntry>(_onCreateSleepEntry);
  }

  Future<void> _onCreateSleepEntry(
    CreateSleepEntry event,
    Emitter<SleepEntryState> emit,
  ) async {
    emit(SleepEntryLoading());
    try {
      final sleepEntry = await healthRepository.createSleepEntry(
        date: event.date,
        sleepStart: event.sleepStart,
        sleepEnd: event.sleepEnd,
        quality: event.quality,
        note: event.note,
      );

      emit(SleepEntrySuccess(sleepEntry: sleepEntry));
    } catch (e) {
      emit(SleepEntryFailure(message: e.toString()));
    }
  }
}
