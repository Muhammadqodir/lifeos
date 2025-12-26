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
                isSelected: selectedType == TransactionType.income,
                onTap: () => onChanged(TransactionType.income),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _TypeButton(
                label: 'Expense',
                isSelected: selectedType == TransactionType.expense,
                onTap: () => onChanged(TransactionType.expense),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _TypeButton(
                label: 'Transfer',
                isSelected: selectedType == TransactionType.transfer,
                onTap: () => onChanged(TransactionType.transfer),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _TypeButton(
                label: 'Exchange',
                isSelected: selectedType == TransactionType.exchange,
                onTap: () => onChanged(TransactionType.exchange),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isSelected
                  ? colorScheme.primaryForeground
                  : colorScheme.foreground,
            ),
          ),
        ),
      ),
    );
  }
}
