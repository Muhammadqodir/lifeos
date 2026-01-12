import 'package:hugeicons/hugeicons.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../data/models/transaction_dto.dart';

class TransactionTypeSelector extends StatelessWidget {
  final TransactionType selectedType;
  final ValueChanged<TransactionType> onChanged;

  const TransactionTypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colorScheme.foreground,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _TypeButton(
                label: 'Income',
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowDownDouble,
                  size: 16,
                ),
                isSelected: selectedType == TransactionType.income,
                onTap: () => onChanged(TransactionType.income),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _TypeButton(
                label: 'Expense',
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowUpDouble,
                  size: 16,
                ),
                isSelected: selectedType == TransactionType.expense,
                onTap: () => onChanged(TransactionType.expense),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _TypeButton(
          label: 'Transfer',
          icon: HugeIcon(icon: HugeIcons.strokeRoundedCardExchange02, size: 16),
          isSelected: selectedType == TransactionType.transfer,
          onTap: () => onChanged(TransactionType.transfer),
        ),
      ],
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    this.icon = const SizedBox.shrink(),
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : colorScheme.muted,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.border,
            width: 1,
          ),
        ),
        child: Center(
          child: IconTheme(
            data: IconThemeData(
              color: isSelected
                  ? Theme.of(context).colorScheme.background
                  : Theme.of(context).colorScheme.primary,
            ),
            child: DefaultTextStyle(
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.background
                    : Theme.of(context).colorScheme.primary,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon is! SizedBox) ...[icon, const SizedBox(width: 6)],
                  Text(label, style: Theme.of(context).typography.small),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
