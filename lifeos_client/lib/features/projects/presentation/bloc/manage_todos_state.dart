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

/// A project's todos grouped by status, straight from the local store.
class ManageTodosWithData extends ManageTodosState {
  final Map<String, List<TodoDto>> todosByStatus;
  final String? currentProjectId;

  const ManageTodosWithData({
    required this.todosByStatus,
    this.currentProjectId,
  });

  Map<String, int> get countsByStatus => {
    for (final entry in todosByStatus.entries) entry.key: entry.value.length,
  };

  @override
  List<Object?> get props => [todosByStatus, currentProjectId];
}

class ManageTodosLoaded extends ManageTodosWithData {
  const ManageTodosLoaded({
    required super.todosByStatus,
    super.currentProjectId,
  });
}

/// A change could not be saved on the device.
class ManageTodosError extends ManageTodosWithData {
  final String message;

  const ManageTodosError({
    required this.message,
    required super.todosByStatus,
    super.currentProjectId,
  });

  @override
  List<Object?> get props => [message, ...super.props];
}
