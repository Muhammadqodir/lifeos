import 'package:lifeos_client/features/projects/data/datasources/projects_api_client.dart';
import 'package:lifeos_client/features/projects/data/models/create_todo_dto.dart';
import 'package:lifeos_client/features/projects/data/models/todo_dto.dart';
import 'package:lifeos_client/features/projects/domain/repositories/todos_repository.dart';

class TodosRepositoryImpl implements TodosRepository {
  final ProjectsApiClient _apiClient;

  TodosRepositoryImpl(this._apiClient);

  @override
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
  }) async {
    return _apiClient.getTodos(
      projectId: projectId,
      status: status,
      tag: tag,
      plannedFrom: plannedFrom,
      plannedTo: plannedTo,
      search: search,
      orderBy: orderBy,
      orderDirection: orderDirection,
      page: page,
      perPage: perPage,
    );
  }

  @override
  Future<TodoDto> createTodo(CreateTodoDto todo) async {
    return _apiClient.createTodo(todo);
  }

  @override
  Future<TodoDto> getTodo(int id) async {
    return _apiClient.getTodo(id);
  }

  @override
  Future<TodoDto> updateTodo(int id, Map<String, dynamic> data) async {
    return _apiClient.updateTodo(id, data);
  }

  @override
  Future<TodoDto> updateTodoStatus(
    int id,
    String status, {
    DateTime? plannedDate,
  }) async {
    return _apiClient.updateTodoStatus(id, status, plannedDate: plannedDate);
  }

  @override
  Future<void> deleteTodo(int id) async {
    return _apiClient.deleteTodo(id);
  }

  @override
  Future<Map<String, int>> getTodoCountsByStatus(int projectId) async {
    return _apiClient.getTodoCountsByStatus(projectId);
  }
}
