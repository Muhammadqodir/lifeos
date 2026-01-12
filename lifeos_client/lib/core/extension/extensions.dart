import 'package:intl/intl.dart';

extension DoubleExtensions on double {
  String toMoneyFormat() {
    return NumberFormat('#,###').format(this).replaceAll(',', ' ');
  }

  String toMoneyFormatShort() {
    final amount = this;
    final absAmount = amount.abs();
    final sign = amount < 0 ? '-' : '';

    if (absAmount >= 1000000) {
      return '$sign${(absAmount / 1000000).toStringAsFixed(1)}M';
    } else if (absAmount >= 1000) {
      return '$sign${(absAmount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(2);
  }
}
