import 'package:equatable/equatable.dart';

abstract class WorkoutSessionsEvent extends Equatable {
  const WorkoutSessionsEvent();

  @override
  List<Object?> get props => [];
}

class WorkoutSessionsLoad extends WorkoutSessionsEvent {
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const WorkoutSessionsLoad({
    this.dateFrom,
    this.dateTo,
  });

  @override
  List<Object?> get props => [dateFrom, dateTo];
}

class WorkoutSessionsRefresh extends WorkoutSessionsEvent {
  const WorkoutSessionsRefresh();
}

class WorkoutSessionsLoadMore extends WorkoutSessionsEvent {
  const WorkoutSessionsLoadMore();
}
