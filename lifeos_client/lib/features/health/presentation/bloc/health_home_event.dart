import 'package:equatable/equatable.dart';

abstract class HealthHomeEvent extends Equatable {
  const HealthHomeEvent();

  @override
  List<Object?> get props => [];
}

class HealthHomeStarted extends HealthHomeEvent {
  const HealthHomeStarted();
}

class HealthHomeRefreshed extends HealthHomeEvent {
  const HealthHomeRefreshed();
}

class HealthHomeRetried extends HealthHomeEvent {
  const HealthHomeRetried();
}
