import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lifeos_client/core/sync/sync_engine.dart';
import 'package:lifeos_client/features/habits/domain/repositories/habits_repository.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/habit_stats_event.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/habit_stats_state.dart';

/// One habit's entries and streaks, computed from the local store.
class HabitStatsBloc extends Bloc<HabitStatsEvent, HabitStatsState> {
  final HabitsRepository habitsRepository;
  final SyncEngine? sync;
  StreamSubscription<void>? _subscription;

  HabitStatsBloc({required this.habitsRepository, this.sync})
    : super(HabitStatsInitial()) {
    on<LoadHabitStats>(_onLoad);
    on<RefreshHabitStats>((event, emit) => sync?.syncNow());
    on<HabitActivityChanged>(
      (event, emit) => emit(
        HabitStatsLoaded(event.activity.entries, stats: event.activity.stats),
      ),
    );
    on<ArchiveHabit>(_onArchive);
  }

  void _onLoad(LoadHabitStats event, Emitter<HabitStatsState> emit) {
    emit(HabitStatsLoading());
    _subscription?.cancel();
    _subscription = habitsRepository
        .watchActivity(event.habitId)
        .listen((a) => add(HabitActivityChanged(a)), onError: addError);
  }

  Future<void> _onArchive(
    ArchiveHabit event,
    Emitter<HabitStatsState> emit,
  ) async {
    final previous = state;
    try {
      await habitsRepository.updateHabit(
        habitId: event.habitId,
        status: 'archived',
      );
      emit(HabitArchived());
    } catch (e) {
      emit(HabitStatsError(e.toString()));
      if (previous is HabitStatsLoaded) emit(previous);
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
