import 'package:equatable/equatable.dart';
import 'category_summary_dto.dart';

/// Analytics summary data for a given period
class AnalyticsSummaryDto extends Equatable {
  final double totalIncome;
  final double totalExpense;
  final double netAmount;
  final String currencyCode;
  final String currencyIcon;
  final DateTime periodStart;
  final DateTime periodEnd;
  final List<CategorySummaryDto> incomeByCategory;
  final List<CategorySummaryDto> expenseByCategory;

  const AnalyticsSummaryDto({
    required this.totalIncome,
    required this.totalExpense,
    required this.netAmount,
    required this.currencyCode,
    required this.currencyIcon,
    required this.periodStart,
    required this.periodEnd,
    required this.incomeByCategory,
    required this.expenseByCategory,
  });

  factory AnalyticsSummaryDto.fromJson(Map<String, dynamic> json) {
    final incomeList = (json['income_by_category'] as List?)
            ?.map((item) => CategorySummaryDto.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];
    final expenseList = (json['expense_by_category'] as List?)
            ?.map((item) => CategorySummaryDto.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];

    return AnalyticsSummaryDto(
      totalIncome: (json['total_income'] as num?)?.toDouble() ?? 0.0,
      totalExpense: (json['total_expense'] as num?)?.toDouble() ?? 0.0,
      netAmount: (json['net_amount'] as num?)?.toDouble() ?? 0.0,
      // Backend currently returns currency_icon; currency_code may be absent
      currencyCode: json['currency_code'] as String? ?? 'USD',
      currencyIcon: json['currency_icon'] as String? ?? '\$',
      // Backend returns date_from/date_to; fall back to period_start/period_end if present
      periodStart: _parseDate(json['date_from'] ?? json['period_start']),
      periodEnd: _parseDate(json['date_to'] ?? json['period_end']),
      incomeByCategory: incomeList,
      expenseByCategory: expenseList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_income': totalIncome,
      'total_expense': totalExpense,
      'net_amount': netAmount,
      'currency_code': currencyCode,
      'currency_icon': currencyIcon,
      'period_start': periodStart.toIso8601String(),
      'period_end': periodEnd.toIso8601String(),
      'income_by_category': incomeByCategory.map((cat) => cat.toJson()).toList(),
      'expense_by_category': expenseByCategory.map((cat) => cat.toJson()).toList(),
    };
  }

  /// Safely parse ISO date strings, defaulting to now when null/empty.
  static DateTime _parseDate(Object? value) {
    if (value == null) return DateTime.now();
    final str = value.toString();
    if (str.isEmpty) return DateTime.now();
    return DateTime.parse(str);
  }

  @override
  List<Object?> get props => [
        totalIncome,
        totalExpense,
        netAmount,
        currencyCode,
        currencyIcon,
        periodStart,
        periodEnd,
        incomeByCategory,
        expenseByCategory,
      ];
}
