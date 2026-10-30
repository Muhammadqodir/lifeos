import 'package:equatable/equatable.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' show ThemeMode;

/// Base class for all theme events
abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

/// Event to set the appearance: system, light or dark
class ThemeChanged extends ThemeEvent {
  final ThemeMode mode;

  const ThemeChanged(this.mode);

  @override
  List<Object?> get props => [mode];
}
