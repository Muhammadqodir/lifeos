import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lifeos_client/features/projects/data/models/todo_dto.dart';
import 'package:lifeos_client/features/projects/domain/repositories/todos_repository.dart';
import 'package:lifeos_client/features/projects/presentation/bloc/manage_todos_event.dart';
import 'package:lifeos_client/features/projects/presentation/bloc/manage_todos_state.dart';

class ManageTodosBloc extends Bloc<ManageTodosEvent, ManageTodosState> {
  final TodosRepository _todosRepository;

  // Store current filters for refresh
  int? _currentProjectId;
  String? _currentStatus;
  String? _currentTag;
  DateTime? _currentPlannedFrom;
  DateTime? _currentPlannedTo;
  String? _currentSearch;
  String _currentOrderBy = 'created_at';
  String _currentOrderDirection = 'desc';

  ManageTodosBloc(this._todosRepository) : super(const ManageTodosInitial()) {
    on<LoadTodos>(_onLoadTodos);
    on<LoadAllStatuses>(_onLoadAllStatuses);
    on<LoadTodosByStatus>(_onLoadTodosByStatus);
    on<LoadMoreTodos>(_onLoadMoreTodos);
    on<RefreshTodos>(_onRefreshTodos);
    on<DeleteTodo>(_onDeleteTodo);
    on<UpdateTodoStatus>(_onUpdateTodoStatus);
    on<SearchTodos>(_onSearchTodos);
    on<FilterTodosByStatus>(_onFilterTodosByStatus);
    on<TodoUpdatedExternally>(_onTodoUpdatedExternally);
  }

  Future<void> _onLoadTodos(
    LoadTodos event,
    Emitter<ManageTodosState> emit,
  ) async {
    emit(const ManageTodosLoading());

    // Store current filters
    _currentProjectId = event.projectId;
    _currentStatus = event.status;
    _currentTag = event.tag;
    _currentPlannedFrom = event.plannedFrom;
    _currentPlannedTo = event.plannedTo;
    _currentSearch = event.search;
    _currentOrderBy = event.orderBy;
    _currentOrderDirection = event.orderDirection;

    try {
      await _todosRepository.getTodos(
        projectId: event.projectId,
        status: event.status,
        tag: event.tag,
        plannedFrom: event.plannedFrom,
        plannedTo: event.plannedTo,
        search: event.search,
        orderBy: event.orderBy,
        orderDirection: event.orderDirection,
      );

      emit(ManageTodosLoaded(
        todosByStatus: const {},
        currentPageByStatus: const {},
        hasMoreByStatus: const {},
        currentProjectId: event.projectId,
      ));
    } catch (e) {
      emit(ManageTodosError(
        message: e.toString(),
        todosByStatus: const {},
        currentPageByStatus: const {},
        hasMoreByStatus: const {},
      ));
    }
  }

  Future<void> _onLoadAllStatuses(
    LoadAllStatuses event,
    Emitter<ManageTodosState> emit,
  ) async {
    // Initialize state
    emit(ManageTodosLoaded(
      todosByStatus: const {},
      currentPageByStatus: const {},
      hasMoreByStatus: const {},
      currentProjectId: event.projectId,
    ));

    try {
      final todosByStatus = <String, List<TodoDto>>{};
      final currentPageByStatus = <String, int>{};
      final hasMoreByStatus = <String, bool>{};

      // Load all statuses in parallel
      await Future.wait(
        event.statuses.map((status) async {
          final todos = await _todosRepository.getTodos(
            projectId: event.projectId,
            status: status,
            page: 1,
            perPage: event.perPage,
          );
          todosByStatus[status] = todos;
          currentPageByStatus[status] = 1;
          hasMoreByStatus[status] = todos.length >= event.perPage;
        }),
      );

      emit(ManageTodosLoaded(
        todosByStatus: todosByStatus,
        currentPageByStatus: currentPageByStatus,
        hasMoreByStatus: hasMoreByStatus,
        currentProjectId: event.projectId,
      ));
    } catch (e) {
      emit(ManageTodosError(
        message: e.toString(),
        todosByStatus: const {},
        currentPageByStatus: const {},
        hasMoreByStatus: const {},
      ));
    }
  }

  Future<void> _onLoadTodosByStatus(
    LoadTodosByStatus event,
    Emitter<ManageTodosState> emit,
  ) async {
    final currentState = state;
    
    // If initial load or different project, initialize state
    if (currentState is! ManageTodosLoaded ||
        currentState.currentProjectId != event.projectId) {
      emit(ManageTodosLoaded(
        todosByStatus: const {},
        currentPageByStatus: const {},
        hasMoreByStatus: const {},
        currentProjectId: event.projectId,
      ));
    }

    try {
      final todos = await _todosRepository.getTodos(
        projectId: event.projectId,
        status: event.status,
        page: event.page,
        perPage: event.perPage,
      );

      final state = this.state;
      if (state is ManageTodosLoaded) {
        final updatedTodosByStatus = Map<String, List<TodoDto>>.from(
          state.todosByStatus,
        );
        updatedTodosByStatus[event.status] = todos;

        final updatedPageByStatus = Map<String, int>.from(
          state.currentPageByStatus,
        );
        updatedPageByStatus[event.status] = event.page;

        final updatedHasMoreByStatus = Map<String, bool>.from(
          state.hasMoreByStatus,
        );
        updatedHasMoreByStatus[event.status] = todos.length >= event.perPage;

        emit(state.copyWith(
          todosByStatus: updatedTodosByStatus,
          currentPageByStatus: updatedPageByStatus,
          hasMoreByStatus: updatedHasMoreByStatus,
        ));
      }
    } catch (e) {
      final currentState = state;
      if (currentState is ManageTodosLoaded) {
        emit(ManageTodosError(
          message: e.toString(),
          todosByStatus: currentState.todosByStatus,
          currentPageByStatus: currentState.currentPageByStatus,
          hasMoreByStatus: currentState.hasMoreByStatus,
          isLoadingMoreByStatus: currentState.isLoadingMoreByStatus,
          currentProjectId: currentState.currentProjectId,
        ));
      } else {
        emit(ManageTodosError(
          message: e.toString(),
          todosByStatus: const {},
          currentPageByStatus: const {},
          hasMoreByStatus: const {},
        ));
      }
    }
  }

  Future<void> _onLoadMoreTodos(
    LoadMoreTodos event,
    Emitter<ManageTodosState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ManageTodosLoaded) return;

    final currentPage = currentState.currentPageByStatus[event.status] ?? 1;
    final isLoadingMore = currentState.isLoadingMoreByStatus[event.status] ?? false;
    final hasMore = currentState.hasMoreByStatus[event.status] ?? false;

    if (isLoadingMore || !hasMore) return;

    // Set loading more flag
    final updatedLoadingMore = Map<String, bool>.from(
      currentState.isLoadingMoreByStatus,
    );
    updatedLoadingMore[event.status] = true;
    emit(currentState.copyWith(isLoadingMoreByStatus: updatedLoadingMore));

    try {
      final nextPage = currentPage + 1;
      final newTodos = await _todosRepository.getTodos(
        projectId: currentState.currentProjectId!,
        status: event.status,
        page: nextPage,
        perPage: 15,
      );

      final state = this.state;
      if (state is ManageTodosLoaded) {
        final updatedTodosByStatus = Map<String, List<TodoDto>>.from(
          state.todosByStatus,
        );
        final existingTodos = updatedTodosByStatus[event.status] ?? [];
        updatedTodosByStatus[event.status] = [...existingTodos, ...newTodos];

        final updatedPageByStatus = Map<String, int>.from(
          state.currentPageByStatus,
        );
        updatedPageByStatus[event.status] = nextPage;

        final updatedHasMoreByStatus = Map<String, bool>.from(
          state.hasMoreByStatus,
        );
        updatedHasMoreByStatus[event.status] = newTodos.length >= 15;

        final updatedLoadingMore = Map<String, bool>.from(
          state.isLoadingMoreByStatus,
        );
        updatedLoadingMore[event.status] = false;

        emit(state.copyWith(
          todosByStatus: updatedTodosByStatus,
          currentPageByStatus: updatedPageByStatus,
          hasMoreByStatus: updatedHasMoreByStatus,
          isLoadingMoreByStatus: updatedLoadingMore,
        ));
      }
    } catch (e) {
      final state = this.state;
      if (state is ManageTodosLoaded) {
        final updatedLoadingMore = Map<String, bool>.from(
          state.isLoadingMoreByStatus,
        );
        updatedLoadingMore[event.status] = false;
        
        emit(ManageTodosError(
          message: e.toString(),
          todosByStatus: state.todosByStatus,
          currentPageByStatus: state.currentPageByStatus,
          hasMoreByStatus: state.hasMoreByStatus,
          isLoadingMoreByStatus: updatedLoadingMore,
          currentProjectId: state.currentProjectId,
        ));
      }
    }
  }

  Future<void> _onRefreshTodos(
    RefreshTodos event,
    Emitter<ManageTodosState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ManageTodosLoaded ||
        currentState.currentProjectId == null) return;

    // Reload all currently loaded statuses
    for (final status in currentState.todosByStatus.keys) {
      add(LoadTodosByStatus(
        projectId: currentState.currentProjectId!,
        status: status,
        page: 1,
      ));
    }
  }

  Future<void> _onDeleteTodo(
    DeleteTodo event,
    Emitter<ManageTodosState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ManageTodosLoaded) return;

    emit(TodoDeleting(
      todoId: event.todoId,
      todosByStatus: currentState.todosByStatus,
      currentPageByStatus: currentState.currentPageByStatus,
      hasMoreByStatus: currentState.hasMoreByStatus,
      isLoadingMoreByStatus: currentState.isLoadingMoreByStatus,
      currentProjectId: currentState.currentProjectId,
    ));

    try {
      await _todosRepository.deleteTodo(event.todoId);

      // Refresh the list
      add(const RefreshTodos());
    } catch (e) {
      emit(ManageTodosError(
        message: e.toString(),
        todosByStatus: currentState.todosByStatus,
        currentPageByStatus: currentState.currentPageByStatus,
        hasMoreByStatus: currentState.hasMoreByStatus,
        isLoadingMoreByStatus: currentState.isLoadingMoreByStatus,
        currentProjectId: currentState.currentProjectId,
      ));

      // Reload to restore previous state
      add(const RefreshTodos());
    }
  }

  Future<void> _onUpdateTodoStatus(
    UpdateTodoStatus event,
    Emitter<ManageTodosState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ManageTodosLoaded) return;

    emit(TodoStatusUpdating(
      todoId: event.todoId,
      newStatus: event.status,
      todosByStatus: currentState.todosByStatus,
      currentPageByStatus: currentState.currentPageByStatus,
      hasMoreByStatus: currentState.hasMoreByStatus,
      isLoadingMoreByStatus: currentState.isLoadingMoreByStatus,
      currentProjectId: currentState.currentProjectId,
    ));

    try {
      await _todosRepository.updateTodoStatus(
        event.todoId,
        event.status,
      );

      // Refresh only affected statuses (old and new)
      final statusesToRefresh = <String>{};
      if (event.oldStatus != null) {
        statusesToRefresh.add(event.oldStatus!);
      }
      statusesToRefresh.add(event.status);

      if (currentState.currentProjectId != null) {
        for (final status in statusesToRefresh) {
          add(LoadTodosByStatus(
            projectId: currentState.currentProjectId!,
            status: status,
            page: 1,
          ));
        }
      }
    } catch (e) {
      emit(ManageTodosError(
        message: e.toString(),
        todosByStatus: currentState.todosByStatus,
        currentPageByStatus: currentState.currentPageByStatus,
        hasMoreByStatus: currentState.hasMoreByStatus,
        isLoadingMoreByStatus: currentState.isLoadingMoreByStatus,
        currentProjectId: currentState.currentProjectId,
      ));

      // Reload to restore previous state
      add(const RefreshTodos());
    }
  }

  Future<void> _onSearchTodos(
    SearchTodos event,
    Emitter<ManageTodosState> emit,
  ) async {
    _currentSearch = event.query.isEmpty ? null : event.query;

    add(LoadTodos(
      projectId: _currentProjectId,
      status: _currentStatus,
      tag: _currentTag,
      plannedFrom: _currentPlannedFrom,
      plannedTo: _currentPlannedTo,
      search: _currentSearch,
      orderBy: _currentOrderBy,
      orderDirection: _currentOrderDirection,
    ));
  }

  Future<void> _onFilterTodosByStatus(
    FilterTodosByStatus event,
    Emitter<ManageTodosState> emit,
  ) async {
    _currentStatus = event.status;

    add(LoadTodos(
      projectId: _currentProjectId,
      status: _currentStatus,
      tag: _currentTag,
      plannedFrom: _currentPlannedFrom,
      plannedTo: _currentPlannedTo,
      search: _currentSearch,
      orderBy: _currentOrderBy,
      orderDirection: _currentOrderDirection,
    ));
  }

  Future<void> _onTodoUpdatedExternally(
    TodoUpdatedExternally event,
    Emitter<ManageTodosState> emit,
  ) async {
    final currentState = state;

    if (currentState is ManageTodosLoaded) {
      // Refresh affected statuses
      add(const RefreshTodos());
    }
  }
}
