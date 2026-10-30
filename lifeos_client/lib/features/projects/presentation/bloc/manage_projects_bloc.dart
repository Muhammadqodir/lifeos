import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/sync/sync_engine.dart';
import '../../domain/repositories/projects_repository.dart';
import 'manage_projects_event.dart';
import 'manage_projects_state.dart';

/// The project list. It follows the local store, so creating, editing or
/// deleting a project anywhere (or a sync bringing changes) updates it.
class ManageProjectsBloc
    extends Bloc<ManageProjectsEvent, ManageProjectsState> {
  final ProjectsRepository projectsRepository;
  final SyncEngine? sync;
  StreamSubscription<void>? _subscription;

  ManageProjectsBloc({required this.projectsRepository, this.sync})
    : super(const ManageProjectsInitial()) {
    on<ManageProjectsLoad>((event, emit) => _watch(null, emit));
    on<ManageProjectsSearch>((event, emit) => _watch(event.query, emit));

    on<ManageProjectsRefresh>((event, emit) => sync?.syncNow());
    on<ManageProjectsChanged>(
      (event, emit) => emit(ManageProjectsLoaded(projects: event.projects)),
    );
    on<ManageProjectsDelete>(_onDelete);
  }

  Future<void> _watch(String? search, Emitter<ManageProjectsState> emit) async {
    if (state is! ManageProjectsWithData) emit(const ManageProjectsLoading());
    await sync?.whenReady();
    await _subscription?.cancel();
    _subscription = projectsRepository
        .watchProjects(search: search)
        .listen(
          (projects) => add(ManageProjectsChanged(projects)),
          onError: addError,
        );
  }

  Future<void> _onDelete(
    ManageProjectsDelete event,
    Emitter<ManageProjectsState> emit,
  ) async {
    final current = state;
    final remaining = current is ManageProjectsWithData
        ? current.projects.where((p) => p.id != event.projectId).toList()
        : const <Never>[];
    try {
      await projectsRepository.deleteProject(event.projectId);
      emit(ManageProjectsDeleteSuccess(projects: remaining));
    } catch (e) {
      emit(
        ManageProjectsDeleteError(
          message: e.toString(),
          projects: current is ManageProjectsWithData ? current.projects : [],
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
