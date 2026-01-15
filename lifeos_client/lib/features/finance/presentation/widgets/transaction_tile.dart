import 'package:lifeos_client/core/theme/app_colors.dart';
import 'package:lifeos_client/core/widgets/category_icon.dart';
import 'package:lifeos_client/core/widgets/tappable.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:lifeos_client/features/finance/presentation/widgets/money_text.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../data/models/transaction_dto.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Get first entry for amount display
    final TransactionEntryDto? entry = transaction.entries.isNotEmpty
        ? transaction.entries.first
        : null;

    final double amount = entry?.amount ?? 0;
    final currencyCode = entry?.currency.code ?? '';
    final isPositive = amount >= 0;

    return Slidable(
      key: ValueKey(transaction.id),
      endActionPane: ActionPane(
        extentRatio: 0.2,
        motion: const ScrollMotion(),
        children: [
          CustomSlidableAction(
            onPressed: (context) async {
              if (onDelete != null) {
                onDelete!();
              }
            },
            backgroundColor: AppColors.redColor,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                HugeIcon(
                  icon: HugeIcons.strokeRoundedDelete02,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  'Delete',
                  style: theme.typography.xSmall.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
      child: Tappable(
        onTap: () {
          if (onTap != null) {
            onTap!();
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Category icon
              CategoryIcon(
                icon: transaction.category?.icon ?? '⭕️',
                color: transaction.category?.color ?? '#000000',
              ),
              const SizedBox(width: 12),
              // Transaction details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.category?.title ??
                          transaction.description ??
                          _getTypeLabel(transaction.type),
                      style: theme.typography.small.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.foreground,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatDate(transaction.occurredAt),
                      style: theme.typography.xSmall.copyWith(
                        color: colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  MoneyText(
                    amount: amount,
                    currencyCode: currencyCode,
                    size: MoneyTextSize.small,
                    color: isPositive
                        ? Colors.green.shade600
                        : Colors.red.shade600,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return 'Today, ${_formatTime(date)}';
    } else if (transactionDate == yesterday) {
      return 'Yesterday, ${_formatTime(date)}';
    } else if (now.difference(date).inDays < 7) {
      return '${_getWeekday(date.weekday)}, ${_formatTime(date)}';
    } else {
      return '${_getMonth(date.month)} ${date.day}, ${_formatTime(date)}';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _getWeekday(int weekday) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return weekdays[weekday - 1];
  }

  String _getMonth(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  String _getTypeIcon(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return '💰';
      case TransactionType.expense:
        return '💸';
      case TransactionType.transfer:
        return '↔️';
      case TransactionType.exchange:
        return '💱';
    }
  }

  String _getTypeLabel(TransactionType type) {
    switch (type) {
      case TransactionType.income:
        return 'Income';
      case TransactionType.expense:
        return 'Expense';
      case TransactionType.transfer:
        return 'Transfer';
      case TransactionType.exchange:
        return 'Exchange';
    }
  }

  Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
