import 'package:equatable/equatable.dart';

class ProjectDto extends Equatable {
  final int id;
  final String title;
  final String? description;
  final String color;
  final String? icon;
  final List<String> tags;
  final int pendingTodosCount;
  final int completedTodosCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProjectDto({
    required this.id,
    required this.title,
    this.description,
    required this.color,
    this.icon,
    required this.tags,
    required this.pendingTodosCount,
    required this.completedTodosCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProjectDto.fromJson(Map<String, dynamic> json) {
    return ProjectDto(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      color: json['color'] as String,
      icon: json['icon'] as String?,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      pendingTodosCount: json['pending_todos_count'] as int? ?? 0,
      completedTodosCount: json['completed_todos_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'color': color,
      'icon': icon,
      'tags': tags,
      'pending_todos_count': pendingTodosCount,
      'completed_todos_count': completedTodosCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        color,
        icon,
        tags,
        pendingTodosCount,
        completedTodosCount,
        createdAt,
        updatedAt,
      ];
}
