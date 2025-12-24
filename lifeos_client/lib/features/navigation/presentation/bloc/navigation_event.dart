import 'package:equatable/equatable.dart';

/// Base class for all navigation events
abstract class NavigationEvent extends Equatable {
  const NavigationEvent();

  @override
  List<Object?> get props => [];
}

/// Event triggered when a tab is selected
class TabSelected extends NavigationEvent {
  final int index;

  const TabSelected(this.index);

  @override
  List<Object?> get props => [index];
}
