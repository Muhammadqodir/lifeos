import 'package:equatable/equatable.dart';

abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();

  @override
  List<Object?> get props => [];
}

class AnalyticsLoadData extends AnalyticsEvent {
  final DateTime? dateFrom;
  final DateTime? dateTo;

  const AnalyticsLoadData({
    this.dateFrom,
    this.dateTo,
  });

  @override
  List<Object?> get props => [dateFrom, dateTo];
}

class AnalyticsDateRangeChanged extends AnalyticsEvent {
  final DateTime dateFrom;
  final DateTime dateTo;

  const AnalyticsDateRangeChanged({
    required this.dateFrom,
    required this.dateTo,
  });

  @override
  List<Object?> get props => [dateFrom, dateTo];
}

class AnalyticsRefreshed extends AnalyticsEvent {
  const AnalyticsRefreshed();
}

class AnalyticsRetried extends AnalyticsEvent {
  const AnalyticsRetried();
}
