import 'package:lifeos_client/features/habits/data/models/habit_dto.dart';
import 'package:lifeos_client/features/projects/data/models/todo_dto.dart';

/// Repository interface for home page data
abstract class HomeRepository {
  /// Get todos for today (planned for today)
  Future<List<TodoDto>> getTodosForToday();

  /// Get inboxed todos (todos with status 'inbox')
  Future<List<TodoDto>> getInboxTodos({int limit = 5});

  /// Get in-progress todos (todos with status 'in_progress')
  Future<List<TodoDto>> getInProgressTodos({int limit = 5});

  /// Get overdue todos (planned for any past date but not completed)
  /// This fetches ALL overdue todos, not just from yesterday
  Future<List<TodoDto>> getOverdueTodos({int limit = 50});

  /// Get habits for today
  Future<List<HabitDto>> getHabitsForToday();
}
