import 'package:equatable/equatable.dart';

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
