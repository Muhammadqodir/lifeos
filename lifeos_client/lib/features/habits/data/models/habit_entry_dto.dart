import 'package:equatable/equatable.dart';
import 'package:lifeos_client/features/habits/data/models/habit_dto.dart';

class HabitEntryDto extends Equatable {
  final int id;
  final int habitId;
  final HabitDto? habit;
  final String date;
  final String completedAt;
  final String? note;
  final String createdAt;
  final String updatedAt;

  const HabitEntryDto({
    required this.id,
    required this.habitId,
    this.habit,
    required this.date,
    required this.completedAt,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HabitEntryDto.fromJson(Map<String, dynamic> json) {
    return HabitEntryDto(
      id: json['id'] as int,
      habitId: json['habit_id'] as int,
      habit: json['habit'] != null
          ? HabitDto.fromJson(json['habit'] as Map<String, dynamic>)
          : null,
      date: json['date'] as String,
      completedAt: json['completed_at'] as String,
      note: json['note'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habit_id': habitId,
      if (habit != null) 'habit': habit!.toJson(),
      'date': date,
      'completed_at': completedAt,
      'note': note,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
        id,
        habitId,
        habit,
        date,
        completedAt,
        note,
        createdAt,
        updatedAt,
      ];
}
