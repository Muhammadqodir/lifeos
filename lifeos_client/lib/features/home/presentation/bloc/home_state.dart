import 'package:equatable/equatable.dart';
import 'package:lifeos_client/features/habits/data/models/habit_dto.dart';
import 'package:lifeos_client/features/projects/data/models/todo_dto.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class HomeInitial extends HomeState {
  const HomeInitial();
}

/// Loading state
class HomeLoading extends HomeState {
  const HomeLoading();
}

/// Success state with data
class HomeSuccess extends HomeState {
  final List<TodoDto> todosToday;
  final List<TodoDto> overdueTodos;
  final List<TodoDto> inboxTodos;
  final List<TodoDto> inProgressTodos;
  final List<HabitDto> habitsToday;

  const HomeSuccess({
    required this.todosToday,
    required this.overdueTodos,
    required this.inboxTodos,
    required this.inProgressTodos,
    required this.habitsToday,
  });

  @override
  List<Object?> get props => [todosToday, overdueTodos, inboxTodos, inProgressTodos, habitsToday];

  HomeSuccess copyWith({
    List<TodoDto>? todosToday,
    List<TodoDto>? overdueTodos,
    List<TodoDto>? inboxTodos,
    List<TodoDto>? inProgressTodos,
    List<HabitDto>? habitsToday,
  }) {
    return HomeSuccess(
      todosToday: todosToday ?? this.todosToday,
      overdueTodos: overdueTodos ?? this.overdueTodos,
      inboxTodos: inboxTodos ?? this.inboxTodos,
      inProgressTodos: inProgressTodos ?? this.inProgressTodos,
      habitsToday: habitsToday ?? this.habitsToday,
    );
  }
}

/// Empty state (no data available)
class HomeEmpty extends HomeState {
  const HomeEmpty();
}

/// Failure state with error message
class HomeFailure extends HomeState {
  final String message;

  const HomeFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
