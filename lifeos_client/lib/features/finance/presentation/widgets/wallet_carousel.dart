import 'package:hugeicons/hugeicons.dart';
import 'package:lifeos_client/core/widgets/empty_state.dart';
import 'package:lifeos_client/core/widgets/tappable.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../../data/models/wallet_dto.dart';
import 'wallet_card.dart';

class WalletCarousel extends StatelessWidget {
  final List<WalletDto> wallets;
  final Function(int walletId)? onWalletTap;
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
    return SizedBox(
      height: 150,
      child: ListView.separated(
        physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: wallets.length + 1, // +1 for the add card button
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          // Add card button at the start
          if (index == 0) {
            if (wallets.length <= 1) {
              return Row(
                children: [
                  _buildActions(context),
                  SizedBox(width: 12),
                  SizedBox(
                    width: 250,
                    child: EmptyState(
                      padding: EdgeInsets.all(0),
                      title: 'No Wallets Yet',
                      description:
                          'Start by adding your first wallet and transaction',
                      icon: HugeIcon(
                        icon: HugeIcons.strokeRoundedWallet03,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              );
            }
            return _buildActions(context);
          }

          final wallet = wallets[index - 1];
          return WalletCard(
            wallet: wallet,
            onTap: onWalletTap != null ? () => onWalletTap!(wallet.id) : null,
          );
        },
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SizedBox(
            width: 90,
            child: Button.secondary(
              onPressed: onAddWallet,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedAdd01,
                    size: 18,
                    strokeWidth: 2,
                  ),
                  const SizedBox(height: 4),
                  Text('Add', style: Theme.of(context).typography.xSmall),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: SizedBox(
            width: 90,
            child: Button.secondary(
              onPressed: onManageWallet,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  HugeIcon(
                    icon: HugeIcons.strokeRoundedListView,
                    size: 18,
                    strokeWidth: 2,
                  ),
                  const SizedBox(height: 4),
                  Text('Manage', style: Theme.of(context).typography.xSmall),
                ],
              ),
            ),
          ),
        ),
      ],
    ).gap(12);
  }
}
