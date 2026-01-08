import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/workout_session_dto.dart';

class WorkoutLocalStorage {
  static const String _activeWorkoutKey = 'active_workout';

  final SharedPreferences prefs;

  WorkoutLocalStorage({required this.prefs});

  Future<void> saveActiveWorkout(WorkoutSessionDto workout) async {
    final json = jsonEncode(workout.toJson());
    await prefs.setString(_activeWorkoutKey, json);
  }

  WorkoutSessionDto? getActiveWorkout() {
    final json = prefs.getString(_activeWorkoutKey);
    if (json == null) return null;

    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return WorkoutSessionDto.fromJson(map);
    } catch (e) {
      return null;
    }
  }

  Future<void> clearActiveWorkout() async {
    await prefs.remove(_activeWorkoutKey);
  }

  bool hasActiveWorkout() {
    return prefs.containsKey(_activeWorkoutKey);
  }
}
