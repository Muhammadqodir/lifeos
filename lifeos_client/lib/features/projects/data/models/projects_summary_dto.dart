import 'package:equatable/equatable.dart';

class ProjectsSummaryDto extends Equatable {
  final int totalProjects;
  final int activeTodos;
  final int completedTodos;

  const ProjectsSummaryDto({
    required this.totalProjects,
    required this.activeTodos,
    required this.completedTodos,
  });

  factory ProjectsSummaryDto.fromJson(Map<String, dynamic> json) {
    return ProjectsSummaryDto(
      totalProjects: json['total_projects'] as int? ?? 0,
      activeTodos: json['active_todos'] as int? ?? 0,
      completedTodos: json['completed_todos'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_projects': totalProjects,
      'active_todos': activeTodos,
      'completed_todos': completedTodos,
    };
  }

  @override
  List<Object?> get props => [totalProjects, activeTodos, completedTodos];
}
