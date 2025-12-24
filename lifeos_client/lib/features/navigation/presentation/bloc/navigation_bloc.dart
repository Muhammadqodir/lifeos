import 'package:flutter_bloc/flutter_bloc.dart';
import 'navigation_event.dart';
import 'navigation_state.dart';

/// BLoC for managing bottom navigation state
class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(const NavigationState()) {
    on<TabSelected>(_onTabSelected);
  }

  /// Handles tab selection events
  void _onTabSelected(TabSelected event, Emitter<NavigationState> emit) {
    // Ensure the index is within valid range (0-4 for 5 tabs)
    if (event.index >= 0 && event.index < 5) {
      emit(state.copyWith(currentIndex: event.index));
    }
  }
}
