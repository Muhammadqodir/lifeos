import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lifeos_client/core/sync/sync_engine.dart';
import 'package:lifeos_client/features/projects/data/models/todo_dto.dart';
import 'package:lifeos_client/features/projects/domain/repositories/todos_repository.dart';
import 'package:lifeos_client/features/projects/presentation/bloc/manage_todos_event.dart';
import 'package:lifeos_client/features/projects/presentation/bloc/manage_todos_state.dart';

/// A project's todos, and status changes / deletes from any todo list.
///
/// Changes are written locally and the lists follow the store, so there is
/// nothing to reload after an action.
class ManageTodosBloc extends Bloc<ManageTodosEvent, ManageTodosState> {
  final TodosRepository _todosRepository;
  final SyncEngine? _sync;
  StreamSubscription<void>? _subscription;
  List<String> _statuses = const [];

  ManageTodosBloc(this._todosRepository, {SyncEngine? sync})
    : _sync = sync,
      super(const ManageTodosInitial()) {
    on<LoadAllStatuses>(_onLoadAllStatuses);
    on<TodosChanged>(_onTodosChanged);
    on<RefreshTodos>((event, emit) => _sync?.syncNow());
    on<DeleteTodo>(
      (event, emit) =>
          _guard(emit, () => _todosRepository.deleteTodo(event.todoId)),
    );
    on<UpdateTodoStatus>(
      (event, emit) => _guard(
        emit,
        () => _todosRepository.updateTodoStatus(
          event.todoId,
          event.status,
          plannedDate: event.plannedDate,
        ),
      ),
    );
  }

  void _onLoadAllStatuses(
    LoadAllStatuses event,
    Emitter<ManageTodosState> emit,
  ) {
    _statuses = event.statuses;
    _subscription?.cancel();
    _subscription = _todosRepository
        .watchTodos(projectId: event.projectId)
        .listen((todos) => add(TodosChanged(todos)), onError: addError);
  }

  void _onTodosChanged(TodosChanged event, Emitter<ManageTodosState> emit) {
    final byStatus = {for (final s in _statuses) s: <TodoDto>[]};
    for (final todo in event.todos) {
      byStatus[todo.status]?.add(todo);
    }
    final current = state;
    emit(
      ManageTodosLoaded(
        todosByStatus: byStatus,
        currentProjectId: current is ManageTodosWithData
            ? current.currentProjectId
            : event.todos.firstOrNull?.projectId,
      ),
    );
  }

  Future<void> _guard(
    Emitter<ManageTodosState> emit,
    Future<void> Function() action,
  ) async {
    try {
      await action();
    } catch (e) {
      final current = state;
      emit(
        ManageTodosError(
          message: e.toString(),
          todosByStatus: current is ManageTodosWithData
              ? current.todosByStatus
              : const {},
          currentProjectId: current is ManageTodosWithData
              ? current.currentProjectId
              : null,
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
