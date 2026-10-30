import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lifeos_client/features/habits/data/models/habit_stats_dto.dart';
import 'package:lifeos_client/features/habits/domain/repositories/habits_repository.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/habit_stats_event.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/habit_stats_state.dart';

class HabitStatsBloc extends Bloc<HabitStatsEvent, HabitStatsState> {
  final HabitsRepository habitsRepository;

  HabitStatsBloc({required this.habitsRepository})
    : super(HabitStatsInitial()) {
    on<LoadHabitStats>(_onLoadHabitStats);
    on<RefreshHabitStats>(_onRefreshHabitStats);
    on<ArchiveHabit>(_onArchiveHabit);
  }

  Future<void> _onArchiveHabit(
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

      final entriesFuture = habitsRepository.getHabitEntries(
        habitId: habitId,
        from: DateFormat('yyyy-MM-dd').format(ninetyDaysAgo),
        to: DateFormat('yyyy-MM-dd').format(now),
      );
      // Stats are optional: the activity chart still renders without them.
      final statsFuture = habitsRepository
          .getHabitStats(habitId: habitId)
          .then<HabitStatsDto?>((s) => s)
          .catchError((_) => null);

      final entries = await entriesFuture;
      emit(HabitStatsLoaded(entries, stats: await statsFuture));
    } catch (e) {
      emit(HabitStatsError(e.toString()));
    }
  }
}
