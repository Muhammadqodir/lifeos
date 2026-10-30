import 'package:equatable/equatable.dart';
import 'package:lifeos_client/features/projects/data/models/todo_dto.dart';

abstract class ManageTodosEvent extends Equatable {
  const ManageTodosEvent();

  @override
  List<Object?> get props => [];
}

/// Follow [projectId]'s todos, grouped into [statuses].
class LoadAllStatuses extends ManageTodosEvent {
  final String projectId;
  final List<String> statuses;

  const LoadAllStatuses({required this.projectId, required this.statuses});

  @override
  List<Object?> get props => [projectId, statuses];
}

/// Sync with the server now (the list itself is always current).
class RefreshTodos extends ManageTodosEvent {
  const RefreshTodos();
}

class DeleteTodo extends ManageTodosEvent {
  final String todoId;

  const DeleteTodo(this.todoId);

  @override
  List<Object?> get props => [todoId];
}

class UpdateTodoStatus extends ManageTodosEvent {
  final String todoId;
  final String status;
  final DateTime? plannedDate;

  const UpdateTodoStatus({
    required this.todoId,
    required this.status,
    this.plannedDate,
  });

  @override
  List<Object?> get props => [todoId, status, plannedDate];
}

/// The local store changed (internal).
class TodosChanged extends ManageTodosEvent {
  final List<TodoDto> todos;

  const TodosChanged(this.todos);

  @override
  List<Object?> get props => [todos];
}
