import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_event.dart';
import 'theme_state.dart';

/// BLoC for managing app theme
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final SharedPreferences _prefs;
  static const String _themeKey = 'isDarkTheme';

  ThemeBloc(this._prefs) : super(ThemeState(isDark: _prefs.getBool(_themeKey) ?? false)) {
    on<ThemeToggled>(_onThemeToggled);
    on<ThemeChanged>(_onThemeChanged);
  }

  /// Handles theme toggle events
  void _onThemeToggled(ThemeToggled event, Emitter<ThemeState> emit) async {
    final newIsDark = !state.isDark;
    await _prefs.setBool(_themeKey, newIsDark);
    emit(state.copyWith(isDark: newIsDark));
  }

  /// Handles theme change events
  void _onThemeChanged(ThemeChanged event, Emitter<ThemeState> emit) async {
    await _prefs.setBool(_themeKey, event.isDark);
    emit(state.copyWith(isDark: event.isDark));
  }
}
