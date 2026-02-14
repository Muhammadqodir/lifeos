import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lifeos_client/features/home/domain/repositories/home_repository.dart';
import 'package:lifeos_client/features/home/presentation/bloc/home_event.dart';
import 'package:lifeos_client/features/home/presentation/bloc/home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository homeRepository;

  HomeBloc({required this.homeRepository}) : super(const HomeInitial()) {
    on<HomeStarted>(_onStarted);
    on<HomeRefreshed>(_onRefreshed);
    on<HomeRetried>(_onRetried);
  }

  Future<void> _onStarted(
    HomeStarted event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    await _loadData(emit);
  }

  Future<void> _onRefreshed(
    HomeRefreshed event,
    Emitter<HomeState> emit,
  ) async {
    await _loadData(emit);
  }

  Future<void> _onRetried(
    HomeRetried event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    await _loadData(emit);
  }

  Future<void> _loadData(Emitter<HomeState> emit) async {
    try {
      // Fetch all data in parallel for better performance
      final results = await Future.wait([
        homeRepository.getTodosForToday(),
        homeRepository.getInboxTodos(limit: 5),
        homeRepository.getInProgressTodos(limit: 5),
        homeRepository.getHabitsForToday(),
      ]);

      final todosToday = results[0] as List;
      final inboxTodos = results[1] as List;
      final inProgressTodos = results[2] as List;
      final habitsToday = results[3] as List;

      // Check if all data is empty
      if (todosToday.isEmpty && inboxTodos.isEmpty && inProgressTodos.isEmpty && habitsToday.isEmpty) {
        emit(const HomeEmpty());
      } else {
        emit(HomeSuccess(
          todosToday: todosToday.cast(),
          inboxTodos: inboxTodos.cast(),
          inProgressTodos: inProgressTodos.cast(),
          habitsToday: habitsToday.cast(),
        ));
      }
    } catch (e) {
      emit(HomeFailure(message: e.toString()));
    }
  }
}
