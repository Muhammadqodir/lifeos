import 'package:dio/dio.dart';
import '../../domain/repositories/projects_repository.dart';
import '../datasources/projects_api_client.dart';
import '../models/project_dto.dart';

class ProjectsRepositoryImpl implements ProjectsRepository {
  final ProjectsApiClient apiClient;

  ProjectsRepositoryImpl({required this.apiClient});

  @override
  Future<List<ProjectDto>> getProjects({String? search, int? perPage}) async {
    return await apiClient.getProjects(search: search, perPage: perPage);
  }

  @override
  Future<ProjectDto> getProject(int id) async {
    return await apiClient.getProject(id);
  }

  @override
  Future<ProjectDto> createProject(Map<String, dynamic> data) async {
    return await apiClient.createProject(data);
  }

  @override
  Future<ProjectDto> createProjectWithFormData(FormData formData) async {
    return await apiClient.createProjectWithFormData(formData);
  }

  @override
  Future<ProjectDto> updateProject(int id, Map<String, dynamic> data) async {
    return await apiClient.updateProject(id, data);
  }

  @override
  Future<void> deleteProject(int id) async {
    return await apiClient.deleteProject(id);
  }
}
