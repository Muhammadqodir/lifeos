import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lifeos_client/core/sync/sync_engine.dart';
import 'package:lifeos_client/features/home/domain/repositories/home_repository.dart';
import 'package:lifeos_client/features/home/presentation/bloc/home_event.dart';
import 'package:lifeos_client/features/home/presentation/bloc/home_state.dart';

/// Home follows the local store: completing a todo or a habit anywhere in
/// the app updates it immediately, with no reload.
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository homeRepository;
  final SyncEngine? sync;
  StreamSubscription<void>? _subscription;

  HomeBloc({required this.homeRepository, this.sync})
    : super(const HomeInitial()) {
    on<HomeStarted>(_onStarted);
    on<HomeRefreshed>((event, emit) => sync?.syncNow());
    on<HomeRetried>((event, emit) => sync?.syncNow());
    on<HomeChanged>(
      (event, emit) => emit(
        event.snapshot.isEmpty
            ? const HomeEmpty()
            : HomeSuccess(
                todosToday: event.snapshot.todosToday,
                overdueTodos: event.snapshot.overdueTodos,
                inboxTodos: event.snapshot.inboxTodos,
                inProgressTodos: event.snapshot.inProgressTodos,
                habitsToday: event.snapshot.habitsToday,
              ),
      ),
    );
  }

  Future<void> _onStarted(HomeStarted event, Emitter<HomeState> emit) async {
    if (_subscription != null) return;
    emit(const HomeLoading());
    await sync?.whenReady();
    _subscription = homeRepository.watchToday().listen(
      (snapshot) => add(HomeChanged(snapshot)),
      onError: addError,
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
