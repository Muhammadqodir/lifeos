import 'package:lifeos_client/features/habits/data/models/habit_dto.dart';
import 'package:lifeos_client/features/habits/domain/repositories/habits_repository.dart';
import 'package:lifeos_client/features/home/domain/repositories/home_repository.dart';
import 'package:lifeos_client/features/projects/data/models/todo_dto.dart';
import 'package:lifeos_client/features/projects/domain/repositories/todos_repository.dart';

/// Implementation of the home repository
class HomeRepositoryImpl implements HomeRepository {
  final TodosRepository todosRepository;
  final HabitsRepository habitsRepository;

  HomeRepositoryImpl({
    required this.todosRepository,
    required this.habitsRepository,
  });

  @override
  Future<List<TodoDto>> getTodosForToday() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = DateTime(today.year, today.month, today.day, 23, 59, 59);

    return await todosRepository.getTodos(
      status: 'planned',
      plannedFrom: startOfDay,
      plannedTo: endOfDay,
      orderBy: 'planned_date',
      orderDirection: 'asc',
      perPage: 50,
    );
  }

  @override
  Future<List<TodoDto>> getInboxTodos({int limit = 5}) async {
    return await todosRepository.getTodos(
      status: 'inbox',
      orderBy: 'created_at',
      orderDirection: 'desc',
      perPage: limit,
    );
  }

  @override
  Future<List<TodoDto>> getInProgressTodos({int limit = 5}) async {
    return await todosRepository.getTodos(
      status: 'in_progress',
      orderBy: 'updated_at',
      orderDirection: 'desc',
      perPage: limit,
    );
  }

  @override
  Future<List<TodoDto>> getOverdueTodos({int limit = 50}) async {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);

    // Get all todos with status 'planned' that have a planned_date before today
    // This will fetch ALL overdue todos (from any past date), not just yesterday
    return await todosRepository.getTodos(
      status: 'planned',
      plannedTo: startOfToday.subtract(const Duration(seconds: 1)),
      orderBy: 'planned_date',
      orderDirection: 'asc', // Oldest first
      perPage: limit,
    );
  }

  @override
  Future<List<HabitDto>> getHabitsForToday() async {
    return await habitsRepository.getHabitsWithTodayStatus();
  }
}
