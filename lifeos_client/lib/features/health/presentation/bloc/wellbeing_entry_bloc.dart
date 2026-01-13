import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/health_repository.dart';
import 'wellbeing_entry_event.dart';
import 'wellbeing_entry_state.dart';

class WellbeingEntryBloc
    extends Bloc<WellbeingEntryEvent, WellbeingEntryState> {
  final HealthRepository healthRepository;

  WellbeingEntryBloc({required this.healthRepository})
      : super(WellbeingEntryInitial()) {
    on<CreateWellbeingEntry>(_onCreateWellbeingEntry);
  }

  Future<void> _onCreateWellbeingEntry(
    CreateWellbeingEntry event,
    Emitter<WellbeingEntryState> emit,
  ) async {
    emit(WellbeingEntryLoading());
    try {
      final wellbeingEntry = await healthRepository.createWellbeingEntry(
        date: event.date,
        energy: event.energy,
        stress: event.stress,
        note: event.note,
      );

      emit(WellbeingEntrySuccess(wellbeingEntry: wellbeingEntry));
    } catch (e) {
      emit(WellbeingEntryFailure(message: e.toString()));
    }
  }
}
