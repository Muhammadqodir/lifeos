import 'package:equatable/equatable.dart';

/// Base class for all theme events
abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

/// Event to toggle between light and dark theme
class ThemeToggled extends ThemeEvent {
  const ThemeToggled();
}

/// Event to set a specific theme mode
class ThemeChanged extends ThemeEvent {
  final bool isDark;

  const ThemeChanged(this.isDark);

  @override
  List<Object?> get props => [isDark];
}
