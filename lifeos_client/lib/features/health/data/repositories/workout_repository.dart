import '../../../../core/sync/local_store.dart';
import '../../../../core/sync/pending_uploads.dart';
import '../../../../core/sync/sync_engine.dart';
import '../../domain/repositories/workout_repository.dart';
import '../datasources/health_api_client.dart';
import '../datasources/workout_local_storage.dart';
import '../models/exercise_dto.dart';
import '../models/workout_completion_dto.dart';
import '../models/workout_session_dto.dart';

/// Local-first exercises and workouts (docs/local-first.md).
///
/// A finished workout is stored with its exercises, sets and measurements
/// as one record and synced; its progress photo and custom exercise images
/// go through [PendingUploads] once the record is on the server.
class WorkoutRepositoryImpl implements WorkoutRepository {
  WorkoutRepositoryImpl({
    required this.apiClient,
    required this.localStorage,
    required this.store,
    required this.sync,
    required this.uploads,
  }) {
    uploads
      ..register(_workoutPhoto, apiClient.uploadWorkoutPhoto)
      ..register(_exerciseImage, apiClient.uploadExerciseImage);
  }

  final HealthApiClient apiClient;
  final WorkoutLocalStorage localStorage;
  final LocalStore store;
  final SyncEngine sync;
  final PendingUploads uploads;

  static const _workoutPhoto = 'workout_photo';
  static const _exerciseImage = 'exercise_image';
  static const _pageSize = 20;
  static const _entities = {
    SyncEntities.exercises,
    SyncEntities.workoutSessions,
  };

  @override
  Stream<void> get changes =>
      store.changes.where((touched) => touched.any(_entities.contains));

  // ---------------------------------------------------------------------------
  // Exercises

  @override
  Future<List<ExerciseDto>> getExercises({
    bool includeLastSession = false,
  }) async {
    final lastSets = <String, List<Object?>>{};
    if (includeLastSession) {
      // Newest workout first, so the first one seen per exercise wins.
      for (final w in await _workoutRecords()) {
        for (final e in (w['exercises'] as List? ?? const [])) {
          final exercise = e as Map;
          lastSets.putIfAbsent(
            exercise['exercise_id'] as String,
            () => exercise['sets'] as List? ?? const [],
          );
        }
      }
    }
    return [
      for (final r in await store.all(SyncEntities.exercises))
        ExerciseDto.fromJson({
          ...r,
          if (lastSets[r['id']] case final sets?)
            'last_session_sets': [
              for (final s in sets) Map<String, dynamic>.from(s as Map),
            ],
        }),
    ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  @override
  Future<ExerciseDto> createExercise({
    required String name,
    required String type,
    String? muscleGroup,
    String? imagePath,
  }) async {
    final record = await sync.create(SyncEntities.exercises, {
      'name': name,
      'type': type,
      'muscle_group': muscleGroup,
      'is_system': false,
    });
    if (imagePath != null) {
      await uploads.add(
        kind: _exerciseImage,
        entity: SyncEntities.exercises,
        id: record['id'] as String,
        path: imagePath,
      );
    }
    return ExerciseDto.fromJson(record);
  }

  @override
  Future<void> deleteExercise(String exerciseId) =>
      sync.delete(SyncEntities.exercises, exerciseId);

  // ---------------------------------------------------------------------------
  // Workouts

  /// Newest first.
  Future<List<Json>> _workoutRecords() async =>
      (await store.all(SyncEntities.workoutSessions))..sort(
        (a, b) =>
            (b['started_at'] as String).compareTo(a['started_at'] as String),
      );

  @override
  Future<List<WorkoutSessionDto>> getWorkoutSessions({
    DateTime? dateFrom,
    DateTime? dateTo,
    int page = 1,
  }) async {
    final exercises = {
      for (final e in await store.all(SyncEntities.exercises)) e['id']: e,
    };
    final matching = (await _workoutRecords()).where((w) {
      final started = DateTime.parse(w['started_at'] as String);
      return (dateFrom == null || !started.isBefore(dateFrom)) &&
          (dateTo == null || !started.isAfter(dateTo));
    }).toList();
    final start = ((page - 1) * _pageSize).clamp(0, matching.length);
    final end = (start + _pageSize).clamp(0, matching.length);
    return [
      for (final w in matching.sublist(start, end))
        WorkoutSessionDto.fromJson({
          ...w,
          'exercises': [
            for (final e in (w['exercises'] as List? ?? const []))
              {
                ...Map<String, dynamic>.from(e as Map),
                if (exercises[e['exercise_id']] case final exercise?)
                  'exercise': exercise,
              },
          ],
        }),
    ];
  }

  @override
  Future<void> deleteWorkoutSession(String workoutId) =>
      sync.delete(SyncEntities.workoutSessions, workoutId);

  @override
  Future<void> saveActiveWorkoutLocally(WorkoutSessionDto workout) =>
      localStorage.saveActiveWorkout(workout);

  @override
  WorkoutSessionDto? getActiveWorkout() => localStorage.getActiveWorkout();

  @override
  bool hasActiveWorkout() => localStorage.hasActiveWorkout();

  @override
  Future<void> clearActiveWorkout() => localStorage.clearActiveWorkout();

  @override
  Future<WorkoutSessionDto> submitWorkout(WorkoutSessionDto workout) =>
      _save(workout, null);

  @override
  Future<WorkoutSessionDto> submitWorkoutWithCompletion(
    WorkoutSessionDto workout,
    WorkoutCompletionDto completion,
  ) => _save(workout, completion);

  Future<WorkoutSessionDto> _save(
    WorkoutSessionDto workout,
    WorkoutCompletionDto? completion,
  ) async {
    final record = await sync.create(SyncEntities.workoutSessions, {
      'started_at': workout.startedAt.toUtc().toIso8601String(),
      'ended_at': (workout.endedAt ?? DateTime.now()).toUtc().toIso8601String(),
      'note': workout.note,
      'exercises': [
        for (final exercise in workout.exercises)
          {
            'exercise_id': exercise.exerciseId,
            'order_index': exercise.orderIndex,
            'sets': [
              for (final set in exercise.sets)
                {
                  'set_index': set.setIndex,
                  'weight_kg': set.weightKg,
                  'reps': set.reps,
                  'duration_seconds': set.durationSeconds,
                  'distance_meters': set.distanceMeters,
                  'rpe': set.rpe,
                  'is_done': set.isDone,
                },
            ],
          },
      ],
      if (completion != null)
        'completion': {
          'body_weight_kg': completion.bodyWeightKg,
          'height_cm': completion.heightCm,
          'biceps_cm': completion.bicepsCm,
          'chest_cm': completion.chestCm,
          'waist_cm': completion.waistCm,
          'thighs_cm': completion.thighsCm,
          'calfs_cm': completion.calfsCm,
          'notes': completion.notes,
        },
    });
    await localStorage.clearActiveWorkout();

    final photo = completion?.photoPath;
    if (photo != null) {
      await uploads.add(
        kind: _workoutPhoto,
        entity: SyncEntities.workoutSessions,
        id: record['id'] as String,
        path: photo,
      );
    }
    return WorkoutSessionDto.fromJson(record);
  }
}
