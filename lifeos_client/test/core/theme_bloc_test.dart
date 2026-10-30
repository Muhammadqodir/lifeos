import 'package:flutter_test/flutter_test.dart';
import 'package:lifeos_client/core/theme/presentation/bloc/theme_bloc.dart';
import 'package:lifeos_client/core/theme/presentation/bloc/theme_event.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' show ThemeMode;
import 'package:shared_preferences/shared_preferences.dart';

Future<ThemeBloc> _bloc(Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  return ThemeBloc(await SharedPreferences.getInstance());
}

void main() {
  test('follows the system appearance by default', () async {
    expect((await _bloc({})).state.mode, ThemeMode.system);
  });

  test('keeps the dark/light choice saved by older builds', () async {
    expect((await _bloc({'isDarkTheme': true})).state.mode, ThemeMode.dark);
    expect((await _bloc({'isDarkTheme': false})).state.mode, ThemeMode.light);
  });

  test('saves the chosen mode and drops the legacy flag', () async {
    final bloc = await _bloc({'isDarkTheme': true});
    bloc.add(const ThemeChanged(ThemeMode.system));
    await expectLater(
      bloc.stream,
      emits(predicate((s) => (s as dynamic).mode == ThemeMode.system)),
    );
    await Future<void>.delayed(Duration.zero);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('themeMode'), 'system');
    expect(prefs.containsKey('isDarkTheme'), isFalse);
  });
}
