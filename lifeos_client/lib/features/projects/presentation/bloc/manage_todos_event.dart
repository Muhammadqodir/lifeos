import 'package:equatable/equatable.dart';
import 'package:lifeos_client/features/projects/data/models/todo_dto.dart';

abstract class ManageTodosEvent extends Equatable {
  const ManageTodosEvent();

  @override
  List<Object?> get props => [];
}

class LoadTodos extends ManageTodosEvent {
  final int? projectId;
  final String? status;
  final String? tag;
  final DateTime? plannedFrom;
  final DateTime? plannedTo;
  final String? search;
  final String orderBy;
  final String orderDirection;

  const LoadTodos({
    this.projectId,
    this.status,
    this.tag,
    this.plannedFrom,
    this.plannedTo,
    this.search,
    this.orderBy = 'created_at',
    this.orderDirection = 'desc',
  });

  @override
  List<Object?> get props => [
        projectId,
        status,
        tag,
        plannedFrom,
        plannedTo,
        search,
        orderBy,
        orderDirection,
      ];
}

class RefreshTodos extends ManageTodosEvent {
  const RefreshTodos();
}

class LoadAllStatuses extends ManageTodosEvent {
  final int projectId;
  final List<String> statuses;
  final int perPage;

  const LoadAllStatuses({
    required this.projectId,
    required this.statuses,
    this.perPage = 15,
  });

  @override
  List<Object?> get props => [projectId, statuses, perPage];
}

class LoadTodosByStatus extends ManageTodosEvent {
  final int projectId;
  final String status;
  final int page;
  final int perPage;

  const LoadTodosByStatus({
    required this.projectId,
    required this.status,
    this.page = 1,
    this.perPage = 15,
  });

  @override
  List<Object?> get props => [projectId, status, page, perPage];
}

class LoadMoreTodos extends ManageTodosEvent {
  final String status;

  const LoadMoreTodos({required this.status});

  @override
  List<Object?> get props => [status];
}

class DeleteTodo extends ManageTodosEvent {
  final int todoId;

  const DeleteTodo(this.todoId);

  @override
  List<Object?> get props => [todoId];
}

class UpdateTodoStatus extends ManageTodosEvent {
  final int todoId;
  final String status;

  const UpdateTodoStatus({
    required this.todoId,
    required this.status,
  });

  @override
  List<Object?> get props => [todoId, status];
}

class SearchTodos extends ManageTodosEvent {
  final String query;

  const SearchTodos(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterTodosByStatus extends ManageTodosEvent {
  final String? status;

  const FilterTodosByStatus(this.status);

  @override
  List<Object?> get props => [status];
}

class TodoUpdatedExternally extends ManageTodosEvent {
  final TodoDto todo;

  const TodoUpdatedExternally(this.todo);

  @override
  List<Object?> get props => [todo];
}
