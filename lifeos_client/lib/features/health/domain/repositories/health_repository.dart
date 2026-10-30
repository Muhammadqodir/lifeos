import '../../data/models/sleep_entry_dto.dart';
import '../../data/models/sleep_summary_dto.dart';
import '../../data/models/wellbeing_entry_dto.dart';
import '../../data/models/wellbeing_summary_dto.dart';
import '../../data/models/workout_summary_dto.dart';

/// Sleep and wellbeing entries and the workout summary, read from the
/// device (local-first); summaries are computed locally.
abstract class HealthRepository {
  /// Fires after any local change to health data.
  Stream<void> get changes;

  Future<List<SleepEntryDto>> getSleepEntries({
    DateTime? dateFrom,
    DateTime? dateTo,
  });

  Future<SleepSummaryDto> getSleepSummary({
    DateTime? dateFrom,
    DateTime? dateTo,
  });

  Future<SleepEntryDto> createSleepEntry({
    required String date,
    required String sleepStart,
    required String sleepEnd,
    required int quality,
    String? note,
  });

  Future<List<WellbeingEntryDto>> getWellbeingEntries({
    DateTime? dateFrom,
    DateTime? dateTo,
  });

  Future<WellbeingSummaryDto> getWellbeingSummary({
    DateTime? dateFrom,
    DateTime? dateTo,
  });

  Future<WellbeingEntryDto> createWellbeingEntry({
    required String date,
    required int energy,
    required int stress,
    String? note,
  });

  Future<WorkoutSummaryDto> getWorkoutSummary({
    DateTime? dateFrom,
    DateTime? dateTo,
  });
}
