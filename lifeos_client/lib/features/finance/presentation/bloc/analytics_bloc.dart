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
    on<AnalyticsCurrencyChanged>(_onCurrencyChanged);
    on<AnalyticsRefreshed>(_onRefreshed);
    on<AnalyticsRetried>(_onRetried);
  }

  Future<void> _onLoadData(
    AnalyticsLoadData event,
    Emitter<AnalyticsState> emit,
  ) async {
    final dateFrom = event.dateFrom ?? _getFirstDayOfCurrentMonth();
    final dateTo = event.dateTo ?? _getLastDayOfCurrentMonth();
    int? currencyId = event.currencyId;

    // If currencyId not provided, get default from finance settings
    if (currencyId == null) {
      try {
        final settings = await financeRepository.getFinanceSettings();
        currencyId = settings['base_currency_id'] as int?;
      } catch (e) {
        // Continue without currency filter if settings fail
      }
    }

    emit(AnalyticsLoading(
      dateFrom: dateFrom,
      dateTo: dateTo,
      currencyId: currencyId,
    ));

    try {
      final analytics = await financeRepository.getAnalytics(
        dateFrom: dateFrom,
        dateTo: dateTo,
        currencyId: currencyId,
      );

      if (analytics.incomeByCategory.isEmpty &&
          analytics.expenseByCategory.isEmpty) {
        emit(AnalyticsEmpty(
          dateFrom: dateFrom,
          dateTo: dateTo,
          currencyId: currencyId,
        ));
      } else {
        emit(
          AnalyticsSuccess(
            analytics: analytics,
            dateFrom: dateFrom,
            dateTo: dateTo,
            currencyId: currencyId,
          ),
        );
      }
    } catch (e) {
      emit(
        AnalyticsFailure(
          message: e.toString().replaceAll('Exception: ', ''),
          dateFrom: dateFrom,
          dateTo: dateTo,
          currencyId: currencyId!,
        ),
      );
    }
  }

  Future<void> _onDateRangeChanged(
    AnalyticsDateRangeChanged event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(AnalyticsLoading(
      dateFrom: event.dateFrom,
      dateTo: event.dateTo,
      currencyId: event.currencyId,
    ));

    try {
      final analytics = await financeRepository.getAnalytics(
        dateFrom: event.dateFrom,
        dateTo: event.dateTo,
        currencyId: event.currencyId,
      );

      if (analytics.incomeByCategory.isEmpty &&
          analytics.expenseByCategory.isEmpty) {
        emit(AnalyticsEmpty(
          dateFrom: event.dateFrom,
          dateTo: event.dateTo,
          currencyId: event.currencyId,
        ));
      } else {
        emit(
          AnalyticsSuccess(
            analytics: analytics,
            dateFrom: event.dateFrom,
            dateTo: event.dateTo,
            currencyId: event.currencyId,
          ),
        );
      }
    } catch (e) {
      emit(
        AnalyticsFailure(
          message: e.toString().replaceAll('Exception: ', ''),
          dateFrom: event.dateFrom,
          dateTo: event.dateTo,
          currencyId: event.currencyId!,
        ),
      );
    }
  }

  Future<void> _onCurrencyChanged(
    AnalyticsCurrencyChanged event,
    Emitter<AnalyticsState> emit,
  ) async {
    final currentState = state;
    DateTime dateFrom = _getFirstDayOfCurrentMonth();
    DateTime dateTo = _getLastDayOfCurrentMonth();

    if (currentState is AnalyticsSuccess) {
      dateFrom = currentState.dateFrom;
      dateTo = currentState.dateTo;
    } else if (currentState is AnalyticsEmpty) {
      dateFrom = currentState.dateFrom;
      dateTo = currentState.dateTo;
    } else if (currentState is AnalyticsFailure) {
      dateFrom = currentState.dateFrom ?? dateFrom;
      dateTo = currentState.dateTo ?? dateTo;
    }

    add(
      AnalyticsDateRangeChanged(
        dateFrom: dateFrom,
        dateTo: dateTo,
        currencyId: event.currencyId,
      ),
    );
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
          currencyId: currentState.currencyId,
        ),
      );
    } else if (currentState is AnalyticsFailure) {
      add(
        AnalyticsLoadData(
          dateFrom: currentState.dateFrom,
          dateTo: currentState.dateTo,
          currencyId: currentState.currencyId,
        ),
      );
    } else if (currentState is AnalyticsEmpty) {
      add(
        AnalyticsLoadData(
          dateFrom: currentState.dateFrom,
          dateTo: currentState.dateTo,
          currencyId: currentState.currencyId,
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
          currencyId: currentState.currencyId,
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
