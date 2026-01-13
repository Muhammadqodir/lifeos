import '../../data/models/sleep_entry_dto.dart';
import '../../data/models/sleep_summary_dto.dart';
import '../../data/models/wellbeing_entry_dto.dart';
import '../../data/models/wellbeing_summary_dto.dart';
import '../../data/models/workout_summary_dto.dart';

abstract class HealthRepository {
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
