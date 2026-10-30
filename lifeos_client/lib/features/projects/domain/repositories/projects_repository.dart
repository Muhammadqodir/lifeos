import 'package:image_picker/image_picker.dart';

import '../../data/models/project_dto.dart';

/// Projects, read from and written to the device (local-first). Writes
/// return as soon as they are stored; sync sends them to the server.
abstract class ProjectsRepository {
  /// All projects, newest first, with todo counts; re-emits on any change.
  Stream<List<ProjectDto>> watchProjects({String? search});

  Stream<ProjectDto?> watchProject(String id);

  Future<ProjectDto> createProject({
    required String title,
    required String color,
    String? description,
    List<String> tags = const [],
    XFile? icon,
  });

  Future<void> updateProject(String id, Map<String, dynamic> changes);

  /// Deletes the project and its todos.
  Future<void> deleteProject(String id);
}
