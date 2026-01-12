import 'package:lifeos_client/core/extension/extensions.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

enum MoneyTextSize { xSmall, small, large, xLarge }

class MoneyText extends StatelessWidget {
  const MoneyText({
    super.key,
    required this.amount,
    required this.currencyCode,
    this.color,
    this.size = MoneyTextSize.large,
    this.isShort = true,
    this.isVisible = true,
    this.isApproximate = false,
    this.alignment = MainAxisAlignment.start,
  });

  final double amount;
  final String currencyCode;
  final Color? color;
  final MoneyTextSize size;
  final MainAxisAlignment alignment;
  final bool isVisible;
  final bool isShort;
  final bool isApproximate;

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
        Text(
          isVisible
              ? ((isApproximate ? '~ ' : '') +
                    (isShort
                        ? amount.toMoneyFormatShort()
                        : amount.toMoneyFormat()))
              : '••••',
          style: amountStyle,
        ),
        const SizedBox(width: 4),
        Text(currencyCode, style: currencyStyle),
      ],
    );
  }
}
