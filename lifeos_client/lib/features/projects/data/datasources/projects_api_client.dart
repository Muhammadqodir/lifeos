import 'package:dio/dio.dart';
import '../models/project_dto.dart';
import '../models/todo_dto.dart';
import '../models/create_todo_dto.dart';

class ProjectsApiClient {
  final Dio dio;

  ProjectsApiClient({required this.dio});

  /// Get all projects
  Future<List<ProjectDto>> getProjects({
    String? search,
    int? perPage,
  }) async {
    final response = await dio.get(
      '/projects',
      queryParameters: {
        if (search != null) 'search': search,
        if (perPage != null) 'per_page': perPage,
      },
    );

    final data = response.data['data'] as List;
    return data.map((json) => ProjectDto.fromJson(json)).toList();
  }

  /// Get project by ID
  Future<ProjectDto> getProject(int id) async {
    final response = await dio.get('/projects/$id');
    return ProjectDto.fromJson(response.data['data']);
  }

  /// Create a new project
  Future<ProjectDto> createProject(Map<String, dynamic> data) async {
    final response = await dio.post(
      '/projects',
      data: data,
    );
    return ProjectDto.fromJson(response.data['data']);
  }

  /// Create a new project with FormData (for file uploads)
  Future<ProjectDto> createProjectWithFormData(FormData formData) async {
    final response = await dio.post(
      '/projects',
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
      ),
    );
    
    // Debug: Print the actual response
    print('Response status: ${response.statusCode}');
    print('Response data: ${response.data}');
    
    // Check if response has data
    if (response.data == null) {
      throw Exception('Empty response from server');
    }
    
    // Handle both direct object and wrapped data response
    final data = response.data is Map && response.data.containsKey('data')
        ? response.data['data']
        : response.data;
    
    if (data == null) {
      throw Exception('No data in response');
    }
    
    
    return ProjectDto.fromJson(data as Map<String, dynamic>);
  }

  /// Update a project
  Future<ProjectDto> updateProject(int id, Map<String, dynamic> data) async {
    final response = await dio.put(
      '/projects/$id',
      data: data,
    );
    return ProjectDto.fromJson(response.data['data']);
  }

  /// Delete a project
  Future<void> deleteProject(int id) async {
    await dio.delete('/projects/$id');
  }

  // ==================== TODO METHODS ====================

  /// Get all todos with optional filters
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
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      'order_by': orderBy,
      'order_direction': orderDirection,
    };

    if (projectId != null) queryParams['project_id'] = projectId;
    if (status != null) queryParams['status'] = status;
    if (tag != null) queryParams['tag'] = tag;
    if (plannedFrom != null) {
      queryParams['planned_from'] = plannedFrom.toIso8601String();
    }
    if (plannedTo != null) {
      queryParams['planned_to'] = plannedTo.toIso8601String();
    }
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final response = await dio.get(
      '/todos',
      queryParameters: queryParams,
    );

    final data = response.data['data'] as List<dynamic>;
    return data.map((json) => TodoDto.fromJson(json)).toList();
  }

  /// Create a new todo
  Future<TodoDto> createTodo(CreateTodoDto todo) async {
    try {
      final response = await dio.post(
        '/todos',
        data: todo.toJson(),
      );

      print('=== CREATE TODO API RESPONSE ===');
      print('Response data: ${response.data}');
      print('Response status: ${response.statusCode}');
      print('================================');

      // Handle both direct object and wrapped data response
      final data = response.data is Map && response.data.containsKey('data')
          ? response.data['data']
          : response.data;
      
      if (data == null) {
        throw Exception('No data in response');
      }

      return TodoDto.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      print('=== DIO ERROR ===');
      print('Status: ${e.response?.statusCode}');
      print('Data: ${e.response?.data}');
      print('=================');
      
      // Handle validation errors (422)
      if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'] as Map<String, dynamic>?;
        if (errors != null) {
          // Combine all error messages
          final errorMessages = errors.values
              .expand((error) => error as List)
              .join('\n');
          throw Exception(errorMessages);
        }
        throw Exception(e.response?.data['message'] ?? 'Validation failed');
      }
      
      // Handle other HTTP errors
      if (e.response?.data != null && e.response?.data is Map) {
        final message = e.response?.data['message'];
        if (message != null) {
          throw Exception(message);
        }
      }
      
      throw Exception(e.message ?? 'Failed to create todo');
    }
  }

  /// Get a single todo by ID
  Future<TodoDto> getTodo(int id) async {
    final response = await dio.get('/todos/$id');
    return TodoDto.fromJson(response.data['data']);
  }

  /// Update a todo
  Future<TodoDto> updateTodo(int id, Map<String, dynamic> data) async {
    final response = await dio.put(
      '/todos/$id',
      data: data,
    );

    return TodoDto.fromJson(response.data['data']);
  }

  /// Update todo status only
  Future<TodoDto> updateTodoStatus(int id, String status) async {
    final response = await dio.patch(
      '/todos/$id/status',
      data: {'status': status},
    );

    return TodoDto.fromJson(response.data['data']);
  }

  /// Delete a todo
  Future<void> deleteTodo(int id) async {
    await dio.delete('/todos/$id');
  }
}
