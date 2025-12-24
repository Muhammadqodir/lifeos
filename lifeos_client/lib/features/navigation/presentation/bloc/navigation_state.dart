import 'package:equatable/equatable.dart';

/// Represents the current state of bottom navigation
class NavigationState extends Equatable {
  final int currentIndex;

  const NavigationState({
    this.currentIndex = 0,
  });

  NavigationState copyWith({
    int? currentIndex,
  }) {
    return NavigationState(
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }

  @override
  List<Object?> get props => [currentIndex];
}
