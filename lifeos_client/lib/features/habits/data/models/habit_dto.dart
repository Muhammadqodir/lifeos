import 'package:equatable/equatable.dart';

class HabitDto extends Equatable {
  final int id;
  final String title;
  final String? description;
  final String color;
  final String? icon;
  final String? status;
  final String frequency;
  final List<int> frequencyDays;
  final String? reminderTime;
  final int? goalDuration;
  final List<String> tags;
  final int? currentStreak;
  final int? longestStreak;
  final double? completionRate;
  final bool? isCompletedToday;
  final String createdAt;
  final String updatedAt;

  const HabitDto({
    required this.id,
    required this.title,
    this.description,
    required this.color,
    this.icon,
    this.status,
    required this.frequency,
    this.frequencyDays = const [],
    this.reminderTime,
    this.goalDuration,
    this.tags = const [],
    this.currentStreak,
    this.longestStreak,
    this.completionRate,
    this.isCompletedToday,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HabitDto.fromJson(Map<String, dynamic> json) {
    return HabitDto(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      color: json['color'] as String,
      icon: json['icon'] as String?,
      status: json['status'] as String?,
      frequency: json['frequency'] as String,
      frequencyDays: json['frequency_days'] != null
          ? List<int>.from(json['frequency_days'] as List)
          : [],
      reminderTime: json['reminder_time'] as String?,
      goalDuration: json['goal_duration'] as int?,
      tags: json['tags'] != null ? List<String>.from(json['tags'] as List) : [],
      currentStreak: json['current_streak'] as int?,
      longestStreak: json['longest_streak'] as int?,
      completionRate: json['completion_rate'] != null
          ? (json['completion_rate'] as num).toDouble()
          : null,
      isCompletedToday: json['is_completed_today'] as bool?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'color': color,
      'icon': icon,
      'status': status,
      'frequency': frequency,
      'frequency_days': frequencyDays,
      'reminder_time': reminderTime,
      'goal_duration': goalDuration,
      'tags': tags,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'completion_rate': completionRate,
      'is_completed_today': isCompletedToday,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  @override
  List<Object?> get props => [
        id,
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
        currentStreak,
        longestStreak,
        completionRate,
        isCompletedToday,
        createdAt,
        updatedAt,
      ];
}
