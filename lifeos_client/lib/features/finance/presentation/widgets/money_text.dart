import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../providers/amount_visibility_provider.dart';

class MoneyText extends StatelessWidget {
  const MoneyText({super.key, required this.amount, required this.currencyCode, this.fontSize = 32, this.currencyFontSize = 16, this.color});

  final String amount;
  final String currencyCode;
  final double fontSize;
  final double currencyFontSize;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final colorScheme = theme.colorScheme;
    final isVisible = context.watch<AmountVisibilityProvider>().isVisible;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          isVisible ? _formatAmount(amount) : '••••',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            color: color ?? colorScheme.foreground,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          currencyCode,
          style: TextStyle(
            fontSize: currencyFontSize,
            fontWeight: FontWeight.w600,
            color: color ?? colorScheme.mutedForeground,
          ),
        ),
      ],
    );
  }


  String _formatAmount(String balance) {
    final amount = double.tryParse(balance) ?? 0.0;
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(2);
  }
}
