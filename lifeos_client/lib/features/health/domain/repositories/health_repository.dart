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

  Future<List<WellbeingEntryDto>> getWellbeingEntries({
    DateTime? dateFrom,
    DateTime? dateTo,
  });

  Future<WellbeingSummaryDto> getWellbeingSummary({
    DateTime? dateFrom,
    DateTime? dateTo,
  });

  Future<WorkoutSummaryDto> getWorkoutSummary({
    DateTime? dateFrom,
    DateTime? dateTo,
  });
}
