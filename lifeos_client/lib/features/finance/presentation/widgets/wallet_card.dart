import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/ui/ui.dart';
import '../../data/models/wallet_dto.dart';
import '../providers/amount_visibility_provider.dart';
import 'money_text.dart';

/// Compact wallet summary used in the wallets strip.
class WalletCard extends StatelessWidget {
  final WalletDto wallet;
  final VoidCallback? onTap;

  const WalletCard({super.key, required this.wallet, this.onTap});

  static List<List<dynamic>> iconFor(WalletType type) => switch (type) {
    WalletType.card => HugeIcons.strokeRoundedCreditCard,
    WalletType.bankAccount => HugeIcons.strokeRoundedBank,
    WalletType.cash => HugeIcons.strokeRoundedMoney03,
    WalletType.other => HugeIcons.strokeRoundedWallet03,
  };

  @override
  Widget build(BuildContext context) {
    final visible = context.watch<AmountVisibilityProvider>().isVisible;
    return SizedBox(
      width: 200,
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(AppSpacing.md + 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                LeadingTile.icon(iconFor(wallet.type), size: 30),
                const Spacer(),
                AppBadge.neutral(label: wallet.currency.code),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              wallet.name,
              style: context.text.itemSubtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSpacing.xxs),
            MoneyText(
              amount: wallet.balance,
              currencyCode: wallet.currency.code,
              size: MoneyTextSize.large,
              isVisible: visible,
            ),
          ],
        ),
      ),
    );
  }
}
