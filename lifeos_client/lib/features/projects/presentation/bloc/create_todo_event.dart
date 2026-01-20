import 'package:equatable/equatable.dart';

abstract class CreateTodoEvent extends Equatable {
  const CreateTodoEvent();

  @override
  List<Object?> get props => [];
}

class TitleChanged extends CreateTodoEvent {
  final String title;

  const TitleChanged(this.title);

  @override
  List<Object?> get props => [title];
}

class CommentChanged extends CreateTodoEvent {
  final String comment;

  const CommentChanged(this.comment);

  @override
  List<Object?> get props => [comment];
}

class StatusChanged extends CreateTodoEvent {
  final String status;

  const StatusChanged(this.status);

  @override
  List<Object?> get props => [status];
}

class PriorityChanged extends CreateTodoEvent {
  final String priority;

  const PriorityChanged(this.priority);

  @override
  List<Object?> get props => [priority];
}

class UrgencyChanged extends CreateTodoEvent {
  final String urgency;

  const UrgencyChanged(this.urgency);

  @override
  List<Object?> get props => [urgency];
}

class EnergyChanged extends CreateTodoEvent {
  final String energy;

  const EnergyChanged(this.energy);

  @override
  List<Object?> get props => [energy];
}

class PlannedDateChanged extends CreateTodoEvent {
  final DateTime? plannedDate;

  const PlannedDateChanged(this.plannedDate);

  @override
  List<Object?> get props => [plannedDate];
}

class PlannedTimeChanged extends CreateTodoEvent {
  final String? plannedTime;

  const PlannedTimeChanged(this.plannedTime);

  @override
  List<Object?> get props => [plannedTime];
}

class TagsChanged extends CreateTodoEvent {
  final List<String> tags;

  const TagsChanged(this.tags);

  @override
  List<Object?> get props => [tags];
}

class SubmitTodo extends CreateTodoEvent {
  final int projectId;

  const SubmitTodo(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

class ResetForm extends CreateTodoEvent {
  const ResetForm();
}
