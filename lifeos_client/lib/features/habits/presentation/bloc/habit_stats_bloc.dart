import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lifeos_client/features/habits/domain/repositories/habits_repository.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/habit_stats_event.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/habit_stats_state.dart';

class HabitStatsBloc extends Bloc<HabitStatsEvent, HabitStatsState> {
  final HabitsRepository habitsRepository;

  HabitStatsBloc({required this.habitsRepository})
      : super(HabitStatsInitial()) {
    on<LoadHabitStats>(_onLoadHabitStats);
    on<RefreshHabitStats>(_onRefreshHabitStats);
  }

  Future<void> _onLoadHabitStats(
    LoadHabitStats event,
    Emitter<HabitStatsState> emit,
  ) async {
    emit(HabitStatsLoading());
    await _fetchHabitEntries(event.habitId, emit);
  }

  Future<void> _onRefreshHabitStats(
    RefreshHabitStats event,
    Emitter<HabitStatsState> emit,
  ) async {
    await _fetchHabitEntries(event.habitId, emit);
  }

  Future<void> _fetchHabitEntries(
    int habitId,
    Emitter<HabitStatsState> emit,
  ) async {
    try {
      final now = DateTime.now();
      final ninetyDaysAgo = now.subtract(const Duration(days: 90));

      final entries = await habitsRepository.getHabitEntries(
        habitId: habitId,
        from: DateFormat('yyyy-MM-dd').format(ninetyDaysAgo),
        to: DateFormat('yyyy-MM-dd').format(now),
      );

      emit(HabitStatsLoaded(entries));
    } catch (e) {
      emit(HabitStatsError(e.toString()));
    }
  }
}
