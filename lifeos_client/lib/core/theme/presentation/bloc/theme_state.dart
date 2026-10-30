import 'package:equatable/equatable.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' show ThemeMode;

/// Represents the current theme state
class ThemeState extends Equatable {
  /// [ThemeMode.system] follows the iPhone, iPad or Mac appearance setting.
  final ThemeMode mode;

  const ThemeState({this.mode = ThemeMode.system});

  ThemeState copyWith({ThemeMode? mode}) {
    return ThemeState(mode: mode ?? this.mode);
  }

  @override
  List<Object?> get props => [mode];
}
