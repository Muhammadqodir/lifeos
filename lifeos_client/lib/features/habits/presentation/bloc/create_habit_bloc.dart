import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lifeos_client/features/habits/domain/repositories/habits_repository.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/create_habit_event.dart';
import 'package:lifeos_client/features/habits/presentation/bloc/create_habit_state.dart';

class CreateHabitBloc extends Bloc<CreateHabitEvent, CreateHabitState> {
  final HabitsRepository habitsRepository;

  CreateHabitBloc({required this.habitsRepository}) : super(CreateHabitInitial()) {
    on<CreateHabitSubmitted>(_onCreateHabitSubmitted);
    on<UpdateHabitSubmitted>(_onUpdateHabitSubmitted);
  }

  Future<void> _onCreateHabitSubmitted(
    CreateHabitSubmitted event,
    Emitter<CreateHabitState> emit,
  ) async {
    emit(CreateHabitLoading());
    try {
      final habit = await habitsRepository.createHabit(
        title: event.title,
        description: event.description,
        color: event.color,
        icon: event.icon,
        status: event.status,
        frequency: event.frequency,
        frequencyDays: event.frequencyDays,
        reminderTime: event.reminderTime,
        goalDuration: event.goalDuration,
        tags: event.tags,
      );

      emit(CreateHabitSuccess(habit: habit));
    } catch (e, stackTrace) {
      emit(CreateHabitFailure(message: e.toString()));
    }
  }

  Future<void> _onUpdateHabitSubmitted(
    UpdateHabitSubmitted event,
    Emitter<CreateHabitState> emit,
  ) async {
    emit(CreateHabitLoading());
    try {
      final habit = await habitsRepository.updateHabit(
        habitId: event.habitId,
        title: event.title,
        description: event.description,
        color: event.color,
        icon: event.icon,
        status: event.status,
        frequency: event.frequency,
        frequencyDays: event.frequencyDays,
        reminderTime: event.reminderTime,
        goalDuration: event.goalDuration,
        tags: event.tags,
      );

      emit(CreateHabitSuccess(habit: habit));
    } catch (e) {
      emit(CreateHabitFailure(message: e.toString()));
    }
  }
}
