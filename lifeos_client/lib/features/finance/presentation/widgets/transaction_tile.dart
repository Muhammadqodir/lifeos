import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../../../core/ui/ui.dart';
import '../../../../core/utils/color_utils.dart';
import '../../../../core/utils/date_labels.dart';
import '../../data/models/transaction_dto.dart';
import '../providers/amount_visibility_provider.dart';
import 'money_text.dart';

/// A transaction row: category, time and wallet, signed amount.
/// Transfers and exchanges show both legs.
class TransactionTile extends StatelessWidget {
  final TransactionDto transaction;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
    this.onDelete,
  });

  bool get _isMovement =>
      transaction.type == TransactionType.transfer ||
      transaction.type == TransactionType.exchange;

  @override
  Widget build(BuildContext context) {
    final semantic = context.semantic;
    final entries = transaction.entries;
    final entry = entries.isNotEmpty ? entries.first : null;
    final amount = entry?.amount ?? 0;
    final visible =
        context.watch<AmountVisibilityProvider?>()?.isVisible ?? true;

    final Widget leading;
    if (_isMovement) {
      leading = LeadingTile.icon(
        transaction.type == TransactionType.transfer
            ? HugeIcons.strokeRoundedArrowDataTransferHorizontal
            : HugeIcons.strokeRoundedMoneyExchange02,
        color: semantic.info,
      );
    } else if (transaction.category != null) {
      leading = LeadingTile.emoji(
        transaction.category!.icon,
        color: parseHexColor(transaction.category!.color),
      );
    } else {
      leading = LeadingTile.icon(
        transaction.type == TransactionType.income
            ? HugeIcons.strokeRoundedArrowDownLeft01
            : HugeIcons.strokeRoundedArrowUpRight01,
        color: semantic.amount(amount),
      );
    }

    final walletNames = entries.map((e) => e.wallet.name).toSet().join(' → ');
    final subtitle = [
      DateLabels.time(transaction.occurredAt),
      if (walletNames.isNotEmpty) walletNames,
      if (transaction.category != null &&
          (transaction.description?.isNotEmpty ?? false))
        transaction.description!,
    ].join(' · ');

    return AppListTile(
      leading: leading,
      title:
          transaction.category?.title ??
          (transaction.description?.isNotEmpty ?? false
              ? transaction.description!
              : _typeLabel(transaction.type)),
      subtitle: subtitle,
      onTap: onTap,
      showActionsButton: false,
      actions: [
        if (onDelete != null)
          AppAction(
            label: 'Delete transaction',
            icon: HugeIcons.strokeRoundedDelete02,
            destructive: true,
            onSelected: onDelete!,
          ),
      ],
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final e in _isMovement ? entries.take(2) : entries.take(1))
            MoneyText(
              amount: e.amount,
              currencyCode: e.currency.code,
              size: MoneyTextSize.small,
              isVisible: visible,
              color: semantic.amount(e.amount),
            ),
        ],
      ),
    );
  }

  String _typeLabel(TransactionType type) => switch (type) {
    TransactionType.income => 'Income',
    TransactionType.expense => 'Expense',
    TransactionType.transfer => 'Transfer',
    TransactionType.exchange => 'Exchange',
  };
}
