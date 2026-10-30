import 'package:hugeicons/hugeicons.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/ui/ui.dart';
import '../../data/models/wallet_dto.dart';
import 'wallet_card.dart';

/// Horizontally scrolling wallets; the "Wallets" header carries the
/// add/manage actions.
class WalletCarousel extends StatelessWidget {
  final List<WalletDto> wallets;
  final void Function(int walletId)? onWalletTap;
  final VoidCallback onAddWallet;
  final VoidCallback onManageWallet;

  const WalletCarousel({
    super.key,
    required this.wallets,
    this.onWalletTap,
    required this.onAddWallet,
    required this.onManageWallet,
  });

  @override
  Widget build(BuildContext context) {
    if (wallets.isEmpty) {
      return AppCard(
        child: EmptyState(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          icon: const HugeIcon(icon: HugeIcons.strokeRoundedWallet03),
          title: 'Add your first wallet',
          description: 'Wallets hold your balances: cards, cash, accounts.',
          action: PrimaryButton(
            onPressed: onAddWallet,
            child: const Text('Add wallet'),
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        physics: const BouncingScrollPhysics(),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final wallet in wallets)
                WalletCard(
                  wallet: wallet,
                  onTap: onWalletTap == null
                      ? null
                      : () => onWalletTap!(wallet.id),
                ),
              _AddWalletCard(onTap: onAddWallet),
            ],
          ).gap(AppSpacing.md),
        ),
      ),
    );
  }
}

class _AddWalletCard extends StatelessWidget {
  const _AddWalletCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppPressable(
      onTap: onTap,
      borderRadius: context.theme.cardRadius,
      semanticLabel: 'Add wallet',
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          borderRadius: context.theme.cardRadius,
          border: Border.all(color: colors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedAdd01,
              size: AppIconSize.md,
              color: colors.mutedForeground,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text('Add wallet', style: context.text.caption),
          ],
        ),
      ),
    );
  }
}
