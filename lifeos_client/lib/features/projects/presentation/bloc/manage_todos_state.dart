import 'package:equatable/equatable.dart';
import 'package:lifeos_client/features/projects/data/models/todo_dto.dart';

abstract class ManageTodosState extends Equatable {
  const ManageTodosState();

  @override
  List<Object?> get props => [];
}

class ManageTodosWithData extends ManageTodosState {
  final Map<String, List<TodoDto>> todosByStatus;
  final Map<String, int> currentPageByStatus;
  final Map<String, bool> hasMoreByStatus;
  final Map<String, bool> isLoadingMoreByStatus;
  final Map<String, int> countsByStatus;
  final int? currentProjectId;

  const ManageTodosWithData({
    required this.todosByStatus,
    required this.currentPageByStatus,
    required this.hasMoreByStatus,
    this.isLoadingMoreByStatus = const {},
    this.countsByStatus = const {},
    this.currentProjectId,
  });

  @override
  List<Object?> get props => [
        todosByStatus,
        currentPageByStatus,
        hasMoreByStatus,
        isLoadingMoreByStatus,
        countsByStatus,
        currentProjectId,
      ];
}

class ManageTodosInitial extends ManageTodosState {
  const ManageTodosInitial();
}

class ManageTodosLoading extends ManageTodosWithData {
  const ManageTodosLoading({
    required super.todosByStatus,
    required super.currentPageByStatus,
    required super.hasMoreByStatus,
    super.isLoadingMoreByStatus = const {},
    super.countsByStatus = const {},
    super.currentProjectId,
  });
}

class ManageTodosLoaded extends ManageTodosWithData {
  const ManageTodosLoaded({
    required super.todosByStatus,
    required super.currentPageByStatus,
    required super.hasMoreByStatus,
    super.isLoadingMoreByStatus = const {},
    super.countsByStatus = const {},
    super.currentProjectId,
  });

  ManageTodosLoaded copyWith({
    Map<String, List<TodoDto>>? todosByStatus,
    Map<String, int>? currentPageByStatus,
    Map<String, bool>? hasMoreByStatus,
    Map<String, bool>? isLoadingMoreByStatus,
    Map<String, int>? countsByStatus,
    int? currentProjectId,
  }) {
    return ManageTodosLoaded(
      todosByStatus: todosByStatus ?? this.todosByStatus,
      currentPageByStatus: currentPageByStatus ?? this.currentPageByStatus,
      hasMoreByStatus: hasMoreByStatus ?? this.hasMoreByStatus,
      isLoadingMoreByStatus:
          isLoadingMoreByStatus ?? this.isLoadingMoreByStatus,
      countsByStatus: countsByStatus ?? this.countsByStatus,
      currentProjectId: currentProjectId ?? this.currentProjectId,
    );
  }
}

class ManageTodosError extends ManageTodosWithData {
  final String message;

  const ManageTodosError({
    required this.message,
    required super.todosByStatus,
    required super.currentPageByStatus,
    required super.hasMoreByStatus,
    super.isLoadingMoreByStatus = const {},
    super.countsByStatus = const {},
    super.currentProjectId,
  });

  @override
  List<Object?> get props => [
        message,
        todosByStatus,
        currentPageByStatus,
        hasMoreByStatus,
        isLoadingMoreByStatus,
        countsByStatus,
        currentProjectId,
      ];
}

class TodoDeleting extends ManageTodosWithData {
  final int todoId;

  const TodoDeleting({
    required this.todoId,
    required super.todosByStatus,
    required super.currentPageByStatus,
    required super.hasMoreByStatus,
    super.isLoadingMoreByStatus = const {},
    super.countsByStatus = const {},
    super.currentProjectId,
  });

  @override
  List<Object?> get props => [
        todoId,
        todosByStatus,
        currentPageByStatus,
        hasMoreByStatus,
        isLoadingMoreByStatus,
        countsByStatus,
        currentProjectId,
      ];
}

class TodoStatusUpdating extends ManageTodosWithData {
  final int todoId;
  final String newStatus;

  const TodoStatusUpdating({
    required this.todoId,
    required this.newStatus,
    required super.todosByStatus,
    required super.currentPageByStatus,
    required super.hasMoreByStatus,
    super.isLoadingMoreByStatus = const {},
    super.countsByStatus = const {},
    super.currentProjectId,
  });

  @override
  List<Object?> get props => [
        todoId,
        newStatus,
        todosByStatus,
        currentPageByStatus,
        hasMoreByStatus,
        isLoadingMoreByStatus,
        countsByStatus,
        currentProjectId,
      ];
}
