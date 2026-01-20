import 'package:equatable/equatable.dart';

class TodoDto extends Equatable {
  final int id;
  final int projectId;
  final String title;
  final String? comment;
  final String status; // inbox, planned, in_progress, blocked, done
  final String priority; // low, middle, high
  final String urgency; // low, middle, high
  final String energy; // easy, medium, hard
  final int? timeSpentMinutes;
  final DateTime? plannedDate;
  final String? plannedTime; // HH:mm:ss format
  final DateTime? completedAt;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TodoDto({
    required this.id,
    required this.projectId,
    required this.title,
    this.comment,
    required this.status,
    required this.priority,
    required this.urgency,
    required this.energy,
    this.timeSpentMinutes,
    this.plannedDate,
    this.plannedTime,
    this.completedAt,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TodoDto.fromJson(Map<String, dynamic> json) {
    return TodoDto(
      id: json['id'] as int,
      projectId: json['project_id'] as int,
      title: json['title'] as String,
      comment: json['comment'] as String?,
      status: json['status'] as String,
      priority: json['priority'] as String,
      urgency: json['urgency'] as String,
      energy: json['energy'] as String,
      timeSpentMinutes: json['time_spent_minutes'] as int?,
      plannedDate: json['planned_date'] != null
          ? DateTime.parse(json['planned_date'] as String)
          : null,
      plannedTime: json['planned_time'] as String?,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'title': title,
      'comment': comment,
      'status': status,
      'priority': priority,
      'urgency': urgency,
      'energy': energy,
      'time_spent_minutes': timeSpentMinutes,
      'planned_date': plannedDate?.toIso8601String().split('T')[0],
      'planned_time': plannedTime,
      'completed_at': completedAt?.toIso8601String(),
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        projectId,
        title,
        comment,
        status,
        priority,
        urgency,
        energy,
        timeSpentMinutes,
        plannedDate,
        plannedTime,
        completedAt,
        tags,
        createdAt,
        updatedAt,
      ];
}
