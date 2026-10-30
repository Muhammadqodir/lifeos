import 'package:equatable/equatable.dart';
import 'package:lifeos_client/features/home/domain/repositories/home_repository.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load home page data
class HomeStarted extends HomeEvent {
  const HomeStarted();
}

/// Event to refresh home page data
class HomeRefreshed extends HomeEvent {
  const HomeRefreshed();
}

/// Event to retry loading data after error
class HomeRetried extends HomeEvent {
  const HomeRetried();
}

/// The local store changed (internal).
class HomeChanged extends HomeEvent {
  final HomeSnapshot snapshot;

  const HomeChanged(this.snapshot);

  @override
  List<Object?> get props => [snapshot];
}
