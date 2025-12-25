import 'package:equatable/equatable.dart';

/// Summary of finances in user's base currency
/// TODO: Update based on actual API endpoint when available
class FinanceSummaryDto extends Equatable {
  final String totalBalance;
  final String currencyCode;

  const FinanceSummaryDto({
    required this.totalBalance,
    required this.currencyCode,
  });

  factory FinanceSummaryDto.fromJson(Map<String, dynamic> json) {
    return FinanceSummaryDto(
      totalBalance: json['total_balance'] as String,
      currencyCode: json['currency_code'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_balance': totalBalance,
      'currency_code': currencyCode,
    };
  }

  @override
  List<Object?> get props => [totalBalance, currencyCode];
}
