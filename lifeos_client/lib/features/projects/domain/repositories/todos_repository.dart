import 'package:lifeos_client/features/projects/data/models/create_todo_dto.dart';
import 'package:lifeos_client/features/projects/data/models/todo_dto.dart';

abstract class TodosRepository {
  Future<List<TodoDto>> getTodos({
    int? projectId,
    String? status,
    String? tag,
    DateTime? plannedFrom,
    DateTime? plannedTo,
    String? search,
    String orderBy = 'created_at',
    String orderDirection = 'desc',
    int page = 1,
    int perPage = 15,
  });

  Future<TodoDto> createTodo(CreateTodoDto todo);

  Future<TodoDto> getTodo(int id);

  Future<TodoDto> updateTodo(int id, Map<String, dynamic> data);

  Future<TodoDto> updateTodoStatus(
    int id,
    String status, {
    DateTime? plannedDate,
  });

  Future<void> deleteTodo(int id);

  Future<Map<String, int>> getTodoCountsByStatus(int projectId);
}
