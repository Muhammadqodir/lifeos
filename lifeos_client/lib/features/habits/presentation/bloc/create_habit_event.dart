import 'package:equatable/equatable.dart';

abstract class CreateHabitEvent extends Equatable {
  const CreateHabitEvent();

  @override
  List<Object?> get props => [];
}

class CreateHabitSubmitted extends CreateHabitEvent {
  final String title;
  final String? description;
  final String? color;
  final String? icon;
  final String? status;
  final String frequency;
  final List<int>? frequencyDays;
  final String? reminderTime;
  final int? goalDuration;
  final List<String>? tags;

  const CreateHabitSubmitted({
    required this.title,
    this.description,
    this.color,
    this.icon,
    this.status,
    required this.frequency,
    this.frequencyDays,
    this.reminderTime,
    this.goalDuration,
    this.tags,
  });

  @override
  List<Object?> get props => [
        title,
        description,
        color,
        icon,
        status,
        frequency,
        frequencyDays,
        reminderTime,
        goalDuration,
        tags,
      ];
}

class UpdateHabitSubmitted extends CreateHabitEvent {
  final int habitId;
  final String? title;
  final String? description;
  final String? color;
  final String? icon;
  final String? status;
  final String? frequency;
  final List<int>? frequencyDays;
  final String? reminderTime;
  final int? goalDuration;
  final List<String>? tags;

  const UpdateHabitSubmitted({
    required this.habitId,
    this.title,
    this.description,
    this.color,
    this.icon,
    this.status,
    this.frequency,
    this.frequencyDays,
    this.reminderTime,
    this.goalDuration,
    this.tags,
  });

  @override
  List<Object?> get props => [
        habitId,
        title,
        description,
        color,
        icon,
        status,
        frequency,
        frequencyDays,
        reminderTime,
        goalDuration,
        tags,
      ];
}
