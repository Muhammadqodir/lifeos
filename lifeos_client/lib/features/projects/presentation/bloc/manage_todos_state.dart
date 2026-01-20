import 'package:equatable/equatable.dart';
import 'package:lifeos_client/features/projects/data/models/todo_dto.dart';

abstract class ManageTodosState extends Equatable {
  const ManageTodosState();

  @override
  List<Object?> get props => [];
}

class ManageTodosInitial extends ManageTodosState {
  const ManageTodosInitial();
}

class ManageTodosLoading extends ManageTodosState {
  const ManageTodosLoading();
}

class ManageTodosLoaded extends ManageTodosState {
  final Map<String, List<TodoDto>> todosByStatus;
  final Map<String, int> currentPageByStatus;
  final Map<String, bool> hasMoreByStatus;
  final Map<String, bool> isLoadingMoreByStatus;
  final int? currentProjectId;

  const ManageTodosLoaded({
    required this.todosByStatus,
    required this.currentPageByStatus,
    required this.hasMoreByStatus,
    this.isLoadingMoreByStatus = const {},
    this.currentProjectId,
  });

  @override
  List<Object?> get props => [
        todosByStatus,
        currentPageByStatus,
        hasMoreByStatus,
        isLoadingMoreByStatus,
        currentProjectId,
      ];

  ManageTodosLoaded copyWith({
    Map<String, List<TodoDto>>? todosByStatus,
    Map<String, int>? currentPageByStatus,
    Map<String, bool>? hasMoreByStatus,
    Map<String, bool>? isLoadingMoreByStatus,
    int? currentProjectId,
  }) {
    return ManageTodosLoaded(
      todosByStatus: todosByStatus ?? this.todosByStatus,
      currentPageByStatus: currentPageByStatus ?? this.currentPageByStatus,
      hasMoreByStatus: hasMoreByStatus ?? this.hasMoreByStatus,
      isLoadingMoreByStatus:
          isLoadingMoreByStatus ?? this.isLoadingMoreByStatus,
      currentProjectId: currentProjectId ?? this.currentProjectId,
    );
  }
}

class ManageTodosError extends ManageTodosState {
  final String message;

  const ManageTodosError(this.message);

  @override
  List<Object?> get props => [message];
}

class TodoDeleting extends ManageTodosState {
  final int todoId;

  const TodoDeleting(this.todoId);

  @override
  List<Object?> get props => [todoId];
}

class TodoStatusUpdating extends ManageTodosState {
  final int todoId;
  final String newStatus;

  const TodoStatusUpdating({
    required this.todoId,
    required this.newStatus,
  });

  @override
  List<Object?> get props => [todoId, newStatus];
}
