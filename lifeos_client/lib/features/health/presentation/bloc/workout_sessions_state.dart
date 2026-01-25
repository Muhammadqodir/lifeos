import 'package:equatable/equatable.dart';
import '../../data/models/workout_session_dto.dart';

abstract class WorkoutSessionsState extends Equatable {
  const WorkoutSessionsState();

  @override
  List<Object?> get props => [];
}

class WorkoutSessionsInitial extends WorkoutSessionsState {
  const WorkoutSessionsInitial();
}

class WorkoutSessionsLoading extends WorkoutSessionsState {
  const WorkoutSessionsLoading();
}

class WorkoutSessionsLoadingMore extends WorkoutSessionsState {
  final List<WorkoutSessionDto> sessions;

  const WorkoutSessionsLoadingMore({required this.sessions});

  @override
  List<Object?> get props => [sessions];
}

class WorkoutSessionsSuccess extends WorkoutSessionsState {
  final List<WorkoutSessionDto> sessions;
  final bool hasMore;
  final int currentPage;

  const WorkoutSessionsSuccess({
    required this.sessions,
    this.hasMore = true,
    this.currentPage = 1,
  });

  @override
  List<Object?> get props => [sessions, hasMore, currentPage];

  WorkoutSessionsSuccess copyWith({
    List<WorkoutSessionDto>? sessions,
    bool? hasMore,
    int? currentPage,
  }) {
    return WorkoutSessionsSuccess(
      sessions: sessions ?? this.sessions,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class WorkoutSessionsEmpty extends WorkoutSessionsState {
  const WorkoutSessionsEmpty();
}

class WorkoutSessionsFailure extends WorkoutSessionsState {
  final String message;

  const WorkoutSessionsFailure({required this.message});

  @override
  List<Object?> get props => [message];
}
