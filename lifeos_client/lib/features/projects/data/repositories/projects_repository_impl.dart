import 'package:image_picker/image_picker.dart';

import '../../../../core/network/api_exception.dart';
import '../../../../core/sync/local_store.dart';
import '../../../../core/sync/pending_uploads.dart';
import '../../../../core/sync/sync_engine.dart';
import '../../domain/repositories/projects_repository.dart';
import '../datasources/projects_api_client.dart';
import '../models/project_dto.dart';

class ProjectsRepositoryImpl implements ProjectsRepository {
  ProjectsRepositoryImpl({
    required this.store,
    required this.sync,
    required this.apiClient,
    required this.uploads,
  }) {
    uploads.register(
      _iconUpload,
      (serverId, path) => apiClient.uploadProjectIcon(serverId, XFile(path)),
    );
  }

  final LocalStore store;
  final SyncEngine sync;

  /// Only for the icon upload; files don't go through sync.
  final ProjectsApiClient apiClient;
  final PendingUploads uploads;

  static const _iconUpload = 'project_icon';

  static const _watched = {SyncEntities.projects, SyncEntities.todos};

  Future<List<ProjectDto>> _read({String? search}) async {
    final todos = await store.all(SyncEntities.todos);
    final pending = <String, int>{};
    final completed = <String, int>{};
    for (final todo in todos) {
      final projectId = todo['project_id'] as String?;
      if (projectId == null) continue;
      final counts = todo['status'] == 'done' ? completed : pending;
      counts[projectId] = (counts[projectId] ?? 0) + 1;
    }

    final query = search?.trim().toLowerCase() ?? '';
    final projects = [
      for (final record in await store.all(SyncEntities.projects))
        if (query.isEmpty ||
            (record['title'] as String).toLowerCase().contains(query))
          ProjectDto.fromJson(record).withCounts(
            pending: pending[record['id']] ?? 0,
            completed: completed[record['id']] ?? 0,
          ),
    ]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return projects;
  }

  @override
  Stream<List<ProjectDto>> watchProjects({String? search}) =>
      store.watch(_watched, () => _read(search: search));

  @override
  Stream<ProjectDto?> watchProject(String id) => store.watch(
    _watched,
    () async => (await _read()).where((p) => p.id == id).firstOrNull,
  );

  @override
  Future<ProjectDto> createProject({
    required String title,
    required String color,
    String? description,
    List<String> tags = const [],
    XFile? icon,
  }) async {
    // The server enforces this too; checking here gives the answer offline.
    final taken = (await store.all(SyncEntities.projects)).any(
      (p) => (p['title'] as String).toLowerCase() == title.trim().toLowerCase(),
    );
    if (taken) {
      throw const ApiException(
        'A project with this title already exists.',
        code: 'validation_failed',
      );
    }
    final record = await sync.create(SyncEntities.projects, {
      'title': title.trim(),
      'color': color,
      'description': (description?.isEmpty ?? true) ? null : description,
      'tags': [for (final t in tags) t.trim().toLowerCase()],
    });
    if (icon != null) {
      await uploads.add(
        kind: _iconUpload,
        entity: SyncEntities.projects,
        id: record['id'] as String,
        path: icon.path,
      );
    }
    return ProjectDto.fromJson(record);
  }

  @override
  Future<void> updateProject(String id, Map<String, dynamic> changes) =>
      sync.update(SyncEntities.projects, id, changes);

  @override
  Future<void> deleteProject(String id) =>
      sync.delete(SyncEntities.projects, id);
}
