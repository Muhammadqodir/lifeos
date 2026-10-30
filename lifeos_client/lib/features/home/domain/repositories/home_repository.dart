import 'package:lifeos_client/features/habits/data/models/habit_dto.dart';
import 'package:lifeos_client/features/projects/data/models/todo_dto.dart';

/// Everything the Home screen shows, computed from the local store.
class HomeSnapshot {
  const HomeSnapshot({
    required this.todosToday,
    required this.overdueTodos,
    required this.inboxTodos,
    required this.inProgressTodos,
    required this.habitsToday,
  });

  final List<TodoDto> todosToday;
  final List<TodoDto> overdueTodos;
  final List<TodoDto> inboxTodos;
  final List<TodoDto> inProgressTodos;
  final List<HabitDto> habitsToday;

  bool get isEmpty =>
      todosToday.isEmpty &&
      overdueTodos.isEmpty &&
      inboxTodos.isEmpty &&
      inProgressTodos.isEmpty &&
      habitsToday.isEmpty;
}

abstract class HomeRepository {
  /// Re-emits whenever a todo, project, habit or entry changes.
  Stream<HomeSnapshot> watchToday();
}
