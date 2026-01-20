import 'package:equatable/equatable.dart';

class CreateTodoDto extends Equatable {
  final int projectId;
  final String title;
  final String? comment;
  final String priority;
  final String urgency;
  final String energy;
  final int? timeSpentMinutes;
  final DateTime? plannedDate;
  final String? plannedTime; // HH:mm:ss format
  final List<String> tags;

  const CreateTodoDto({
    required this.projectId,
    required this.title,
    this.comment,
    this.priority = 'middle',
    this.urgency = 'middle',
    this.energy = 'medium',
    this.timeSpentMinutes,
    this.plannedDate,
    this.plannedTime,
    this.tags = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'project_id': projectId,
      'title': title,
      if (comment != null && comment!.isNotEmpty) 'comment': comment,
      'priority': priority,
      'urgency': urgency,
      'energy': energy,
      if (timeSpentMinutes != null) 'time_spent_minutes': timeSpentMinutes,
      if (plannedDate != null)
        'planned_date': plannedDate!.toIso8601String().split('T')[0],
      if (plannedTime != null) 'planned_time': plannedTime,
      if (tags.isNotEmpty) 'tags': tags,
    };
  }

  @override
  List<Object?> get props => [
        projectId,
        title,
        comment,
        priority,
        urgency,
        energy,
        timeSpentMinutes,
        plannedDate,
        plannedTime,
        tags,
      ];
}
