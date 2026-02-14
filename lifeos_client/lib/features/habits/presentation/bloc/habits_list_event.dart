import 'package:equatable/equatable.dart';

abstract class HabitsListEvent extends Equatable {
  const HabitsListEvent();

  @override
  List<Object?> get props => [];
}

class HabitsListRequested extends HabitsListEvent {
  final String? status;
  final String? frequency;
  final String? search;

  const HabitsListRequested({
    this.status,
    this.frequency,
    this.search,
  });

  @override
  List<Object?> get props => [status, frequency, search];
}

class HabitsListRefreshed extends HabitsListEvent {
  const HabitsListRefreshed();
}
