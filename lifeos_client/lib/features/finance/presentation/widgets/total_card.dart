import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/ui/ui.dart';
import '../providers/amount_visibility_provider.dart';
import 'money_text.dart';

/// Total balance across wallets with a privacy toggle.
class TotalCard extends StatelessWidget {
  final double amount;
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
    final visibility = context.watch<AmountVisibilityProvider>();
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total balance', style: context.text.itemSubtitle),
                const SizedBox(height: AppSpacing.xs),
                MoneyText(
                  amount: amount,
                  isApproximate: true,
                  isShort: false,
                  currencyCode: currencyCode,
                  isVisible: visibility.isVisible,
                  size: MoneyTextSize.xLarge,
                ),
              ],
            ),
          ),
          HeaderAction(
            icon: visibility.isVisible
                ? HugeIcons.strokeRoundedViewOff
                : HugeIcons.strokeRoundedView,
            tooltip: visibility.isVisible ? 'Hide amounts' : 'Show amounts',
            onTap: visibility.toggle,
          ),
        ],
      ),
    );
  }
}
