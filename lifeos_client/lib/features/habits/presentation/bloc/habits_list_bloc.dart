import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lifeos_client/core/sync/sync_engine.dart';
import 'package:lifeos_client/features/habits/domain/repositories/habits_repository.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/habits_list_event.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/habits_list_state.dart';

/// Active habits with today's state, following the local store.
class HabitsListBloc extends Bloc<HabitsListEvent, HabitsListState> {
  final HabitsRepository habitsRepository;
  final SyncEngine? sync;
  StreamSubscription<void>? _subscription;

  HabitsListBloc({required this.habitsRepository, this.sync})
    : super(HabitsListInitial()) {
    on<HabitsListRequested>(_onRequested);
    on<HabitsListRefreshed>((event, emit) => sync?.syncNow());
    on<HabitsListChanged>(
      (event, emit) => emit(
        event.habits.isEmpty
            ? HabitsListEmpty()
            : HabitsListSuccess(habits: event.habits),
      ),
    );
  }

  Future<void> _onRequested(
    HabitsListRequested event,
    Emitter<HabitsListState> emit,
  ) async {
    if (_subscription != null) return;
    emit(HabitsListLoading());
    await sync?.whenReady();
    _subscription = habitsRepository
        .watchHabits(status: event.status ?? 'active')
        .listen((habits) => add(HabitsListChanged(habits)), onError: addError);
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
