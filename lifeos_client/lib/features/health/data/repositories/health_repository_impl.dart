import '../../domain/repositories/health_repository.dart';
import '../datasources/health_api_client.dart';
import '../models/sleep_entry_dto.dart';
import '../models/sleep_summary_dto.dart';
import '../models/wellbeing_entry_dto.dart';
import '../models/wellbeing_summary_dto.dart';
import '../models/workout_summary_dto.dart';

class HealthRepositoryImpl implements HealthRepository {
  final HealthApiClient apiClient;

  HealthRepositoryImpl({required this.apiClient});

  @override
  Future<List<SleepEntryDto>> getSleepEntries({
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    return await apiClient.getSleepEntries(
      dateFrom: dateFrom,
      dateTo: dateTo,
    );
  }

  @override
  Future<SleepSummaryDto> getSleepSummary({
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    return await apiClient.getSleepSummary(
      dateFrom: dateFrom,
      dateTo: dateTo,
    );
  }

  @override
  Future<SleepEntryDto> createSleepEntry({
    required String date,
    required String sleepStart,
    required String sleepEnd,
    required int quality,
    String? note,
  }) async {
    return await apiClient.createSleepEntry(
      date: date,
      sleepStart: sleepStart,
      sleepEnd: sleepEnd,
      quality: quality,
      note: note,
    );
  }

  @override
  Future<List<WellbeingEntryDto>> getWellbeingEntries({
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    return await apiClient.getWellbeingEntries(
      dateFrom: dateFrom,
      dateTo: dateTo,
    );
  }

  @override
  Future<WellbeingSummaryDto> getWellbeingSummary({
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    return await apiClient.getWellbeingSummary(
      dateFrom: dateFrom,
      dateTo: dateTo,
    );
  }

  @override
  Future<WellbeingEntryDto> createWellbeingEntry({
    required String date,
    required int energy,
    required int stress,
    String? note,
  }) async {
    return await apiClient.createWellbeingEntry(
      date: date,
      energy: energy,
      stress: stress,
      note: note,
    );
  }

  @override
  Future<WorkoutSummaryDto> getWorkoutSummary({
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    return await apiClient.getWorkoutSummary(
      dateFrom: dateFrom,
      dateTo: dateTo,
    );
  }
}
