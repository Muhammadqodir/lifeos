import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/health_repository.dart';
import 'health_home_event.dart';
import 'health_home_state.dart';

class HealthHomeBloc extends Bloc<HealthHomeEvent, HealthHomeState> {
  final HealthRepository healthRepository;

  HealthHomeBloc({required this.healthRepository})
      : super(const HealthHomeInitial()) {
    on<HealthHomeStarted>(_onStarted);
    on<HealthHomeRefreshed>(_onRefreshed);
    on<HealthHomeRetried>(_onRetried);
  }

  Future<void> _onStarted(
    HealthHomeStarted event,
    Emitter<HealthHomeState> emit,
  ) async {
    emit(const HealthHomeLoading());
    await _loadData(emit);
  }

  Future<void> _onRefreshed(
    HealthHomeRefreshed event,
    Emitter<HealthHomeState> emit,
  ) async {
    await _loadData(emit);
  }

  Future<void> _onRetried(
    HealthHomeRetried event,
    Emitter<HealthHomeState> emit,
  ) async {
    emit(const HealthHomeLoading());
    await _loadData(emit);
  }

  Future<void> _loadData(Emitter<HealthHomeState> emit) async {
    try {
      // Get data for last 7 days
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));

      final sleepSummary = await healthRepository.getSleepSummary(
        dateFrom: sevenDaysAgo,
        dateTo: now,
      );

      final wellbeingSummary = await healthRepository.getWellbeingSummary(
        dateFrom: sevenDaysAgo,
        dateTo: now,
      );

      final workoutSummary = await healthRepository.getWorkoutSummary(
        dateFrom: sevenDaysAgo,
        dateTo: now,
      );

      // Always show success state with charts (they handle empty data)
      emit(HealthHomeSuccess(
        sleepSummary: sleepSummary,
        wellbeingSummary: wellbeingSummary,
        workoutSummary: workoutSummary,
      ));
    } catch (e) {
      emit(HealthHomeFailure(message: e.toString()));
    }
  }
}
