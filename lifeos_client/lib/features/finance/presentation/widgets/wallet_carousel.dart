import 'package:shadcn_flutter/shadcn_flutter.dart';
import '../../data/models/wallet_dto.dart';
import 'wallet_card.dart';

class WalletCarousel extends StatelessWidget {
  final List<WalletDto> wallets;
  final Function(int walletId)? onWalletTap;

  const WalletCarousel({
    super.key,
    required this.wallets,
    this.onWalletTap,
  });

  @override
  Widget build(BuildContext context) {
    if (wallets.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 150,
      child: ListView.separated(
        physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: wallets.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
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
}
