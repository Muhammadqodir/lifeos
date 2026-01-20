import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/projects_repository.dart';
import 'manage_projects_event.dart';
import 'manage_projects_state.dart';

class ManageProjectsBloc
    extends Bloc<ManageProjectsEvent, ManageProjectsState> {
  final ProjectsRepository projectsRepository;
  String? _currentSearchQuery;

  ManageProjectsBloc({required this.projectsRepository})
      : super(const ManageProjectsInitial()) {
    on<ManageProjectsLoad>(_onLoad);
    on<ManageProjectsRefresh>(_onRefresh);
    on<ManageProjectsDelete>(_onDelete);
    on<ManageProjectsSearch>(_onSearch);
  }

  Future<void> _onLoad(
    ManageProjectsLoad event,
    Emitter<ManageProjectsState> emit,
  ) async {
    emit(const ManageProjectsLoading());
    await _loadData(emit);
  }

  Future<void> _onRefresh(
    ManageProjectsRefresh event,
    Emitter<ManageProjectsState> emit,
  ) async {
    await _loadData(emit);
  }

  Future<void> _onSearch(
    ManageProjectsSearch event,
    Emitter<ManageProjectsState> emit,
  ) async {
    _currentSearchQuery = event.query;
    emit(const ManageProjectsLoading());
    await _loadData(emit);
  }

  Future<void> _loadData(Emitter<ManageProjectsState> emit) async {
    try {
      final projects = await projectsRepository.getProjects(
        search: _currentSearchQuery,
      );

      emit(ManageProjectsLoaded(projects: projects));
    } catch (e) {
      emit(ManageProjectsError(message: e.toString()));
    }
  }

  Future<void> _onDelete(
    ManageProjectsDelete event,
    Emitter<ManageProjectsState> emit,
  ) async {
    final currentState = state;
    if (currentState is ManageProjectsLoaded) {
      emit(ManageProjectsDeleting(
        projectId: event.projectId,
        projects: currentState.projects,
      ));

      try {
        await projectsRepository.deleteProject(event.projectId);

        // Reload projects after deletion
        final projects = await projectsRepository.getProjects(
          search: _currentSearchQuery,
        );

        emit(ManageProjectsDeleteSuccess(projects: projects));
      } catch (e) {
        emit(ManageProjectsDeleteError(
          message: e.toString(),
          projects: currentState.projects,
        ));
      }
    }
  }
}
