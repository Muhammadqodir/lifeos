import '../../../../core/sync/local_store.dart';
import '../../../../core/sync/sync_engine.dart';
import '../../domain/repositories/todos_repository.dart';
import '../models/create_todo_dto.dart';
import '../models/todo_dto.dart';

class TodosRepositoryImpl implements TodosRepository {
  TodosRepositoryImpl({required this.store, required this.sync});

  final LocalStore store;
  final SyncEngine sync;

  static const _watched = {SyncEntities.projects, SyncEntities.todos};

  Future<List<TodoDto>> _read({String? projectId, String? id}) async {
    final projects = {
      for (final p in await store.all(SyncEntities.projects)) p['id']: p,
    };
    final todos = [
      for (final record in await store.all(SyncEntities.todos))
        if ((projectId == null || record['project_id'] == projectId) &&
            (id == null || record['id'] == id))
          TodoDto.fromJson({
            ...record,
            'project': projects[record['project_id']],
          }),
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return todos;
  }

  @override
  Stream<List<TodoDto>> watchTodos({String? projectId}) =>
      store.watch(_watched, () => _read(projectId: projectId));

  @override
  Stream<TodoDto?> watchTodo(String id) =>
      store.watch(_watched, () async => (await _read(id: id)).firstOrNull);

  @override
  Future<TodoDto> createTodo(CreateTodoDto todo) async {
    final data = {
      ...todo.toJson(),
      'status': todo.plannedDate == null ? 'inbox' : 'planned',
    };
    final record = await sync.create(SyncEntities.todos, data);
    return (await _read(id: record['id'] as String)).first;
  }

  @override
  Future<void> updateTodo(String id, Map<String, dynamic> changes) =>
      sync.update(SyncEntities.todos, id, changes);

  @override
  Future<void> updateTodoStatus(
    String id,
    String status, {
    DateTime? plannedDate,
  }) async {
    final current = await store.get(SyncEntities.todos, id);
    if (current == null) return;
    await sync.update(SyncEntities.todos, id, {
      'status': status,
      if (plannedDate != null) 'planned_date': _date(plannedDate),
      // Same rule as the backend's Todo model.
      'completed_at': status == 'done'
          ? (current['completed_at'] ??
                DateTime.now().toUtc().toIso8601String())
          : null,
    });
  }

  @override
  Future<void> deleteTodo(String id) => sync.delete(SyncEntities.todos, id);

  static String _date(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';
}
