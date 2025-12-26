import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lifeos_client/features/finance/presentation/widgets/money_text.dart';
import 'package:provider/provider.dart';

import '../providers/amount_visibility_provider.dart';

class TotalCard extends StatelessWidget {
  final String amount;
  final String currencyCode;
  final bool isLoading;

  const TotalCard({
    super.key,
    required this.amount,
    required this.currencyCode,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.foreground,
            ),
          ),
          const SizedBox(height: 8),
          if (isLoading)
            Container(
              width: 200,
              height: 32,
              decoration: BoxDecoration(
                color: colorScheme.muted,
                borderRadius: BorderRadius.circular(4),
              ),
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: MoneyText(
                    amount: amount,
                    currencyCode: currencyCode,
                    fontSize: 32,
                    currencyFontSize: 16,
                  ),
                ),
                IconButton.primary(
                  icon: HugeIcon(
                    icon: context.watch<AmountVisibilityProvider>().isVisible
                        ? HugeIcons.strokeRoundedView
                        : HugeIcons.strokeRoundedViewOff,
                  ),
                  onPressed: () {
                    context.read<AmountVisibilityProvider>().toggle();
                  },
                ),
              ],
            ),
        ],
      ),
    );
  }
}
