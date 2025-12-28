import 'package:equatable/equatable.dart';
import '../../data/models/analytics_summary_dto.dart';

abstract class AnalyticsState extends Equatable {
  const AnalyticsState();

  @override
  List<Object?> get props => [];
}

class AnalyticsInitial extends AnalyticsState {
  const AnalyticsInitial();
}

class AnalyticsLoading extends AnalyticsState {
  final DateTime dateFrom;
  final DateTime dateTo;
  final int? currencyId;
  
  const AnalyticsLoading({
    required this.dateFrom,
    required this.dateTo,
    this.currencyId,
  });

  @override
  List<Object?> get props => [dateFrom, dateTo, currencyId];
}

class AnalyticsSuccess extends AnalyticsState {
  final AnalyticsSummaryDto analytics;
  final DateTime dateFrom;
  final DateTime dateTo;
  final int? currencyId;

  const AnalyticsSuccess({
    required this.analytics,
    required this.dateFrom,
    required this.dateTo,
    this.currencyId,
  });

  @override
  List<Object?> get props => [analytics, dateFrom, dateTo, currencyId];
}

class AnalyticsFailure extends AnalyticsState {
  final String message;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final int? currencyId;

  const AnalyticsFailure({
    required this.message,
    this.dateFrom,
    this.dateTo,
    this.currencyId,
  });

  @override
  List<Object?> get props => [message, dateFrom, dateTo, currencyId];
}

class AnalyticsEmpty extends AnalyticsState {
  final DateTime dateFrom;
  final DateTime dateTo;
  final int? currencyId;
  
  const AnalyticsEmpty({
    required this.dateFrom,
    required this.dateTo,
    this.currencyId,
  });

  @override
  List<Object?> get props => [dateFrom, dateTo, currencyId];
}
