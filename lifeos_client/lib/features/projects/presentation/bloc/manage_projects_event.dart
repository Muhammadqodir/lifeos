import 'package:equatable/equatable.dart';

import '../../data/models/project_dto.dart';

abstract class ManageProjectsEvent extends Equatable {
  const ManageProjectsEvent();

  @override
  List<Object?> get props => [];
}

class ManageProjectsLoad extends ManageProjectsEvent {
  const ManageProjectsLoad();
}

class ManageProjectsRefresh extends ManageProjectsEvent {
  const ManageProjectsRefresh();
}

class ManageProjectsDelete extends ManageProjectsEvent {
  final String projectId;

  const ManageProjectsDelete({required this.projectId});

  @override
  List<Object?> get props => [projectId];
}

class ManageProjectsSearch extends ManageProjectsEvent {
  final String? query;

  const ManageProjectsSearch({this.query});

  @override
  List<Object?> get props => [query];
}

/// The local store changed (internal).
class ManageProjectsChanged extends ManageProjectsEvent {
  final List<ProjectDto> projects;

  const ManageProjectsChanged(this.projects);

  @override
  List<Object?> get props => [projects];
}
