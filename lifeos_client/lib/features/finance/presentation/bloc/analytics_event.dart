import 'package:equatable/equatable.dart';

abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();

  @override
  List<Object?> get props => [];
}

class AnalyticsLoadData extends AnalyticsEvent {
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final int? currencyId;

  const AnalyticsLoadData({
    this.dateFrom,
    this.dateTo,
    this.currencyId,
  });

  @override
  List<Object?> get props => [dateFrom, dateTo, currencyId];
}

class AnalyticsDateRangeChanged extends AnalyticsEvent {
  final DateTime dateFrom;
  final DateTime dateTo;
  final int? currencyId;

  const AnalyticsDateRangeChanged({
    required this.dateFrom,
    required this.dateTo,
    this.currencyId,
  });

  @override
  List<Object?> get props => [dateFrom, dateTo, currencyId];
}

class AnalyticsCurrencyChanged extends AnalyticsEvent {
  final int? currencyId;

  const AnalyticsCurrencyChanged({this.currencyId});

  @override
  List<Object?> get props => [currencyId];
}

class AnalyticsRefreshed extends AnalyticsEvent {
  const AnalyticsRefreshed();
}

class AnalyticsRetried extends AnalyticsEvent {
  const AnalyticsRetried();
}
