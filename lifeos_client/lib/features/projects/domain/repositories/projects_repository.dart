import 'package:dio/dio.dart';
import '../../data/models/project_dto.dart';

abstract class ProjectsRepository {
  Future<List<ProjectDto>> getProjects({String? search, int? perPage});
  Future<ProjectDto> getProject(int id);
  Future<ProjectDto> createProject(Map<String, dynamic> data);
  Future<ProjectDto> createProjectWithFormData(FormData formData);
  Future<ProjectDto> updateProject(int id, Map<String, dynamic> data);
  Future<void> deleteProject(int id);
}
