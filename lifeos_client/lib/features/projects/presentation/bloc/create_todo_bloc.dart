import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lifeos_client/features/projects/data/models/create_todo_dto.dart';
import 'package:lifeos_client/features/projects/domain/repositories/todos_repository.dart';
import 'package:lifeos_client/features/projects/presentation/bloc/create_todo_event.dart';
import 'package:lifeos_client/features/projects/presentation/bloc/create_todo_state.dart';

class CreateTodoBloc extends Bloc<CreateTodoEvent, CreateTodoState> {
  final TodosRepository _todosRepository;

  CreateTodoBloc(this._todosRepository) : super(const CreateTodoInitial()) {
    on<TitleChanged>(_onTitleChanged);
    on<CommentChanged>(_onCommentChanged);
    on<PriorityChanged>(_onPriorityChanged);
    on<UrgencyChanged>(_onUrgencyChanged);
    on<EnergyChanged>(_onEnergyChanged);
    on<PlannedDateChanged>(_onPlannedDateChanged);
    on<PlannedTimeChanged>(_onPlannedTimeChanged);
    on<TagsChanged>(_onTagsChanged);
    on<SubmitTodo>(_onSubmitTodo);
    on<ResetForm>(_onResetForm);
  }

  void _onTitleChanged(
    TitleChanged event,
    Emitter<CreateTodoState> emit,
  ) {
    if (state is CreateTodoInitial) {
      final currentState = state as CreateTodoInitial;
      String? error;
      
      if (event.title.isEmpty) {
        error = 'Title is required';
      } else if (event.title.length < 3) {
        error = 'Title must be at least 3 characters';
      }

      emit(currentState.copyWith(
        title: event.title,
        titleError: error,
        clearTitleError: error == null,
      ));
    }
  }

  void _onCommentChanged(
    CommentChanged event,
    Emitter<CreateTodoState> emit,
  ) {
    if (state is CreateTodoInitial) {
      final currentState = state as CreateTodoInitial;
      emit(currentState.copyWith(comment: event.comment));
    }
  }

  void _onPriorityChanged(
    PriorityChanged event,
    Emitter<CreateTodoState> emit,
  ) {
    if (state is CreateTodoInitial) {
      final currentState = state as CreateTodoInitial;
      emit(currentState.copyWith(priority: event.priority));
    }
  }

  void _onUrgencyChanged(
    UrgencyChanged event,
    Emitter<CreateTodoState> emit,
  ) {
    if (state is CreateTodoInitial) {
      final currentState = state as CreateTodoInitial;
      emit(currentState.copyWith(urgency: event.urgency));
    }
  }

  void _onEnergyChanged(
    EnergyChanged event,
    Emitter<CreateTodoState> emit,
  ) {
    if (state is CreateTodoInitial) {
      final currentState = state as CreateTodoInitial;
      emit(currentState.copyWith(energy: event.energy));
    }
  }

  void _onPlannedDateChanged(
    PlannedDateChanged event,
    Emitter<CreateTodoState> emit,
  ) {
    if (state is CreateTodoInitial) {
      final currentState = state as CreateTodoInitial;
      emit(currentState.copyWith(
        plannedDate: event.plannedDate,
        clearPlannedDate: event.plannedDate == null,
      ));
    }
  }

  void _onPlannedTimeChanged(
    PlannedTimeChanged event,
    Emitter<CreateTodoState> emit,
  ) {
    if (state is CreateTodoInitial) {
      final currentState = state as CreateTodoInitial;
      emit(currentState.copyWith(
        plannedTime: event.plannedTime,
        clearPlannedTime: event.plannedTime == null,
      ));
    }
  }

  void _onTagsChanged(
    TagsChanged event,
    Emitter<CreateTodoState> emit,
  ) {
    if (state is CreateTodoInitial) {
      final currentState = state as CreateTodoInitial;
      emit(currentState.copyWith(tags: event.tags));
    }
  }

  Future<void> _onSubmitTodo(
    SubmitTodo event,
    Emitter<CreateTodoState> emit,
  ) async {
    if (state is! CreateTodoInitial) return;
    
    final currentState = state as CreateTodoInitial;

    // Validate
    if (currentState.title.isEmpty) {
      emit(currentState.copyWith(titleError: 'Title is required'));
      return;
    }

    if (currentState.title.length < 3) {
      emit(currentState.copyWith(titleError: 'Title must be at least 3 characters'));
      return;
    }

    emit(const CreateTodoSubmitting());

    try {
      final dto = CreateTodoDto(
        projectId: event.projectId,
        title: currentState.title,
        comment: currentState.comment.isEmpty ? null : currentState.comment,
        priority: currentState.priority,
        urgency: currentState.urgency,
        energy: currentState.energy,
        plannedDate: currentState.plannedDate,
        plannedTime: currentState.plannedTime != null 
            ? '${currentState.plannedTime}:00' // Convert HH:mm to HH:mm:ss
            : null,
        tags: currentState.tags,
      );

      print('=== CREATE TODO DEBUG ===');
      print('DTO: $dto');
      print('JSON: ${dto.toJson()}');
      print('Project ID: ${event.projectId}');
      print('Title: ${currentState.title}');
      print('Comment: ${currentState.comment}');
      print('Priority: ${currentState.priority}');
      print('Urgency: ${currentState.urgency}');
      print('Energy: ${currentState.energy}');
      print('Planned Date: ${currentState.plannedDate}');
      print('Planned Time: ${currentState.plannedTime}');
      print('Tags: ${currentState.tags}');
      print('========================');

      final todo = await _todosRepository.createTodo(dto);

      emit(CreateTodoSuccess(todo));
    } catch (e, stackTrace) {
      print('=== CREATE TODO ERROR ===');
      print('Error: $e');
      print('Stack trace:');
      print(stackTrace);
      print('========================');
      emit(CreateTodoError(e.toString()));
      
      // Return to form state with data preserved
      emit(currentState);
    }
  }

  void _onResetForm(
    ResetForm event,
    Emitter<CreateTodoState> emit,
  ) {
    emit(const CreateTodoInitial());
  }
}
