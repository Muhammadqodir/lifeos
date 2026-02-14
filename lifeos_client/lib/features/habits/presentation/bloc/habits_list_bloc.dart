import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lifeos_client/features/habits/domain/repositories/habits_repository.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/habits_list_event.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/habits_list_state.dart';

class HabitsListBloc extends Bloc<HabitsListEvent, HabitsListState> {
  final HabitsRepository habitsRepository;

  HabitsListBloc({required this.habitsRepository}) : super(HabitsListInitial()) {
    on<HabitsListRequested>(_onHabitsListRequested);
    on<HabitsListRefreshed>(_onHabitsListRefreshed);
  }

  Future<void> _onHabitsListRequested(
    HabitsListRequested event,
    Emitter<HabitsListState> emit,
  ) async {
    emit(HabitsListLoading());
    try {
      final habits = await habitsRepository.getHabitsWithTodayStatus();

      if (habits.isEmpty) {
        emit(HabitsListEmpty());
      } else {
        emit(HabitsListSuccess(habits: habits));
      }
    } catch (e) {
      emit(HabitsListFailure(message: e.toString()));
    }
  }

  Future<void> _onHabitsListRefreshed(
    HabitsListRefreshed event,
    Emitter<HabitsListState> emit,
  ) async {
    try {
      final habits = await habitsRepository.getHabitsWithTodayStatus();

      if (habits.isEmpty) {
        emit(HabitsListEmpty());
      } else {
        emit(HabitsListSuccess(habits: habits));
      }
    } catch (e) {
      emit(HabitsListFailure(message: e.toString()));
    }
  }
}
