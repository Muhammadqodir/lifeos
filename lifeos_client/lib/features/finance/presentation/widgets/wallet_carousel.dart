import 'package:hugeicons/hugeicons.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../../data/models/wallet_dto.dart';
import 'wallet_card.dart';

class WalletCarousel extends StatelessWidget {
  final List<WalletDto> wallets;
  final Function(int walletId)? onWalletTap;
  final VoidCallback? onAddWallet;

  const WalletCarousel({
    super.key,
    required this.wallets,
    this.onWalletTap,
    this.onAddWallet,
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
          // Add card button at the end
          if (index == wallets.length) {
            return _buildAddCardButton(context);
          }
          
          final wallet = wallets[index];
          return WalletCard(
            wallet: wallet,
            onTap: onWalletTap != null
                ? () => onWalletTap!(wallet.id)
                : null,
          );
        },
      ),
    );
  }

  Widget _buildAddCardButton(BuildContext context) {
    return GestureDetector(
      onTap: onAddWallet,
      child: Card(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HugeIcon(icon: HugeIcons.strokeRoundedAdd01, size: 32,),
            const SizedBox(height: 8),
            Text(
              'Add Wallet',
              style: Theme.of(context).typography.small
            ),
          ],
        ),
      ),
    );
  }
}
