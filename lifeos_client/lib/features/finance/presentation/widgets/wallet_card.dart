import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lifeos_client/features/finance/presentation/widgets/money_text.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import '../../data/models/wallet_dto.dart';

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
    final theme = ShadTheme.of(context);
    final colorScheme = theme.colorScheme;

    return ShadCard(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
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
              if (wallet.balance != null)
                MoneyText(
                  amount: wallet.balance!,
                  currencyCode: wallet.currency.code,
                  fontSize: 20,
                  currencyFontSize: 12,
                )
              else
                Container(
                  width: 100,
                  height: 20,
                  decoration: BoxDecoration(
                    color: colorScheme.muted,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
