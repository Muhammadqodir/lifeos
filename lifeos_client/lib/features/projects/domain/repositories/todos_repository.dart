import 'package:lifeos_client/features/projects/data/models/create_todo_dto.dart';
import 'package:lifeos_client/features/projects/data/models/todo_dto.dart';

/// Todos, read from and written to the device (local-first). Writes return
/// as soon as they are stored; sync sends them to the server.
abstract class TodosRepository {
  /// Todos (with their project), newest first; re-emits on any change.
  Stream<List<TodoDto>> watchTodos({String? projectId});

  Stream<TodoDto?> watchTodo(String id);

  Future<TodoDto> createTodo(CreateTodoDto todo);

  Future<void> updateTodo(String id, Map<String, dynamic> changes);

  Future<void> updateTodoStatus(
    String id,
    String status, {
    DateTime? plannedDate,
  });

  Future<void> deleteTodo(String id);
}
