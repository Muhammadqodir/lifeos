import 'package:shadcn_flutter/shadcn_flutter.dart';

enum MoneyTextSize { xSmall, small, large, xLarge }

class MoneyText extends StatelessWidget {
  const MoneyText({
    super.key,
    required this.amount,
    required this.currencyCode,
    this.color,
    this.size = MoneyTextSize.large,
    this.isVisible = true,
    this.alignment = MainAxisAlignment.start,
  });

  final String amount;
  final String currencyCode;
  final Color? color;
  final MoneyTextSize size;
  final MainAxisAlignment alignment;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final (amountStyle, currencyStyle) = switch (size) {
      MoneyTextSize.xSmall => (
        theme.typography.xSmall.copyWith(
          fontWeight: FontWeight.w600,
          color: color ?? colorScheme.foreground,
        ),
        theme.typography.xSmall.copyWith(
          fontWeight: FontWeight.w500,
          color: color ?? colorScheme.mutedForeground,
        ),
      ),
      MoneyTextSize.small => (
        theme.typography.xSmall.copyWith(
          fontWeight: FontWeight.w600,
          color: color ?? colorScheme.foreground,
        ),
        theme.typography.xSmall.copyWith(
          fontWeight: FontWeight.w500,
          color: color ?? colorScheme.mutedForeground,
        ),
      ),
      MoneyTextSize.large => (
        theme.typography.large.copyWith(
          fontWeight: FontWeight.w700,
          color: color ?? colorScheme.foreground,
        ),
        theme.typography.xSmall.copyWith(
          fontWeight: FontWeight.w600,
          color: color ?? colorScheme.mutedForeground,
        ),
      ),
      MoneyTextSize.xLarge => (
        theme.typography.h3.copyWith(
          fontWeight: FontWeight.w700,
          color: color ?? colorScheme.foreground,
        ),
        theme.typography.small.copyWith(
          fontWeight: FontWeight.w600,
          color: color ?? colorScheme.mutedForeground,
        ),
      ),
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      mainAxisAlignment: alignment,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(isVisible ? _formatAmount(amount) : '••••', style: amountStyle),
        const SizedBox(width: 4),
        Text(currencyCode, style: currencyStyle),
      ],
    );
  }

  String _formatAmount(String balance) {
    final amount = double.tryParse(balance) ?? 0.0;
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
