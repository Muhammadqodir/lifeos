import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' show ThemeMode;
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_event.dart';
import 'theme_state.dart';

/// BLoC for managing app theme
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final SharedPreferences _prefs;
  static const String _modeKey = 'themeMode';

  /// Earlier builds stored a plain dark/light flag.
  static const String _legacyDarkKey = 'isDarkTheme';

  ThemeBloc(this._prefs) : super(ThemeState(mode: _readMode(_prefs))) {
    on<ThemeChanged>(_onThemeChanged);
  }

  static ThemeMode _readMode(SharedPreferences prefs) {
    final stored = prefs.getString(_modeKey);
    for (final mode in ThemeMode.values) {
      if (mode.name == stored) return mode;
    }
    final legacyDark = prefs.getBool(_legacyDarkKey);
    if (legacyDark == null) return ThemeMode.system;
    return legacyDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> _onThemeChanged(
    ThemeChanged event,
    Emitter<ThemeState> emit,
  ) async {
    emit(state.copyWith(mode: event.mode));
    await _prefs.setString(_modeKey, event.mode.name);
    await _prefs.remove(_legacyDarkKey);
  }
}
