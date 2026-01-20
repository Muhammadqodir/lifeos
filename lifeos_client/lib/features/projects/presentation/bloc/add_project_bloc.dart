import 'package:dio/dio.dart';
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
    emit(const AddProjectSubmitting());

    try {
      // Use FormData if there's an icon image to upload
      if (event.iconImage != null) {
        final Map<String, dynamic> formDataMap = {
          'title': event.title,
          'color': event.color,
        };

        if (event.description != null && event.description!.isNotEmpty) {
          formDataMap['description'] = event.description;
        }

        // Add tags individually with array notation for Laravel
        if (event.tags != null && event.tags!.isNotEmpty) {
          for (int i = 0; i < event.tags!.length; i++) {
            formDataMap['tags[$i]'] = event.tags![i];
          }
        }

        formDataMap['icon'] = await MultipartFile.fromFile(
          event.iconImage!.path,
          filename: event.iconImage!.name,
        );

        final formData = FormData.fromMap(formDataMap);
        
        await projectsRepository.createProjectWithFormData(formData);
      } else {
        // Regular JSON request without icon
        final data = <String, dynamic>{
          'title': event.title,
          'color': event.color,
        };

        if (event.description != null && event.description!.isNotEmpty) {
          data['description'] = event.description;
        }
        
        if (event.tags != null && event.tags!.isNotEmpty) {
          data['tags'] = event.tags;
        }

        await projectsRepository.createProject(data);
      }

      emit(const AddProjectSuccess());
    } catch (e, s) {
      print('Error creating project: $e');
      print('Stack trace: $s');
      emit(AddProjectError(message: e.toString()));
    }
  }
}
