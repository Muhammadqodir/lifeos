import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/finance_repository.dart';
import 'analytics_event.dart';
import 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final FinanceRepository financeRepository;

  AnalyticsBloc({required this.financeRepository})
      : super(const AnalyticsInitial()) {
    on<AnalyticsLoadData>(_onLoadData);
    on<AnalyticsDateRangeChanged>(_onDateRangeChanged);
    on<AnalyticsRefreshed>(_onRefreshed);
    on<AnalyticsRetried>(_onRetried);
  }

  Future<void> _onLoadData(
    AnalyticsLoadData event,
    Emitter<AnalyticsState> emit,
  ) async {
    final dateFrom = event.dateFrom ?? _getFirstDayOfCurrentMonth();
    final dateTo = event.dateTo ?? _getLastDayOfCurrentMonth();

    emit(AnalyticsLoading(dateFrom: dateFrom, dateTo: dateTo));

    try {
      final analytics = await financeRepository.getAnalytics(
        dateFrom: dateFrom,
        dateTo: dateTo,
      );

      if (analytics.incomeByCategory.isEmpty &&
          analytics.expenseByCategory.isEmpty) {
        emit(AnalyticsEmpty(dateFrom: dateFrom, dateTo: dateTo));
      } else {
        emit(
          AnalyticsSuccess(
            analytics: analytics,
            dateFrom: dateFrom,
            dateTo: dateTo,
          ),
        );
      }
    } catch (e) {
      emit(
        AnalyticsFailure(
          message: e.toString().replaceAll('Exception: ', ''),
          dateFrom: dateFrom,
          dateTo: dateTo,
        ),
      );
    }
  }

  Future<void> _onDateRangeChanged(
    AnalyticsDateRangeChanged event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(AnalyticsLoading(dateFrom: event.dateFrom, dateTo: event.dateTo));

    try {
      final analytics = await financeRepository.getAnalytics(
        dateFrom: event.dateFrom,
        dateTo: event.dateTo,
      );

      if (analytics.incomeByCategory.isEmpty &&
          analytics.expenseByCategory.isEmpty) {
        emit(AnalyticsEmpty(dateFrom: event.dateFrom, dateTo: event.dateTo));
      } else {
        emit(
          AnalyticsSuccess(
            analytics: analytics,
            dateFrom: event.dateFrom,
            dateTo: event.dateTo,
          ),
        );
      }
    } catch (e) {
      emit(
        AnalyticsFailure(
          message: e.toString().replaceAll('Exception: ', ''),
          dateFrom: event.dateFrom,
          dateTo: event.dateTo,
        ),
      );
    }
  }

  Future<void> _onRefreshed(
    AnalyticsRefreshed event,
    Emitter<AnalyticsState> emit,
  ) async {
    final currentState = state;
    if (currentState is AnalyticsSuccess) {
      add(
        AnalyticsDateRangeChanged(
          dateFrom: currentState.dateFrom,
          dateTo: currentState.dateTo,
        ),
      );
    } else if (currentState is AnalyticsFailure) {
      add(
        AnalyticsLoadData(
          dateFrom: currentState.dateFrom,
          dateTo: currentState.dateTo,
        ),
      );
    } else if (currentState is AnalyticsEmpty) {
      add(
        AnalyticsLoadData(
          dateFrom: currentState.dateFrom,
          dateTo: currentState.dateTo,
        ),
      );
    } else {
      add(const AnalyticsLoadData());
    }
  }

  Future<void> _onRetried(
    AnalyticsRetried event,
    Emitter<AnalyticsState> emit,
  ) async {
    final currentState = state;
    if (currentState is AnalyticsFailure) {
      add(
        AnalyticsLoadData(
          dateFrom: currentState.dateFrom,
          dateTo: currentState.dateTo,
        ),
      );
    } else {
      add(const AnalyticsLoadData());
    }
  }

  DateTime _getFirstDayOfCurrentMonth() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  DateTime _getLastDayOfCurrentMonth() {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, 0);
  }
}
