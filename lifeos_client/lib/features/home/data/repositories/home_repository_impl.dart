import 'package:lifeos_client/core/utils/streams.dart';
import 'package:lifeos_client/features/habits/data/models/habit_dto.dart';
import 'package:lifeos_client/features/habits/domain/repositories/habits_repository.dart';
import 'package:lifeos_client/features/home/domain/repositories/home_repository.dart';
import 'package:lifeos_client/features/projects/data/models/todo_dto.dart';
import 'package:lifeos_client/features/projects/domain/repositories/todos_repository.dart';

/// Home's lists, filtered on the device. No requests: the sync engine keeps
/// the local store current, so this replaces the five calls Home used to
/// make (and the "home/today" endpoint it would otherwise need).
class HomeRepositoryImpl implements HomeRepository {
  final TodosRepository todosRepository;
  final HabitsRepository habitsRepository;

  /// How many inbox / in-progress todos Home lists.
  static const shortListLimit = 5;

  HomeRepositoryImpl({
    required this.todosRepository,
    required this.habitsRepository,
  });

  @override
  Stream<HomeSnapshot> watchToday() => combineLatest2(
    todosRepository.watchTodos(),
    habitsRepository.watchHabits(),
    _snapshot,
  );

  static HomeSnapshot _snapshot(List<TodoDto> todos, List<HabitDto> habits) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    DateTime? day(TodoDto t) => t.plannedDate == null
        ? null
        : DateTime(
            t.plannedDate!.year,
            t.plannedDate!.month,
            t.plannedDate!.day,
          );
    int byPlan(TodoDto a, TodoDto b) {
      final date = day(a)!.compareTo(day(b)!);
      return date != 0
          ? date
          : (a.plannedTime ?? '').compareTo(b.plannedTime ?? '');
    }

    final planned = todos.where((t) => t.status == 'planned' && day(t) != null);
    return HomeSnapshot(
      todosToday: planned.where((t) => day(t) == today).toList()..sort(byPlan),
      overdueTodos: planned.where((t) => day(t)!.isBefore(today)).toList()
        ..sort(byPlan),
      // Already newest first.
      inboxTodos: todos
          .where((t) => t.status == 'inbox')
          .take(shortListLimit)
          .toList(),
      inProgressTodos:
          (todos.where((t) => t.status == 'in_progress').toList()
                ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt)))
              .take(shortListLimit)
              .toList(),
      habitsToday: habits,
    );
  }
}
