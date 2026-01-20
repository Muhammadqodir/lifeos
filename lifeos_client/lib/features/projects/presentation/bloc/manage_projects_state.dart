import 'package:equatable/equatable.dart';
import '../../data/models/project_dto.dart';

abstract class ManageProjectsState extends Equatable {
  const ManageProjectsState();

  @override
  List<Object?> get props => [];
}

class ManageProjectsWithData extends ManageProjectsState {
  final List<ProjectDto> projects;

  const ManageProjectsWithData({required this.projects});
}

class ManageProjectsInitial extends ManageProjectsState {
  const ManageProjectsInitial();
}

class ManageProjectsLoading extends ManageProjectsState {
  const ManageProjectsLoading();
}

class ManageProjectsLoaded extends ManageProjectsWithData {
  const ManageProjectsLoaded({required super.projects});

  @override
  List<Object?> get props => [projects];
}

class ManageProjectsError extends ManageProjectsState {
  final String message;

  const ManageProjectsError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ManageProjectsDeleting extends ManageProjectsWithData {
  final int projectId;

  const ManageProjectsDeleting({
    required this.projectId,
    required super.projects,
  });

  @override
  List<Object?> get props => [projectId, projects];
}

class ManageProjectsDeleteSuccess extends ManageProjectsWithData {
  const ManageProjectsDeleteSuccess({required super.projects});

  @override
  List<Object?> get props => [projects];
}

class ManageProjectsDeleteError extends ManageProjectsWithData {
  final String message;

  const ManageProjectsDeleteError({
    required this.message,
    required super.projects,
  });

  @override
  List<Object?> get props => [message, projects];
}
