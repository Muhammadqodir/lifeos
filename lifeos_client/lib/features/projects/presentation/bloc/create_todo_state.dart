import 'package:equatable/equatable.dart';
import 'package:lifeos_client/features/projects/data/models/todo_dto.dart';

abstract class CreateTodoState extends Equatable {
  const CreateTodoState();

  @override
  List<Object?> get props => [];
}

class CreateTodoInitial extends CreateTodoState {
  final String title;
  final String comment;
  final String priority;
  final String urgency;
  final String energy;
  final DateTime? plannedDate;
  final String? plannedTime; // HH:mm format for display
  final List<String> tags;
  final String? titleError;

  const CreateTodoInitial({
    this.title = '',
    this.comment = '',
    this.priority = 'middle',
    this.urgency = 'middle',
    this.energy = 'medium',
    this.plannedDate,
    this.plannedTime,
    this.tags = const [],
    this.titleError,
  });

  CreateTodoInitial copyWith({
    String? title,
    String? comment,
    String? priority,
    String? urgency,
    String? energy,
    DateTime? plannedDate,
    String? plannedTime,
    List<String>? tags,
    String? titleError,
    bool clearPlannedDate = false,
    bool clearPlannedTime = false,
    bool clearTitleError = false,
  }) {
    return CreateTodoInitial(
      title: title ?? this.title,
      comment: comment ?? this.comment,
      priority: priority ?? this.priority,
      urgency: urgency ?? this.urgency,
      energy: energy ?? this.energy,
      plannedDate: clearPlannedDate ? null : (plannedDate ?? this.plannedDate),
      plannedTime: clearPlannedTime ? null : (plannedTime ?? this.plannedTime),
      tags: tags ?? this.tags,
      titleError: clearTitleError ? null : (titleError ?? this.titleError),
    );
  }

  @override
  List<Object?> get props => [
        title,
        comment,
        priority,
        urgency,
        energy,
        plannedDate,
        plannedTime,
        tags,
        titleError,
      ];
}

class CreateTodoSubmitting extends CreateTodoState {
  const CreateTodoSubmitting();
}

class CreateTodoSuccess extends CreateTodoState {
  final TodoDto todo;

  const CreateTodoSuccess(this.todo);

  @override
  List<Object?> get props => [todo];
}

class CreateTodoError extends CreateTodoState {
  final String message;

  const CreateTodoError(this.message);

  @override
  List<Object?> get props => [message];
}
