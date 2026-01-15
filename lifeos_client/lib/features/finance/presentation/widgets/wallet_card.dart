import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lifeos_client/features/finance/presentation/widgets/money_text.dart';

import 'package:provider/provider.dart';
import '../../data/models/wallet_dto.dart';
import '../providers/amount_visibility_provider.dart';

class WalletCard extends StatelessWidget {
  final WalletDto wallet;
  final VoidCallback? onTap;

  const WalletCard({super.key, required this.wallet, this.onTap});

  dynamic _getWalletIcon(WalletType type) {
    switch (type) {
      case WalletType.card:
        return HugeIcons.strokeRoundedCreditCard;
      case WalletType.bankAccount:
        return HugeIcons.strokeRoundedBank;
      case WalletType.cash:
        return HugeIcons.strokeRoundedMoneyBag01;
      case WalletType.other:
        return HugeIcons.strokeRoundedWallet03;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      child: GestureDetector(
        onTap: onTap,
        child: SizedBox(
          width: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  HugeIcon(
                    icon: _getWalletIcon(wallet.type),
                    size: 24,
                    color: colorScheme.primary,
                  ),
                  const Spacer(),
                  Text(
                    wallet.currency.code,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.mutedForeground,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                wallet.name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.mutedForeground,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              MoneyText(
                amount: wallet.balance,
                currencyCode: wallet.currency.code,
                size: MoneyTextSize.large,
                isVisible: context.watch<AmountVisibilityProvider>().isVisible,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
