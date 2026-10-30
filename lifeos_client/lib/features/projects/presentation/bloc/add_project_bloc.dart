import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/projects_repository.dart';
import 'add_project_event.dart';
import 'add_project_state.dart';

class AddProjectBloc extends Bloc<AddProjectEvent, AddProjectState> {
  final ProjectsRepository projectsRepository;

  AddProjectBloc({required this.projectsRepository})
    : super(const AddProjectInitial()) {
    on<AddProjectSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    AddProjectSubmitted event,
    Emitter<AddProjectState> emit,
  ) async {
    emit(
      AddProjectSubmitting(
        title: event.title,
        description: event.description ?? '',
        color: event.color,
        iconImage: event.iconImage,
        tags: event.tags ?? [],
      ),
    );

    try {
      await projectsRepository.createProject(
        title: event.title,
        color: event.color,
        description: event.description,
        tags: event.tags ?? const [],
        icon: event.iconImage,
      );

      emit(
        AddProjectSuccess(
          title: event.title,
          description: event.description ?? '',
          color: event.color,
          iconImage: event.iconImage,
          tags: event.tags ?? [],
        ),
      );
    } catch (e) {
      emit(
        AddProjectError(
          message: e.toString(),
          title: event.title,
          description: event.description ?? '',
          color: event.color,
          iconImage: event.iconImage,
          tags: event.tags ?? [],
        ),
      );
    }
  }
}
