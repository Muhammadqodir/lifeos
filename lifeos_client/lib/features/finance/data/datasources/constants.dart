import 'package:hugeicons/hugeicons.dart';
import 'package:lifeos_client/features/finance/data/models/wallet_dto.dart';

class FinanceConstants {
  static String getWalletTypeName(WalletType type) {
    switch (type) {
      case WalletType.card:
        return 'Card';
      case WalletType.bankAccount:
        return 'Bank Account';
      case WalletType.cash:
        return 'Cash';
      case WalletType.other:
        return 'Other';
    }
  }

  static dynamic getWalletTypeIcon(WalletType type) {
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
}
