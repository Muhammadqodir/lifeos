import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/workout_repository.dart';
import 'workout_sessions_event.dart';
import 'workout_sessions_state.dart';

class WorkoutSessionsBloc
    extends Bloc<WorkoutSessionsEvent, WorkoutSessionsState> {
  final WorkoutRepository workoutRepository;
  DateTime? _dateFrom;
  DateTime? _dateTo;
  int _currentPage = 1;

  WorkoutSessionsBloc({required this.workoutRepository})
      : super(const WorkoutSessionsInitial()) {
    on<WorkoutSessionsLoad>(_onLoad);
    on<WorkoutSessionsRefresh>(_onRefresh);
    on<WorkoutSessionsLoadMore>(_onLoadMore);
    on<WorkoutSessionsDelete>(_onDelete);
  }

  Future<void> _onLoad(
    WorkoutSessionsLoad event,
    Emitter<WorkoutSessionsState> emit,
  ) async {
    emit(const WorkoutSessionsLoading());

    try {
      _dateFrom = event.dateFrom;
      _dateTo = event.dateTo;
      _currentPage = 1;

      final sessions = await workoutRepository.getWorkoutSessions(
        dateFrom: _dateFrom,
        dateTo: _dateTo,
        page: _currentPage,
      );

      if (sessions.isEmpty) {
        emit(const WorkoutSessionsEmpty());
      } else {
        emit(WorkoutSessionsSuccess(
          sessions: sessions,
          hasMore: sessions.length >= 20, // API returns 20 per page
          currentPage: _currentPage,
        ));
      }
    } catch (e) {
      emit(WorkoutSessionsFailure(message: e.toString()));
    }
  }

  Future<void> _onRefresh(
    WorkoutSessionsRefresh event,
    Emitter<WorkoutSessionsState> emit,
  ) async {
    try {
      _currentPage = 1;

      final sessions = await workoutRepository.getWorkoutSessions(
        dateFrom: _dateFrom,
        dateTo: _dateTo,
        page: _currentPage,
      );

      if (sessions.isEmpty) {
        emit(const WorkoutSessionsEmpty());
      } else {
        emit(WorkoutSessionsSuccess(
          sessions: sessions,
          hasMore: sessions.length >= 20,
          currentPage: _currentPage,
        ));
      }
    } catch (e) {
      emit(WorkoutSessionsFailure(message: e.toString()));
    }
  }

  Future<void> _onLoadMore(
    WorkoutSessionsLoadMore event,
    Emitter<WorkoutSessionsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! WorkoutSessionsSuccess || !currentState.hasMore) {
      return;
    }

    emit(WorkoutSessionsLoadingMore(sessions: currentState.sessions));

    try {
      _currentPage += 1;

      final newSessions = await workoutRepository.getWorkoutSessions(
        dateFrom: _dateFrom,
        dateTo: _dateTo,
        page: _currentPage,
      );

      final allSessions = [...currentState.sessions, ...newSessions];

      emit(WorkoutSessionsSuccess(
        sessions: allSessions,
        hasMore: newSessions.length >= 20,
        currentPage: _currentPage,
      ));
    } catch (e) {
      // On error, restore previous state
      emit(currentState);
    }
  }

  Future<void> _onDelete(
    WorkoutSessionsDelete event,
    Emitter<WorkoutSessionsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! WorkoutSessionsSuccess) {
      return;
    }

    try {
      await workoutRepository.deleteWorkoutSession(event.workoutId);

      // Remove the deleted session from the list
      final updatedSessions = currentState.sessions
          .where((session) => session.id != event.workoutId)
          .toList();

      // Emit delete success state
      emit(WorkoutSessionsDeleteSuccess(
        sessions: updatedSessions,
        hasMore: currentState.hasMore,
        currentPage: currentState.currentPage,
      ));

      // Then emit regular state
      if (updatedSessions.isEmpty) {
        emit(const WorkoutSessionsEmpty());
      } else {
        emit(currentState.copyWith(sessions: updatedSessions));
      }
    } catch (e) {
      // Emit delete error state
      emit(WorkoutSessionsDeleteError(
        message: 'Failed to delete workout',
        sessions: currentState.sessions,
        hasMore: currentState.hasMore,
        currentPage: currentState.currentPage,
      ));
      
      // Keep current state
      emit(currentState);
    }
  }
}
